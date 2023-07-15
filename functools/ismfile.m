function [tf, onpath] = ismfile(filename, varargin)
%ISMFILE return true if filename has a .m or .p extension
%
%  TF = ISMFILE(FILENAME) returns TRUE if FILENAME has a .m or .p extension
%  [TF, ONPATH] = ISMFILE(FILENAME) also returns TRUE if FILENAME is on the path
% 
% Example
%
%  tf = ismfile('plot')
%
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also

% parse inputs
narginchk(1,Inf)
[varargin{:}] = convertStringsToChars(varargin{:});

% if (nargin<2) % set default ; end

%% main code

% Check which second to allow files off the path to be checked
tf = strncmp(reverse(filename), 'm.', 2) || ... 
   strncmp(reverse(which(filename)), 'm.', 2) || ...
   any(ismember(exist(filename), [5 6])); %#ok<EXIST> 
    
onpath = isfile(filename) || ~isempty(which(filename));


% parse outputs
% [varargout{1:max(1, nargout)}] = dealout(tf, onpath)

%% local functions


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