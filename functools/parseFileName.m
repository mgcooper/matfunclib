function filepath = parseFileName(pathname, filename, pathvarname, filevarname)
   %PARSEFILENAME Parse filename function input argument.
   %
   %  Syntax:
   %
   %    filepath = parseFileName(pathname, filename)
   %    filepath = parseFileName(pathname, filename, pathvarname)
   %    filepath = parseFileName(pathname, filename, pathvarname, filevarname)
   %
   %  Description:
   %
   %    FILEPATH = PARSEFILENAME(PATHNAME, FILENAME) Creates a fully-resolved
   %    FILEPATH from input parent path PATHNAME and file name FILENAME. If
   %    FILEPATH is not found by the ISFILE function, an error is thrown from
   %    the calling function.
   %
   %    FILEPATH = PARSEFILENAME(PATHNAME, FILENAME, PATHVARNAME) Checks if the
   %    environment variable PATHVARNAME exists and if not, alerts the user to
   %    this cause of the file not found error. PATHVARNAME is intended to be an
   %    environment variable which the user is expected to set and which points
   %    to the parent folder of FILENAME.
   %
   %    FILEPATH = PARSEFILENAME(PATHNAME, FILENAME, PATHVARNAME, FILEVARNAME)
   %    Checks if the environment variable FILEVARNAME exists and if not, alerts
   %    the user to this cause of the file not found error. FILEVARNAME is
   %    intended to be an environment variable which the user is expected to set
   %    and which points to the FILENAME.
   %
   %  Inputs:
   %
   %    PATHNAME - Scalar text representing the full path to the parent folder.
   %
   %    FILENAME - Scalar text representing the file name. Can be a full path.
   %
   %    PATHVARNAME - (optional) Scalar text representing the name of the
   %    environment variable used to set the PATHNAME value.
   %
   %    FILEVARNAME - (optional) Scalar text representing the name of the
   %    environment variable used to set the FILENAME value.
   %
   %  Outputs:
   %
   %    FILEPATH - Scalar text representing the fully resolved path to the file,
   %    constructed by appending PATHNAME and FILENAME using the fullpath
   %    function.
   %
   %  Examples:
   %
   %    If you don't want to use a pathname and a filename argument (maybe you
   %    prefer a single argument representing the full path), use fileparts:
   %
   %       filename = parseFileName(fileparts(filename), filename)
   %
   %  Note:
   %
   %    parseFileName uses throwAsCaller to throw exceptions. While the error
   %    message displayed by throwAsCaller does not include the line number of
   %    the error in the calling function, it does include the calling function
   %    name and is generally clearer than using the 'error' function directly
   %    in the calling function. parseFileName supports three possible error
   %    sources: parent path not found, file not found, or environment variable
   %    (which defines the parent path and/or file name) not set. The "addCause"
   %    method is used to alert the user which of these three error sources
   %    caused the error, thus printing the line number is generally not needed.
   %
   %  Todo:
   %    - Use name-value input for flexibility e.g., omit the varname arguments,
   %    add an "expectedExtension" argument, etc.
   %
   % See also:

   if nargin < 3
      pathvarname = [];
   end
   if nargin < 4
      filevarname = [];
   end

   filepath = fullfile(pathname, filename);
   if ~isfile(filepath)

      % Base exception - fileNotFound.
      eid = ['custom:' mfilename ':fileNotFound'];
      msg = sprintf('File not found: %s', filepath);
      mxc = MException(eid, msg);

      % Diagnose possible causes.
      mxc = diagnoseCauses(mxc, mfilename, ...
         pathname, filename, pathvarname, filevarname);

      % Throw the error from the calling function.
      throwAsCaller(mxc);
   end
end

function mxc = diagnoseCauses(mxc, mfilename, ...
      pathname, filename, pathvarname, filevarname)

   % Diagnose empty pathname or pathname not found.
   if isempty(pathname)

      eid = ['custom:' mfilename ':emptyFolderNameVariable'];
      msg = sprintf('Empty path name variable');

      % Add additional context if the environment variable is missing.
      if ~isempty(pathvarname) && isempty(getenv(pathvarname))
         msg = sprintf([msg ', possibly caused by unset environment ' ...
            'variable: %s'], pathvarname);
      end
      mxc = addCause(mxc, MException(eid, msg));

   elseif ~isfolder(pathname)
      eid = ['custom:' mfilename ':folderNotFound'];
      msg = sprintf('Folder not found: %s', pathname);
      mxc = addCause(mxc, MException(eid, msg));
   end

   % Diagnose empty filename or filename not found.
   if isempty(filename)

      eid = ['custom:' mfilename ':emptyFileNameVariable'];
      msg = sprintf('Empty file name variable');

      % Add additional context if the environment variable is missing.
      if ~isempty(filevarname) && isempty(getenv(filevarname))
         msg = sprintf([msg ', possibly caused by unset environment ' ...
            'variable: %s'], filevarname);
      end
      mxc = addCause(mxc, MException(eid, msg));

   elseif ~isfile(filename)
      eid = ['custom:' mfilename ':fileNotFound'];
      msg = sprintf('File does not exist or is not on path');
      mxc = addCause(mxc, MException(eid, msg));
   end
end
