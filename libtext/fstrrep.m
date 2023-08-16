function varargout = fstrrep(filename, oldstr, newstr, opts)
%FSTRREP Replace old string in file with new string and resave the file.
% 
%    STR = FSTRREP(FILENAME, OLDSTR, NEWSTR) replaces occurrences of OLDSTR
%    in the file specified by FILENAME with NEWSTR and saves the modified
%    content back to the file.
%    
%    STR = FSTRREP(FILENAME, OLDSTR, NEWSTR, 'dryrun', true) performs
%    the replacement but does not save the changes to the file. The modified
%    content is returned in STR. Default value is FALSE.
%    
%    STR = FSTRREP(_, 'backup', true) performs the replacement and creates a
%    backup of the original file. Default value is FALSE.
%    
%    Example:
%    FSTRREP('example.txt', 'old', 'new');
% 
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
% 
% See also: STRREP


   % PARSE ARGUMENTS
   arguments
      filename (1,:) char {mustBeFile(filename)}
      oldstr (1, :) char
      newstr (1, :) char
      opts.dryrun (1,1) logical = false
      opts.backup (1,1) logical = true
   end
   
   % MAIN CODE
   
   % Read in the file
   wholefile = readinfile(filename);
   
   % Back up the file if requested
   if opts.backup == true
      rewritefile(backupfilename(filename), wholefile, opts)
   end
   
   % Replace the string
   wholefile = strpat(wholefile, oldstr, newstr);
   
   % Rewrite the file
   rewritefile(filename, wholefile, opts)
   
   % PARSE OUTPUTS
    nargoutchk(0, 1)
    varargout{1} = wholefile;
end

%% LOCAL FUNCTIONS

function wholefile = readinfile(filename);
   %read in the file
   fid = fopen(filename, 'r');
   if fid == -1
      error('Failed to open file %s for reading', filename);
   end
   wholefile = fscanf(fid,'%c');
   status = fclose(fid);
   if status == -1
      warning('Failed to close file %s after reading', filename);
   end
end

function rewritefile(filename, wholefile, opts)
   %rewrite the file
   
   if opts.dryrun == true
      return
   end
   
   fid = fopen(filename, 'wt'); % confirm if 'wt' or 'w' should be used
   if fid == -1
      error('Failed to open file %s for writing', filename);
   end
   fprintf(fid,'%c',wholefile);
   status = fclose(fid);
   if status == -1
      warning('Failed to close file %s after writing', filename);
   end
end


%% TESTS

%!test

% ## add octave tests here

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) YYYY, Matt Cooper (mgcooper)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.