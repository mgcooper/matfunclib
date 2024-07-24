function TT = totimetable(A, props)
   %TOTIMETABLE Convert table, array, or struct to a timetable.
   %
   %  T = TOTIMETABLE(rowTimes, var1, ..., varN)
   %  T = TOTIMETABLE(var1, ..., varN, 'RowTimes', rowTimes)
   %  T = TOTIMETABLE(var1, ..., varN, 'SampleRate', Fs)
   %  T = TOTIMETABLE(var1, ..., varN, 'TimeStep', dt)
   %  T = TOTIMETABLE(___, Name, Value)
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

   % I did not finish this but the point is to avoid the dumb timetable syntax
   % where you have to use array2timetable

   % PARSE INPUTS
   arguments(Input, Repeating)
      A
   end
   arguments(Input)
      props.?matlab.tabular.TimetableProperties
   end

   % If "RowTimes" is not populated in props, then one of A must be the
   % rowtimes, and it must match (one of) the dimension sizes of the others.

   % Todo:
   % array2timetable
   % table2timetable
   % timeseries2timetable

   % Confirm all inputs are tables or arrays but not a mixture
   if istable(A{1})
      assert(all(cellfun(@istable, A)))
   end
   if ismatrix(A{1})
      % assert(all(cellfun(@istable, A)))
   end

   TT = cellfun(@(a, props) processOneInput(a, props), A);


   % PARSE OUTPUTS
   nargoutchk(0, Inf)
   [varargout{1:nargout}] = dealout(TT{:});
end

function T = processOneInput(A, Time, props)

   switch class(A)
      case 'table'
         T = table2timetable(A, 'RowTimes', Time);

      otherwise
         % assume a numeric matrix for now
         T = array2timetable(A, 'RowTimes', Time);
   end
end

%% TESTS

%!test

% ## add octave tests here

%% Developer notes

%{

This is the documented timetable syntax.

TT = timetable(rowTimes,var1,...,varN)
TT = timetable(var1,...,varN,'RowTimes',rowTimes)
TT = timetable(var1,...,varN,'SampleRate',Fs)
TT = timetable(var1,...,varN,'TimeStep',dt)
TT = timetable('Size',sz,'VariableTypes',varTypes,'RowTimes',rowTimes)
TT = timetable('Size',sz,'VariableTypes',varTypes,'SampleRate',Fs)
TT = timetable('Size',sz,'VariableTypes',varTypes,'TimeStep',dt)
TT = timetable(___,Name,Value)

There is no need to support the initialization ones, and the first one
2-4 should be equivalent to "array2timetable".

%}

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
