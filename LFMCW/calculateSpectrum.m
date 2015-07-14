% function freqSignal = calculateSpectrum(timeSignal)
%
% This function calculates a time signal's frequency spectrum.
% timeSignal: vector containing the time signal
%
% returns freqSignal: vector with the complex spectrum of timeSignal
function freqSignal = calculateSpectrum(timeSignal)
     win_length=length(timeSignal);  % in real-time measurement data the length could be 1024
     window=hamming(win_length);
     timeSignal_win=timeSignal.*window*win_length/sum(window);
     freqSignal = fftshift(fft(timeSignal_win,win_length));
%      freqSignal = fftshift(abs(fft(timeSignal)));
%      freqSignal1=freqSignal-freqSignal2;
%      subplot(2,1,1)
%      plot(abs(freqSignal).^2);
%      subplot(2,1,2)
%      plot(abs(freqSignal2).^2);
% plot(timeSignal);
end

