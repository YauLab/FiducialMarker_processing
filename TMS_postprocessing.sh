#!/usr/bin/env tcsh

# TMS target estimation - Postprocessing
# @vmark_3pt (original script file)
# modified by HO (5/1/2018)

# set original mprage file name
set orig = t1_mprage+orig
set bd = `apsearch -afni_bin_dir`

#A low res version of the template (tlrc) - half resolution
if ( ! -f TT_N27_r2+tlrc.HEAD) then
3dresample  -dxyz 2 2 2 -rmode Li -prefix ./TT_N27_r2 \
-input ${bd}/TT_N27+tlrc.
endif

# Quick trip to standard space
# mprage data (capture a outer boundary of the subject) was used as an
# anatomical data for the better SkullStrip performance in the next step (@fast_roi)
3dcalc -a t1_mprage.UNI.rad5.c04+orig. -expr 'a/100' -prefix anat

# Part of the process(@fast_roi) involves running 3dSkullStrip with a set of options to speed it up for
# the purpose of real-time use
# converts an anatomical data (standard space) to tlrc space (based on TT_N27)
@fast_roi  -region CA_N27_ML::Hip -region CA_N27_ML::Amygda \
-base TT_N27_r2+tlrc. -anat anat+orig  \
-roi_grid anat+orig -prefix toy -time

# The tags should be in some file by now, say in paddle.tag
1dcat -ok_1D_text paddle.tag > paddle.orig.1D

# Make toy surface from 3 points forming plane
echo 0 1 2 > paddle.orig.1D.topo

# From point 0 (center of the TMS coil), and along normal, intersect surface
# find the closest triangle t on the subject brain surface using Barycentric Interpolation
# nosk.anat.ply (subject brain surface) from @fast_roi
SurfToSurf -i_1D paddle.orig.1D paddle.orig.1D.topo \
-i_ply nosk.anat.ply -prefix s2s \
-output_params NearestTriangleNodes NearestNodeCoords

# Get intersection point for node 0 (from the center of the TMS coil) and put it in TLRC space
1dcat s2s.1D'[7-9]{0}' > Intersection_orig.1D
set xyz = `1dcat Intersection_orig.1D`
Vecwarp -apar nosk.anat+tlrc. -input Intersection_orig.1D > Intersection_tlrc.1D
set xyz_tlrc = `1dcat Intersection_tlrc.1D`

# generate the line between TMS center and intersection
1d_tool.py -infile 'paddle.tag[0..2]{0}' -write t1.1D 	# TMS center
3dcalc -a 't1.1D' -expr 'a+.5' -prefix t2.1D			# TMS center + .5
1dcat t2.1D > t2_re.1D
cat t1.1D t2_re.1D Intersection_orig.1D > paddle.line.orig.1D

# visualize in original space
@Quiet_Talkers -npb_val 3
afni -npb 3 -yesplugouts -niml &
suma  -npb 3 -niml -onestate   -i_1D paddle.line.orig.1D paddle.orig.1D.topo \
-i_ply nosk.anat.ply -sv nosk.anat+orig.

# run whereami
whereami -space TLRC $xyz_tlrc