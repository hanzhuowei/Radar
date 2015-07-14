function simSensorNetwork(fileName)
% simSensorNetwork(fileName)
% This function encapsulates and manages the whole sensing network.
% It runs the signal processing chain, using LFMCW_DSP(), and stops the time
% of the evaluation.
% fileName: optional argument. filename of the file with the measurement
% data, which should be loaded
clc; close all;

% The final real time requirement is measured if plotting is disabled
plottingEnabled = 1;

% add subfolders to matlab path to increase portability
addpath(genpath(fileparts(mfilename('fullpath'))));

% Support debugging
%clear persistent; close all; clc

%the filename to load, if not given as extra argument, Need put All files
%in Data Folder.
if ~exist('fileName', 'var')
    fileName = 'scenarioExample.mat';
    %  fileName = 'testScene.mat';
    %         fileName = 'straightScene.mat';
%            fileName = 'complexScene.mat';
%             fileName = 'cornerReflector.mat';
%            fileName = 'carAndCornerReflector.mat';
%             fileName = 'slowTownScene.mat';
%             fileName = 'complexTownScene.mat';
%             fileName = 'complexHighwaySceneAtNight.mat';
end

%load measurements
measurement = loadMeasurement(fileName);

%stop the time
processingStart = tic();
%run all functions of the signalprocessing chain
trackList = analyzeMeasurementData(measurement, plottingEnabled); %#ok<NASGU>
%stop the time
elapsedTime = toc(processingStart);

%check if evaluation time is smaller than the real time of the
%measurement
if ~plottingEnabled
    if elapsedTime < measurement.time(end)
        disp('Real time requirement fulfilled:');
    else
        warning('Real time requirement failed:'); %#ok<WNTAG>
    end
    fprintf('%.0f%% of available time used\n', 100 * elapsedTime / measurement.time(end));
end
end

% this function executes LFMCW_DSP for all measured cycles in measurement
function trackList = analyzeMeasurementData(measurement, plottingEnabled)

%set some parameters
% do we have an IQmixer?
freqmatchingParam.IQmixer = true;

% x and y axes in meter which should be plotted
plotParam.xInt = [0 250];
plotParam.yInt = [-50 50];
plotParam.plottingEnabled = plottingEnabled;

if plottingEnabled
    figure(2);
    plotParam.handle = axes();
    hold on;
end
%%%%%%%%%%%% Liu %%%%%%%%%%%%%%
trackList = [];
previous_measurement=[0;0;0];
% Sensor network main loop:
trackParam.time=[];
for cycIdx = 1:measurement.numCycles
    
    % retrieve current measurements:
    currentMeasurement = getCurMeasurement(measurement, cycIdx);
    
    % carry out LFMCW dsp:
    LFMCWparam.timeSignals = currentMeasurement.timeSignals;
    LFMCWparam.modulation = currentMeasurement.modulation;
    
    LFMCWparam.steeringVectors = measurement.steeringVectors;
    LFMCWparam.angs = measurement.angs;
    LFMCWparam.freqmatchingParam = freqmatchingParam;
    
    [locationList,matchList] = LFMCW_DSP(LFMCWparam);
    
    % execute tracking stage
    trackParam.time = [trackParam.time,currentMeasurement.time];
    trackParam.ego = currentMeasurement.ego;
    [trackList,previous_measurement] = trackingLiu(trackList, locationList,LFMCWparam.modulation,previous_measurement,cycIdx,matchList,trackParam);
    
    % execute plotting
    handleAllPlots(trackList, plotParam, currentMeasurement.reference);
end
% %%%%%%%%%%%%% Han %%%%%%%%%%%%%%%
% % Sensor network main loop:
% for cycIdx =1:measurement.numCycles
%     
%     % retrieve current measurements:
%     currentMeasurement = getCurMeasurement(measurement, cycIdx);
%     
%     % carry out LFMCW dsp:
%     LFMCWparam.timeSignals = currentMeasurement.timeSignals;
%     LFMCWparam.modulation = currentMeasurement.modulation;
%     
%     LFMCWparam.steeringVectors = measurement.steeringVectors;
%     LFMCWparam.angs = measurement.angs;
%     LFMCWparam.freqmatchingParam = freqmatchingParam;
%     
%     locationList = LFMCW_DSP(LFMCWparam);
%     
%     
%     
%     % execute tracking stage
%     trackParam.time = currentMeasurement.time;
%     trackParam.ego = currentMeasurement.ego;
%     trackList = tracking(trackList, locationList , LFMCWparam.modulation);
% %     trackList = transform_locations(locationList);
%     % execute plotting
%     handleAllPlots(trackList, plotParam, currentMeasurement.reference);
%         IdxOutput=num2str(cycIdx)
% %     h=figure(2);
% %     cd('D:\radar\software\Figure');
% %     saveas(h,IdxOutput,'jpg');
% %     cd('D:\radar\software');
%     
% end
end