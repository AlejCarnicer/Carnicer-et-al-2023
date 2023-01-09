

[FileName,PathName,FilterIndex] = uigetfile({'*.out;*.txt','potential force curves'},'Select curve','C:\ac563\work\measurementdata\test\','MultiSelect','on');


% this iscell check is required, because if only one force curve is analyzed it is not
% put into a field, but FileName is required to be in a field later on.
q = iscell(FileName);
if (q == 0)
    FileName = {FileName};
end

%Radius
R = 18.64*10^(-6);

[analyzed_file_name, analyzed_path_name, analyzed_filter_index] = ...
        uigetfile({'*.mat','analyzed curves'},...
        'Select curve','C:\ac563\work\measurementdata\test\',...
        'MultiSelect','on');
q = iscell(analyzed_file_name);
if (q == 0)
    analyzed_file_name = {analyzed_file_name};
end
indentationInput = 0;
forceInput = 0;
assumedCP = 0;
detailedRun = 0;
%intervals = input('For which indentations do you want to see fits?\nType ''[indentation1 indentation2 ...]'' in microns\n>>>');
intervals = [3];
intervals = intervals * 1E-6;
%maxDist = input('What is the maximum error in indentations (in microns)\n>>>');
maxDist = 0.5;
maxDist = maxDist * 1E-6;





[w,e] =  size(FileName)
for i = 1:e
    FileName(i)
    [rawdata,headerinfo] = Readfile(PathName,FileName(i));
    q = iscell(rawdata);
    if (q == 0)
        rawdata = {rawdata};
    end
    rawdata{1,2}=smooth(rawdata{1,2},150);
    rawdata = (CleanData(rawdata));
    %rawdata
    
    % find the corresponding .mat file from the analysis
    analyzed_file_index = strmatch(FileName{i}(1:end-4), analyzed_file_name);
	if isempty(analyzed_file_index)
        print(FileName{i})
    end
	analyzed_file = [analyzed_path_name analyzed_file_name{analyzed_file_index}];
	load(analyzed_file);
    
    % select the values for the fitting
        result_size = size(RESULTS);
        binned_data = [];
        binned_data_index = [];
        for interval_number = 1:length(intervals)
            dataPointIndex = find(RESULTS(:,1) <= intervals(interval_number) + maxDist,1);
            if ~isempty(dataPointIndex)
                while dataPointIndex < result_size(1) && abs(RESULTS(dataPointIndex+1,1) - intervals(interval_number)) < abs(RESULTS(dataPointIndex,1) - intervals(interval_number))
                    dataPointIndex = dataPointIndex + 1;
                end
                if (abs(RESULTS(dataPointIndex,1) - intervals(interval_number)) < maxDist)
                    binned_data = [binned_data; RESULTS(dataPointIndex,:) intervals(interval_number)];
                    binned_data_index = [binned_data_index; dataPointIndex];
                end
            end
        end
    contactpointindex = RESULTS(binned_data_index,5);
    
    
    h=figure%('visible','off');
    subplot(1, 2, 1);
    hold on
    if length(contactpointindex)==1
        plot(-rawdata{1,3}+rawdata{1,3}(contactpointindex(j)),rawdata{1,2}-rawdata{1,2}(1))%,-rawdata{3},smooth(rawdata{2},10))
    end;
    length(intervals)
    length(contactpointindex)
    for j=1:length(intervals)
        if length(contactpointindex)==1
        % fit approach data to the contactpoint of furthest indentation
        %contactpointindex = RESULTS(1,5);
        numberofdatapoints = length(rawdata{:,2});
        approachdata = [rawdata{1,3}(1:contactpointindex(j)) rawdata{1,2}(1:contactpointindex(j))];
        [approachfit] = fitapproach (approachdata);
        approachfitcoefficients = coeffvalues(approachfit);
        plot(-rawdata{1,3}(1:contactpointindex(j))+rawdata{1,3}(contactpointindex(j)),-rawdata{1,2}(1)+rawdata{1,3}(1:contactpointindex(j))*approachfitcoefficients(1,1)+approachfitcoefficients(1,2),'Color','red')
        %plot(-rawdata{1,3}(contactpointindex(j):end),rawdata{1,3}(contactpointindex(j):end)*approachfitcoefficients(1,1)+approachfitcoefficients(1,2),'Color','red')
        plot(rawdata{1,3}(contactpointindex(j))-rawdata{1,3}(contactpointindex(j):end),-rawdata{1,2}(1)+4/3*RESULTS(binned_data_index(j),3)*sqrt(R)*(-rawdata{1,3}(contactpointindex(j):end)+rawdata{1,3}(contactpointindex(j))).^(3/2)+rawdata{1,3}(contactpointindex(j):end)*approachfitcoefficients(1,1)+approachfitcoefficients(1,2)-4/3*RESULTS(binned_data_index(j),3)*sqrt(R)*(-rawdata{1,3}(contactpointindex(j))+rawdata{1,3}(contactpointindex(j))).^(3/2),'Color','red')
        %rawdata{1,3}(contactpointindex(j):end);
        end;
    end;
    subplot(1, 2, 2);
    hold on
    contactpointindex(j)
    size(rawdata{1,3})
    PPoint=find(round(rawdata{1,3}*10^7)==round(rawdata{1,3}(contactpointindex(j))*10^7)+100)
    PPoint2=find(round(rawdata{1,3}*10^7)==round(rawdata{1,3}(contactpointindex(j))*10^7)-50)
    if isempty(PPoint)==1
        PPoint=1;
    end
