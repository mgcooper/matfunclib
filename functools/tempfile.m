function filename = tempfile(varargin)
   %TEMPFILE Get a temporary file name, or full path to temporary file name
   %
   %  FILENAME = TEMPFILE()
   %  FILENAME = TEMPFILE('FULLPATH')
   %  FILENAME = TEMPFILE(FILEPATH)
   %  FILENAME = TEMPFILE(FILEPATH,'FULLPATH'))
   %
   % See also: tempname

   % this way supports a full tempdir/tempname path, or a user-provided
   % filepath/tempname path, or just tempname

   if nargin == 0 || ( nargin == 1 && strcmp(varargin{1},'fullpath') )
      if nargin == 0
         % FILENAME = TEMPFILE()
         [~,filename] = fileparts(tempname);
      else
         % FILENAME = TEMPFILE('FULLPATH')
         filename = tempname;
      end

      return

   elseif nargin == 1 || ( nargin == 2 && strcmp(varargin{2},'fullpath') )
      % FILENAME = TEMPFILE(FILEPATH)
      % FILENAME = TEMPFILE(FILEPATH,'FULLPATH'))

      % confirm the calling syntax
      if isfolder(varargin{1})
         filepath = varargin{1};
      else
         error('unsupported input') % todo: validation
      end

      % get a temp file name
      [~,filename] = fileparts(tempname);

      % make the full file
      filename = fullfile(filepath,filename);

   end
end

% % simplest method
% function filename = tempfile(filepath)
%
% [~,filename] = fileparts(tempname);
% if nargin == 0
%    % return
% elseif nargin == 1
%    filename = fullfile(filepath,filename);
% end

% % This way could be useful
% function filename = tempfile(filepath,varargin)
% [~,filename] = fileparts(tempname);
% if nargin == 1
%    % return
% elseif nargin == 2
%    if strcmp(varargin{1},'fullpath')
%       filename = fullfile(filepath,filename);
%    end
% end
