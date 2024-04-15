function varargout = timespan(timeLikeObject,varargin)
   %TIMESPAN return time span of timetable, datetime, or duration object T
   %
   % Syntax
   %
   %  tspan = TIMESPAN(T) returns the time spanned by dates found in T. T can be
   %  any date-like object, such as a datetime vector, timetable, or vector of
   %  datenums or datestr's. If T is a struct or cell array, the function
   %  returns the timespan of the first date-like object contained within the
   %  array, or an empty array if none are found.
   %
   %  NOTE: only timetables and datetimes are currently supported
   %
   % Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
   %
   % See also:

   % input parsing
   narginchk(1,1)

   withwarnoff('MATFUNCLIB:libtime:convertToDatetimeFailed');

   % main function
   tf = istimetable(timeLikeObject) || isdatetime(timeLikeObject);
   if ~tf
      % try to convert
      [timeLikeObject, tf] = todatetime(timeLikeObject);
   end

   if tf
      [tspan, tzone] = gettimespan(timeLikeObject);

   elseif isstruct(timeLikeObject)
      % search for a datetime or timetable in timeLikeObject

      if isscalar(timeLikeObject)
         tf = structfun(@(s) isdatetime(s) || istimetable(s), timeLikeObject);
      else
         tf = arrayfun(@(s) isdatetime(s) || istimetable(s), timeLikeObject);
      end

      % obtain the time span of all time-like objects in the struct
      if any(tf)
         structFields = fieldnames(timeLikeObject);
         structFields = structFields(tf);
         tspan = NaT(numel(structFields), 2);
         for n = 1:numel(structFields)
            [tspan_, tzone] = gettimespan([timeLikeObject(:).(structFields{n})]);
            tspan(n, :) = tspan_;
         end
      end

   elseif iscell(timeLikeObject)
      tf = cellfun(@(c) isdatetime(c) || istimetable(c), timeLikeObject);

      if any(tf)
         [tspan, tzone] = gettimespan(timeLikeObject{tf});
      end

   else
      error( ...
         'Expected input, T, to be a timetable, datetime, or otherwise time-like')
   end

   % Add the timezone - For now this assumes all found dates have the same zone
   tspan.TimeZone = tzone;

   % Return output
   switch nargout
      case 0
         varargout{1} = tspan;
      case 1
         varargout{1} = tspan;
      case 2
         varargout{1} = tspan(1);
         varargout{2} = tspan(2);
      otherwise
         nargoutchk(1, 2)
   end
end

%% LOCAL FUNCTIONS

function [tspan, tzone] = gettimespan(T)

   if istimetable(T)
      T = settimetabletimevar(T);
      Time = T.Time;

   elseif isdatetime(T)
      Time = T;
   end
   tspan = [Time(1) Time(end)];
   tzone = Time(1).TimeZone;

   % Remove the timezone so NaT can be populated, otherwise "cannot combine a
   % datetime array ... " error . This should be fixed up later.
   tspan.TimeZone = '';
end

%% TESTS

%!test

% ## add octave tests here

%% LICENSE

% BSD 3-Clause License
%
% Copyright (c) 2024, Matt Cooper (mgcooper)
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
