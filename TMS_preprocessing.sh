#!/usr/bin/env tcsh

# TMS target estimation - Preprocessing
# @vmark_3pt (original script file)
# modified by HO (5/1/2018)

# set original mprage file name
set orig = t1_mprage+orig
set bd = `apsearch -afni_bin_dir`

# capture a outer boundary of the subject
# Urad and clfrac parameters may be modified for each subject if it is needed
3dUnifize -input $orig -prefix t1_mprage.UNI.rad5.c04 -Urad 5 -clfrac 0.4

# clip regions of a volume
# TMS coil positions above Z mm (0 mm)
@clip_volume -input $orig -prefix t1_mprage.below -below 0

# create a mask (outer of the subject)
3dcalc -a $orig -b t1_mprage.UNI.rad5.c04+orig. -expr 'step(a)-step(b)' -prefix t1_mprage.mask.marker.c04

# create a mask (outer and above Z mm of the subject)
3dcalc -a $orig -b t1_mprage.mask.marker.c04+orig. -c t1_mprage.below+orig -expr 'a*b*step(c)' -prefix t1_mprage.masked.c04

# thresholding to capture all the voxels of fiducial markers 
# thresholding number (500) may be modified based on the raw data
3dcalc -a t1_mprage.masked.c04+orig. -expr 'step(a-500)' -prefix t1_mprage.final.c04

# writes ASCII file values of fiducial markers
3dmaskdump -o xyz_coordinates.tag -noijk -xyz -mask t1_mprage.final.c04+orig. $orig

# set the MATLAB path
# mean_coordinates.m written by HO (5/1/2018)
# clustering the fiducial markers (using k-means cluster)
# output: paddle.tag including 3 (x,y,z) coordinates 
# 1. center of the TMS coil
# 2.3. two two other fiducial marker coordinates generating the triangle surface
/Applications/MATLAB_R2018a.app/bin/matlab -nosplash -nodisplay -r "run mean_coordinates(4).m;quit;"