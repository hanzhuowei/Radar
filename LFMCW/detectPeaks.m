% function peakList = detectPeaks(freqSignal)
%
% This function returns the positions of the target frequencies contained
% in the provided freqSignal by finding its peaks.
% Right now, the function always detects three peaks, no matter if they are
% resulting from a target or not.
% freqSignal: the input signal that we would like to find the peaks of.
%
% returns peakList: A list of structs with the fields 'freqs' and 'vals'.
% The length of peakList is the number of detected peaks.
% One peak is made up of several bins.
% Each peakList entry contains the frequency bins of a peak in 'freqs' and
% the corresponding values in 'vals'. This peak list is passed to
% interpolatePeaks().
function peakList = detectPeaks(freqSignal)
% enable the doVisualization() function at the bottom.
visualize = 0;

% processing
%spec = abs(freqSignal).^2;
spec = abs(freqSignal);
%%% Not using .^2 because of linear detector.
% spec = log(spec);
numSamp = length(spec);
freqs = (-numSamp/2:(numSamp/2-1)).';
Idx_CA=1;                               % =0,OS; =1,CA

spec(find(abs(freqs)<3))=0;
% determine threshold

%%%-----HAN--------%%%%
%
threshold=CalThres(spec,Idx_CA);  %

%     thresh = sort(spec);
%     threshold = thresh(end-3);      %Set to detect how many peaks.

% find peak indices
peakIdxs = spec > threshold;      %logical
peak = spec(peakIdxs);
PI=find(peakIdxs);


% group peaks, i.e. group adjacent peak indices to make up one peak
peakList = struct('freqs', {}, 'vals', {});

while any(peakIdxs)
    firstIdx = find(peakIdxs, 1);
    curIdx = firstIdx;
    while peakIdxs(curIdx) && curIdx < length(spec)
        curIdx = curIdx + 1;
    end
    lastIdx = curIdx;  %if no the peak not adjucent, lastIdx=firstIdx+1;
    
    % delete found group from peakIdxs
    peakIdxs(firstIdx:lastIdx) = 0;
    
    newPeak.freqs = freqs(firstIdx:lastIdx);  %freq at peak and the next.
    newPeak.vals = abs(freqSignal(firstIdx:lastIdx));
    peakList(end+1) = newPeak;
    
end

% plot results if visualization is enabled
if visualize
    doVisualization(freqs, spec, threshold,peak,PI);
end
end

function doVisualization(freqs, spec, thresh,peak,PI)
figure(1);
plot(freqs, spec, '-b');
%semilogy(freqs, spec, 'b')
hold on;
plot(freqs(PI),peak, 'go');
hold on;
plot(freqs, thresh, 'r');
xlim([freqs(1) freqs(end)]);
ylim([0 max(spec)+1]);
xlabel('FFT bin');
ylabel('Power Spectral Density');
% legend('spectrum', 'threshold');
hold off;
end