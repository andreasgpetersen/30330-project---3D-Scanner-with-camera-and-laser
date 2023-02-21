close all;
clear all;
load 3Dscanner_math.mat

frame_by_frame = false;
show_plot = false;

cross = true % set to true to load video of the cross

if cross
    start_frame = 83;
    y_upper_bound = 885;
    y_lower_bound = 300;
    path = 'C:\Users\augus\Pictures\digiCamControl\Session1\spincross2laser.mov';
    v = VideoReader(path);
else
    start_frame = 177;
    y_upper_bound = 890;
    y_lower_bound = 470;
    path = 'C:\Users\augus\Pictures\digiCamControl\Session1\laserwoodobject.mov';
    v = VideoReader(path);
    maxx = 1;
    minn = 10e10;
    while(hasFrame(v))

        [bins, ~] = histcounts(rgb2gray(readFrame(v)), 255);
        val  = bins(255);

        if val > maxx
            maxx = val;
        end
        if val < minn 
            minn = val;
        end
    end
    v = VideoReader(path);
end

image_w = v.Width;
image_h = v.Height;


dot_N = 28;
epi_lines_x = zeros(dot_N, 1);
epi_lines_y = zeros(dot_N, 1);
epi_radii = zeros(dot_N, 1);
epi_metric = zeros(dot_N, 1);
frame_interval = 1;

end_frame = 1005-start_frame;

rot = deg_per_frame*[0:frame_interval:360/deg_per_frame]*pi/180;

frame_N = length(rot);

z_Matrix = zeros(60, frame_N); 
y_Matrix = zeros(60, frame_N); 

count = start_frame;

gauss_threshold = 80;

se = strel('diamond',3);

loop_count = 1;
while(loop_count <= frame_N && hasFrame(v))
    
    %if loop_count == 247
    if loop_count == 1000 %54 
        frame_by_frame = true;
        show_plot = true;
    end
    
    %se = strel('diamond',3);
    % read frame and get lvl of saturation due to glare
    cur = read(v,count);
    
    if ~cross
        [N_cur, ~] = histcounts(rgb2gray(cur),255);
        val = N_cur(255);
        %lvl = val/maxx;
        lvl = (val-minn)/(maxx-minn);
        if lvl>1
            lvl = 1;
        end
        lvl = lvl*100; % lvl is in percentage

        % Filter image in HSV with saturation value adjusted to fit
        [t5,masked] = colorMask_both_HSV(cur, lvl);
        t5 = imclose(t5,se);
    
    else
        % For the cross
        t5 = cur(:,:,1)-imgaussfilt(cur(:,:,1),15) > gauss_threshold;
    end
    
    centers = zeros(60, 2);
    radii = zeros(60, 1);
    radii_x = zeros(60, 1);
    radii_y = zeros(60, 1);
    metric = zeros(60, 1);
    
    B = bwboundaries(t5,'noholes');
    if show_plot
        figure(99);
        imshow(cur);
        hold on
        title(sprintf("Frame %d", loop_count));
    end
    for k = 1:length(B)
       %plot boundary
       boundary = B{k};  
       if length(boundary) < 5
           continue;
       end
       
       if (all(boundary(:,1)<y_upper_bound) && all(boundary(:,1)>y_lower_bound)) 
          if show_plot
              plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1)
          end
          centers(k, 2) = round(median(boundary(:,1))); % y center
          centers(k, 1) = round(median(boundary(:,2))); % x center
          radii_x = 0.5*( max(boundary(:,2)) - min(boundary(:,2)) );
          radii_y = 0.5*( max(boundary(:,1)) - min(boundary(:,1)) );
          radii(k, 1) = radii_y;
          metric(k, 1) = radii(k, 1);
       end     
    end 
    
    
    P = zeros(60, 3);
    
    if count == start_frame
        M = [centers, radii, metric];
        u0 = 980; % set biggest center u as u0
        c = mean(nonzeros(centers(:,1)));
        v0 = y_upper_bound; % set bottom of object as 0 height
        M_sort = sortrows(M,2);
        epi_lines_x = M_sort(:, 1);
        epi_lines_y = M_sort(:, 2);
        epi_radii = M_sort(:, 3);
        epi_metric = M_sort(:, 4);
        a = -0.0897;
    else
        for j = 1:length(epi_lines_y)
            for i = 1:length(centers)
                dy = abs(a*(centers(i, 1)-c)+epi_lines_y(j) - centers(i, 2));
                    if dy < epi_radii(j)+1
                        if P(j, 3) < metric(i)
                            P(j, 1) = centers(i, 1);
                            P(j, 2) = centers(i, 2);
                            P(j, 3) = metric(i);
                        end
                    end
            end    
        end
    end
    
    px = P(:, 1);
    py = P(:, 2);
    
    pz_w = triangulate_depth(u0, px, pixel_w, f_x, f_manual, phi, z_m, b_m, 0, false);
    z_prime = (u0, px, pixel_w, f_x, f_manual, phi, z_m, b_m, 0, false);
    
    y_Matrix(:, loop_count) = -(py - v0).*sqrt(z_prime.^2+b_m.^2)/fy;
    
    z_Matrix(:, loop_count) = pz_w;
    
    % Plot
    if show_plot

        %viscircles(centers, radii, 'EdgeColor','b');
        %plot(centers, 'bo')
        hold on;
        plot(P(:, 1), P(:, 2), 'gx');
        xline(u0,'--c');
        yline(v0,'--g');
        yline(y_lower_bound,'--g');
        xline(image_w/2, 'r')
        
        for i=33:1:length(epi_lines_y)
            plot([0:1:1919],[-c:1:1919-c]*a+epi_lines_y(i), '--w', 'LineWidth', 0.5)
        end
        
        disp('P = ')
        disp(P)
        
        fprintf('Z depth in cm is: [');
        fprintf('%g ', pz_w*100);
        fprintf(']\n');
    
    end
    
    % Wait for user input to continue
    if frame_by_frame
        reply = input("Press any key to continue or Q to quit: ", 's');
        if reply == 'Q'
            break;
        end
    end
     
    count = count + frame_interval;
    loop_count = loop_count + 1;
    if mod(loop_count, 10) == 0
        fprintf("Progress %0.2f%s \n", round(loop_count/frame_N * 100,3), '%');
    end
