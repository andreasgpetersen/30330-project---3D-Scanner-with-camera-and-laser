#define _CRT_SECURE_NO_WARNINGS
#include <opencv2/opencv.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <iostream>

using namespace cv;
using namespace std;

// Defining the dimensions of checkerboard
int CHECKERBOARD[2]{ 5,8 };
int square_size = 3; // 3 x 3cm

int main()
{
	// Creating vector to store vectors of 3D points for each checkerboard image
	std::vector<std::vector<cv::Point3f> > objpoints;

	// Creating vector to store vectors of 2D points for each checkerboard image
	std::vector<std::vector<cv::Point2f> > imgpoints;

	// Defining the world coordinates for 3D points
	std::vector<cv::Point3f> objp;
	for (int i{ 0 }; i < CHECKERBOARD[1]; i++)
	{
		for (int j{ 0 }; j < CHECKERBOARD[0]; j++)
			objp.push_back(cv::Point3f(j, i, 0));
	}


	// Extracting path of individual image stored in a given directory
	std::vector<cv::String> images;
	// Path of the folder containing checkerboard images

	std::string path = "Z:/24-11-2020/calibration/best/*.png";

	cv::glob(path, images);

	cv::Mat frame, gray;
	// vector to store the pixel coordinates of detected checker board corners 
	std::vector<cv::Point2f> corner_pts;
	bool success;
	printf("\nNo. of images: %d\n", images.size());
	
	// Specifying size to resize image to if needed 
	cv::Size dim;
	dim.height = 1080;
	dim.width = 1920;


	// Looping over all the images in the directory
	for (int i{ 0 }; i <images.size() ; i++) 
	{
		cout << i << endl;
		// Read image in
		frame = cv::imread(images[i]);
		printf("Have read image in\n");

		// Resize to desired size
		cv::resize(frame, frame, dim, cv::INTER_AREA);
		printf("Converted to desired size\n");

		cv::cvtColor(frame, gray, cv::COLOR_RGB2GRAY);
		printf("Converted color \n");

		// Finding checker board corners
		// If desired number of corners are found in the image then success = true  
		success = cv::findChessboardCornersSB(gray, cv::Size(CHECKERBOARD[0], CHECKERBOARD[1]), corner_pts);

		// If desired number of corner are detected,
		// we refine the pixel coordinates and display
		// them on the images of checker board
		if (success)
		{

			printf("\nImage #%i", i);
			printf("Found corners\n");
			cv::TermCriteria criteria(cv::TermCriteria::EPS + cv::TermCriteria::COUNT, 30, 0.1);


			// refining pixel coordinates for given 2d points.
			cv::cornerSubPix(gray, corner_pts, cv::Size(11, 11), cv::Size(-1, -1), criteria);
			printf("Have refined pixel coordinates\n");
			// Displaying the detected corner points on the checker board. Only use if image is displayed
			//cv::imshow("Image", frame);
			//cv::drawChessboardCorners(gray, cv::Size(CHECKERBOARD[0], CHECKERBOARD[1]), corner_pts, success);

			// Add object and image points to relevant arrays
			objpoints.push_back(objp);
			imgpoints.push_back(corner_pts);
		}

		else
		{
			printf("\nCould not detect corners for image %d\n", i);
		}

		// Only use if image is displayed
		//cv::waitKey(0);
	}

	cv::destroyAllWindows();

	cv::Mat cameraMatrix, distCoeffs, R, T;
	cameraMatrix = cv::Mat::eye(3, 3, CV_64F);

	
	// Performing camera calibration by
	// passing the value of known 3D points (objpoints)
	// and corresponding pixel coordinates of the
	// detected corners (imgpoints)
	
	double rms = cv::calibrateCamera(objpoints, imgpoints, dim, cameraMatrix, distCoeffs, R, T);

	// Print results to terminal if needed
	//printf("RMS:\n");
	//std::cout << "cameraMatrix : " << cameraMatrix << std::endl;
	//std::cout << "distCoeffs : " << distCoeffs << std::endl;
	//std::cout << "RMS :" << rms << std::endl;

	

	cv::Mat new_camera_matrix;
	// Refining the camera matrix using parameters obtained by calibration
	new_camera_matrix = cv::getOptimalNewCameraMatrix(cameraMatrix, distCoeffs, dim, 1, dim, 0);
	std::cout << "new_camera_matrix : " << new_camera_matrix << std::endl;





	// print camera parameters to output file
	FileStorage fs("camera_parameters.xml", FileStorage::WRITE);
	fs << "nr_of_frames" << (int)images.size();
	fs << "image_width" << (int)dim.width;
	fs << "image_height" << (int)dim.height;
	fs << "board_width" << (int)CHECKERBOARD[0];
	fs << "board_height" << (int)CHECKERBOARD[1];
	fs << "camera_matrix" << new_camera_matrix;
	fs << "distortion_coefficients" << distCoeffs;
	fs << "RMS" << (int)rms;

		/* Code for performing undistortion of images if needed: 

	cv::Mat image;
	image = cv::imread(images[0]);
	cv::Mat dst, map1, map2
	cv::Size imageSize(cv::Size(image.cols, image.rows));


	// map1 is x, map2 is y
	cv::initUndistortRectifyMap(cameraMatrix, distCoeffs, cv::Mat(), new_camera_matrix, dim, CV_16SC2, map1, map2);
	//
	for (size_t i = 0; i < images.size(); i++)
	{
		// Read image in
		frame = cv::imread(images[i]);

		// Resize to desired size
		cv::resize(frame, frame, dim, cv::INTER_AREA);

		cv::cvtColor(frame, gray, cv::COLOR_RGB2GRAY);
		success = cv::findChessboardCornersSB(gray, cv::Size(CHECKERBOARD[0], CHECKERBOARD[1]), corner_pts);
		cv::drawChessboardCorners(frame, cv::Size(CHECKERBOARD[0], CHECKERBOARD[1]), corner_pts, success);
		cv::resize(frame, frame, dim, cv::INTER_AREA);
	
		cv::remap(frame, dst, map1, map2, cv::INTER_LINEAR);
		if (frame.empty())
			continue;
		printf("\nImage #%i", i);
		cv::imshow("Image View", dst);
		cv::waitKey(0);
	}
	
	*/
	return 0;
}