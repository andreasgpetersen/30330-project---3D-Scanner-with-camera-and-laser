# 30330 project - 3D Scanner with camera and laser
Final project for course 30330 - Image analysis on Microcomputer @ DTU. Created a 3D scanner only using a DSLR camera and a laser pointer. 


This project concentrates on constructing, deriving and programming a system that can per- form 3D profiling of an object that moves with constant speed. The object will be rotating on a stand and a dotted line laser will be used as the structured light source. The focus is to create a proof-of-concept rather than a complete and autonomous plug-n-play system. The object was filmed with a DSLR camera at an angle while a laser pointer lit up the object. The laser point had a spectral filter on which created a long vertical line of several dots. The test object to be scanned was a black cross. 

![Scanning setup](https://github.com/andreasgpetersen/30330-project---3D-Scanner-with-camera-and-laser/blob/main/report/figures/reconstruction/setup_2.png)


In order to develop a simple yet functional 3D scanner, the following four tasks were iden- tified: 
1) A suitable test setup needs to be actualized for collecting data of the object while it is illuminated by the laser and rotating simultaneously. This is required to get good and usable data. 
2)By using trigonometry, a mathematical relation between the depth of the object and horizontal displacement of the laser must be derived to acquire 3D information of the target. 
3) To correctly scale the size of the object using the mathematical relations found, the intrinsic and extrinsic parameters of the camera must be computed using cam- era calibration. 
4)In order to build the 3D model using a point cloud, the feature points from the data collection have to be extracted correctly. Different methods and approaches is evaluated, to find the optimal solution.


By following the outlined steps, a simple 3D scanner was developed. An operative test setup was build and a mathematical relation derived. The optimal feature extraction method was found to be a combination of using Gaussian blur and Moore neighborhood tracing to robustly extract and detect feature points. 

The scanned objects were recreated as digital 3D models with a reasonable degree of precision. An upper bound on the expected precision was found as well, to evaluate the performance of the system even better. Keeping in mind the equipment and approach used, the scanner is successful in recreating 3D models of the scanned objects.

Cross-shaped object       |  Point cloud reconstruction of cross-shaped object
:-------------------------:|:-------------------------:
![](https://github.com/andreasgpetersen/30330-project---3D-Scanner-with-camera-and-laser/blob/main/report/figures/reconstruction/crossdimensions.png)  |  ![](https://github.com/andreasgpetersen/30330-project---3D-Scanner-with-camera-and-laser/blob/main/report/figures/reconstruction/cross_reconstruction.png)


Stack of wooden blocks    |  Point cloud reconstruction of wooden blocks
:-------------------------:|:-------------------------:
![](https://github.com/andreasgpetersen/30330-project---3D-Scanner-with-camera-and-laser/blob/main/report/figures/reconstruction/wooddimensions.png)  |  ![](https://github.com/andreasgpetersen/30330-project---3D-Scanner-with-camera-and-laser/blob/main/report/figures/reconstruction/wood_pointcloud.png)



<p align="center">
  <img alt="Light" src="https://github.com/andreasgpetersen/30330-project---3D-Scanner-with-camera-and-laser/blob/main/report/figures/reconstruction/wooddimensions.png" width="45%">
&nbsp; &nbsp; &nbsp; &nbsp;
  <img alt="Dark" src="https://github.com/andreasgpetersen/30330-project---3D-Scanner-with-camera-and-laser/blob/main/report/figures/reconstruction/wood_pointcloud.png" width="45%">
</p>