end

%% Plots
set(groot,'defaultfigureposition',[400 300 900 700])
set(0,'DefaultTextInterpreter','latex');
set(0,'DefaultAxesFontSize',14);
set(0,'DefaultLineLineWidth',2);

x_Matrix_rot = z_Matrix.*cos(rot);
z_Matrix_rot = z_Matrix.*sin(rot);

X_max = 0.25;
Y_max = 0.25;


fig = figure;
line0 = 1;
for i = line0:1:frame_N
    %X = x_Matrix_rot(1:dot_N, i);
    %Y = z_Matrix_rot(1:dot_N, i);
    X = x_Matrix_rot(1:end, i);
    Y = z_Matrix_rot(1:end, i);
    Z = y_Matrix(1:end, i);
    X((X > X_max) | (X < -X_max)) = nan;
    Y((Y > Y_max) | (Y < -Y_max)) = nan;
    plot3(X, Y, Z, 'r.');
    hold on;
    
end
grid on;
xlim([-X_max X_max]);
ylim([-Y_max Y_max]);
xlabel('Z');
ylabel('X');
zlabel('Y');
axis equal;

for i = 1:dot_N
    X = x_Matrix_rot(i, 1:end);
    Y = z_Matrix_rot(i, 1:end);
    Z = y_Matrix(i, 1:end);
    X((X > X_max) | (X < -X_max)) = nan;
    Y((Y > Y_max) | (Y < -Y_max)) = nan;
    plot3(X, Y, Z, 'r.');
    
    hold on;
end
grid on;
xlim([-X_max X_max]);
ylim([-Y_max Y_max]);
xlabel('Z [m]');
ylabel('X [m]');
zlabel('Y [m]');
axis equal;
title("Point cloud reconstruction")

set(fig,'Units','Inches');
pos = get(fig,'Position');
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(fig,'crossPC1','-dpdf','-r0')

X = reshape(x_Matrix_rot,[],1);
Y = reshape(z_Matrix_rot,[],1);
Z = reshape(y_Matrix,[],1);
X((X > X_max) | (X < -X_max)) = nan;
Y((Y > Y_max) | (Y < -Y_max)) = nan;

PC_matrix = [X(:), Y(:), Z(:)];
PC_matrix(any(isnan(PC_matrix), 2), :) = [];

%% Export point cloud as .xyz file
fID = fopen('3DPointCloud.xyz' , 'w');
fprintf(fID,'%d\n',length(PC_matrix)); 
fprintf(fID,'\n'); 
for i=1:length(PC_matrix)-1 
    fprintf(fID,'N     %16.10f     %16.10f     %16.10f\n' ,  PC_matrix(i,:));
end
fprintf(fID,'N     %16.10f     %16.10f     %16.10f' ,  PC_matrix(end,:));
fclose(fID);

\end{minted}


\section{Other functions}

\begin{minted}[breaklines,linenos,xleftmargin=0pt]{matlab}
function z_depth = triangulate_depth(u0, px, pixel_w, f_x, f_manual, phi, z_m, b_m, rot_axis_offset, use_f_manual)
    u = px - u0; % distance from center in pixels

    l = u*pixel_w; % distance converted to meters
    
    if use_f_manual
        theta = atan(l/f_manual);
    else
        theta = atan(l/f_x);
    end
    
    z_prime = b_m.*tan(phi-theta);
    
    z_depth = (z_m-z_prime) + rot_axis_offset;

end

function z_prime = triangulate_z_prime(u0, px, pixel_w, f_x, f_manual, phi, ~, b_m, ~, use_f_manual)
    u = px - u0; % distance from center in pixels

    l = u*pixel_w; % distance converted to meters
    
    if use_f_manual
        theta = atan(l/f_manual);
    else
        theta = atan(l/f_x);
    end
    
    z_prime = b_m.*tan(phi-theta);

end