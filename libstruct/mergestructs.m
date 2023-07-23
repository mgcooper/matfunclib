function S = mergestructs(S, T)
%MERGESTRUCTS Combines fields of both input structures into a single structure
% 
%   Output structure will contain all fields and their corresponding values of
%   the two input structures. If a field is present in both input structures,
%   the field in S is used, and a warning is produced. This warning can be
%   turned off using warning('off', "mergestructs:commonfield")
%
%   Example:
%   S.one = 1;
%   T.two = 2;
%   mergestructs(S,T)
%
%   ans =
%   struct with fields:
%     one: 1
%     two: 2
%
%   Inputs:
%   S       first structure to merge
%   T       second structure to merge
%
%   Output:
%   S       combination structure

arguments
   S(:,1) struct
   T(:,1) struct
end

% for octave compatibility
if ~isstruct(S) || ~isstruct(T)
    error('all inputs must be of type struct');
end

% try scalar merge, catch non-scalar
try
   S = mergescalarstructs(S,T);
catch ME
   if strcmp(ME.identifier,'MATLAB:scalarStrucRequired')
      try
         S = mergenonscalarstructs(S,T);
      catch ME
         rethrow(ME)
      end
   end
end


function S = mergescalarstructs(S,T)
f = fieldnames(T);
for n = 1:length(f)
   if checkfield(S, f{n})
      continue
   end
   S.(f{n}) = T.(f{n});
end

function S = mergenonscalarstructs(S,T)
f = fieldnames(T);
if numel(S) == numel(T) && ~isscalar(S)
   for n = 1:numel(f)
      try % num2cell converts arrays of any type to cell, so may not need try
         % not sure about num2cell vs {} vs mat2cell
         % C = num2cell([T.(f{n})]);
         C = {T.(f{n})};
         [S(:).(f{n})] = deal(C{:});
      catch
      end
   end
end

function tf = checkfield(S,f)
tf = isfield(S, f);
if tf
   warning("mergestructs:commonfield",...
      "Field '%s' exists in both structures.", f);
end
