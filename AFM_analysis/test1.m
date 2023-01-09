function [p]=test()
q=0;
for i=1:10000
q=q+1;

end

p=tic

nameoffile=datestr(now);
nameoffile=['BBBtest1.mat'];
save (nameoffile, 'q');







