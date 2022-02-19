base_dir = "/";

image_folder = base_dir + File.separator + "Images/"
Cropped_resliced_image_folder = base_dir + File.separator + "Cropped Resliced Downsized Images/"
Cropped_resliced_DAPI_image_folder = base_dir + File.separator + "Cropped Resliced Downsized DAPI Images/"

image_list = getFileList(image_folder);

for (i = 0; i < image_list.length; i++) {
	image_name = image_list[i];

	open(image_folder + File.separator + image_name);
	image_title = getTitle();
	
	run("Split Channels");
	
	selectWindow("C1-" + image_title);
	// The reslice depth should match the xy resolution of your images to improve the anisotrophy
	run("Reslice Z", "new=1");
	run("Grays");
	rename("Channel 1");

	selectWindow("C2-" + image_title);
	run("Reslice Z", "new=1");
	run("Green");
	rename("Channel 2");
	
	selectWindow("C3-" + image_title);
	run("Reslice Z", "new=1");
	run("Magenta");
	rename("Channel 3");
	
	selectWindow("C4-" + image_title);
	run("Reslice Z", "new=1");
	run("Cyan");
	rename("Channel 4");

	run("Merge Channels...", "c1=[Channel 1] c2=[Channel 2] c3=[Channel 3] c4=[Channel 4] create");
	// Images that are too large take up too much computational power in the next step of the pipeline necessitating downsampling
	run("downsample ", "width=512 height=512 source=0.50 target=0.50 keep");
	rename("Downsized image");


	makeRectangle(40, 40, 400, 400);
	waitForUser("Adjust cropping square");

	// Images should be cropped to the size of the actual object (e.g., leaving no black space) to make them as small as possible for the next stage
	run("Crop");
	rename("Cropped image");

	saveAs("Tiff", Cropped_resliced_image_folder + File.separator + "Processed_" + image_title);
	selectWindow("Processed_" + image_title);

	run("Split Channels");
	selectWindow("C1-" + "Processed_" + image_title);
	run("Grays");
	saveAs("Tiff", Cropped_resliced_DAPI_image_folder + File.separator + image_title);
	
	
	close();
	run("Close All");
}