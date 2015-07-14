% function chann = getChann(array)
% this functions returns the number of channels of the array.
% 
% array: the array struct containing the positions of the elements, can be 
% constructed with LinearSimulatedArray
% returns chann: the number of channels of the array

function chann = getChann(array)
    chann = length(array.positions);
end