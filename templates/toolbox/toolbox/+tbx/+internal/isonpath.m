function yn = isonpath(dirs)
   % ISONPATH     Checks if given directory ison the current MATLAB path.
   %              Accepts cell-arrays of strings.
   %
   % y = ISONPATH(dirs) for string [dirs] checks whether the specified
   % directory is on the MATLAB search path. The output [y] is a logical
   % scalar equal to 'true' when the directory is on the path, 'false'
   % otherwise.
   %
   % In case [dirs] is a cell array of strings, the same check is
   % performed for each entry in [dirs]. In this case, the output [y] is
   % a logical array the same size as [dirs].
   %
   % See also path, pathtool, exist.


   % Please report bugs and inquiries to:
   %
   % Name       : Rody P.S. Oldenhuis
   % E-mail     : oldenhuis@gmail.com    (personal)
   %              oldenhuis@luxspace.lu  (professional)
   % Affiliation: LuxSpace sàrl
   % Licence    : BSD


   % Changelog
   %{
      2014/March/19 (Rody Oldenhuis)
      - NEW: first version
   %}


   % If you find this work useful and want to show your appreciation:
   % https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6G3S5UYM7HJ3N


   %% Initialize

   % Quick exit
   if nargin==0 || isempty(dirs)
      yn = []; return; end

   % Checks & conversions
   if ~iscell(dirs)
      dirs = {dirs}; end
   if ~iscellstr(dirs)
      throwAsCaller(MException(...
         'ispathdir:type_error',...
         'ISONPATH expects a string or a cell array of strings.'));
   end

   %% Do the work

   P  = regexp(path, ';', 'split');
   yn = false(size(dirs));
   for ii = 1:numel(dirs)
      if ispc % Windows is NOT case sensitive
         yn(ii) = ~isempty(dirs{ii}) && any(strcmpi(P,dirs{ii}));
      else % *nix IS case sensitive
         yn(ii) = ~isempty(dirs{ii}) && any(strcmp (P,dirs{ii}));
      end
   end

end

%% License

% Copyright (c) 2018, Rody Oldenhuis All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
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
%
% The views and conclusions contained in the software and documentation are
% those of the authors and should not be interpreted as representing official
% policies, either expressed or implied, of this project.

