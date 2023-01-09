function [weighedHertzfit,weighedHertzfitquality] = weighedhertzfitbeta(indentationdata)
% makes a weighed fit to the indentationdata (further indentation weights
% more)
q=1;
while (q==1);
weighedHertzmodel = fittype({'x^(3/2)'},'coefficients','Hertzfactor');
    indentationdatapoints = length (indentationdata);
    Weights = 1:indentationdatapoints;
    Weights = (Weights'/indentationdatapoints).^2;
    weighedoptions = fitoptions('Method', 'LinearLeastSquares','Weights',Weights);
    [weighedHertzfit,weighedHertzfitquality,weighedHertzfitoutput] = fit(indentationdata(:,1),indentationdata(:,2),weighedHertzmodel,weighedoptions);
    y = feval(weighedHertzfit,indentationdata(:,1));
    differencesquared = (y-indentationdata(:,2)).^2;
    meandiff = mean (differencesquared);
    if (differencesquared(1)>2*meandiff)
        while (differencesquared(1)>2*meandiff)
            differencesquared = differencesquared (2:end);
            indentationdata = indentationdata(2:end,:);
        end
    elseif (differencesquared(1) < 2*meandiff)
        q=0;
    else
        disp('error at fitapproach')
    end
end

    