% function array = LinearSimulatedArray(positions)
%
% LinearSimulatedArray(positions) constructs an array struct
% positions: vector with positions of the rx-antennas
% returns: array struct, with field positions
%
function array = LinearSimulatedArray(positions)
    assert(isnumeric(positions) && isvector(positions));
    array.positions = positions(:);
end