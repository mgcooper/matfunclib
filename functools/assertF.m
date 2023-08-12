function assertF(condition, varargin)
%ASSERTF assert with function handle
% 
%  ASSERTF(condition,varargin)
% 
% This function allows condition calls with function handles so if persistent
% assertFlag is false, the condition is not tested. This enables increased
% performance if the condition takes a lot of CPU cycles but you no longer want
% to test the assert after fully debugging your code If the condition is not
% preceeded by a function handle then the condition will be evaluated before the
% stack moves into this function (and therefore ignores the persistent
% assertFlag and behaves like MATLAB's assert) 
% 
% For example this MATLAB assert call always evaluates the condition
% 
%  iCount = 10000000; 
%  tic; assert(sum(ones(1, iCount)) < iCount + 1); toc % ~0.02 seconds 
%  tic; assert(sum(ones(1, iCount)) < iCount + 0); toc % Assertion failed.
% 
% Whereas
% 
%  assertF(true, true); % If the 2nd input is a logical, it sets the persistent
%  assertFlag to determine if future "condition" calls to this function are
%  evaluated if condition is handle function 
%  
%  tic; assertF(sum(ones(1, iCount)) < iCount + 1); toc % ~0.02 seconds 
%  tic; assertF(@() sum(ones(1, iCount)) < iCount + 1); toc % ~0.02 seconds. 
% 
%  We place a function handle in front of the condition which has little to no
%  impact on the performance 
%   
%  assertF(true, false); % Set the persistent assertFlag to false (so it will
%  not check the condition if the condition has a function handle) 
%  
%  tic; assertF(sum(ones(1, iCount)) < iCount + 1); toc % ~0.02 seconds 
%  tic; assertF(sum(ones(1, iCount)) < iCount + 0); toc % Assertion failed
% 
%  Even though the persistent assertFlag is false, the condition is not
%  preceeded by a handle so it behaves like normal assert. This allows the user
%  to always call the assert independent of the persistent flag value 
% 
%  tic; assertF(@() sum(ones(1, iCount)) < iCount + 1); toc % ~0.000001 seconds
%  (and the condition (which is true) is not evaluated) 
%  tic; assertF(@() sum(ones(1, iCount)) < iCount + 0); toc % ~0.000001 seconds
%  (and the condition (which is false) is not evaluated - and would normally
%  throw an error)
%
%  The call also allows for all the normal settings for assert (errID, msg,
%  A1,...,An) 
% 
% assertF(true, true); % Set the flag to true so conditions are tested
% assertF(@() false, 'The assertF has a false value'); 
% Error using assertF The assertF has a false value
%
% assertF(@() false, 'CustomError:MyError', 'string error and two numbers
% %d:%d',1,2); 
% Error using assertF string error and two numbers 1:2 

persistent P_assertFlag

if (isempty(P_assertFlag))
   P_assertFlag = true;
end

if (nargin > 1 && islogical(varargin{1})) % Then assertFlag is present - so set it
   P_assertFlag = varargin{1};
   varargin = varargin(2:end);
end

% if condition is not a function handle then it has already been evaluated and
% we will behave like normal assert function if condition is a function handle
% then it has not been evaluated. Only evaluate if assertFlag == true
% condition() works for either a value or function handle, e.g. true == true()
if ( (P_assertFlag || ~isa(condition,'function_handle')) && ~condition()) 
   % Comment out next two lines if not desired. Helps to locate assert issue if
   % assert is caught by try/catch
   fprintf(1,'assertF(condition) == false (and either assertFlag is true or there is no function handle on condition)\n');
   dbstack(1); % show stack from code that made this call (why we use 1)
   assert(false,varargin{:}); % call the normal MATLAB assert with settings passed in
end

%% LICENSE
% Copyright (c) 2022, Dave Ober
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
% 
% * Neither the name of  nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
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
