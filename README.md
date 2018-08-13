# FiducialMarker_processing

These script files are generated to estimate the TMS target area using 4 fiducial markers attached around the TMS coil. In preprocessing script file, fiducial markers’ x, y, z coordinates will be extracted and mean_coordinates.m Matlab script file will perform k-means clustering to partition all of x, y, z coordinates into 4 clusters. Postprocessing script file will estimate the TMS target location in subject’s brain surface and report the intersection surface in standard (Talairach. TLRC) space.

Content:
1. TMS_preprocessing.sh – AFNI/shell script file to extract fiducial markers’ x,y,z coordinates in subject space
2. TMS_postprocessing.sh -  AFNI/shell script file to estimate TMS target location (intersection) in both subject/ standard (TLRC) space
3. mean_coordinates.m – Matlab code for clustering the fiducial markers’ coordinates
4. t1_mprage+orig.BRIK/HEAD – t1 mprage example file for demo (AFNI format)
5. marker_processing.pdf - flowchart of pre/postprocessing script file
6. TMS marker processing.docx - overview of TMS marker processing script files

Requirements: AFNI/ SUMA, Matlab (Any versions include kmeans function) 
