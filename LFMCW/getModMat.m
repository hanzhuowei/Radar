% function M = getModMat(modulation)
%
% This function computes the discrete modulation matrix M for a given modulation
% We can use it to compute the difference frequencies f, given the distance
% d and velocity v of a target in  a vector x = [d; v]: 
% f = M*x
% 
% modulation: struct with the modulation parameters rampSlope, rampMidFreq,
% rampDuration, each of them is a vector with the length equals the number of
% ramps, c.f. Data/dataFormat.txt
% returns: the modulation matrix M of dimension (numberOfRamps x 2). The unit
% of the frequencies we get by f = M*x is in "bins" of a FFT of length rampDuration, 
% i.e. Hertz * rampDuration
%
function M = getModMat(modulation)
    %speed of light
    c = 3e8;
    M = [modulation.rampSlope(:) modulation.rampMidFreq(:)];
    M = 2/c * diag(modulation.rampDuration) * M;
end