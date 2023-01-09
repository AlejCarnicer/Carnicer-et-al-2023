function [figure1] = creategraphs (rawdata,contactpointquality,newapproachdata,indentationdata,approachfit,weighedHertzfit,maxindentation)




datax = [(-1)*newapproachdata(:,1);indentationdata(:,1)];
datay = [newapproachdata(:,2);indentationdata(:,2)];
approachfitcoefficients = coeffvalues(approachfit);
newapproachdata0 = [newapproachdata;[0,0]];
newapproachfitdata = [newapproachdata0(:,1),newapproachdata0(:,1)*approachfitcoefficients(1)+approachfitcoefficients(2)];
weighedHertzfitcoefficients = coeffvalues(weighedHertzfit);
weighedHertzfitcoefficients = real(weighedHertzfitcoefficients);
weighedHertzfitdata = [indentationdata(:,1),real(indentationdata(:,1).^(3/2))*weighedHertzfitcoefficients];
figure1 = figure(1);
clf reset;
subplot (4,3,1); plot(approachfit,'-r',newapproachdata(:,1),newapproachdata(:,2),'bo','fit');
   title approachfit
   legend('off');
%subplot (4,3,2); plot(indentationdata(:,1),indentationdata(:,2),'ob','MarkerSize',2)
%    hold on
%    plot(weighedHertzfitdata(:,1),weighedHertzfitdata(:,2),'r-');
%    hold off
%   title forcefit
%   legend('off');
%subplot (4,3,1); plot(contactpointquality(:,1),contactpointquality(:,2),'ob','MarkerSize',2);
%    title approachresiduals
%    legend('off');
subplot (4,3,2); plot(weighedHertzfit,'-r',indentationdata(:,1),indentationdata(:,2),'bo','residuals');
    title forceresiduals
    legend('off');
subplot (4,3,3); plot(contactpointquality(:,1),contactpointquality(:,3),'ob','MarkerSize',2);
    title contactpoint
    legend('off');
subplot (4,3,4:6); plot(-rawdata{1,3},rawdata{1,2},'ob','MarkerSize',2);
    title rawdata;
    legend('off');
subplot (4,3,7:12); plot(datax,datay,'bo','MarkerSize',2)
    hold on
    plot(weighedHertzfitdata(:,1),weighedHertzfitdata(:,2),'r-')
    plot((-1)*newapproachfitdata(:,1),newapproachfitdata(:,2),'r--');
    hold off
    title TheFIT
    legend('off');