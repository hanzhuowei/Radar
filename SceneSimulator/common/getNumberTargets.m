% function numberTargets = getNumberTargets(targets)
%
% targets: strcut with information of all targets
% returns: the number of targets contained in targets
function numberTargets = getNumberTargets(targets)
    numberTargets = size(targets.azi, 2);
end