% function measurement = loadMeasurement(fileName)
%
% loadMeasurement(fileName) loads a complete measurement of multiple time 
% cycles. The measurement can be a real measurement or data which was
% simulated by a simulator.
%
% fileName: the file name of the data to load. 
% returns: measurement struct. c.f. Data/dataFormat.txt
% the additional variable measurement.numCylces contains the number of cycles of the measurement

function measurement = loadMeasurement(fileName)
    measurement = load(fileName);

    measurement.numCycles = length(measurement.timeSignals);
    %ensure that doubles are used.
    measurement.timeSignals = toDouble(measurement.timeSignals);
end

function timeSignals = toDouble(timeSignals)
    for t = 1:length(timeSignals)
        for k = 1:numel(timeSignals{t})
            timeSignals{t}{k} = double(timeSignals{t}{k});
        end
    end
end
