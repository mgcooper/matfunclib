function varargs = unmatched2varargin(S,varargin)
%UNMATCHED2VARARGIN convert p.Unmatched to varargin format
% 
% 
% See also parser2varargin, namedargs2cell
% 
% NOTE this does exactly what namedargs2cell does
% 
% TODO rename struct2namevalue or structexpand

opts = optionParser('asstring',varargin(:));

if opts.asstring == true
   varargs = reshape(transpose([string(fieldnames(S)), struct2cell(S)]),1,[]);
else
   varargs = reshape(transpose([fieldnames(S) struct2cell(S)]),1,[]);
end

% % another method, picked up from addCodeTrace
% names = string(fieldnames(S));
% varargs = strings(length(names),1);
% for n = 1:numel(names)
%    if isstring(S.(names(n)))
%       varargs(n) = names(n) + "=" + """" + S.(names(n)) + """";
%    elseif isnumeric(S.(names(n))) || islogical(S.(names(n)))
%       varargs(n) = names(n) + "=" + S.(names(n));
%    end
% end
% varargs = join(varargs,",");


% % old method:
% fields   = fieldnames(unmatched);
% varargs  = {};
% for n = 1:numel(fields)
%    varargs{2*n-1}  = fields{n};
%    varargs{2*n}    = unmatched.(fields{n});
% end


