% function locationList_transformed = transform_locations(locationList)
%
% This function transforms location coordinates to track system
% coordinates, i.e. it transforms polar coordinates to Cartestian 
% coordinates
%
% locationList: list containing all targets. Each 
% entry is a struct with fields: dist, vel and angle.
%
% returns locationList_transformed: a list of targets. Each entry is a
% struct with fields pos and vel representing one target. 
% pos is a 2x1 
% vectors containing the x- and y-components of a targets position. vel is 
% a 2x1 vector containing NaN entries, since the velocity cannot be
% transformed to cartesian coordinates, if only the radial velocity is
% known
function locationList_transformed = transform_locations(locationList)

    if isempty(locationList)
        locationList_transformed = [];
    else
        for idx = 1:length(locationList)
            curLocation = locationList(idx);
            [posVecX posVecY] = pol2cart(curLocation.angle, curLocation.dist);
            [velVecX velVecY] = pol2cart(curLocation.angle, curLocation.vel);
            locationList_transformed(idx) = init_trackObj([posVecX; posVecY], [velVecX; velVecY]);
        end
    end
end

% function newObj = init_trackObj(posVec, velVec)
%
% This function initializes a new track object
%
function newObj = init_trackObj(posVec, velVec)
    newObj.pos = posVec;
    newObj.vel = velVec;
end