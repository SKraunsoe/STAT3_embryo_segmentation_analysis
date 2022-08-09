
// Base_dir is the path to the directory in which your files are held
// image_folder is the path to the directory in which your TIF image files are held
// DAPI_channel_number=the order of the DAPI channel in a multichannel image e.g. C1 (channel 1), C2 (channel 2)
// Number_of_channels=the total number of channels in the image

base_dir="/Volumes/S KRAUNSOE/MPhil/STAT3 paper/Pre-processed images/";
image_folder=base_dir + "/Images/";
segmentation_output_folder=base_dir + "/Segmentation/";
csvs_folder=base_dir + "/Csvs/";

DAPI_channel_number="C1"

Number_of_channels=4

//setBatchMode(true);

///////////////// NO USER INPUT BEYOND HERE ///////////////////////////////////////

image_list=getFileList(image_folder);

for (i=0; i < image_list.length; i++) {
	roiManager("reset");
	image_name=image_list[i];
	image_path = image_folder + image_name;
	open(image_path);
	//run("Bio-Formats Importer", "open=["+image_path+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	rename(image_name);
	image_title=getTitle();
	
	image_title = File.nameWithoutExtension;
	run("Split Channels");

	selectWindow("C1-" + image_title + ".tif");
	run("Grays");
	saveAs("Tiff", segmentation_output_folder + "C1-" + image_title + ".tif");
	rename("C1-" + image_title + ".tif");
	
	selectWindow("C2-" + image_title + ".tif");
	run("Green");
	saveAs("Tiff", segmentation_output_folder + "C2-" + image_title + ".tif");
	rename("C2-" + image_title+ ".tif");

	selectWindow("C3-" + image_title + ".tif");
	run("Cyan");
	saveAs("Tiff", segmentation_output_folder + "C3-" + image_title + ".tif");
	rename("C3-" + image_title + ".tif");

	selectWindow("C4-" + image_title + ".tif");
	run("Magenta");
	saveAs("Tiff", segmentation_output_folder + "C4-" + image_title + ".tif");
	rename("C4-" + image_title + ".tif");

	
	selectWindow(DAPI_channel_number + "-" + image_title + ".tif");
	run("Unsharp Mask...", "radius=15 mask=0.60 stack");
	image = getTitle();
	run("Square Root", "stack");
	
	run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'"+image+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.9', 'probThresh':'0.2', 'nmsThresh':'0.2', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	//run("TrackMate");
	//waitForUser("Manual running of the Trackmate-StarDist pipeline", "DO NOT PRESS OKAY UNTIL MANUAL RUNNING OF THE TRACKMATE-STARDIST PIPELINE IS COMPLETE \n Follow these selection instructions: \n 1. Click Next, there is no need to adjust the crop settings \n 2. Select 'StarDist detector' then click Next \n 3. Click 'Preview' to see how well the 2D StarDist detector is performing on an individual slice and when satisifed click Next \n 4. Wait for the Detection bar at the top to complete and then click Next (this may take a few minutes) \n 5. If the number of spots is > the number of slices* the approximate number of cells then consider adjusting the Quality bar to reduce the number of spots (or objects) \n taken forward, otherwise click Next \n 6. Wait for the calculation to complete then add filters to the spots using the green plus button e.g. filters for Area/Average Ch1 (DAPI) intensity can help to filter out erroneous segmentation \n (this can be checked by seeing which spots disappear from the visible slice), then click Next \n 7. Select the LAP Tracker then click Next \n 8. Set the Frame-to-frame linking to 4uM, tick the Allow gap closure box and set the Max Track segment gap closing to 4uM and Max frame gap to 3, then click Next \n 9. Wait for the tracks to be calculated, then click Next \n 10. Add some filters to the tracks using the green plus button e.g. Track duration set to Above 3.45, then click Next \n 11. Do not change any Display options, click Next \n 12. Click Next \n 13. Under Select an action chose 'Export label image' and click Execute \n 14. Select 'Export only spots in tracks' \n Close the TrackMate window and click okay on this message");
	wait(3000);

	run("glasbey inverted");


	run("Duplicate...", "duplicate");
	
	rename("Segmentation");
	//run("Edit LUT...");
	
	selectWindow("C1" + "-" + image_title + ".tif");
	run("16-bit");
	setMinAndMax(0, 255);
		selectWindow("C2" + "-" + image_title + ".tif");
	run("16-bit");
	setMinAndMax(0, 255);
		selectWindow("C3" + "-" + image_title + ".tif");
	run("16-bit");
	setMinAndMax(0, 255);
		selectWindow("C4" + "-" + image_title + ".tif");
	run("16-bit");
	setMinAndMax(0, 255);

if(Number_of_channels==4) {
	run("Merge Channels...", "c1=[C1-" + image_title + ".tif" + "] c2=[C2-" + image_title + ".tif" + "] c3=[C3-" + image_title + ".tif" + "] c4=[C4-" + image_title + ".tif" + "] c5=Segmentation create");
	} else if (Number_of_channels==3) {
	run("Merge Channels...", "c1=[C1-" + image_title + ".tif" + "] c2=[C2-" + image_title + ".tif" + "] c3=[C3-" + image_title + ".tif" + "]  c4=[" + Segmentation + "] create");
	} else if (Number_of_channels==5) {
		run("Merge Channels...", "c1=[C1-" + image_title + ".tif" + "] c2=[C2-" + image_title + ".tif" + "] c3=[C3-" + image_title + ".tif" + "] c4=[C4-" + image_title + ".tif" + "] c5=[C5-" + image_title + ".tif" + "] c6=[" + Segmentation + "] create");
	} else {
		print("Error image must have between 3 and 5 channels");
	}
	
	saveAs("Tiff", segmentation_output_folder + "Segmented_" + image_title + ".tif");
	
}



	