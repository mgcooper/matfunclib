function f = pauseSaveFig(filenamepath,savekey,pausekey,varargin)

   % this is when I tried to have an option to pause, but since this will
   % be used intentionally when i know i want to save, instead i think i
   % should only have an otion to save, and if savekey isn't entered, or if
   % it is, either way, we pause
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'pauseSaveFig';
   p.CaseSensitive   = true;

   % i was gonna try to detect existing figures and then write the figs as
   % figure1.png, figure2.png, and so on. for now it will overwrite as
   % figure 1.png.
 % existingfigs      = dir(fullfile('*.png'));
  
   defaultfilename   = [pwd '/figure1.png'];
   defaultfigres     = 300;
   defaultsavekey    = 's';
   defaultpausekey   = 'none'; % 'p';
   
   addOptional(   p,'filenamepath', defaultfilename,  @(x)ischar(x)     );
   addOptional(   p,'savekey',      defaultsavekey,   @(x)ischar(x)     );
   addOptional(   p,'pausekey',     defaultpausekey,  @(x)ischar(x)     );
   addParameter(  p,'Resolution',   defaultfigres,    @(x)isnumeric(x)  );
   
   parse(p,varargin{:});
   
   filenamepath   = p.Results.filenamepath;
   savekey        = p.Results.savekey;
   pausekey       = p.Results.pausekey;
   figres         = p.Results.Resolution;
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   if string(pausekey) == "none"
      msg   = ['press ' savekey ' to save the figure, '];
      msg   = [msg 'or any other key to continue'];
   else
      
      msg   = ['press ' savekey ' to save the figure,' pausekey];
      msg   = [msg ' to pause code, or any other key to continue'];
      
   end
   
   disp(msg);
   
   
   % convert the provided keys to ascii numbers
   savekey   = double(savekey);
   pausekey  = double(pausekey);
   
   ch = getkey();
   
   if ch==savekey
      exportgraphics(gcf,filenamepath,'Resolution',figres);
   end
   
   if string(pausekey) ~= "none"
      string(pausekey) == "none"
      pause;
   end


   
end