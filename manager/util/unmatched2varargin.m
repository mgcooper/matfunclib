function varargs = unmatched2varargin(unmatched)
%UNMATCHED2VARARGIN convert p.Unmatched to varargin format.
% 
% 
% See also parser2varargin

fields   = fieldnames(unmatched);
varargs  = {};
for n = 1:numel(fields)
   varargs{2*n-1}  = fields{n};
   varargs{2*n}    = unmatched.(fields{n});
end

% NOTE: I think this does exactly what namedargs2cell does.