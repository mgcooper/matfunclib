%% demo dealout

%#ok<*NOPTS>
%#ok<*ASGLU>

% Case definitions:
%    case 1
%       varargout = dealout(arg1, arg2, arg3);
%    case 2
%       varargout = dealout({arg1, arg2, arg3});
%    case 3
%       varargout = dealout(arg1);
%    case 4
%       [varargout{1:nargout}] = dealout(arg1, arg2, arg3);
%    case 5
%       [varargout{1:nargout}] = dealout({arg1, arg2, arg3});
%    case 6
%       [varargout{1:nargout}] = dealout(arg1);

% Fail definitions

% error, varargout{2} not assigned:
% Output argument "varargout{2}" (and possibly others) not assigned a value

% error, varargout must be cell
% Variable output array "varargout" must be a cell array.



% fail, arg1=1:
% arg1 = 1 not {[1]}

% works (but warn):
% works as intended but issues my custom warning about scalar cell array

% error, success
% outputs exceed inputs

%% dealout

% 1 varargout = dealout(arg1, arg2, arg3)

% Note: second two should fail because even though 2 and 3 outputs are requested
% here, in the calling function varargout is on the lhs so nargout=1 in dealout.

call_dealout(1)                 % pass, fail, arg1=1
arg1 = call_dealout(1)                 % pass, fail, arg1=1
[arg1, arg2] = call_dealout(1)         % error, success, varargout{2} not assigned
[arg1, arg2, arg3] = call_dealout(1)   % error, success, varargout{2} not assigned

% 2 varargout = dealout({arg1, arg2, arg3})

% Here errors are fails because nargout=1 and {arg1, arg2, arg3} is scalar, the
% fail occurrs b/c of the args{:} expansion.

call_dealout(2)                 % pass, fail, arg1=1 (and warn)
arg1 = call_dealout(2)                 % pass, fail, arg1=1 (and warn)
[arg1, arg2] = call_dealout(2)         % error, fail, varargout{2} not assigned (and warn)
[arg1, arg2, arg3] = call_dealout(2)   % error, fail, varargout{2} not assigned (and warn)

% 3 varargout = dealout(arg1)

% The first fail is ambiguous, arg1 is a cell array at the close of dealout, but
% in call_dealout its assigned to varargout and for some reason is expanded to
% 1. So I think in dealout I'd need to package it into another cell array, which
% might work in general for the special case nargin=1, nargout=1, and varargout
% is a scalar.

% Note: The first one also fails w/dealout2 so I think this is an unadvoidable
% failure and reflects the fundamental behavior of varargout. Since varargout is
% a scalar cell array comprised of one element, a scalar double, it returns that
% scalar double. If [varargout{1:nargout}] is used, it packages that cell into
% another cell element due to curly braces.

% The second two you would think should fail b/c two outputs are requested here
% but only one input is sent to dealout, but since only one is sent they fail
% due to the same reason. BUT THIS IS MISLEADING b/c in reality, it makes no
% sense to have a function which a user could request >1 outputs but only one
% would be sent to dealout, so ignore the second two.

arg1 = call_dealout(3)                 % error, fail, varargout must be cell
[arg1, arg2] = call_dealout(3)         % error, n/a
[arg1, arg2, arg3] = call_dealout(3)   % error, n/a

% 4 [varargout{1:nargout}] = dealout(arg1, arg2, arg3)

% These should all pass and do

arg1 = call_dealout(4)                 % pass, success
[arg1, arg2] = call_dealout(4)         % pass, success
[arg1, arg2, arg3] = call_dealout(4)   % pass, success

% 5 [varargout{1:nargout}] = dealout({arg1, arg2, arg3})

% These should all pass and do

arg1 = call_dealout(5)                 % pass, success (but warn)
[arg1, arg2] = call_dealout(5)         % pass, success (but warn)
[arg1, arg2, arg3] = call_dealout(5)   % pass, success (but warn)

% 6 [varargout{1:nargout}] = dealout(arg1)

% The two errors on this one do so with or without my custom error

arg1 = call_dealout(6)                 % pass, fail, arg1 = 1 (and warn)
[arg1, arg2] = call_dealout(6)         % error, success, outputs exceed inputs
[arg1, arg2, arg3] = call_dealout(6)   % error, success, outputs exceed inputs

%% dealout without args{:}

% 1 varargout = dealout(arg1, arg2, arg3) (SAME AS w/ args{:})

% Note: second two should fail because even though 2 and 3 outputs are requested
% here, in the calling function varargout is on the lhs so nargout=1 in dealout.

arg1 = call_dealout(1)                 % pass, fail, arg1=1
[arg1, arg2] = call_dealout(1)         % error, success, varargout{2} not assigned
[arg1, arg2, arg3] = call_dealout(1)   % error, success, varargout{2} not assigned

% 2 varargout = dealout({arg1, arg2, arg3})

% Here errors are fails because nargout=1 and {arg1, arg2, arg3} is scalar, the
% fail occurrs b/c of the args{:} expansion.

