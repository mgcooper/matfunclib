function varargout = goto(tbname)
   %GOTO cd to toolbox folder
   %
   % Syntax
   %  MSG = GOTO(tbname)
   %
   % Description
   %  MSG = GOTO(tbname) Changes the current directory to the toolbox directory.
   %
   % Input Arguments
   %  tbname - char or string indicating the toolbox name
   %
   % Output Arguments
   %  none
   %
   % Copyright (c) 2024, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also: activate

   % PARSE ARGUMENTS
   arguments
      tbname (:, 1) string
   end


   % MAIN CODE
   % cleanup = onCleanup(@() cleanupfunc());

   % Retrieve the toolbox directory
   toolboxes = readtbdirectory(gettbdirectorypath);
   tbsrcpath = toolboxes.source{findtbentry(toolboxes, tbname)};

   % CHECKS
   assert(isfolder(tbsrcpath))
   
   % Go to the folder
   cd(tbsrcpath)

   % PARSE OUTPUTS
   % nargoutchk(0, Inf)
   % [varargout{1:nargout}] = dealout(argout1, argout2);
end

%% LOCAL FUNCTIONS
function cleanupfunc

end

%% TESTS

%!test

% ## add octave tests here

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) 2024, Matt Cooper (mgcooper) All rights reserved.
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
