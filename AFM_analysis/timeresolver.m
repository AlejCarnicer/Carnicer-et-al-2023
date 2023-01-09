function [figure1, whiteMatter, grayMatter] = timeresolver
%% timeresolver produces a graph displaying the a scatterplot of elastic
%% modulus versus time of measurement for force curves analyzed with
%% "pointwise". Things to be specified is the indentation depth, and
%% possibly the white and gray matter distinction

%% determine files to open
[FileName,PathName,FilterIndex] = uigetfile('*.mat','Resultsfiles',...
    'c:\ac563\work\measurementdata\','MultiSelect','on');
q = iscell(FileName);
if (q == 0)
    FileName = {FileName};
end
[w,NumberOfFiles] =  size(FileName);
% loop over all files
filelist = [];
for i = 1:NumberOfFiles
    filename = [PathName FileName{i}];
    filelist = [filelist; filename];
end
whiteOrGrayFile = [PathName 'whiteorgray.txt'];

clear FileName FilterIndex PathName filename i q w

%% input
indentationDepth = input('Indentation Depth of the plot in microns?>>');
indentationDepth = indentationDepth * 1E-6;
plotMatter = input('should the plot consist of white(1), gray(2) or all matter?>>');


%% get white or gray matter distinction
openWhiteOrGray = fopen(whiteOrGrayFile);
whiteOrGray = textscan (openWhiteOrGray, '%s %f');
fclose('all');
whiteOrGraySize = size(whiteOrGray{1,1});

clear openWhiteOrGray whiteOrGrayFile

%% get Data, maybe cut of data, append to data matrix, probably do the
% sorting here with an if loop into white and gray matter data
allData=[];
for i =1:NumberOfFiles
    load(filelist(i,:));
    fileString = filelist(i, end-11:end-4);
    TimeCompare = [];
    for q = 1:whiteOrGraySize
        compareString = strcmp(fileString,whiteOrGray{1,1}{q});
        TimeCompare = [TimeCompare; compareString];
    end
    sameStringIndex = find(TimeCompare,1); 
    whichMatter = whiteOrGray{1,2}(sameStringIndex);
    w = size (RESULTS);
    measurementNumber = i*ones(w(1),1);
    matterNumber = whichMatter*ones(w(1),1);
    hours = str2num(fileString(1:2));
    hoursNumber = hours * ones(w(1),1);
    minutes = str2num(fileString(4:5));
    minutesNumber = minutes * ones(w(1),1);
    seconds = str2num(fileString(7:8));
    secondsNumber = seconds * ones(w(1),1);
    results = [RESULTS measurementNumber matterNumber hoursNumber ...
        minutesNumber secondsNumber];
    allData = [allData; results];
end
% CAREFULL: the following step assumes that a measurement is finished
% before midnight. If that is not given anymore, just include the date
% from the filename and do the extended calculation.
allData(:,12) = allData(:,9)*3600 + allData(:,10)*60 + allData(:,11);
minTime = min(allData(:,12));
allData(:,12) = allData(:,12)-minTime;
allData(:,12) = allData(:,12)./60;

clear TimeCompare compareString fileString i matterNumber %minTime
clear measurementNumber q results sameStringIndex w whichMatter 

%% get data for the right indentation depth
timeData=[];
for i = 1:NumberOfFiles
    results = allData(allData(:,7) == i,:);
    dataPointIndex = find(results(:,1) <= indentationDepth,1);
    if ~isempty(dataPointIndex)
        timeData = [timeData; results(dataPointIndex,:) indentationDepth]; 
    end
end

clear whiteOrGraySize RESULTS whiteOrGray
%% data sorting for white and gray matter
whiteMatter = timeData(timeData(:,8)==1,:);
grayMatter = timeData(timeData(:,8)==2,:);

%% plot
if plotMatter == 1
    time = subplot(4,3,7:12); plot(whiteMatter(:,12),whiteMatter(:,3),'kx', 'MarkerSize', 8);
    hold on
    % careful these are fixed values!!!! needs to be changed for future use
    plot([0 120],[190 190],'r-');
    set(time, 'YLim', [0 900]);
    set(time, 'Xlim', [0 120]);
    set(time, 'TickDir','out');
    hold off
elseif plotMatter == 2
    time = subplot(4,3,7:12); plot(grayMatter(:,12),grayMatter(:,3),'kx', 'MarkerSize', 8);
    hold on
    % careful these are fixed values!!!! needs to be changed for future use
    plot([0 120],[524 524],'r-');
    set(time, 'YLim', [0 900]);
    set(time, 'Xlim', [0 120]);
    set(time, 'TickDir','out');
    hold off
elseif plotMatter == 3
    time = plot(timeData(:,12),timeData(:,3),'xr');
else
    time = plot(whiteMatter(:,12),whiteMatter(:,3),'or',...
        grayMatter(:,12),grayMatter(:,3),'xb');
end
set(time, 'TickDir','out');
    % axis([0 7E-6 0 1000])