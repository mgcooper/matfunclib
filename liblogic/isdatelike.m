function varargout = isdatelike(X, varargin)
   %ISDATELIKE return TRUE if X can be converted to a datetime array
   %
   %  [TF, DATETYPE] = ISDATELIKE(X) returns logical TF indicating if input X
   %  can be converted to a DATETIME object, and the inferred input date type
   %  DATETYPE which is the value of the 'ConvertFrom' property passed to
   %  DATETIME(X, 'CONVERTFROM', DATETYPE). If the conversion was not
   %  successful, then DATETYPE = 'none'.
   %
   %  [TF, DATETYPE] = ISDATELIKE(X, DATETYPE) uses the specified input date
   %  DATETYPE to try the conversion.
   %
   % Example
   %
   % [tf, datetype] = isdatelike(now)
   % tf =
   %   logical
   %    1
   % datetype =
   %     'datenum'
   %
   % [tf, datetype] = isdatelike(1, 'datenum')
   % tf =
   %   logical
   %    1
   % datetype =
   %     'datenum'
   %
   % [tf, datetype] = isdatelike(1, 'posixtime')
   % tf =
   %   logical
   %    1
   % datetype =
   %     'posixtime'
   %
   % [tf, datetype] = isdatelike(now, 'dum')
   % Error using isdatelike
   % Expected input number 2, datetype, to match one of these values:
   % 'datenum', 'excel', 'excel1904', 'juliandate', 'modifiedjuliandate', 'posixtime', 'yyyymmdd', 'ntp', 'ntfs', '.net',
   % 'tt2000', 'epochtime'
   %
   % See also:

   % PARSE INPUTS
   narginchk(1,2)

   % % fallback to false
   tf = false;
   notStructOrCell = false;
   try
      notStructOrCell = ~isstruct(X) && ~iscell(X);
   catch
   end

   notInfinite = false;
   try
      notInfinite = ~isinf(X);
   catch
   end

   if notStructOrCell && notInfinite

      try
         tf = isnat(X);
      catch
      end

      if tf
         whichtype = class(X);

      elseif isdatetime(X) || isduration(X) || iscalendarduration(X)
         % if the input is a datetime, timetable, or duration, return true
         tf = true;
         whichtype = class(X);

      elseif ismissing(X)
         % if the input is missing, return false (unless it is NaT)
         tf = false;

      else
         [~, tf, whichtype] = todatetime(X);
      end
   end

   if ~tf
      whichtype = 'none';
   end

   % PARSE OUTPUTS
   [varargout{1:max(1,nargout)}] = dealout(tf, whichtype);

end

%% TESTS

%!test

% ## add octave tests here

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper)
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