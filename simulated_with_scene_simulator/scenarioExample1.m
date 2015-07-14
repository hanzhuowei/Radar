function scenarioExample1( )
%SCENARIOEXAMPLE1 Example for use of scene simulator

  %% filename, just use the filename of this function
  fileName = mfilename();
  
 %% modulation parameters
    modulation.rampSlope         = [75 150 -75 -150] * 1e9;
    modulation.rampDuration      = [2 1 2 1] * 1e-3;
    modulation.rampNumSamp       = 2.^[9 9 9 9];
    modulation.rampMidTime       = [1 3.5 6 10] * 1e-3;
    modulation.rampMidFreq       = 76.5e9 * ones(1,4);
    
    %% time between one cycle and the next cycle
    sleepTime = 0.5;
            
    
  %% array parameters
    
    %maximum angle, for which the steering Vectors are computed (in rad)
    maxAng = pi/6; % corresponds to 30 degrees
    %difference between two adjacent angle values, for which steeringVectors 
    %are computed
    angPrecision = pi/720; % 0.25° precision 
    
    % at which angles to compute the steeringVectors
    angs = (-maxAng):angPrecision:maxAng;
    % position of the Rx Array elements in units of lambda (the carrier
    % wavelength)
    array = LinearSimulatedArray(0:0.5:3.5);
    
  %% target parameters
    targetParam(1).lateralDistance = 5;
    targetParam(1).longitudinalDistance = 40;
    targetParam(1).relLateralVelocity = 0;
    targetParam(1).relLongitudinalVelocity = 5;
    targetParam(1).RCS = 1e2;


  %% other simulation parameters
    overallSimulationTime = 2*25;
    
  
  %% execute the simulator
  sceneSimulator(angs, array, overallSimulationTime, modulation, sleepTime, targetParam, fileName);
end

