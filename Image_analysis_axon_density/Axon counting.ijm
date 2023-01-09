roiManager("Add");
run("Measure");
run("8-bit");
waitForUser("Choose contrast");

run("Clear Outside");
setAutoThreshold("Huang dark");
//run("Threshold...");
//setThreshold(7, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=2-25 circularity=0.50-1.00 show=Outlines display exclude clear");
close();