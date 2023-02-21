clear all;

rot_axis_offset = 0.05;

new_configuration = true
if new_configuration
    b_m = 0.553 + 0.096
    z_m = 1.008 + 0.128
    h = 1.335;
    phi = atan(z_m/b_m)
    phi_deg = phi*180/pi
    
    sqrt(z_m^2 + b_m^2)
end

vel = 10; %% 10 deg / s
fps = 25; %% 25 frames per second

deg_per_frame = vel / fps;

if new_configuration
    %fx = 4803.75;
    %fy = 4794.07;
    fx = 4804;
    fy = 4794;
    cx = 903.487;
    cy = 409.888;
end

K = [fx 0 cx;
     0 fy cy;
     0 0 1]

% ku and kv are the inverse of pixel size along x- and y-axis
% au = ku * f  
% av = kv * f
% f = fx / ku;
% f = fy / kv;
% sensor_w = 22.3 mm
% sensor_h = 14.9 mm

sensor_w = 22.3/1000;
sensor_h = 14.9/1000;

sensor_res_x = 1920;
sensor_res_y = 1080;

pixel_h = 3.72e-6
pixel_w = 3.71e-6

ku = pixel_h^-1
kv = pixel_w^-1

use_f_manual = false;
f_manual = 0.055; %% 55 mm

f_x_mm = (fx / ku)*1000 %% mm
f_y_mm = (fy / kv)*1000 %% mm

f_x = fx/ku
f_y = fy/kv

u = 980-914 % example distance from center in pixels

l = u*pixel_w; % distance converted to meters

if use_f_manual
    theta = atan(l/f_manual)
else
    theta = atan(l/f_x)
end
theta_deg = theta*180/pi

z_prime = b_m*tan(phi-theta)

z_depth_cm = (z_m-z_prime)*100
disp(z_depth_cm)

save 3Dscanner_math.mat b_m z_m h phi K ku kv pixel_w pixel_h rot_axis_offset f_manual f_x f_y vel fps deg_per_frame fx fy

path = 'C:\Users\augus\Pictures\digiCamControl\Session1\spincross1laser.mov';
v = VideoReader(path);

frame = read(v,823);
imshow(frame);
frame = read(v,1);
imshow(frame);

img_w = 1920;
img_h = 1080;