%     if isempty(PPoint2)==1
%         PPoint2=end;
%     end
    if length(contactpointindex)==1
        plot(-rawdata{1,3}(PPoint(1):PPoint2(end))+rawdata{1,3}(contactpointindex(j)),rawdata{1,2}(PPoint(1):PPoint2(end))-rawdata{1,2}(1))%,-rawdata{3},smooth(rawdata{2},10))
    end;
    length(intervals)
    length(contactpointindex)
    for j=1:length(intervals)
        if length(contactpointindex)==1
        % fit approach data to the contactpoint of furthest indentation
        %contactpointindex = RESULTS(1,5);
        numberofdatapoints = length(rawdata{:,2});
        approachdata = [rawdata{1,3}(1:contactpointindex(j)) rawdata{1,2}(1:contactpointindex(j))];
        [approachfit] = fitapproach (approachdata);
        approachfitcoefficients = coeffvalues(approachfit);
        plot(-rawdata{1,3}(PPoint(1):contactpointindex(j))+rawdata{1,3}(contactpointindex(j)),-rawdata{1,2}(1)+rawdata{1,3}(PPoint(1):contactpointindex(j))*approachfitcoefficients(1,1)+approachfitcoefficients(1,2),'Color','red')
        %plot(-rawdata{1,3}(contactpointindex(j):end),rawdata{1,3}(contactpointindex(j):end)*approachfitcoefficients(1,1)+approachfitcoefficients(1,2),'Color','red')
        plot(rawdata{1,3}(contactpointindex(j))-rawdata{1,3}(contactpointindex(j):PPoint2(end)),-rawdata{1,2}(1)+4/3*RESULTS(binned_data_index(j),3)*sqrt(R)*(-rawdata{1,3}(contactpointindex(j):PPoint2(end))+rawdata{1,3}(contactpointindex(j))).^(3/2)+rawdata{1,3}(contactpointindex(j):PPoint2(end))*approachfitcoefficients(1,1)+approachfitcoefficients(1,2)-4/3*RESULTS(binned_data_index(j),3)*sqrt(R)*(-rawdata{1,3}(contactpointindex(j))+rawdata{1,3}(contactpointindex(j))).^(3/2),'Color','red')
        %rawdata{1,3}(contactpointindex(j):end);
        end;
    end;
xlim([-10*10^(-6) 5*10^(-6)]);
    %saveas(h,strcat(PathName,FileName{i}(1:end-4),'.tif'), 'tif') ;
    %close all;
end;


%rawdata{3}(RESULTS(:,5))
%RESULTS(1,5)