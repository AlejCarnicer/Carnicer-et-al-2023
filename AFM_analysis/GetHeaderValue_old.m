function [headervalue] = GetHeaderValue (headerinfo,whichconstant)
%% extracts a particular value from the header

check = 0;
counter = 1;
q = size(headerinfo);
while (check == 0) && (counter <= q(1))
    if strcmp(headerinfo{counter,1},whichconstant) == 1
        headervalue = headerinfo{counter,2};
        check = 1;
    else counter = counter + 1;
    end
end
if counter > q(1)
    error('The headervalue %s could not be found in GetHeaderValue:', whichconstant);
end