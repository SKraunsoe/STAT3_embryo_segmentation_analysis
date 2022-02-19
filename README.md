# STAT3_embryo_segmentation_analysis
Fiji macros, R script and links to Google Colab notebooks (3D Stardist segmentation) for the analysis of transcription factors (STAT3, TFCP2L1, NANOG) in E3.5, E4.5 and diapause mouse embryos. 

This repository contains the Fiji macros and R script used to analyse and quantify the expression patterns of STAT3 and TFCP2L1 in mouse embryos which we use to support the qualitative observation that expression of STAT3 and its target, TFCP2L1 is enhanced in the ICM of diapaused mouse embryos. See our paper for more details.  

There are four sections to this analysis pipeline which must be run in order. 
1. The first Fiji macro, "Image pre-processing macro to prepare images for 3D stardist segmentation.ijm" takes the raw 4-channel images (in tif format) and processes them so they are ready to be fed into the 3D Stardist segmentation script. If images are not in .tif format or have more than one channel, 
2. The second 
