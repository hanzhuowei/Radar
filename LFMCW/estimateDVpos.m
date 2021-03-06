% function locationList = estimateDVpos(matchList, modulation)
%
% This function returns the d-v coordinate estimation.
% Right now, these are just random numbers.
%
% matchList: a #ramps-by-#targets matrix(4*1), each column representing 
% the frequency vector for one matched target in units "bin". It is 
% generated by frequencyMatching.
% modulation: modulation parameters of the measurement
%
% returns locationList: list containing all targets. The length of the list
% is the number of detected targets. Each entry is a struct with fields: 
% distance, velocity and angle. Angles are set to NaN. Distance and
% velocity are in SI units
function locationList = estimateDVpos(matchList, modulation)
        if isempty(matchList)
            locationList = [];
        else
            matches = size(matchList, 2);%#of Obj.
            locationList = repmat(struct('dist', nan(), 'vel', nan(), 'angle', nan()), [matches 1]);
            
            for idx = 1:matches
            M=getModMat(modulation);
            Mpinv=pinv(M);
            ParaVect=Mpinv*matchList;% each Column of Para is for One Object. Dim: 2* #of Obj.
            locationList(idx).dist = ParaVect(1,idx);
            locationList(idx).vel = ParaVect(2,idx);   
            end
        end
    

end

