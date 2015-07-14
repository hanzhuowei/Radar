% function SNR = getAmpSNR(targets)
% returns the SNR in linear units (NOT dB) of targets.SNR

%TODO: db2mag corresponds to y in dB = 20*  log10(x), hence factor 20 not
%factor 10?!

function SNR = getAmpSNR(targets)
    SNR = db2mag(targets.SNR);
end