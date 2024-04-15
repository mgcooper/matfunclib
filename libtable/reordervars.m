function T = reordervars(T, neworderVarnames, opts)
   %REORDERVARS One line description of function.
   %
   % Syntax
   %  T = REORDERVARS(T, NEWORDERVARNAMES)
   %  T = REORDERVARS(T, NEWORDERVARNAMES, keepMissingVars=false)
   %
   % Description
   %  T = REORDERVARS(T, NEWORDERVARNAMES) Reorders the variables (columns) of
   %  input table T by the order of NEWORDERVARNAMES.
   %  T = REORDERVARS(T, NEWORDERVARNAMES, keepMissingVars=false) Removes
   %  variables in input table T which are not present in NEWORDERVARNAMES.
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
   arguments (Input)
      T (:, :) tabular
      neworderVarnames (1, :) string {mustBeText}
      opts.keepMissingVars (1, 1) logical {mustBeNumericOrLogical} = true
   end

   % MAIN CODE
   varNames = T.Properties.VariableNames;
   keepPositionVarnames = varNames(~ismember(varNames, neworderVarnames));
   movePositionVarnames = varNames(ismember(varNames, neworderVarnames));
   [~, newPositions] = ismember(neworderVarnames, movePositionVarnames);
   movePositionVarnames = movePositionVarnames(newPositions);

   % At this time, non-common vars are moved to the end, not interleaved.
   if opts.keepMissingVars
      movePositionVarnames = [movePositionVarnames, keepPositionVarnames];
   end

   % Reorder the vars.
   T = T(:, [movePositionVarnames, keepPositionVarnames]);

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
