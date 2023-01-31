function TT = struct2timetable(Struct,varargin)
%------------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

defaultRowTimes   = NaT;
defaultVarNames   = fieldnames(Struct);
defaultVarUnits   = {};
defaultRowNames   = {};

validStruct    = @(x)validateattributes(x,{'struct'},{'nonempty'},            ...
   'struct2timetable','Struct',1);
validTime      = @(x)validateattributes(x,{'datetime'},{'nonempty'},          ...
   'struct2timetable','RowTimes');
validVarNames  = @(x)validateattributes(x,{'cellstr','string'},{'nonempty'},  ...
   'struct2timetable','VariableNames');
validVarUnits  = @(x)validateattributes(x,{'cellstr','string'},{'nonempty'},  ...
   'struct2timetable','VariableUnits');
validRowNames  = @(x)validateattributes(x,{'cellstr','string'},{'nonempty'},  ...
   'struct2timetable','RowNames');

addRequired(   p,'Struct',                         validStruct          );
addParameter(  p,'RowTimes',     defaultRowTimes,  validTime            );
addParameter(  p,'VariableNames',defaultVarNames,  validVarNames        );
addParameter(  p,'VariableUnits',defaultVarUnits,  validVarUnits        );
addParameter(  p,'RowNames',     defaultRowNames,  validRowNames        );
addParameter(  p,'AsArray',      false,            @(x)islogical(x)     );

parse(p,Struct,varargin{:});

Struct         = p.Results.Struct;
RowTimes       = p.Results.RowTimes;
VariableNames  = p.Results.VariableNames;
VariableUnits  = p.Results.VariableUnits;
RowNames       = p.Results.RowNames;
AsArray        = p.Results.AsArray;
%------------------------------------------------------------------------------

T  = struct2table(Struct,'AsArray',AsArray,'RowNames',RowNames);

% I think I can just let table2timetable handle this
if isnat(RowTimes)
   % RowTimes = findRowTimes(T);
   % TT = table2timetable(T,'RowTimes',RowTimes);
   TT = table2timetable(T);
else
   TT = table2timetable(T,'RowTimes',RowTimes);
end

if ~isequal(VariableNames,defaultVarNames)
   TT.Properties.VariableNames = VariableNames;
end

TT.Properties.VariableUnits = VariableUnits;
TT = renametimetabletimevar(TT);

end

% function RowTimes = findRowTimes(T)
%
% % this is borrowed from table2timetable. to implement, need getVars function
% % but could not find it. besides, better to just let table2timetable handle
% % this
%
% varnames = T.Properties.VariableNames;
% % Take the time vector as the first datetime/duration variable in the table.
% % If the table is n-by-p, the timetable will be n-by-(p-1).
% isTime = @(x) isa(x,'datetime') || isa(x,'duration');
% rowtimesCandidates = varfun(isTime,T,'OutputFormat','uniform');
% rowtimesIndex = find(rowtimesCandidates,1);
% if isempty(rowtimesIndex)
%   error(message('MATLAB:struct2timetable:NoTimeVarFound'));
% end
% rowsDimname = varnames{rowtimesIndex};
%
% vars = getVars(t,false);
% RowTimes = vars{rowtimesIndex};
% vars(rowtimesIndex) = [];
% varnames(rowtimesIndex) = [];
% t.(rowtimesIndex) = []; % remove it from the table, updating the metadata in the process.
%
% end
