function [D,Thick]=FBR_capsule(file,height,width,thickness)



%Provides an intensity profile of an FBR capsule. Alej 2017-10-29. 
%Example: FBR_capsule('example.tif',10,10)
%Width and height provided in pixels. Requires 8-bit .tif input.
%Outputs vector D with the averaged intensity.
%If thickness=1, will also locate the edge at which the sample ends on the right
%and give you a capsule depth vector.

%First step locates edge of the capsule to analyse based on input provided
%by user
%The image is then separated into vectors. Each vector corresponds to an
%array of pixels of height and width provided. Vectors begin at capsule
%edge and end at end of picture.[p
%For each pixel an average intensity is calculated. 
%Function outputs a .csv containing a matrix with the intensity profile, as
%well as a .fig plot of the intensity profile calculated from the collapsed
%set of vectors.

%%
%Import figure I
I = imread(file);

%%
%Detect edges and produce a binary mask fudged enough to fill in holes
%Taken and modified from https://uk.mathworks.com/help/images/examples/detecting-a-cell-using-image-segmentation.html
%Main point to edit is the threshold multiplication factor to obtain best
%result.

[BW,threshold]=edge(I,'sobel');
BWs=edge(I,'sobel',threshold*0.3);

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

BWsdil = imdilate(BWs, [se90 se0]);

BWdfill = imfill(BWsdil, 'holes');

%Section below can be skipped if structures to be detected are small
BWclear = imclearborder(BWdfill, 4);
BWnobord = BWdfill-BWclear;


seD = strel('diamond',1);
BWfinal = imerode(BWdfill,seD);
BWfinal = imerode(BWfinal,seD);

BWoutline = bwperim(BWfinal);
Segout = I; 
Segout(BWoutline) = 255; 

%%
%Define grid workspace with dimensions of image

%Choose length of image onto which analysis should be applied.

figure, imshow(Segout), title('Provide two points between which to perform analysis in Y axis (*Enter* to finish)')
[~,y]=getpts;
y=round(y);
close

%Implant must have been placed on left side of image. Otherwise script
%won't work.
%Locate X-axis position of the left-most edge in BWfinal image. Outputs a
%matrix Pos with these.

xx=y(1);
nn=1;
ff=y(2);
Pos=NaN([y(2)-y(1),1]);
while xx<=ff
    k=find(I(xx,:)>0);  %If you want to rely on the edge detection from the script, switch I to BWFinal
    if k>=0
        k1=k(1);
        Pos(nn,:)=k1;
    else
        Pos(nn,:)=length(I);
    end
    xx=xx+1;
    nn=nn+1;
end
    


%Obtain median (rather than mean, in case there are speckles in image acting as
%outliers) of the X position of edge for every pixel height (defined at
%start by user). Outputs in matrix MedPos.

MedPos = arrayfun(@(i) median(Pos(i:i+height-1)),1:height:length(Pos)-height+1)';

%'Stretch out' MedPos to make it of the same dimensions as original image. 

MedPosR = repmat(MedPos,1,height);  %Tile a matrix with as many elements as removed by pixel median.
MedPosR = MedPosR';
MedPos2 = MedPosR(:);               %Turn matrix into vector
MedPos2 = round(MedPos2);           %Round to nearest pixel.

%Produce a version of the original inputted version of image (I) where
%left-most point is defined by the edge of capsule (MedPos). Output is
%IAlign. The right side of image becomes filled with NaNs as appropriate.

xx=y(1);
nn=1;
ff=y(2);
ff2=size(MedPos2,1);
IAlign=NaN(y(2)-y(1),size(I,2)); %exact dimensions will not match original image due to averaging in MedPos2
while nn<=ff2
    v=I(xx,:);
    valign=v(MedPos2(nn):end);
    valign2=[valign,NaN(1,MedPos2(nn)-1)];
    IAlign(nn,:)=valign2;
    insertpos = size(valign,2)+1;       %Have to insert the NaNs into IAlign matrix. Since they dissapear in valign2 as it is a uint8.
    IAlign(nn,insertpos:end)= NaN(1,MedPos2(nn)-1);
    xx=xx+1;
    nn=nn+1;
end

%%
%Produce a pixelated image of matrix - average intensity values in every
%vector with a pixel width defined by user (IGrid).

yy=1-height;
ny=0;

%Define grid size
gx=size(IAlign,2)/width;
gy=size(IAlign,1)/height;
IGrid=NaN(floor(gy),floor(gx)); %Round down (floor) to prevent matrix from exceeding IAlign dimensions if rounding up.

while ny<=floor(gy)-1 %'Typewrite' your way through the matrix 
    xx=1;
    nx=1;
    ny=ny+1;
    yy=yy+height;
    
    while nx<=floor(gx)-1
    Iseg = IAlign(yy:yy+(height-1),xx:xx+(width-1));
    Imean = mean2(Iseg);
    IGrid(ny,nx) = Imean;   %Insert value into Grid.
    nx=nx+1;
    xx=xx+width;
    end
end

%%
%If required, find edge at which sample ends on the right (to calculate
%thickness).

if thickness==1;
    nn=1;
    ff=size(IGrid,1);
    EPos=NaN([y(2)-y(1),1]);
    IGridFlip=flip(IGrid,2);
    IGridFlip(isnan(IGridFlip))=0;
    while nn<=ff
        k=find(IGridFlip(nn,:)>0);  %If you want to rely on the edge detection from the script, switch I to BWFinal
        if k>=0
            k1=k(1);
            EPos(nn,:)=k1;
        else
            EPos(nn,:)=length(I);
        end
    nn=nn+1;
    end
end

Thick=size(IGrid,2)-EPos;   

%%
%Produce a vector with the mean value of IGrid (to be used for analysis,
%unless some rows are to be deleted). IVect.

IVect=mean(IGrid);


%Note: for 20x confocal images, calibration is usually 0.9291 pixels/microm
%%
%Make output directory on current directory. Create name for file from input image.

mkdir FBR_capsule_output;

tag = mfilename(file);
tag = {'FBR_capsule_output\',tag};
tag = strjoin(tag,'');
csvtag = {tag,'AlignedGrid.csv'};
csvtagfull = strjoin(csvtag,'_');
csvtag2 = {tag,'MeanVector.csv'};
csvtagfull2 = strjoin(csvtag2,'_');
IAtag = {tag,'AlignedMap'};
IAtagfull = strjoin(IAtag,'_');
IGtag = {tag,'AlignedGrid'};
IGtagfull = strjoin(IGtag,'_');
Proftag = {tag,'FBR.Profile.png'};
Proftagfull = strjoin(Proftag,'_');

%Create vector with matrix averages. Export .csv with the vector created. Save .csv as.
IVect=mean(IGrid);
csvwrite(csvtagfull,IGrid);
csvwrite(csvtagfull2,IVect);
D=IVect;


%Create an image of the aligned original image (IAligned). Plot using smart plotting (imagesc)
%rather than imshow. Save image as AlignedMap in current directory.

%imagesc(IAlign);
%axis equal tight;    %imagesc by default produces a 1:1 ratio image, stretching out pixels. Tight eliminates white spaces.
%print(IAtagfull,'-dpng');
%close

%Save image of 'Gridded' version of image. Save as AlignedGrid in
%directory.

%imagesc(IGrid);
%axis equal tight;
%print(IGtagfull,'-dpng');
%close

%Create graph for stiffness intensity of image based on distance from
%implant. Save graph as FBR.Profile.

%FBR=boxplot(IGrid);
%xlabel('Distance from implant (input width variable) [pixels]');
%ylabel('Stain intensity [a.u.]');
%print(Proftagfull,'-dpng');
%close



end
