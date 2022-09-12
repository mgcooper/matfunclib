function [ list ] = getlist( path,pattern )
%GETLIST generates a list of files matching pattern in folder path

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   p                 = inputParser;
   p.FunctionName    = 'getlist';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   validpath         = @(x)validateattributes(x,{'char','string'},      ...
                        {'scalartext'},                                 ...
                        'getlist','path',1);
   validpattern      = @(x)validateattributes(x,{'char','string'},      ...
                        {'scalartext'},                                 ...
                        'getlist','pattern',2);

   addRequired(   p,'path',                        validpath            );
   addRequired(   p,'pattern',                     validpattern         );

   parse(p,path,pattern);
   
   path        = p.Results.path;
   pattern     = p.Results.pattern;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   
   
   if strcmp(path(end),'/') == false; path = [path '/']; end
   
   [pattern,pflag] = fixpattern(pattern);

   list = dir(fullfile([path pattern]));
   % list = list([list.isdir]); % activate if you only want folders
   list(strncmp({list.name}, '.', 1)) = []; 

   % if the pattern is **, only return directories
   if pflag==true
       list = list([list.isdir]);
   end
    
    
end

function [pattern,pflag] = fixpattern(pattern)
   
    pflag=false; % assume the pattern is for files, not directories
    
    % if the pattern is just the suffix e.g. 'tif' or 'mat', add *.
    if ~contains(pattern,'.') && ~contains(pattern,'*')
        pattern = ['*.' pattern];
    % if the pattern is **, don't adjust it
    elseif contains(pattern,'**')
        pflag=true;
        return
    % if the pattern has the * but no . add the .    (e.g. *mat)
    elseif contains(pattern,'*') && ~contains(pattern,'.')
       % if the pattern is just *, use it (e.g. to list all folders)
       if strcmp(pattern,'*')
          return;
       else
       % otherwise, add the . so we get all the fiels
         pattern = [pattern(1) '.' pattern(2:end)];
       end
    % if the pattern has the . but no * add the *   (e.g. .mat)
    elseif contains(pattern,'.') && ~contains(pattern,'*')
        pattern = ['*' pattern];
    end
end

