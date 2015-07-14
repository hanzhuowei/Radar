%% sceneSimulator(angs, array, overallSimulationTime, modulation, targetParam, fileName)
% computes the simulated time signals for a specified Radar Sensor 
% and a specified scenario.
% 
% for the parameters: c.f. scenarioExample.m for an example
%
% angs: the angles, at which to compute the steering vectors, in rad
% array: the rx-array, containing the positions of the rx-elements in units
% of lambda (the carrier wavelength). can be constructed by
% LinearSimulatedArray(positions)
% overallSimulationTime: the time, the overall simulated scenario should
% take (in seconds)
% modulation: modulation parameters. struct with fields:
% rampSlope,rampDuration, rampNumSamp, rampMidTime, rampMidFreq. Each field
% is a 1xnumberOfRamps array
% sleepTime: time in seconds to wait between two cycles (one cycle corresponds to sending numberOfRamps ramps) 
% targetParam: vector of structs. each structs has the fields: lateralDistance, longitudinalDistance, relLateralVelocity,
% relLongitudinalVelocity, RCS (everything is SI-units). Each struct
% corresponds to one target. The length of targetParam is the number of
% targets.
% fileName: name of the file, in which simulated data is saved. (without
% .mat suffix) the simulated data is saved in Data/fileName.mat

function sceneSimulator(angs, array, overallSimulationTime, modulation, sleepTime, targetParam, fileName)
  
    % add subfolders to matlab path to increase portability
    addpath(genpath(fileparts(mfilename('fullpath'))));

    %% computation of some parameters
   
    % computation of the steeringVectors
    steeringVectors = getSteeringMatrix(array, angs); %#ok<NASGU>

    % The ramps cannot have a negative delay
    assert(all(cumsum(modulation.rampDuration) - 1/2*(modulation.rampDuration) ...
        <= modulation.rampMidTime));

    % overall time of one cycle
    cycleTime = sum(modulation.rampDuration) + sleepTime;
     
    % number of cycles
    cycles = ceil(overallSimulationTime / cycleTime);
    
    %% simulation
    timeSignals = cell(cycles,1);
    time = ones(cycles,1);
    currTime = 0;

    for k = 1:cycles
        % calculate new positions
        for m = 1:length(targetParam)
            latDist = targetParam(m).lateralDistance + targetParam(m).relLateralVelocity * currTime;
            longDist = targetParam(m).longitudinalDistance + ...
                targetParam(m).relLongitudinalVelocity * currTime;
            distVec = [latDist; longDist];

            targetParam(m).distance = norm(distVec);
            targetParam(m).ang = atan2(latDist, longDist);
            targetParam(m).relVelocity = distVec.' / norm(distVec) * ...
                [targetParam(m).relLateralVelocity; targetParam(m).relLongitudinalVelocity];
            targetParam(m).inAllRamps = nan();

            % construct reference signal
            cur_ref.pos = flipud(distVec);
            cur_ref.vel = [targetParam(m).relLongitudinalVelocity; ...
                targetParam(m).relLateralVelocity];
            cur_ref.inAllRamps = nan();
            reference(k,m) = cur_ref; %#ok<AGROW>
        end


        [SNRs frequencies] = calculateFrequencies(targetParam, modulation);

        targets = Targets([targetParam(:).ang], [], SNRs);

        timeSignals{k} = createTimeSignals(array, targets, frequencies, modulation);

        currTime = currTime + cycleTime;
        time(k) = currTime; %#ok<AGROW,NASGU>

        for m = 1:length(targetParam)
            reference(k,m).inAllRamps = ~any(isnan(frequencies(:,m))); %#ok<AGROW>
        end

%         figure(gcf)
%         plot(-256:255, abs(fftshift(fft(timeSignals{k}{1,1}))));
%         drawnow
%         pause(0.3)
    end

    % clone modulation to all cycles to be compatible with measurement data format
    modulation = repmat(modulation, [1 cycles]); %#ok<NASGU>
    
    ego.velocity = 0;
    ego.angularVelocity = 0;
    ego = repmat(ego, [1 cycles]); %#ok<NASGU>

    %% save time signals and modulation into mat file
    fullfileName = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'Data', 'simulated_with_scene_simulator', fileName);
    save(fullfileName, 'time', 'timeSignals', 'modulation', 'steeringVectors', 'angs', 'ego', ...
        'reference');

    % plot spectra
%     for m = 1:size(timeSignals{1}, 1);
%         for n = 1:size(timeSignals{1}, 2);
%             figure; plot(abs(fftshift(fft(timeSignals{1}{m,n}))));
%         end
%         plot(abs(fftshift(fft(timeSignals{m}{1,1}))));
%         pause(0.1)
%     end
end
