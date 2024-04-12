function varargout = loadprojcrs(NAME)
   %LOADPROJCRS One line description of function.
   %
   % Syntax
   %  S = LOADPROJCRS(NAME)
   %  S = LOADPROJCRS(NAME, 'flag')
   %  S = LOADPROJCRS(_, 'opts.name1', opts.value1, 'opts.name2', opts.value2)
   %
   % Description
   %  S = LOADPROJCRS(NAME) description.
   %  S = LOADPROJCRS(NAME,'flag') description.
   %  S = LOADPROJCRS(_, 'opts.name1', opts.value1, 'opts.name2', opts.value2)
   %
   % Example
   %
   %
   % Input Arguments
   %
   %
   % Output Arguments
   %
   %
   % Copyright (c) 2024, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also:

   % PARSE ARGUMENTS
   arguments
      NAME (:, 1) string
   end

   % MAIN CODE
   switch lower(NAME)
      case 'ease-north'
         proj = projcrs(6931, 'Authority', 'EPSG');

      case 'ease-south'
         proj = projcrs(6932, 'Authority', 'EPSG');

      case 'ease-global'
         proj = projcrs(6933, 'Authority', 'EPSG');

      case {'sipsn', 'spsn'}
         proj = projcrs(3413, 'Authority', 'EPSG');

      case 'psn'
         proj = projcrs(102018, 'Authority', 'ESRI');

      case 'utm22n'
         proj = projcrs(32622, 'Authority', 'EPSG');

      case 'aka'
         proj = projcrs(3338, 'Authority', 'EPSG');

   end

   % PARSE OUTPUTS
   nargoutchk(0, Inf)
   [varargout{1:nargout}] = dealout(proj);
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
