function varargout = aggannualdata(Data,aggfunc,aggvars)
%AGGANNUALDATA aggregate annual data
% 
%  varargout = aggannualdata(Data,aggfunc,aggvars)
% 
% See also: 

% originla plan:
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

allyears = unique(year(Data.Time));
allvars = Data.Properties.VariableNames;

if nargin < 3
   aggvars = allvars;
end

ival = NaN(numel(allyears),numel(aggvars));
tval = NaT(numel(allyears),numel(aggvars));
val = NaN(numel(allyears),numel(aggvars));

for n = 1:numel(allyears)

   nyear = allyears(n);
   idx = isbetween(Data.Time,datetime(nyear,1,1),datetime(nyear+1,1,1));

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

% aggData = ival;

% for reference, here are two slick ways to get the annual max value and indice,
% but I was not able to get the date wihtout resorting to the loops here

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


