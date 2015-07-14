% function steeringVectors = getSteeringMatrix(array, angs)
%
% array: array struct with the position of the rx elements, can be
% constructed by LinearSimulatedArray(positions)
% angs: angles at which to compute the steeringVectors, in rad.
% returns: steeringVectors. A matrix with dimension 
% #channels of the array X length(angs)

function steeringVectors = getSteeringMatrix(array, angs)
    assert(nargin() == 2);
    assert(isnumeric(angs) && isvector(angs));
    angs = angs(:).';

    steeringVectors = exp(-2j * pi * array.positions(:) * sin(angs));
end