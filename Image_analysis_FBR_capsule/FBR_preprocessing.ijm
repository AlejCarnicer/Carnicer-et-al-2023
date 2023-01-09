//Preprocessing for FBR capsule images. Provide a line selection of the edge with a thickness.
//Output should be fed to FBR_capsule.m

roiManager("Add");
run("Straighten...");
run("Duplicate...", " ");
waitForUser("Remove any unwanted bits with black pen");

run("32-bit");
setAutoThreshold("Mean dark");
run("Make Binary");
run("Fill Holes");
waitForUser("Fill tissue with black and remove unwanted (large) bits from outside");

run("Erode");
run("Create Selection");
waitForUser("Select duplicated capsule image");

run("Restore Selection");
setBackgroundColor(0, 0, 0);
run("Clear Outside");
run("Restore Selection");
waitForUser("Happy with selection? Unwanted bits can be carefully removed with black pen");

run("Rotate 90 Degrees Right");
run("32-bit");