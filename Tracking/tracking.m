% function trackList = tracking(trackList, locationList, trackParam)
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
%        correspond to the own velocity and angularVelocity(Obj.) at the time 
%        when the measurement was taken
% return trackList: updated trackList

% Tracklist update 

% Model:
% 
% Variable declaration:
% x_estimate        estimate for next state
% [x;y;vel_x;vel_y]
%
% x_prior       the Prior state
% A             Process Matrix
% x_estimate = A*x_prior + N_pred;
% N_pred is the error in Prediction, affected by acceleration of the
% object.
% T is the time between two measurement. ramp duration
% 
% f_meas = inv(M)* x_pred + N_meas;
% predict the measurement for next state. 
% Q ?: is the measurement in the lab the matchlist?
% N_meas is the measurement error, (d-v chart?)

%

function trackList = tracking(trackList, locationList, modulation)

    % transform measurements to tracking coordinate system, both velocity
    % and distance are transformed in cartesian coordinates.
    x_tem = zeros(2,1);
    x_prior = zeros(2,1);
    x_estimate = zeros(2,1);
    Accel_noise_mag = 0.05;
    mea_noise = 0.1;
    T = sum(modulation.rampDuration);
    N_pred = Accel_noise_mag^2 * [T^4/4 T^3/2; T^3/2 T^2]; %(4*1 dim)
    N_meas = mea_noise^2;
    A = [1 T; 0 1]; % 
    % R=1*R +T*V;
    % V=0*R +1*V;
    %
    P = N_pred;
    trackList = locationList;
    
    for idx=1:length(trackList)
        x_tem(1) = trackList(idx).dist;
        x_tem(2) = trackList(idx).vel;
        x_prior = x_tem(:);
        %predict the next state
        x_estimate = A*x_prior;
        
        %predict the next state covariance
        P = A * P * A' + N_pred;
        
        %predict the measurement covariance
        %Kalman Gain
        M = [1 0];
%         Mpinv = pinv(M);
        K = P*M'*inv(M*P*M'+N_meas);
        
        %update the state estimate
        x_estimate = x_estimate + K * (x_prior(1) - M * x_estimate); % measurement is Freq.
        
        %store in trackList
        trackList(idx).dist = x_estimate(1);
        trackList(idx).vel  = x_estimate(2);

        
    end
    
    trackList = transform_locations(trackList);

    


end

