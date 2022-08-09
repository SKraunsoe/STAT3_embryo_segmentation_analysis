setBatchMode(true);

base_dir = "/";

image_folder = base_dir + File.separator + "Cropped Resliced Downsized Images/";
segmentation_image_folder = base_dir + File.separator + "3D segmentation output/";
combined_image_folder = base_dir + File.separator + "Combined image and segmentation/";
csvs_folder = base_dir + File.separator + "3D quantification output csvs/";

image_list = getFileList(image_folder);
segmentation_image_list = getFileList(segmentation_image_folder);
run("3D Manager Options", "volume surface compactness integrated_density mean_grey_value std_dev_grey_value mode_grey_value feret minimum_grey_value maximum_grey_value centroid_(pix) centroid_(unit) distance_to_surface centre_of_mass_(pix) centre_of_mass_(unit) objects bounding_box radial_distance surface_contact closest distance_between_centers=10 distance_max_contact=1.80 drawing=Contour");


for (i = 0; i < image_list.length; i++) {
	image_name = image_list[i];
	segmentation_name = segmentation_image_list[i];

	open(image_folder + File.separator + image_name);
	image_title = getTitle();
	run("32-bit");

	open(segmentation_image_folder + File.separator + segmentation_name);
	segmentation_title = getTitle();
	rename("segmentation");
	run("glasbey inverted");


	selectWindow(image_title);
	rename("image");
	run("Split Channels");

	run("Merge Channels...", "c1=C1-image c2=C2-image c3=C3-image c4=C4-image c5=segmentation create");
	saveAs("Tiff", combined_image_folder + File.separator + image_title);

	selectWindow(image_title);
	run("Split Channels");

	selectWindow("C5-" + image_title);
	run("3D Manager");
	Ext.Manager3D_AddImage();
	Ext.Manager3D_SelectAll();
	Ext.Manager3D_Measure();
	Ext.Manager3D_SaveResult("M", csvs_folder + "Embryo_" + (i+1) + "_Morphological_measurements_" + image_title + ".csv");
	Ext.Manager3D_CloseResult("M");

	selectWindow("C1-" + image_title);
	Ext.Manager3D_Quantif();
	Ext.Manager3D_SaveResult("Q", csvs_folder + "Embryo_" + (i+1) + "_C1_Hoechst_" + image_title + ".csv");
	Ext.Manager3D_CloseResult("Q");

	selectWindow("C2-" + image_title);
	Ext.Manager3D_Quantif();
	Ext.Manager3D_SaveResult("Q", csvs_folder + "Embryo_" + (i+1) + "_C2_transcription_factor_1_" + image_title + ".csv");
	Ext.Manager3D_CloseResult("Q");

	selectWindow("C3-" + image_title);
	Ext.Manager3D_Quantif();
	Ext.Manager3D_SaveResult("Q", csvs_folder + "Embryo_" + (i+1) + "_C3_transcription_factor_2_" + image_title + ".csv");
	Ext.Manager3D_CloseResult("Q");

	selectWindow("C4-" + image_title);
	Ext.Manager3D_Quantif();
	Ext.Manager3D_SaveResult("Q", csvs_folder + "Embryo_" + (i+1) + "_C4_transcription_factor_3_" + image_title + ".csv");
	Ext.Manager3D_CloseResult("Q");

	Ext.Manager3D_SelectAll();
	Ext.Manager3D_Delete();
	
	run("Clear Results");
	close();
	run("Close All");
}
setBatchMode(false);
