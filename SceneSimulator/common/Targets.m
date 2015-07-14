% function targets = Targets(azi, ele, SNR)
% Targets(azi, ele, SNR) constructs a struct with fields azi, ele and SNR
%
% azi: vector with the azimuth angles of the targets in rad
% ele: vector with the elevation angles of the targets in rad
% SNR: vector with the SNR values of the targets in dB
% returns: a struct with fields azi in rad, ele in rad, and SNR in dB
function targets = Targets(azi, ele, SNR)
    assert(isnumeric(azi) && isvector(azi));
    targets.azi = azi(:).';
    assert(isempty(ele));
    assert(isnumeric(SNR) && isvector(SNR));
    targets.SNR = SNR(:).';
    assert(length(azi) == length(SNR));
end