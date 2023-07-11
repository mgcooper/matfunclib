function varargout = aggannualdata(Data,aggfunc,aggvars)
%AGGANNUALDATA aggregate annual data
% 
%  [val, ival, tval] = aggannualdata(Data,aggfunc,aggvars) aggregates columns of
%  timetable DATA to annual values using aggregation function AGGFUNC and
%  returns the aggregated value VAL, index of the value IVAL, and time TVAL. 
% 
%  Example
%  
%  [val, ival, tval] = aggannualdata(Data,'min','Discharge') finds the minimum
%  value of Data.Discharge each year and returns the minimum value, annual
%  index, and annual date.
% 
% See also: 

% NOTE: isbetween and year(datetime) are very slow, so I need a
% faster way to index into the calendars for arbitrary timesteps

allvars = Data.Properties.VariableNames;
allyears = year(Data.Time);
uniqueyears = unique(allyears);

if nargin < 3
   aggvars = allvars;
end

ival = NaN(numel(uniqueyears),numel(aggvars));
tval = NaT(numel(uniqueyears),numel(aggvars));
val = NaN(numel(uniqueyears),numel(aggvars));

% test for speeding up the indexing
% Dates = datenum(Data.Time);


for n = 1:numel(uniqueyears)

   % don't do this - isbetween is very slow and inclusive of endpoints
   %idx = isbetween(Data.Time,datetime(nyear,1,1),datetime(nyear+1,1,1));
   
   % this fixes the endpoint inclusive issue but is even slower
   idx = allyears == uniqueyears(n);

   for m = 1:numel(aggvars)
      switch aggfunc
         case 'min'
            [ival(n,m),val(n,m)] = findglobalmin(Data.(aggvars{m})(idx));
         case 'max'
            [ival(n,m),val(n,m)] = findglobalmax(Data.(aggvars{m})(idx));
      end
      T = Data.Time(idx);
      tval(n,m) = T(ival(n,m));
   end
end

switch nargout
   case 1
      varargout{1} = val;
   case 2
      varargout{1} = val;
      varargout{2} = ival;
   case 3
      varargout{1} = val;
      varargout{2} = ival;
      varargout{3} = tval;
end

%%

% original plan:
% mkfunction('findannualmaxmin','library','libtable','parser','MIP')

% switch nargout
%    case 2
%       switch aggfunc
%          case 'max'
%             valfunc = @(x)max(x);
%             idxfunc = @(x)find(x==max(x),1);
%          case 'min'
%             valfunc = @(x)min(x);
%             idxfunc = @(x)find(x==min(x),1);
%       end
% 
%       val = table2array(retime(Data,'regular',valfunc,'TimeStep',calyears(1)));
%       ival = table2array(retime(Data,'regular',idxfunc,'TimeStep',calyears(1)));
%       JAN1 = find(ismember(Data.Time,datetime(unique(year(Data.Time)),1,1,0,0,0)));
%       tval = Data.Time(ival+JAN1);
% 
%    case 3
%       
% end
%%
% aggData = ival;

% for reference, here are two slick ways to get the annual max value and index,
% but I was not able to get the date wihtout resorting to the loops here. note
% that annualDates is actually the index of the annual max value, not the date

% % method 1) here annualDates is actually the index of the max value 
% annualPeaks = retime(Q,'regular',@(x)max(x),'TimeStep',calyears(1));
% annualDates = retime(Q,'regular',@(x)find(x==max(x),1),'TimeStep',calyears(1));
% annualPeaks = annualPeaks.Q;
% annualDates = annualDates.Q;

% % method 2)
% 
% imax=@(x) find(x==max(x),1);  % anonymous function for index to maximum in group
% 
% Q.Date = Q.Time;
% Q.Year = year(Q.Time);
% 
% test = varfun(imax,Q,'InputVariables',{'Q','Date'},'GroupingVariables','Year');


