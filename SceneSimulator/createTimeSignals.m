% function timeSignals = createTimeSignals(array, targets, frequencies, rampLengths)
%
% This function gets:
% array: the rx-array, containing the positions of the rx-elements in units
% of lambda (the carrier wavelength). can be constructed by
% LinearSimulatedArray(positions)
% targets: a struct with fields azi and SNR. Both are vectors of length
% "Number of Targets". azi contains the azimuth angle in rad and the SNR in
% dB. it can be constructed by the function Targets()
% frequencies: a matrix of normalized frequencies with dimensions
% (numberOfRamps x length(targetParam)). numberOfRamps =
% length(modulation.rampSlope)
% containing NaNs when a target could not be detected by the dedicated
% ramp. The frequencies are normalized to binNumbers of the FFT with the length of the rampDuration, i.e.
% frequenciesWithNormamlizedUnits = frequencyInSiUnits * rampDuration
% it can be computed by calculateFrequencies()
% modulation: modulation parameters. struct with fields:
% rampSlope,rampDuration, rampNumSamp, rampMidTime, rampMidFreq. Each field
% is a 1xnumberOfRamps array
%
% returns: the complex time signals as a cell with dimensions (rampLengths x getChann(array)) of
% column vectors using the given antenna array
%
function timeSignals = createTimeSignals(array, targets, frequencies, modulation)
    ramps = length(modulation.rampDuration);

    % initialize time signals with noise
    timeSignals = cell(ramps, getChann(array));
    for rampIndex = 1:ramps
        for antennaIndex = 1:getChann(array)
            bins = modulation.rampNumSamp(rampIndex);
            % todo: stimmt 1/sqrt(2) hier?
            timeSignals{rampIndex,antennaIndex} = 1/sqrt(2) * (randn(bins, 1) + 1j* randn(bins, 1));
        end
    end

    ang = getAzi(targets);
    SNR = getAmpSNR(targets);

    for targetIndex = 1:getNumberTargets(targets)
        for rampIndex = 1:ramps
            freq = frequencies(rampIndex,targetIndex);
            % square root of duration is needed, as SNR is normalized to power of one second ramp
            % and this is the amplitude, not the power
            steeringVector = getSteeringMatrix(array, ang(targetIndex)) ...
                * SNR(targetIndex) * sqrt(modulation.rampDuration(rampIndex));

            if ~isnan(freq)
                for antennaIndex = 1:getChann(array)
                    timeSignals{rampIndex,antennaIndex} = ...
                        timeSignals{rampIndex,antennaIndex} + steeringVector(antennaIndex) ...
                        * exp( ( (1:modulation.rampNumSamp(rampIndex)).' ) * 1j*pi*freq);
                end
            end
        end
    end
end
