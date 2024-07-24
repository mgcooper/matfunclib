function tbl = reordervars(tbl, orderednames, kwargs)
   %REORDERVARS Reorder variables in tabular object.
   %
   % Syntax
   %  TBL = REORDERVARS(TBL, ORDEREDNAMES)
   %  TBL = REORDERVARS(TBL, ORDEREDNAMES, keepMissingVars=false)
   %
   % Description
   %  TBL = REORDERVARS(TBL, ORDEREDNAMES) Reorders the variables (columns) of
   %  input table TBL by the order of ORDEREDNAMES.
   %  TBL = REORDERVARS(TBL, ORDEREDNAMES, keepMissingVars=false) Removes
   %  variables in input table TBL which are not present in ORDEREDNAMES.
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
   arguments(Input)
      tbl (:, :) tabular
      orderednames (1, :) string {mustBeText}
      kwargs.keepMissingVars (1, 1) logical {mustBeNumericOrLogical} = true
   end

   % MAIN CODE
   names = tbl.Properties.VariableNames;
   keepPositionNames = names(~ismember(names, orderednames)) ;
   movePositionNames = names( ismember(names, orderednames)) ;
   [~, newPositions] = ismember(orderednames, movePositionNames);
   movePositionNames = movePositionNames(newPositions);

   % At this time, non-common vars are moved to the end, not interleaved.
   if kwargs.keepMissingVars
      movePositionNames = [movePositionNames, keepPositionNames];
   end

   % Reorder the vars.
   tbl = tbl(:, [movePositionNames, keepPositionNames]);

   % CHECKS
   % assert()

   % PARSE OUTPUTS

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
