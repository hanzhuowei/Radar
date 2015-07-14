% function matchList = frequencyMatching(peakCell, modulation, param)
%
% This function combines the provided peaks, i.e. it does the frequency
% matching. It uses the algorithm explained in Marcus Reihers PhD thesis
%
% peakCell: cell array with the detected frequency peaks. It is constructed in
% LFMCW_DSP(). The dimension of the cell array is #ramps x #beams. Each
% entry of this cell array is a list of interpolated peaks, as computed by
% interpolatePeaks()
% modulation: modulation parameters of the measurement, c.f.
% Data/dataFormat.txt
% returns matchList: a #ramps-by-#targets matrix, each column representing
% the frequency vector for one matched target in units "bin".

function matchList = frequencyMatching(peakCell, modulation, param)
matchThresh = 1;
thres_pos   = 1;
Visualisation = 0; % 1,for plot D-V diagramm
%

% join all beams to one virtual spectrum
[numRamps numBeams] = size(peakCell);
peakListCell = cell(numRamps, 1);
for rampIdx = 1:numRamps
    curFreqs = zeros(1, 0);
    for beamIdx = 1:numBeams
        curFreqs = [curFreqs peakCell{rampIdx, beamIdx}]; %#ok<AGROW>
    end
    peakListCell{rampIdx} = unique(curFreqs);
end

% mirror frequencies in case of missing IQ-mixer
if ~param.IQmixer
    for rampIdx = 1:numRamps
        peakListCell{rampIdx} = peakListCell{rampIdx} - peakListCell{rampIdx};
    end
end

% build and test all combinations
A = getModMat(modulation); % modulation
ACpinv = pinv(A(1:2,:));
matchList = [];
testPos = [];
testPos_tem = [];

Var_Obj= [];
for r1Idx = 1:length(peakListCell{1})
    for r2Idx = 1:length(peakListCell{2})
        % combination hypothesis
        
        testComb = [peakListCell{1}(r1Idx); peakListCell{2}(r2Idx)];
        %%%%%%%%%% Visualisation %%%%%%%%%%
        if Visualisation == 1
        testComb_up = [peakListCell{1}(r1Idx); peakListCell{2}(r2Idx)];
        testComb_down = [peakListCell{3}(r1Idx); peakListCell{4}(r2Idx)];
        close all;
        figure(1);
        x=[0:1:100];
        y=cell(4,1);
        y{1}=(testComb_up(1)-A(1,1)*x)./A(1,2);
        y{2}=(testComb_up(2)-A(2,1)*x)./A(2,2);
        y{3}=(testComb_down(1)-A(3,1)*x)./A(3,2);
        y{4}=(testComb_down(2)-A(4,1)*x)./A(4,2);
        
        plot(x,y{1} );
        hold on
        plot(x,y{2} );
%         hold on
%         plot(x,y{3} );
%         hold on
%         plot(x,y{4} );
        xlabel('R(m)');
        ylabel('Velocity(m/s)');
        title('R-V diagramm')
        axis([[0 100] [-10 10]])
        pause;
        end
        %%%%%%%%%%%%%% end visualisastion  %%%%%%%%
        % find exact position
        testPos_tem= ACpinv * testComb;
        
        %                % validation for pos_tem, if the test position lies within the
        %                % defined range of existed testPos, considered as same object, so drop it.
        %                % 20.Jan by Han.
        K = zeros(2,2);
        ghost       = 0;
        if ~isempty(testPos)
            for PosIdx= 1: size(testPos,2)
                K(:,1)=testPos_tem;
                K(:,2)=testPos(:,PosIdx);
                
                %%%%%%%%%%%%% Visualization of Cross Section Algorithm %%%%%%%%%%%%%%
%                 figure(2);
%                 hold on;
%                 %                     grid on;
%                 plot(K(1,:),K(2,:),'+r','markersize',10,'markerfacecolor','g','markeredgecolor','k');
%                 xlabel('R');
%                 ylabel('Velocity');
%                 axis([[0 100] [0 10]]);
%                 title('Range-Velocity Diagramm')
                
                %%%%%%%%%%%%% End %%%%%%%%%%%%%%%%%%%%%%%%%%
                if sqrt(sum(var(K,0,2))) < thres_pos
                    %                         Var_Obj(end+1)= sqrt(sum(var(K,0,2)));
                    ghost = 1;
                    break; %break the "for" of testPos
                end
                
                if PosIdx == size(testPos,2)
                    testPos(:,end+1)=testPos_tem;
                end
            end
            
        else
            testPos(:,end+1)=testPos_tem;
        end
        
        if ghost == 1
            continue; %break the for of r2Idx
        end
        
        
        % predict frequencies in remaining ramps
        predFreq = A(3:end,:) * testPos_tem;
        % search and validate predicted frequencies
        foundIndxs = NaN(size(A,1)-2, 1);
        for searchIdx = 3:size(A,1)
            localPeakList = peakListCell{searchIdx};
            searchVals = abs(localPeakList - predFreq(searchIdx-2)) < matchThresh;
            if any(searchVals)
                foundIndxs(searchIdx-2) = find(searchVals, 1);
            end
        end
        % has the hypothesis been validated in all spectra?
        if ~any(isnan(foundIndxs))
            for subIdx = 1:size(A,1)-2
                testComb = [testComb; peakListCell{2+subIdx}(foundIndxs(subIdx))];
            end
            matchList(:, end+1) = testComb; %#ok<AGROW>
        end
    end
    %         pause;
end


end