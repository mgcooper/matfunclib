function pauseSaveFig(savekey,filename,obj,varargin)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   
   p                 = inputParser;
   p.FunctionName    = 'pauseSaveFig';
   p.CaseSensitive   = true;
   
   addRequired(   p,'savekey',               @(x)ischar(x)     );
   addRequired(   p,'filename',              @(x)ischar(x)     );
   addOptional(   p,'obj',             gcf,  @(x)isgraphics(x) );
   addParameter(  p,'Resolution',      300,  @(x)isnumeric(x)  );
   
   parse(p,savekey,filename,obj,varargin{:});
   
   filename    = p.Results.filename;
   savekey     = p.Results.savekey;
   obj         = p.Results.obj;
   figres      = p.Results.Resolution;
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   msg   = ['press ' savekey ' to save the figure, '];
   msg   = [msg 'or any other key to continue without saving'];
   
   disp(msg);
   
   
   % convert the provided keys to ascii numbers
   savekey   = double(savekey);
   
   ch = getkey();
   
   if ch==savekey
      exportgraphics(obj,filename,'Resolution',figres);
      disp('figure saved, press any key to continue');
      commandwindow
      pause; 
   else
      commandwindow
   end
   
end