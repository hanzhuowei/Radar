% function locationList = LFMCW_DSP(inputData)
%
% This function encapsulates the whole LFMCW signal processing
% It executes the functions of signal processing chain in the right order
%
% inputData: struct containting the fields: timeSignals, modulation,
% steeringVectors, angs, and the parameters for the different functions
% c.f. simSensorNetwork for an example
%
% returns locationList: a list of structs. Each struct has the fields d, v,
% angle which correspond to the distance, the relative radial velocity and
% the angle of a target. The length of locationList equals the number of
% detected targets.

function [locationList,matchList] = LFMCW_DSP(inputData)

% extract parameters
numRamps = length(inputData.modulation.rampDuration);
numBeams = size(inputData.steeringVectors, 1);% =8
timeSignals = inputData.timeSignals;
modulation = inputData.modulation;
steeringVectors = inputData.steeringVectors;
angs=inputData.angs;
% ...

% dsp stages

% transform to frequency domain
freqSignals = cell(size(timeSignals));  %creat a cell same with size of tim.Sig.
for rampIdx = 1:numRamps
    for beamIdx = 1:numBeams
        freqSignals{rampIdx,beamIdx} = ...
            calculateSpectrum(timeSignals{rampIdx,beamIdx});
    end
end

% perform peak detection
peakCell = cell(size(freqSignals));
for rampIdx = 1:numRamps
    for beamIdx = 1:numBeams
        % detect frequency peaks
        peakList = detectPeaks(freqSignals{rampIdx,beamIdx});
        
        % interpolate detected frequency peaks
        peakCell{rampIdx,beamIdx} = interpolatePeaks(peakList);
    end
end

% execute target frequency matching
matchList = frequencyMatching(peakCell, modulation, inputData.freqmatchingParam);

% estimate target distance and velocity
locationList = estimateDVpos(matchList, modulation);

% estimate target azimuth angle, the direction of arrival (DOA)
locationList = estimateAnglePos(locationList, steeringVectors, matchList, freqSignals,angs);

% apply plausibility checking
locationList = checkPlausibility(locationList);
end