function T = settablevariablecontinuity(T,continuity)

% if we don't know a-priori, use 'unset'. If we knew which variables
% were continuous we could set here. Temperature would be 'continuous',
% precipitation would be 'step'

numvars  = width(T);

if nargin == 1
   continuity = cellstr(repmat('unset',numvars,1))';
end

if numel(continuity) ~= numvars
   error('need one value of continuity per variable')
end

T.Properties.VariableContinuity = continuity;