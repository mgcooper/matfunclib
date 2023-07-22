function out = strrepi(str,old,new)
%STRREPI Performs a case-insensitive replacement of a substring within a string
%
%   OUT = STRREPI(STR,OLD,NEW) replaces all occurrences of the string OLD within
%   the string STR with the string NEW. The comparison is case-insensitive.
%   The function returns the result as the output OUT.
%
%   Inputs:
%   STR - a string or character array where replacements are to be made
%   OLD - the target string or character array to be replaced
%   NEW - the string or character array to replace OLD
%
%   Output:
%   OUT - the output string after replacements
%
%   Example:
%   strrepi('Hello World!', 'World', 'everyone') % returns 'Hello everyone!'
%
%   Note: If STR, OLD or NEW are not provided, the function uses default values.
% 
% See also: strrep, replace, strrepn, strrepin

if ~nargin
    str = 'Hello World!';
    old = 'World';
    new = 'everyone';
else
   narginchk(3,3)
end

ileft = strfind(lower(str),lower(old));

if isempty(ileft)
    out = str; % return the original string if no matches found

else
   iright = ileft + length(old) - 1;

   newCell = arrayfun(@(x,y) x+1:y-1,[0,iright(1:end)],[ileft,length(str)+1],'uni',0);
   strCell = cellfun(@(x) str(x), newCell, 'uni', 0);
   
   out = strjoin(strCell,new);
end

%% LICENSE
% 
% Copyright (c) 2019, raym
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% * Neither the name of  nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.