arg1 = call_dealout(2)                 % pass, success (warn)
[arg1, arg2] = call_dealout(2)         % pass, success (warn)
[arg1, arg2, arg3] = call_dealout(2)   % pass, success (warn)

% 3 varargout = dealout(arg1)

arg1 = call_dealout(3)                 % error, fail, varargout must be cell
[arg1, arg2] = call_dealout(3)         % error, n/a
[arg1, arg2, arg3] = call_dealout(3)   % error, n/a

% 4 [varargout{1:nargout}] = dealout(arg1, arg2, arg3)

% These should all pass and do

arg1 = call_dealout(4)                 % pass, success
[arg1, arg2] = call_dealout(4)         % pass, success
[arg1, arg2, arg3] = call_dealout(4)   % pass, success

% 5 [varargout{1:nargout}] = dealout({arg1, arg2, arg3})

% These should all pass but fail. The second two are somewhat ambiguous but not
% as much as the varargout case, here [varargout{1:nargout}] is used, so
% requested nargout is known. NOTE THIS IS THE CASE THAT CAN BE FIXED EITHER BY
% EXPANDING ARGS{:} EARLY OR IN THE CATCH.

arg1 = call_dealout(5)                 % pass, fail, arg1={arg1,arg2,arg3}
[arg1, arg2] = call_dealout(5)         % error, fail (outputs exceed inputs)
[arg1, arg2, arg3] = call_dealout(5)   % error, fail (outputs exceed inputs)

% 6 [varargout{1:nargout}] = dealout(arg1)

% The two errors on this one do so with or without my custom error. Note: these
% are also success since more outputs were requested than inputs, but they're
% n/a in the sense this would never be done in practice, it's just to understand
% the behavior. The only case where this shouldn't fail is if arg1 is a cell
% array of cell arrays (or objects), then it would pass in teh expansion step.

arg1 = call_dealout(6)                 % pass, success (but warn)
[arg1, arg2] = call_dealout(6)         % error, n/a
[arg1, arg2, arg3] = call_dealout(6)   % error, n/a


%% dealout2

% 1 varargout = dealout2(arg1, arg2, arg3) (SAME AS w/ args{:})

% Note: second two should fail because even though 2 and 3 outputs are requested
% here, in the calling function varargout is on the lhs so nargout=1 in dealout.

call_dealout2(1)                % pass, fail, arg1=1
arg1 = call_dealout2(1)                % pass, fail, arg1=1
[arg1, arg2] = call_dealout2(1)        % error, success, varargout{2} not assigned
[arg1, arg2, arg3] = call_dealout2(1)  % error, success, varargout{2} not assigned

% 2 varargout = dealout2({arg1, arg2, arg3})

% THIS IS THE ONE THAT WORKED AND WAS CONFUSING WHY IT DIDN'T WORK W/NEW VERSION
% IT WORKS B/C OF THE CATCH ARGS{:}

call_dealout2(2)                % pass, success
arg1 = call_dealout2(2)                % pass, success
[arg1, arg2] = call_dealout2(2)        % pass, success
[arg1, arg2, arg3] = call_dealout2(2)  % pass, success

% 3 varargout = dealout2(arg1)

call_dealout2(3)                 % pass, fail, arg1=1
arg1 = call_dealout2(3)                 % pass, fail, arg1=1
[arg1, arg2] = call_dealout2(3)         % error, success, n/a
[arg1, arg2, arg3] = call_dealout2(3)   % error, success, n/a

% 4 [varargout{1:nargout}] = dealout2(arg1, arg2, arg3)

% These should all pass and do

call_dealout2(4)                 % pass, success
arg1 = call_dealout2(4)                 % pass, success
[arg1, arg2] = call_dealout2(4)         % pass, success
[arg1, arg2, arg3] = call_dealout2(4)   % pass, success

% 5 [varargout{1:nargout}] = dealout2({arg1, arg2, arg3})

% NOTE THIS IS THE CASE THAT IS FIXED BY CATCH ARGS{:} BUT NOT EXPANDING EARLY

% The reason arg1 fails is because it DOESN'T FAIL in the try step, because
% nargin=nargout. THe other ones fail in the try because nargout>nargin.

call_dealout2(5)                 % pass, success
arg1 = call_dealout2(5)                 % pass, fail, arg1={arg1,arg2,arg3}
[arg1, arg2] = call_dealout2(5)         % pass, success
[arg1, arg2, arg3] = call_dealout2(5)   % pass, success

% 6 [varargout{1:nargout}] = dealout2(arg1)

% The two errors on this one do so with or without my custom error. Note: these
% are also success since more outputs were requested than inputs, but they're
% n/a in the sense this would never be done in practice, it's just to understand
% the behavior. The only case where this shouldn't fail is if arg1 is a cell
% array of cell arrays (or objects), then it would pass in the expansion step,
% which is what case 5 tests

call_dealout2(6)                 % pass, success
arg1 = call_dealout2(6)                 % pass, success
[arg1, arg2] = call_dealout2(6)         % error, success, n/a
[arg1, arg2, arg3] = call_dealout2(6)   % error, success, n/a


