
% This is all the functions in 
% /Applications/MATLAB_R2020b.app/toolbox/matlab/datatypes/tabular/+matlab/+internal/+tabular/+functionSignatures
% 
% Use these to generate choices={} in functionSignatures.json

% For Row Times:
% {"name":"RowTimes", "kind":"namevalue", "type":[["choices=matlab.internal.tabular.functionSignatures.varChoices(T)"], ["logical", "vector"], ["integer", ">=1", "scalar"], ["datetime", "vector"], ["duration", "vector"]]}

% For variable names:
% {"name":"vars", "kind":"required", "type":[["choices=matlab.internal.tabular.functionSignatures.varChoices(T)"], ["integer", ">=1"], ["@islogical"], ["pattern", "scalar"]]},

% For unit of time:
% {"name":"unitOfTime", "kind":"required", "type":["choices=matlab.internal.datatypes.functionSignatures.unitOfTimeChoices('yqmwdhms_plural')"]}

% In the function signatures, they use @ e.g.:
% {"name":"startPeriod", "kind":"required", "type":[["datetime","scalar"], ["char", "row", "@matlab.internal.datatypes.functionSignatures.couldBeDatetimeText"]]},

% Return to the file to see how the rest are used:
% /Applications/MATLAB_R2022b.app/toolbox/matlab/datatypes/tabular/resources/functionSignatures.json

function names = commonKeyChoices(t1,t2)
% Return a sorted list of common var names (and common row dim names if applicable) shared by two tables.

%   Copyright 2017-2020 The MathWorks, Inc.

% Return the common row dim name only if both tabulars have row labels: all
% timetables, but only some tables
t1SuggestRowDimName = isa(t1,'timetable') || ~isempty(t1.Properties.RowNames);
t2SuggestRowDimName = isa(t2,'timetable') || ~isempty(t2.Properties.RowNames);

if t1SuggestRowDimName
    t1Names = [t1.Properties.DimensionNames{1} t1.Properties.VariableNames];
else
    t1Names = t1.Properties.VariableNames;
end

if t2SuggestRowDimName
    t2Names = [t2.Properties.DimensionNames{1} t2.Properties.VariableNames];
else
    t2Names = t2.Properties.VariableNames;
end

% intersect sorts case-sensitively, return these sorted case-insensitively.
names = matlab.internal.datatypes.functionSignatures.sorti(intersect(t1Names, t2Names));

%%
function names = commonVarChoices(t1,t2)
% Return a sorted list of common var names shared by two tables.

%   Copyright 2020 The MathWorks, Inc.

t1Names = t1.Properties.VariableNames;
t2Names = t2.Properties.VariableNames;

% intersect sorts case-sensitively, return these sorted case-insensitively.
names = matlab.internal.datatypes.functionSignatures.sorti(intersect(t1Names, t2Names));

%%
function names = keyChoices(t)
% Return a sorted list of a table's var names (and row dim name if applicable).

%   Copyright 2017-2020 The MathWorks, Inc.

% Return the row dim name only if the tabular has row labels: all
% timetables, but only some tables
suggestRowDimName = isa(t,'timetable') || ~isempty(t.Properties.RowNames);
if suggestRowDimName
    names = [t.Properties.DimensionNames{1} t.Properties.VariableNames];
else
    names = t.Properties.VariableNames;
end

% Return these sorted case-insensitively.
names = matlab.internal.datatypes.functionSignatures.sorti(names);

%%
function names = keyChoicesDiff(t,vars,otherVars)
% Return a sorted list of a table's var names (and row dim name if applicable) NOT specified.

%   Copyright 2020 The MathWorks, Inc.

% Return the row dim name only if the tabular has row labels: all
% timetables, but only some tables
suggestRowDimName = isa(t,'timetable') || ~isempty(t.Properties.RowNames);
if suggestRowDimName
    names1 = [t.Properties.DimensionNames{1} t.Properties.VariableNames];
else
    names1 = t.Properties.VariableNames;
end

if nargin < 3
    names2 = t.Properties.VariableNames(vars);
else
    names2 = [t.Properties.VariableNames(vars) t.Properties.VariableNames(otherVars)];
end

% setdiff sorts case-sensitively, return these sorted case-insensitively.
names = matlab.internal.datatypes.functionSignatures.sorti(setdiff(names1,names2));

%%
function names = rowChoices(t)
% Return a sorted list of a table's row names, possibly empty.

%   Copyright 2020 The MathWorks, Inc.

% Return these sorted case-insensitively.
names = matlab.internal.datatypes.functionSignatures.sorti(t.Properties.RowNames);

%%
function method = synchronizeMethodChoices()
% A list of valid values for synchronize's and retime's method inputs

%   Copyright 2020 The MathWorks, Inc.

method = {'fillwithmissing','fillwithconstant','previous','next','nearest','linear','makima','spline','pchip','sum','mean','prod','min','max','count','firstvalue','lastvalue'};

%%
function names = varChoices(t,vars)
% Return a sorted list of a table's var names, or specified var names.

%   Copyright 2020 The MathWorks, Inc.

if nargin == 1
    names = t.Properties.VariableNames;
else
    names = t.Properties.VariableNames(vars);
end

% Return these sorted case-insensitively.
names = matlab.internal.datatypes.functionSignatures.sorti(names);

%%
function names = varChoicesDiff(t,vars)
% Return a sorted list of a table's var names NOT specified.

%   Copyright 2020 The MathWorks, Inc.

names1 = t.Properties.VariableNames;
names2 = t.Properties.VariableNames(vars);

% setdiff sorts case-sensitively, return these sorted case-insensitively.
names = matlab.internal.datatypes.functionSignatures.sorti(setdiff(names1,names2));
