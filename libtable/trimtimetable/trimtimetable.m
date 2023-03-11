function T = trimtimetable(T,t1,t2)
%TRIMTIMETABLE trim timetable to dates that span t1,t2 inclusive
%
%
% See also

% parse inputs
p = inputParser;
p.FunctionName = mfilename;
p.CaseSensitive = false;
p.KeepUnmatched = true;

validx = @(x)validateattributes(x,{'timetable'},{'nonempty'}, ...
   'trimtimetable','T',1);
validy = @(x)validateattributes(x,{'datetime'},{'nonempty'}, ...
   'trimtimetable','t1',2);
validz = @(x)validateattributes(x,{'datetime'},{'nonempty'}, ...
   'trimtimetable','t2',3);

addRequired( p,'T',  validx );
addRequired( p,'t1', validy );
addRequired( p,'t2', validz );

parse(p,T,t1,t2);

T = p.Results.T;
t1 = p.Results.t1;
t2 = p.Results.t2;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ok = isbetween(T.Time,t1,t2);
T = T(ok,:);


