function Degrees = dmsToDegrees(dms)
%DMSTODEGREES general description of function
%
%  S = DMSTODEGREES(GEOM) description
%  S = DMSTODEGREES(GEOM,'flag') description
%  S = DMSTODEGREES(_,'opts.name1',opts.value1,'opts.name2',opts.value2)
%
% Example
%
%
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
%
% See also


% PARSE ARGUMENTS
arguments
   dms (:,:) {mustBeReal, mustHaveColumns(dms, 3)}
end

% MAIN CODE
dms(any(isinf(dms(:, 2:end)))) = nan;
for n = 1:3
   assert(none(dms(:, n)~=0 & any(dms(:, n+1:end) < 0, 2)), ...
      'matfunclib:dmsToDegrees:badMinutesOrSeconds', ...
      'bad minutes or seconds values');
end
check = notnan(dms(:, 1));
if none(check)
   Degrees = nan;
   return
end
assert(all(all(abs(dms(:, 2:3)) < 60)), ...
      'matfunclib:dmsToDegrees:badMinutesOrSeconds', ...
      'bad minutes or seconds values');
assert(all(abs(dms(check,1)-round(dms(check,1)))<= eps), ...
      'matfunclib:dmsToDegrees:badMinutesOrSeconds', ...
      'bad minutes or seconds values');

Degrees = (1-2*any(dms<0, 2)) .* (abs(dms(:,1)) + ...
   (abs(dms(:,2)) + abs(dms(:,3))/60)/60);

%% LOCAL FUNCTIONS

function mustHaveColumns(dms, numColumns)
% Test for number of columns
if ~isequal(size(dms, 2), numColumns)
   eid = 'matfunclib:dmsToDegrees:wrongNumberofColumns';
   msg = ['Input must have ',num2str(numColumns),' column(s).'];
   throwAsCaller(MException(eid,msg))
end

%% TESTS

%!test
%! 
%! ## Define test data
%! dms = [0, -30, 30; 30, 30, 30; 0, 30, 59];
%! expected = [0+ -30/60 + -30/3600; 30 + 30/60 + 30/3600; 0 + 30/60 + 59/3600];
%! 
%! ## Test function accuracy using assert
%! for n = 1:size(dms, 1)
%!    
%!    returned = dmsToDegrees(dms(n, :));
%!    assert(isequal(returned, expected(n)));
%!    
%!    % Test function accuracy using assert with tolerance
%!    tol = 20*eps;
%!    assert(abs(returned - expected(n)) < tol);
%! end
%! 
%! ## Test with edge cases (Inf, NaN, very large/small numbers)
%! assert(isnan(dmsToDegrees([NaN, NaN, NaN])));
%! assert(isnan(dmsToDegrees([Inf, Inf, Inf])));

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