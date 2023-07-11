function headers = readtableheaders(filepath,sheetnames,opts)
%READTABLEHEADERS read header line of spreadsheet files
% 
%  T = READTABLEHEADERS(T) description
%  T = READTABLEHEADERS(T,'flag1') description
%  T = READTABLEHEADERS(T,'flag2') description
%  T = READTABLEHEADERS(___,'options.name1',options.value1,'options.name2',options.value2) description
%        The default flag is 'plot'. 
% 
% Example
% 
% 
% Matt Cooper, 21-Mar-2023, https://github.com/mgcooper
% 
% See also

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------

% turned this off for now, it autocompletes the options but not the valid
% choices for the option and the optionsToNamedArgs doesnt work as intneded

% arguments
%    filepath { mustContainOnlyText(filepath) }
%    sheetnames { mustContainOnlyText(sheetnames) } = ""
%    
%    % access the built in options for autocomplete
%    opts.?matlab.io.ImportOptions
%    %opts.?matlab.io.VariableImportOptions
% end

% inputArg (dim1,dim2) ClassName {valfnc1,valfunc2} = defaultValue
% doc argument-validation-functions
% see argumentsTest folder for powerful examples of accessing built-in
% name-value options w/tab completion
%-------------------------------------------------------------------------------

% args = optionsToNamedArguments(opts);

if isempty(sheetnames)
   %opts = detectImportOptions(filepath,args(:));
   opts = detectImportOptions(filepath);
   headers = string(opts.VariableNames);
else
   for n = 1:numel(sheetnames)
      opts = detectImportOptions(filepath,'Sheet',sheetnames{n});
      if n == 1
         headers = string(opts.VariableNames);
      else
         headers = intersect(headers,string(opts.VariableNames));
      end
   end
end

end

% picked this up from addCodeTrace
function s = optionsToNamedArguments(options)
    names = string(fieldnames(options));
    s = strings(length(names),1);
    for k = 1:length(names)
        name = names(k);
        value = options.(name);
        if isstring(value) 
            s(k) = name + "=" + """" + value + """";
        elseif isnumeric(value) || islogical(value)
            s(k) = name + "=" + value;
        end
    end
    s = join(s,",");
end
