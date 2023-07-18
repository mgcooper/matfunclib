function opts = test_optionparser(validopts, varargin)

% Could option parser be this simple?
varargs = varargin(cellfun(@ischar, convertStringsToChars(varargin)));
for arg = validopts(:).'
   opts.(arg{:}) = any(ismember(arg, varargs));
end

% tf = cellfun(@(arg) ismember(arg, validopts), varargs, 'un', 1);