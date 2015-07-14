% function trackList = tracking(trackList, locationList(i), trackParam)
%
% This function is to handle tracking.
% Right now it does nothing but transforming the position coordinates in
% cartesian coordinates
%
% trackList: a list of target tracks. Each entry is a struct with fields pos
% and vel representing one target. pos and vel are both 2x1 vectors
% containing the x- and y-components of a targets relative position and
% relative velocity respectively.
% localtionList: the list with the estimated parameters of all targets, as
% returned by LFMCW_DSP. The length of the list equals the number of
% detected targets. Each entry is a struct with fields: distance, velocity
% and angle
% trackParam: tracking parameters, a struct containing the fields time and
% ego.
%   time is the time when the measurement was taken
%   ego: struct with fields velocity and angularVelocity. The values
%        correspond to the own velocity and angularVelocity at the time
%        when the measurement was taken
% return trackList: updated trackList
function [trackList,previous_measurement] = tracking_sub(trackList, locationList,modulation,previous_measurement,cycIdx,matchList,trackParam)

% transform measurements to tracking coordinate system
% trackList = transform_locations(locationList(i));

if (isempty(locationList)) | (isempty(matchList))
    if previous_measurement == [0;0;0]
        return
    end
    
    for k=1:length(locationList())  %  discuss different object
    T=mean(diff(trackParam.time));
    v_hat_star=locationList(1).vel;
    R_hat_star=previous_measurement(2,1)+previous_measurement(1,1).*T;



        
    locationList(1).vel=v_hat_star;
    locationList(1).dist=R_hat_star;
    locationList(1).angle=previous_measurement(3);
    previous_measurement=[locationList.vel;locationList.dist;locationList.angle];
    trackList = transform_locations(locationList());
    end
    
else
    
    for k=1:length(locationList())  %  discuss different object
        
        T=mean(diff(trackParam.time));
        gate=20;
        alpha=0.75;
        
        
        if cycIdx ==1
            v_hat_star=locationList(k).vel;
            R_hat_star=locationList(k).dist;
            previous_measurement=[locationList(k).vel;locationList(k).dist;locationList(1).angle];
        else
            
            R_hat_star=previous_measurement(2,1)+previous_measurement(1,1).*T;
            v_hat_star=locationList(1).vel;
            trackList_hat_star=[v_hat_star;R_hat_star];
            c = 3e8;
            M = [modulation.rampSlope(:) modulation.rampMidFreq(:)];
            M = 2/c * diag(modulation.rampDuration) * M;
            M(:,[1,2])=M(:,[2,1]);
            
            f_hat_star=zeros(4,1);
            f_hat_star = M*trackList_hat_star;
            
            if abs(f_hat_star(1)-matchList(1,1))>gate
                f_hat(1)=f_hat_star(1);
            else
                f_hat(1)=matchList(1,1);
            end
            
            if abs(f_hat_star(2)-matchList(2,1))>gate
                f_hat(2)=f_hat_star(2);
            else
                f_hat(2)=matchList(2,1);
            end
            
            if abs(f_hat_star(3)-matchList(3,1))>gate
                f_hat(3)=f_hat_star(3);
            else
                f_hat(3)=matchList(3,1);
            end
            
            if abs(f_hat_star(4)-matchList(4,1))>gate
                f_hat(4)=f_hat_star(4);
            else
                f_hat(4)=matchList(4,1);
            end
            
            if size(f_hat)==[1,4]
                f_hat=f_hat';
            end
            
                
            trackList_0=zeros(2,1);
            trackList_0=pinv(M)*f_hat;
            
            trackList_hat=zeros(2,1);
            trackList_hat=(1-alpha).*trackList_hat_star+alpha.*trackList_0;
            
            trackList(k).vel=trackList_hat(1);
            trackList(k).dist=trackList_hat(2);
            
            if previous_measurement(1)==0
                locationList
            
            locationList(k).vel=trackList(k).vel;
            locationList(k).dist=trackList(k).dist;
            
            previous_measurement=[locationList(k).vel;locationList(k).dist;locationList(k).angle];
            
            
        end
        
        % transform measurements to tracking coordinate system
        
        trackList = transform_locations(locationList);
        
        
        
    end
    
end

end