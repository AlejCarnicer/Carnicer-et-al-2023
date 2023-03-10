
function [i]= batchforce 
%% batchforce analyzes a batch of force curves obtained with a colloidal
%% probe. The model used is the Hertz-model (assuming a paraboloid indenter
%% rather than a spherical one). The program requires the force curves to
%% be relatively well behaved, though they can be pretty bad around the
%% contact point and it requires all force curves to be obtained with a
%% probe of the same size (though it can be a different cantilever). Also
%% the cantilevers should be calibrated and only certain headers can be
%% read.


%% Select the force curves to be analyzed


[FileName,PathName,FilterIndex] = uigetfile({'*.out;*.txt','potential force curves'},'Select curve','C:\ac563\work\measurementdata\test\','MultiSelect','on');


% this iscell check is required, because if only one force curve is analyzed it is not
% put into a field, but FileName is required to be in a field later on.
q = iscell(FileName);
if (q == 0)
    FileName = {FileName};
end



%% get the necessary inputs
beadradius = input('Beadradius in nm >');
beadradius = beadradius*1E-9;
weight_user_index = input('Should data points at deeper indentations be given more weight[y/n]?\n>>>','s');
if strcmp('y',weight_user_index) == 1
    weight_user_index = 1;
elseif strcmp('n',weight_user_index) == 1
    weight_user_index = 0;
else
    error('no valid input')
end
specialSelect = input('Select type of analysis:\n(1)  Complete analysis with tabulated output\n(2)  Specific output for one Indentation\n(3)  Specific output for one Force\n(4)  Check fits\n(5)  Residuals\n>>>');
if specialSelect == 3
    forceInput = input('To which force in nN do you wish to analyze?>>');
    forceInput = forceInput*1E-9;
    indentationInput = 0;
    assumedCP = input('Which contactpoint(index) do you assume? (0 for none)>>');
    if assumedCP == 0
        detailedRun = 0;
    else detailedRun = 1;
    end
elseif specialSelect == 2
    indentationInput = input('To which indentation in microns do you want to analyze?>>');
    indentationInput = indentationInput*1E-6;
    forceInput = 0;
    assumedCP = input('Which contactpoint(index) do you assume? (0 for none)>>');
    if assumedCP == 0
        detailedRun = 0;
    else detailedRun = 1;
    end
elseif specialSelect == 1
    resolution = input('Every how many data points should a fit be performed?\nWARNING: A too small value may make the calculation take forever.\nFor a 1000 data point force curves 7 may be reasonable.\nBecause of certain parts of the algorithm the number should be below 20.\n>>>');
    forceInput = 0;
    indentationInput = 0.03*beadradius;
    assumedCP = 0;
    detailedRun = 0;
elseif specialSelect == 4
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
    intervals = input('For which indentations do you want to see fits?\nType ''[indentation1 indentation2 ...]'' in microns\n>>>');
    intervals = intervals * 1E-6;
    maxDist = input('What is the maximum error in indentations (in microns)\n>>>');
    maxDist = maxDist * 1E-6;
elseif specialSelect == 5
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
    intervals = input('For which indentations do you want to see residuals?\nType ''[indentation1 indentation2 ...]'' in microns\n>>>');
    intervals = intervals * 1E-6;
    maxDist = input('What is the maximum error in indentations (in microns)\n>>>');
    maxDist = maxDist * 1E-6;
else
    print('invalid input')
end
deletePoints = 0;

space = ' ';
userInput{1} = {['beadradius' space num2str(beadradius)];...
    ['specialSelect' space num2str(specialSelect)];...
    ['forceInput' space num2str(forceInput)];...
    ['indentationInput' space num2str(indentationInput)];...
    ['assumedCP' space num2str(assumedCP)];...
    ['detailedRun' space num2str(detailedRun)];...
    ['weight_user_index' space num2str(weight_user_index)]};

%% iteration over all files
[w,e] =  size(FileName);
for i = 1:e
    
    %% Read the force curve data and cut of 'bad' start and end
    [rawdata,headerinfo] = Readfile(PathName,FileName(i));
    rawdata
    rawdata{2} = smooth(rawdata{2},10);% inserted by David 14/03/13
    rawdata = CleanData(rawdata);
    
    %% this loop following finds the index of the point with minCP_value
    minCP_value = min([(max(rawdata{1,3}) - 2E-6) (min(rawdata{1,3}) + 2*beadradius)]) % the multiplication of bead radiud by factor 2 changed David 14/03/13 
    minCP_index = 1;
    length(rawdata{1,3})
    rawdata{1,3}(minCP_index)
    minCP_value
    if rawdata{1,3}(minCP_index) > minCP_value
        while rawdata{1,3}(minCP_index) > minCP_value
            minCP_index = minCP_index+1;
          
            
        end
    end
    
    %% actual calculation of force curve fit for one particular curve
    local_indentation = 15000E-9;
    local_CP_index = minCP_index + 1;
    if specialSelect == 1
        w=1;
        while (minCP_index < local_CP_index)
            results = forcecurveanalysis(rawdata,headerinfo,userInput,minCP_index,w,local_CP_index);
            local_indentation = GetHeaderValue(results,'indentation');
            if (local_indentation < indentationInput)
                break
            end
            local_force = GetHeaderValue(results,'force');
            local_CP_index = GetHeaderValue(results,'contactpointindex');
            RESULTS(w,1) = GetHeaderValue(results,'indentation');
            RESULTS(w,2) = GetHeaderValue(results,'force');
            RESULTS(w,3) = GetHeaderValue(results,'modulus');
            RESULTS(w,4) = GetHeaderValue(results,'hertzfactor');
            RESULTS(w,5) = GetHeaderValue(results,'contactpointindex');
            RESULTS(w,6) = GetHeaderValue(results,'bestcontactpointrms');
            rawdata = {rawdata{1,1}(1:end-resolution) rawdata{1,2}(1:end-resolution) rawdata{1,3}(1:end-resolution)};
            w=w+1;
        end
        filename = [PathName FileName{i}(1:end-4) '.mat'];
        if 1 == exist('RESULTS', 'var')
            save(filename, 'RESULTS', '-mat')
        end
        clear('RESULTS', 'rawdata');
    elseif specialSelect == 4 || 5
            %% find the corresponding .mat file from the analysis
        analyzed_file_index = strmatch(FileName{i}(1:end-4), analyzed_file_name);
        if isempty(analyzed_file_index)
            print(FileName{i})
        end
        %% get the cp from .mat file
        analyzed_file = [analyzed_path_name analyzed_file_name{analyzed_file_index}];
        load(analyzed_file);
        %% select the values for the fitting
        result_size = size(RESULTS);
        binned_data = [];
        for interval_number = 1:length(intervals)
            dataPointIndex = find(RESULTS(:,1) <= intervals(interval_number) + maxDist,1);
            if ~isempty(dataPointIndex)
                while dataPointIndex < result_size(1) && abs(RESULTS(dataPointIndex+1,1) - intervals(interval_number)) < abs(RESULTS(dataPointIndex,1) - intervals(interval_number))
                    dataPointIndex = dataPointIndex + 1;
                end
                if (abs(RESULTS(dataPointIndex,1) - intervals(interval_number)) < maxDist)
                    binned_data = [binned_data; RESULTS(dataPointIndex,:) intervals(interval_number)];
                end
            end
        end
        %% fit approach data to the contactpoint of furthest indentation
        contactpointindex = RESULTS(1,5);
        numberofdatapoints = length(rawdata{:,2});
        approachdata = [rawdata{1,3}(1:contactpointindex) rawdata{1,2}(1:contactpointindex)];
        [approachfit] = fitapproach (approachdata);
        approachfitcoefficients = coeffvalues(approachfit);
        newapproachdata = [approachdata(:,1)-rawdata{1,3}(contactpointindex),approachdata(:,2)-approachfitcoefficients(1,1)*approachdata(:,1)-approachfitcoefficients(1,2)];
        
        %% recalculate indentationdata
        springConstant = GetHeaderValue(headerinfo,'springConstant');
        forcecurvedata = [rawdata{1,3}(contactpointindex:numberofdatapoints,1) rawdata{1,2}(contactpointindex:numberofdatapoints,1)];
        forcecurvedata = [(forcecurvedata(:,1)-rawdata{1,3}(contactpointindex)),forcecurvedata(:,2)-approachfitcoefficients(1,1)*forcecurvedata(:,1)-approachfitcoefficients(1,2)];
        indentationdata = [forcecurvedata(:,1) - springConstant*forcecurvedata(:,2), forcecurvedata(:,2)];
        indentationdata(:,1) = (-1)*indentationdata(:,1);
        
        %% make additional indentationdata from fit data
        if not(isempty(binned_data))
            for q = 1:length(binned_data(:,1))
                distance_to_cp = rawdata{1,3}(contactpointindex)-rawdata{1,3}(binned_data(q,5));
                first_positive = find(indentationdata(:,1)-distance_to_cp>0 , 1);
                indentationdata(first_positive:end,2*q+2) = binned_data(q,4)*((indentationdata(first_positive:end,1)-distance_to_cp).^(3/2));
                indentationdata(1:first_positive,2*q+2) = indentationdata(1:first_positive,2*q+2)*0;
                indentationdata(:,2*q+3) = indentationdata(:,1);
                indentationdata(1:first_positive,2*q+3) = ones(first_positive,1)* distance_to_cp;
            end
            if specialSelect == 5
                newapproachdata = [0 0]
                for q = 1:length(binned_data(:,1))
                    indentationdata(:,2*q+2) = indentationdata(:,2)-indentationdata(:,2*q+2)
                end
                indentationdata(:,2) = 0
            end
        end
                
        %% draw the graph
        if specialSelect == 4
            datax = [(-1)*newapproachdata(:,1); indentationdata(:,1)];
            datay = [newapproachdata(:,2); indentationdata(:,2)];
            figure1 = plot(datax,datay,'.k');
            hold all
            legend_string = [num2str(0) '  ' num2str(0)];
            if not(isempty(binned_data))
                for q = 1:length(binned_data(:,1))
                    plot(indentationdata(:,2*q+3), indentationdata(:,2*q+2));
                    legend_string_try = [num2str(binned_data(q,7)) '  ' num2str(binned_data(q,3))];
                    legend_string = strvcat(legend_string, legend_string_try);
                end
            end
            legend(legend_string);
            legend('Location', 'NorthWest');
            legend('show');
            axis auto
            hold off
        elseif specialSelect == 5
            datax = [(-1)*newapproachdata(:,1); indentationdata(:,1)];
            datay = [newapproachdata(:,2); indentationdata(:,2)];
            figure1 = plot(datax,datay,'-k');
            hold all
            legend_string = [num2str(0) '  ' num2str(0)];
            if not(isempty(binned_data))
                for q = 1:length(binned_data(:,1))
                    plot(indentationdata(:,2*q+3), indentationdata(:,2*q+2), '.');
                    legend_string_try = [num2str(binned_data(q,7)) '  ' num2str(binned_data(q,3))];
                    legend_string = strvcat(legend_string, legend_string_try);
                end
            end
            legend(legend_string);
            legend('Location', 'NorthWest');
            legend('show');
            axis([0 7E-6 -0.2E-8 0.2E-8])
            hold off
        end
        
        %% save the plot
        filename = [PathName FileName{i}];
        r = length(filename);
        timestampstart = r-11;
        timestampend = r-4;
        timestamp = filename(timestampstart:timestampend);
        newtimestamp = [timestamp(1:2) ':' timestamp(4:5) ':' timestamp(7:8)];
        imagename = filename(1:end-4);
        if specialSelect == 4
            imagename = [imagename '.png'];
        elseif specialSelect == 5
            imagename = [imagename 'residual.png'];
        end
        print('-dpng ','-r300',imagename);
    end
    fclose all
        %% fit curve with the contact point from analysis
        
        %% draw the graph
end
    
    
    %% create graphs
    
    %% IF LOOP: IF RESULTS ONLY ONE LINE, DO GRAPH FOR THOSE VALUES AND
    %% PRINT OUT ONLY THAT LINE. IF MORE THAN ONE LINE, GRAPH FOR FIRST
    %% LINE, FOR LAST LINE AND TEXTFILE OUTPUT OF TABLE
    
    % [figure1] = creategraph (rawdata,headerinfo,userInput,Results);
    %% save the data
    %{
    if specialSelect == 1
        filename = [PathName FileName{i}(1:end-4) '.mat'];
        save(filename, 'RESULTS', '-mat')
        clear('RESULTS', 'rawdata');
    end
    %}
    %Timestampvector(i) = timestamp;
    %Resultsmatrix(i,:) = Results;
    %Forcestring = num2str(MaxForceVector(counter))
    %Analysisfilename = [PathName 'Analysis-' Forcestring 'nN.txt'];
    %fid = fopen(Analysisfilename,'at');
    %s = fprintf(fid,'%8s\t',newtimestamp);
    %s = fprintf(fid,'%10e\t %10e\t %10e\t %10e\t %10e\t %10e\t %10e\t %10e\t %10e\n',Results);
    %status = fclose(fid);
    %imagename = filename(1:end-4);
    %imagename = [imagename '-' Forcestring 'nN.png'];
    %print('-dpng ','-r300',imagename);
    %disp(i)
    %disp(MaxForceVector(counter))
    %disp(timestamp)
end
%path = input(path)
%beadsize = input(beadsize)
