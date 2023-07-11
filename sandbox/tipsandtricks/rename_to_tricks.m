% decided not to do this ... instead functions will be tabletricks,
% mappingtricks, etc, and will open these ... for now

% UPDATE: they should all be functions and have the if nargin == 0 open
% mfilename

clean

dryrun = false;

list = getlist(pwd,'.m');

for n = 1:numel(list)
   
   filename = list(n).name;
   funcname = strrep(filename,'.m','');
   
   if strcmp(filename(end-5:end),'_fun.m') == true
      
      newfuncname = [filename(1:end-5) 'tricks'];
      newfilename = [filename(1:end-5) 'tricks.m'];

      % try this instead
      wholefile = readlines(filename);

      % make a function line, H1 line, and default open line
      firstline = ['function varargout = ' newfuncname '(varargin)'];
      secondline = ['%' upper(newfuncname) ' ' strrep(funcname,'_fun','') ' tips and tricks'];
      openline = [""; ...
         "% if called with no input, open this file"; ...
         "if nargin == 0; open(mfilename('fullpath')); return; end";...
         ""];
      nargchkline = ["% just in case this is called by accident"; ...
         "narginchk(0,0)"; ...
         ""; ...
         "%%"];
      
      % insert the function line, H1 line, and default open line
      wholefile = [firstline; secondline; openline; nargchkline; wholefile];

      % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      % REWRITE THE FILE (DANGER ZONE)
      % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if dryrun == false
         
         copyfile(fullfile(pwd,filename),fullfile(pwd,'temp',filename));

         fid = fopen(filename,'w'); % Open file to write
         for m = 1:size(wholefile,1)
            fprintf(fid,'%s\n',wholefile(m,:));
         end
         fclose(fid);

         % rename the file 
         system(['git mv ' filename ' ' newfilename]);

      end
   end
end

