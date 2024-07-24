function TT = struct2timetable(S, varargin)

   parser = inputParser();
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;

   defaultRowTimes = NaT;
   defaultVarNames = fieldnames(S);
   defaultVarUnits = {};
   defaultRowNames = {};

   validStruct = @(x) validateattributes(x,{'struct'},{'nonempty'}, ...
      'struct2timetable','S',1);
   validTime = @(x) validateattributes(x,{'datetime'},{'nonempty'}, ...
      'struct2timetable','RowTimes');
   validVarNames = @(x) validateattributes(x,{'cellstr','string'},{'nonempty'}, ...
      'struct2timetable','VariableNames');
   validVarUnits = @(x) validateattributes(x,{'cellstr','string'},{'nonempty'}, ...
      'struct2timetable','VariableUnits');
   validRowNames = @(x) validateattributes(x,{'cellstr','string'},{'nonempty'}, ...
      'struct2timetable','RowNames');

   parser.addRequired('S', validStruct);
   parser.addParameter('RowTimes', defaultRowTimes, validTime);
   parser.addParameter('VariableNames', defaultVarNames, validVarNames);
   parser.addParameter('VariableUnits', defaultVarUnits, validVarUnits);
   parser.addParameter('RowNames', defaultRowNames, validRowNames);
   parser.addParameter('AsArray', false, @islogicalscalar);

   parse(parser, S, varargin{:});

   S = parser.Results.S;
   RowTimes = parser.Results.RowTimes;
   VariableNames = parser.Results.VariableNames;
   VariableUnits = parser.Results.VariableUnits;
   RowNames = parser.Results.RowNames;
   AsArray = parser.Results.AsArray;

   T = struct2table(S,'AsArray',AsArray,'RowNames',RowNames);

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
