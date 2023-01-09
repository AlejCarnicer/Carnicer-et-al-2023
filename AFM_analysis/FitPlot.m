clear all
clc
close all

[FileName,PathName,FilterIndex] = uigetfile({'*.out;*.txt','potential force curves'},'Select curve','C:\ac563\work\measurementdata\test\','MultiSelect','on');

PathName2=strcat(PathName,'BadFC\')
PathName3=strcat(PathName,'TooFlat\')
PathName4=strcat(PathName,'Bad3microFit\')
% this iscell check is required, because if only one force curve is analyzed it is not
% put into a field, but FileName is required to be in a field later on.
q = iscell(FileName);
if (q == 0)
    FileName = {FileName};
    %FileName2 = {FileName2};
    %FileName3 = {FileName3};
end

for i=1:length(FileName)
    i
    FileName2{i}=strcat(FileName{i}(1:end-3),'mat');
    FileName3{i}=strcat(FileName{i}(1:end-3),'jpk-force');
end

%Radius
R = 18.64*10^(-6);

% % [analyzed_file_name, analyzed_path_name, analyzed_filter_index] = ...
% %         uigetfile({'*.mat','analyzed curves'},...
% %         'Select curve','C:\ac563\work\measurementdata\test\',...
% %         'MultiSelect','on');
% % q = iscell(analyzed_file_name);
% % if (q == 0)
% %     analyzed_file_name = {analyzed_file_name};
% % end
analyzed_file_name = FileName2;


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
    rawdata{1,2}=smooth(rawdata{1,2},10);
    rawdata = (CleanData(rawdata));
    i
    if exist(strcat(PathName,analyzed_file_name{i}))==0
        'hallo'
    else
    %rawdata
    
% % %     % find the corresponding .mat file from the analysis
% % %     analyzed_file_index = strmatch(FileName{i}(1:end-4), analyzed_file_name);
% % % 	if isempty(analyzed_file_index)
% % %         print(FileName{i})
% % %     end
% % % 	analyzed_file = [analyzed_path_name analyzed_file_name{analyzed_file_index}];
	load(strcat(PathName,analyzed_file_name{i}));
    
    % select the values for the fitting
        result_size = size(RESULTS);
        binned_data = [];
        binned_data_index = [];
        binned_data2 = [];
        binned_data_index2 = [];
        binned_data3 = [];
        binned_data_index3 = [];
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
            
            dataPointIndex2 = find((RESULTS(:,1) <= indentationDepth(j)+ErrorIndentationDepth));
            dataPointIndex3 = find((RESULTS(:,1) >= indentationDepth(j)-ErrorIndentationDepth));
            dataPointIndex4 = intersect(dataPointIndex3,dataPointIndex2);
             [minumumvalue dataPointIndex5] = min(abs(RESULTS(dataPointIndex4,1)-indentationDepth(j)));  
% %                     dataPointIndex2
% %                     dataPointIndex3
% %                     dataPointIndex4
% %                     RESULTS(dataPointIndex4,1)
% %                     dataPointIndex5
% %                     dataPointIndex4(dataPointIndex5)
% %                     RESULTS(dataPointIndex4(dataPointIndex5),3)
            dataPointIndex6 = find((RESULTS(:,1) <= indentationDepth(j)+0.1*ErrorIndentationDepth));
            dataPointIndex7 = find((RESULTS(:,1) >= indentationDepth(j)-0.1*ErrorIndentationDepth));
            dataPointIndex8 = intersect(dataPointIndex6,dataPointIndex7);
            [maxumumvalue dataPointIndex9] = max(RESULTS(dataPointIndex8,3));
            if ~isempty(dataPointIndex9)
                if abs(maxumumvalue-RESULTS(dataPointIndex4(dataPointIndex5),3))>10
                    CounterOOO(j) = CounterOOO(j) + 1;
                end;
                binned_data2 = [binned_data; RESULTS(dataPointIndex8(dataPointIndex9),:) intervals(interval_number)];
                binned_data_index2 = [binned_data_index; dataPointIndex8(dataPointIndex9)];
%                 elasticityData(q,j) = maxumumvalue;
            end;
            if ~isempty(dataPointIndex5)
                binned_data3 = [binned_data; RESULTS(dataPointIndex4(dataPointIndex5),:) intervals(interval_number)];
                binned_data_index3 = [binned_data_index; dataPointIndex4(dataPointIndex5)];
%             	elasticityData(q,j) = RESULTS(dataPointIndex4(dataPointIndex5),3); 
         	end;
        end
    fullcontactpointindex = RESULTS(1,5)
    EModulus(2) = RESULTS(1,3)
    
    
    if isempty(binned_data_index)==1
        contactpointindex = 400;
        EModulus(1) = 0;
    else
        contactpointindex = RESULTS(binned_data_index,5);
        EModulus(1) = RESULTS(binned_data_index,3);
    end;
    
    h=figure('name', strcat(num2str(EModulus(1)),' and ',num2str(EModulus(2))))%('visible','off');
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
    hold on
    j=1;
    if isempty(binned_data_index)==0
    
    if length(contactpointindex)==1
        contactpointindex(j)
        rawdata{1,3}(contactpointindex(j))
        plot(-rawdata{1,3}+rawdata{1,3}(contactpointindex(j)),rawdata{1,2}-rawdata{1,2}(1),'Color','blue')%,-rawdata{3},smooth(rawdata{2},10))
        plot(-rawdata{1,3}(contactpointindex(j))+rawdata{1,3}(contactpointindex(j)),rawdata{1,2}(1)-rawdata{1,2}(1),'rx')
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
        plot(-rawdata{1,3}(1:contactpointindex(j))+rawdata{1,3}(contactpointindex(j)),-rawdata{1,2}(1)+rawdata{1,3}(1:contactpointindex(j))*approachfitcoefficients(1,1)+approachfitcoefficients(1,2),'Color','black')
        plot(rawdata{1,3}(contactpointindex(j))-rawdata{1,3}(contactpointindex(j):end),-rawdata{1,2}(1)+4/3*RESULTS(binned_data_index(j),3)*sqrt(R)*(-rawdata{1,3}(contactpointindex(j):end)+rawdata{1,3}(contactpointindex(j))).^(3/2)+rawdata{1,3}(contactpointindex(j):end)*approachfitcoefficients(1,1)+approachfitcoefficients(1,2)-4/3*RESULTS(binned_data_index(j),3)*sqrt(R)*(-rawdata{1,3}(contactpointindex(j))+rawdata{1,3}(contactpointindex(j))).^(3/2),'Color','red')
        %plot(-rawdata{1,3}(contactpointindex(j):end),rawdata{1,3}(contactpointindex(j):end)*approachfitcoefficients(1,1)+approachfitcoefficients(1,2),'Color','red')
        %rawdata{1,3}(contactpointindex(j):end);
        end;
    end;
    end;
    
%     contactpointindex=fullcontactpointindex
    if length(contactpointindex)==1
        contactpointindex(j)
        rawdata{1,3}(contactpointindex(j))
        plot(-rawdata{1,3}+rawdata{1,3}(contactpointindex(j)),rawdata{1,2}-rawdata{1,2}(1),'Color','blue')%,-rawdata{3},smooth(rawdata{2},10))
        plot(-rawdata{1,3}(fullcontactpointindex(j))+rawdata{1,3}(contactpointindex(j)),rawdata{1,2}(1)-rawdata{1,2}(1),'mx')
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
        plot(-rawdata{1,3}(1:fullcontactpointindex(j))+rawdata{1,3}(contactpointindex(j)),-rawdata{1,2}(1)+rawdata{1,3}(1:fullcontactpointindex(j))*approachfitcoefficients(1,1)+approachfitcoefficients(1,2),'Color','black')
        plot(rawdata{1,3}(contactpointindex(j))-rawdata{1,3}(fullcontactpointindex(j):end),-rawdata{1,2}(1)+4/3*RESULTS(1,3)*sqrt(R)*(-rawdata{1,3}(fullcontactpointindex(j):end)+rawdata{1,3}(fullcontactpointindex(j))).^(3/2)+rawdata{1,3}(fullcontactpointindex(j):end)*approachfitcoefficients(1,1)+approachfitcoefficients(1,2)-4/3*RESULTS(1,3)*sqrt(R)*(-rawdata{1,3}(fullcontactpointindex(j))+rawdata{1,3}(fullcontactpointindex(j))).^(3/2),'m')
        %plot(-rawdata{1,3}(contactpointindex(j):end),rawdata{1,3}(contactpointindex(j):end)*approachfitcoefficients(1,1)+approachfitcoefficients(1,2),'Color','red')
        %rawdata{1,3}(contactpointindex(j):end);
        end;
    end;
    
    
    %Construct a questdlg with three options
    choice = questdlg('Fitting evaluation!',strcat(num2str(EModulus(1)),' and ',num2str(EModulus(2))),'Good Fit!','Bad Curve','Bad 3µm Fit/To Flat of a Fit at 3µm','Good Fit!');
    % Handle response
    switch choice
        case 'Good Fit!'
            saveas(h,strcat(PathName,FileName{i}(1:end-4),'.tif'), 'tif') ;
            close all;
            fclose('all')
        case 'Bad Curve'
            saveas(h,strcat(PathName2,FileName{i}(1:end-4),'.tif'), 'tif') ;
            close all;
            fclose('all')
%             movefile(strcat(PathName,FileName{i}),strcat(PathName2,FileName{i}))
            movefile(strcat(PathName,FileName2{i}),strcat(PathName2,FileName2{i}))
%             movefile(strcat(PathName,FileName3{i}),strcat(PathName2,FileName3{i}))
        case 'Bad 3µm Fit/To Flat of a Fit at 3µm'
            choice2 = questdlg('Fitting evaluation!',strcat(num2str(EModulus(1)),' and ',num2str(EModulus(2))),'Bad 3µm Fit','To Flat of a Fit at 3µm','Not an Option','Good Fit!');
            switch choice2
            case 'Bad 3µm Fit'
                saveas(h,strcat(PathName4,FileName{i}(1:end-4),'.tif'), 'tif') ;
                close all;
                fclose('all')
%                   movefile(strcat(PathName3,FileName{i}),strcat(PathName2,FileName{i}))
                movefile(strcat(PathName,FileName2{i}),strcat(PathName4,FileName2{i}))
%                 movefile(strcat(PathName,FileName3{i}),strcat(PathName4,FileName3{i}))
            case 'To Flat of a Fit at 3µm'
                saveas(h,strcat(PathName3,FileName{i}(1:end-4),'.tif'), 'tif') ;
                close all
                fclose('all')
%                   movefile(strcat(PathName,FileName{i}),strcat(PathName3,FileName{i}))
                movefile(strcat(PathName,FileName2{i}),strcat(PathName3,FileName2{i}))
%                 movefile(strcat(PathName,FileName3{i}),strcat(PathName3,FileName3{i}))
            case 'Not an Option'
                print 'Not an Option'
            end
          
    end
% %     saveas(h,strcat(PathName,FileName{i}(1:end-4),'.tif'), 'tif') ;
% %     close all;
    end;
end;


%rawdata{3}(RESULTS(:,5))
%RESULTS(1,5)