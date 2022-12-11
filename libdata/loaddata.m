function varargout = loaddata(datapath,filename,varargin)
%LOADMATFILE loads a matfile into the workspace
%
%
%
% See also loadgis

%-------------------------------------------------------------------------------
   p                 = inputParser;
   p.FunctionName    = 'loaddata';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   validpath         = @(x)validateattributes(x,{'char','string'},      ...
                        {'scalartext'},                                 ...
                        'loaddata','datapath',1);
   validfile         = @(x)validateattributes(x,{'char','string'},      ...
                        {'scalartext'},                                 ...
                        'loaddata','filename',2);
   validvars         = @(x)validateattributes(x,{'cell','char','string'});
   
   addRequired(   p,'datapath',                    validpath            );
   addRequired(   p,'filename',                    validfile            );
   addOptional(   p,'varnames',     'all',         validvars            );
   addOptional(   p,'newvarnames',  'none',        validvars            );
   addOptional(   p,'unpackstructs', false,        @(x)islogical(x)     );

   parse(p,datapath,filename,varargin{:});
   
   datapath          = p.Results.datapath;
   filename          = p.Results.filename;
   varnames          = p.Results.varnames;
   newvarnames       = p.Results.newvarnames;
   unpackstructs     = p.Results.unpackstructs;
   
%-------------------------------------------------------------------------------

   loadalldata    = string(varnames) == "all";
   renamevars     = string(newvarnames) == "false";
   

% first, either load all the variables (default) or the requested ones
   if loadalldata
      Data  = load([datapath,filename]);    % load all vars into workspace
   else
      if iscell(varnames)
         Data  = load([datapath,filename],varnames{:});
      else
         Data  = load([datapath,filename],varnames);
      end
   end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   
% these are needed in most of what follows
   varnames  = fieldnames(Data);

% if we don't want to unpack the structs or rename anything, two options:
% 1) send back Data, or 2) unpack it, in which case 'unpackstructs' means
% unpack structs that exist in 'Data' 

   if unpackstructs == false && renamevars == false
      
      % % option 1:
      % varargout{1} = Data; return;
      
      % option 2: (structs get sent back just like any other data)
      for n = 1:numel(varnames)
         assignin('base', varnames{n}, Data.(varnames{n}));
      end
      varargout{1}   = []; return;
      
   end
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% % if we want to unpack structs in data, it gets more complicated, but we
% % need to move the unpack statement above into a function and call it
% % afaik, there are two options: use assignin, and a dummy varargout, in
% % which case the variables are loaded into the base with their names, and
% % what's needed beyond here is sorting out the case where one var is a
% % struct and we don't want to unpack it. the second option is eval, in
% % which case we need to know ahead of time how many vars to use in the
% % calling statement, b/c even though eval in here gets them all into
% % varargout, the number of elements in varargout must match the number in
% % the calling statement
% 
% % note that this can be continued from above as an 'else' but I separated
% % it to make it easier to write
% 
% % if one (or all) of the variables are structs, this will unpack them
% 
%    if unpackstructs
%       
% % if there are no structs, we can simply assignin
%       varnames  = fieldnames(Data);
%    
%    % first determine how many of the variables are structs
%       [~,numstructs] = findstructvars(Data);
%  
%    % the disadvantage here is that in the base we have to write [~] = load...
%       if numstructs == 0
% 
%          for n = 1:numel(varnames)
%             assignin('base', varnames{n}, Data.(varnames{n}));
%          end
%          varargout{1}   = [];
%          return;
% 
% % % % this is one (ugly) way to do it - replaces above statemetn
% %          for n = 1:numel(varnames)
% %             eval(sprintf('varargout{%d} = Data.(varnames{%d});',n,n));
% %          end
% %          return;
% 
%       else  % unpack the structs
%          
%          varnames  = fieldnames(Data);
% 
%          % first determine how many of the variables are structs
%          [tfisstruct,numstructs,idxstructs] = findstructvars(Data);
% 
%       
%       end
%       
%       
%    end
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % this was one attempt, i think it is the best one

