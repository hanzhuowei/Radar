function [] = handleAllPlots(trackList, plotParam, reference)

% handleAllPlots(trackList, plotParam, reference)
% This function handles plotting. It plots the target tracks resulting from
% the whole signal processing chain. If data given by the simulator is used
% the known reference targets from the simulator are also plotted for
% comparison with your estimated tracks.

% trackList: list of tracks to be plotted as given by the tracking
% function.  It is a list of targets. Each entry is a struct with fields 
% pos and vel representing one target. pos and vel are both 2x1 vectors 
% containing the x- and y-components of a targets position and velocity 
% respectively.
% plotParam: contains parameters for plotting purposes; created in the main
% program simSensorNetwork. 
%   plotParam.xInt: Vector containing the 
%   boundaries in meter which should be plotted for the x-axis.
%   plotParam.yInt analogously. 
%   plotParam.plottingEnabled Bool which decides if plotting should be done
%   plotParam.handle: is created in simSensorNetwork by executing axes()
% reference: the list with the true target parameters as given by the
% simulators


  %% plotting
    if plotParam.plottingEnabled
        % plot reference if available
        if ~isempty(reference)
            plot_measurements(reference, plotParam, 'c.');
        end

        % plot current track List
        figure(2);
        plot_measurements(trackList, plotParam, 'b*');
        xlabel('x [m]');
        ylabel('y [m]');
        
        % update plot
        figure(2);
        axis([plotParam.xInt plotParam.yInt]);
        drawnow();
    end


end

