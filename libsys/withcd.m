function varargout = withcd(dir)
   %WITHCD Temporarily cd to a directory.
   %
   %  cleanupObj = WITHCD(dir)
   %
   %  Changes the working folder to DIR and returns it to the caller's original
   %  working folder when CLEANUPOBJ is released, on success and after an error.
   %  Release CLEANUPOBJ by letting it leave scope, or with clear. Do not
   %  release it with delete: Octave raises "can't perform indexing operations
   %  for onCleanup type".
   %
   %  DIR must be a character vector or a string scalar naming a folder this
   %  function can enter. Under MATLAB the arguments block below converts DIR
   %  to a string scalar before mustBeFolder runs. A 1-by-1 cell of text, or a
   %  number that names a folder, therefore also passes. Under Octave,
   %  inputParser accepts only a character vector or a string object.
   %
   % Based on Andrew Janke's code.
   %
   % Matt Cooper, 26-May-2023, https://github.com/mgcooper
   %
   % See also: withwarnoff

   arguments
      dir (1, 1) string {mustBeFolder}
   end

   % Octave parses the block above but does not run it, so check DIR with
   % inputParser there. Delete this block when Octave implements arguments
   % blocks. DIR must be text before char converts it: char(47) is '/'. The
   % char call stands in for the block's string conversion, because Octave's
   % isfolder rejects a string object from the datatypes package.
   if isoctave
      parser = inputParser;
      parser.FunctionName = mfilename;
      parser.addRequired('dir', @(d) (ischar(d) || isa(d, 'string')) ...
         && isrow(char(d)) && isfolder(char(d)));
      parser.parse(dir);
      dir = char(dir);
   end

   % Temporarily change to a new directory and create the cleanup object.
   originalDir = pwd;
   cleanupObj = onCleanup(@() restorefolder(originalDir));
   cd(dir);

   % Return the cleanup task if requested.
   if nargout > 0
      varargout{1} = cleanupObj;
   end
end

function restorefolder(originalDir)
   %RESTOREFOLDER Return to ORIGINALDIR, giving up when it fails.
   %
   % The caller's folder can be gone by the time the cleanup runs: a test
   % fixture removed, a checkout deleted, or the folder renamed while the body
   % ran. An error raised from an onCleanup destructor is not catchable at the
   % call site, so a failed restore must not propagate.
   try
      cd(originalDir);
   catch
      % Nothing to do: the caller's folder no longer accepts a cd, and raising
      % here would replace the caller's own result with this.
   end
end

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper) All rights reserved.
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
%    contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
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
