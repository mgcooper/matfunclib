function S = catstructfields(dim, varargin)
%CATSTRUCTFIELDS concatenate two or more struct arrays with common field names
% 
% S = catstructfields(S1, S2) catenates structures S1 and S2 along dimension 1
% S = catstructfields(dim, S1, S2) catenates structures S1 and S2 along
% dimension DIM.
% 
% All fieldnames of S1 must be present in S2. If not, see CATSTRUCTS
% 
% See also: catstructs

if isstruct(dim) && all(cellfun(@isstruct, varargin))
   args = [{dim}, varargin];
   dim = 1;
end

F = cellfun(@fieldnames, args, 'uni', 0);
assert(isequal(F{:}),'All structures must have the same field names.')
T = [args{:}];
S = struct();
F = F{1};
for k = 1:numel(F)
   S.(F{k}) = cat(dim,T.(F{k}));
end