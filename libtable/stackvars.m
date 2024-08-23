function varargout = stackvars(U, VariableNames, kwargs)
   %STACKVARS One line description of function.
   %
   % Syntax
   %  S = STACKVARS(U)
   %  S = STACKVARS(U, VariableNames)
   %  S = STACKVARS(_, 'ConstantVariables', ConstantVariables)
   %  S = STACKVARS(_, 'NewDataVariableName', NewDataVariableName)
   %  S = STACKVARS(_, 'IndexVariableName', IndexVariableName)
   %
   % Description
   %  S = STACKVARS(U) description.
   %  S = STACKVARS(U, VariableNames)
   %  S = STACKVARS(_, 'ConstantVariables', ConstantVariables)
   %  S = STACKVARS(_, 'NewDataVariableName', NewDataVariableName)
   %  S = STACKVARS(_, 'IndexVariableName', IndexVariableName)
   %
   % Examples
   %
   % Example table
   %    U = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'A', 'B'});
   %
   %    % Stack all variables by default
   %    S = stackvars(U);
   %
   %    % Stack all variables with custom name-value pairs
   %    S = stackvars(U, 'NewDataVariableNames', 'Data', 'IndexVariableName', 'Index');
   %
   %    % Stack a subset of variables
   %    S = stackvars(U, {'A'}, 'ConstantVariables', 'B');

   % Input Arguments
   %
   %   Use the following parameter name/value pairs to control how variables in
   %   U are converted to variables in S:
   %
   %      'ConstantVariables'   Variables in U to be copied to S without
   %                            stacking.  A positive integer, a vector of
   %                            positive integers, a variable name, a cell
   %                            array containing one or more variable names, a
   %                            logical vector, or a pattern scalar.  The
   %                            default is all variables in U not specified in
   %                            DATAVARS.
   %      'NewDataVariableName' A name for the data variable to be created in S.
   %                            The default is a concatenation of the names of the
   %                            M variables that are stacked up.
   %      'IndexVariableName'   A name for the new variable to be created in S
   %                            that indicates the source of each value in the new
   %                            data variable.  The default is based on the
   %                            'NewDataVariableName' parameter.
   %
   % Output Arguments
   %
   %    S - the stacked table
   %
   % Copyright (c) 2024, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also: stack splitvars mergevars

   arguments
      U tabular
      VariableNames = U.Properties.VariableNames
      kwargs.ConstantVariables (1, :) string = []
      kwargs.NewDataVariableNames (1, :) string = []
      kwargs.IndexVariableName (1, :) string = []
      kwargs.SortBy (1, :) string = []
   end
   if isempty(kwargs.SortBy)
      kwargs.SortBy = kwargs.IndexVariableName;
   end

   % Prepare name-value pairs for stack
   stackArgs = {};
   if ~isempty(kwargs.ConstantVariables)
      stackArgs = [stackArgs, {'ConstantVariables', kwargs.ConstantVariables}];
   end

   % Add optional name-value pairs if they are not empty
   if ~isempty(kwargs.NewDataVariableNames)
      stackArgs = [stackArgs, {'NewDataVariableName', kwargs.NewDataVariableNames}];
   end

   if ~isempty(kwargs.IndexVariableName)
      stackArgs = [stackArgs, {'IndexVariableName', kwargs.IndexVariableName}];
   end

   VariableNames = setdiff(VariableNames, kwargs.ConstantVariables);

   % Call stack with the prepared arguments
   S = stack(U, VariableNames, stackArgs{:});

   % Sort by IndexVariableName if SortIndex is true and IndexVariableName is provided
   if ~isempty(kwargs.SortBy)
      S = sortrows(S, kwargs.SortBy);
   end

   % Handle output arguments
   nargoutchk(0, 1)
   [varargout{1:nargout}] = deal(S);
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
