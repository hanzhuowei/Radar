% function plot_measurements(locationsList, plotParam, markerSymbol)
%
% This function handles measurement plotting
% It plots the position of the targets in localtionsList. If velocity
% entries in locationList are NOT NaN, the velocities are plotted as well 
%
% locationsList: can either be the list of reference targets known from
% simulated data or your own list of tracks, i.e. the trackList from the
% tracking function
% plotParam: struct with field handle. plotParam.handle: is created in 
% simSensorNetwork by executing axes()
% markerSymbol: symbol which is used in plot
function plot_measurements(locationsList, plotParam, markerSymbol)

    for idx = 1:length(locationsList)
        curPos = locationsList(idx).pos;
        plot(plotParam.handle, curPos(1), curPos(2), markerSymbol);

        curVel = locationsList(idx).vel; %Velocity Plot
        if ~any(isnan(curVel))
            plot(plotParam.handle, curPos(1) + [0 curVel(1)], curPos(2) + [0 curVel(2)], 'k');
        end
    end
end