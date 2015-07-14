% function peakFrequencies = interpolatePeaks(peakList)
%
% This function returns an interpolated frequency value for all peak positions.
% It processes peakList to determine the exact target frequencies.
% Right now it is just the mean value.
%
% peakList: The list of detected peaks as calculated by detectPeaks(). It 
% is a list of structs with the fields 'freqs' and 'vals'.
% Each peakList entry contains the frequency bins of a peak in 'freqs' and
% the corresponding values in 'vals'. 
% returns peakFrequencies: a list of target frequencies, each entry being
% the interpolated frequency of one target.
function peakFrequencies = interpolatePeaks(peakList)

    numPeaks = length(peakList);
    peakFrequencies = zeros(1, numPeaks);
        
    for idx = 1:numPeaks
        [max_peak,max_peak_idx]=max(peakList(idx).vals);
        peak_max(idx)=max_peak; %max peak in each cell
    end 
      %peakFrequencies(idx) = mean(peakList(idx).freqs);
    i=0; %deleted number of elements
    
      
    for idx = 1:numPeaks
        [max_peak,max_peak_idx]=max(peakList(idx).vals); %max_peak_idx is a relevant position
        max_peak_idx_total=max_peak_idx+peakList(idx).freqs(1)-1;
        
        
        if length(peakList(idx).vals)==1  %only one sample point
            if peak_max(idx)>max(peak_max)*0.2 %to avoid fake_peaks
                peakFrequencies(idx) = max_peak_idx;
            else peakFrequencies(idx-i)=[];
                 i=i+1;
            end
                
        else if max_peak_idx==length(peakList(idx).freqs)   %max value hits right bound
            sum_total(idx)=(max_peak_idx_total-1).*peakList(idx).vals(max_peak_idx-1)+(max_peak_idx_total).*peakList(idx).vals(max_peak_idx);
            sum_f(idx)=peakList(idx).vals(max_peak_idx-1)+peakList(idx).vals(max_peak_idx);
            f_hat(idx)=sum_total(idx)./sum_f(idx);
            if peak_max(idx) > max(peak_max)*0.2
                peakFrequencies(idx) = f_hat(idx);
            else peakFrequencies(idx-i)=[];
                 i=i+1;

            end
            
        else if max_peak_idx==1  %max value hits left bound
            sum_total(idx)=(max_peak_idx_total).*peakList(idx).vals(max_peak_idx)+(max_peak_idx_total+1).*peakList(idx).vals(max_peak_idx+1);    
            sum_f(idx)=peakList(idx).vals(max_peak_idx)+peakList(idx).vals(max_peak_idx+1);
            f_hat(idx)=sum_total(idx)./sum_f(idx);
            if peak_max(idx) > max(peak_max)*0.2
                peakFrequencies(idx) = f_hat(idx);
            else peakFrequencies(idx-i)=[];
                 i=i+1;
            end

      
        else
            sum_total(idx)=(max_peak_idx_total-1).*peakList(idx).vals(max_peak_idx-1)+(max_peak_idx_total).*peakList(idx).vals(max_peak_idx)+(max_peak_idx_total+1).*peakList(idx).vals(max_peak_idx+1);
            sum_f(idx)=peakList(idx).vals(max_peak_idx-1)+peakList(idx).vals(max_peak_idx)+peakList(idx).vals(max_peak_idx+1);    
            f_hat(idx)=sum_total(idx)./sum_f(idx);    
            if peak_max(idx) > max(peak_max)*0.2
                peakFrequencies(idx) = f_hat(idx);
            else peakFrequencies(idx-i)=[];
                 i=i+1;
            end
    
        end
      
    end  
      
    end
end