% % if one (or all) of the variables are structs, this will unpack them
% 
%    if unpackstructs
%       
%       varnames  = fieldnames(Data);
% 
%       % first determine how many of the variables are structs
%       [tfisstruct,numstructs,idxstructs] = findstructvars(Data);
% 
%       for n = 1:numstructs
% 
%          thisfield   = varnames{idxstructs(n)};
%          thisstruct  = Data.(thisfield);
%          
%          % test unpacking a struct 
%          tf = findstructvars(thisstruct);
%          
%          if tf
%             vars   = fieldnames(thisstruct);
%             
%             for m = 1:numel(vars)
%                thisvar  = vars{m};
%                assignin('base',thisvar,thisstruct.(thisvar));
%                
%             end
%          end
%          
% %          thisfield   = varnames{idxstructs(n)};
% %          thisstruct  = Data.(thisfield);
% % 
% %          assignin('base',thisfield,thisstruct);
%          
%          
%       end
%    end
%    

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % pick bakc up here on the renaming

% % now, rename the vriables if requested
% 
% %    if string(newvarnames) == "none"
% %       
% %       return;
% %       
% %    else  % rename them
% %       
% %       oldvarnames = fieldnames(Data);
% %       
% %       if numel(oldvarnames) ~= numel(newvarnames)
% %          
% %          error('numel(oldvarnames) does not match numel(newvarnames)');
% %          
% %       end
% %       
% %       Data  = renamestructfields(Data,oldvarnames,newvarnames);
% %    end
%    
%    % test structvars and assignin
%    
%    % if one of the vars is already a struct, we don't want to unpack it,
%    % but structvars won't be able to determine 
%    
%    % the variable names are now the fieldnames 
%    
% 
%    
% %       if isst
% %    
% %       
% %       if isstruct(thisstruct)
% %          
% %       end
% %    end
% %       
% % %    % unpack the struct vars
% %    for n = 1:numel(vars)
% %       
% %       if 
% %       
% %       thisvar  = data.(vars{n});
%       
%       % if thisvar is a struct array, then we need to unpack it
%    
% %    vars  = structvars(data);
% %    structvars(data)
% %    
% %    
% %    test = structvars(data.data)
% % 
% %    test = string(test);
% % 
% %    for n = 1:numel(test)
% % 
% %       varout   = strsplit(test(n)
% %       assignin(
% % 
% %    end


end

function [tfisstruct,numstructs,idxstructs] = findstructvars(data)
   
   if ~isstruct(data)
      tfisstruct = false; numstructs = 0; idxstructs = [];
      return
   end
   
   varnames    = fieldnames(data);
   numvars     = numel(varnames);
   tfisstruct = false(numvars,1);
   
   for n = 1:numvars
      if isstruct(data.(varnames{n}))
         tfisstruct    = true;
      end
   end
   
   numstructs  = sum(tfisstruct);
   idxstructs  = find(tfisstruct);
   
end
%       
%       
%       
% %    
% %       
% %       for n = 1:numel(oldvarnames)
% %          
% %          if iscell(newvarnames)
% %             
% %             data  = renamestructfields
% %             for m = 1:numel(newvarnames)
% %                
% %                data.(newvarnames{m})  = 
% %          
% %       end
% %       
% %    end
%    
%    
%    




% % keeping this temporarily 
%    if unpackstructs == false && renamevars == false
%       
%       % % option 1:
%       % varargout{1} = Data; return;
%       
%       % option 2:
%       [~,numstructs] = findstructvars(Data);
%       
%       if numstructs == 0
%          
%          for n = 1:numel(varnames)
%             assignin('base', varnames{n}, Data.(varnames{n}));
%          end
%          varargout{1}   = [];
%          return;
%          
%       end
%    
%    end