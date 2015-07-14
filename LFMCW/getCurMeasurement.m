% function LFMCW_measurement = getCurMeasurement(measurement, cycle)
%
% This function returns the measured quantities of the requested cycle.
% measurement: the whole measurement data, c.f. Data/dataFormat.txt
% cycle: the number of the cycle which should be returned
% LFMCW_measurement: the measurement of the requested cycle. It is a struct
% containing the elements: time, timeSignals, modulation, ego and reference
% c.f. Data/dataFormat.txt
%
function LFMCW_measurement = getCurMeasurement(measurement, cycle)

    LFMCW_measurement.time = measurement.time(cycle);
    LFMCW_measurement.timeSignals = measurement.timeSignals{cycle};
    LFMCW_measurement.modulation = measurement.modulation(cycle);
    LFMCW_measurement.ego = measurement.ego(cycle);

    if isfield(measurement, 'reference')
        LFMCW_measurement.reference = measurement.reference(cycle,:);
    else
        LFMCW_measurement.reference = [];
    end
end