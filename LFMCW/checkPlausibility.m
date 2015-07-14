% function locationList = checkPlausibility(locationList)
%
% This function deletes all unplausible locations.
%
% locationList: a list of structs. Each struct has the fields d, v, angle,
% which correspond to the distance, the radial velocity and the angle of 
% a target. The length of locationList equals the number of detected targets.
% It is computed by estimateDVpos() or estimateAnglePos()
%
% returns: an updated locationList, in which unplausible targets are
% deleted. 

function locationList = checkPlausibility(locationList)
    % ignore objects we already would have chrashed into ...
    if ~isempty(locationList)
        locationList([locationList.dist] <= 0) = [];
    end
end