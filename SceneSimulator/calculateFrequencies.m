% calculateFrequencies(targetParam, modulation)
% this function computes the difference frequencies of the targets given in
% targetParam, with the given modulation
%
% targetParam: vector of structs. each structs has the fields: lateralDistance, longitudinalDistance, relLateralVelocity,
% relLongitudinalVelocity, RCS (everything is SI-units). Each struct
% corresponds to one target. The length of targetParam is the number of
% targets.
% modulation: modulation parameters. struct with fields:
% rampSlope,rampDuration, rampNumSamp, rampMidTime, rampMidFreq. Each field
% is a 1xnumberOfRamps array
%
% At the moment, all ramps are evaluated at the same point of time, this can be changed later,
% if necessaray.
%
% At the moment, we implicitely use IQ mixers. This can be changed later, if necessary.
%
% Assumption: The number of bins is even.
%
% Assumption: We have one more negative than positive frequency bin.
%
% It is assumed: Delta f = f_{Tx} - f_{Rx}
%
% returns:
% - SNRsdB: a row vector of the SNRs in dB
% - frequencies: a matrix of normalized frequencies with dimensions
% (numberOfRamps x length(targetParam)). numberOfRamps =
% length(modulation.rampSlope)
% containing NaNs when a target could not be detected by the dedicated
% ramp. The frequencies are normalized to binNumbers of the FFT with the length of the rampDuration, i.e.
% frequenciesWithNormamlizedUnits = frequencyInSiUnits * rampDuration
%
function [SNRsdB frequencies] = calculateFrequencies(targetParam, modulation)
    SNRsdB = zeros(1, length(targetParam));
    ramps = length(modulation.rampSlope);
    frequencies = zeros(ramps, length(targetParam));

    lightspeed = 299792458;
    maxAngle = pi/2;
    
    for targetIndex = 1:length(targetParam)
        tp = targetParam(targetIndex);

        % calculate frequencies. frequencyBin = frequencyInHertz * rampDuration
        for rampIndex = 1:ramps
            freqBin = 2/lightspeed * (tp.distance * modulation.rampSlope(rampIndex) + ...
                modulation.rampMidFreq(rampIndex) * tp.relVelocity) * ...
                modulation.rampDuration(rampIndex);

            if freqBin >= -modulation.rampNumSamp(rampIndex)/2 ...
                    && freqBin <= modulation.rampNumSamp(rampIndex)/2-1 && abs(tp.ang) <= maxAngle
                frequencies(rampIndex,targetIndex) = freqBin /(modulation.rampNumSamp(rampIndex)/2);
            else
                frequencies(rampIndex,targetIndex) = nan();
            end
        end

        % calculate SNRs
        % The SNR is proportional to (no absolut values available): RCS * duration / distance^4
        % Proportionality to duration follows from Eq 4.7 of Michael Schoor's Phd
        % We set the proportional constant so that a 5000 m^2 target has an SNR of 50 dB in a
        % distance of 100 m using a ramp of 0.1 ms duration
        % We here set an SNR of a ramp of duration 1 s, so this has to be scaled for each ramp
        % accordingly, when generating time signals
        propConstant = 50 * 100^4 / (5000 * 0.1);
        SNRsdB(targetIndex) = 10 * log10(propConstant * tp.RCS / tp.distance^4);
    end
end