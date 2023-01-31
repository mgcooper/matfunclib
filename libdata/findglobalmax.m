function [maxinds,maxvals,maxtimes] = findglobalmax(Data,k,position,iref,varargin)
%FINDGLOBALMAX find k global max values and indici(s) of the max value(s)
% 
% Syntax
% 
%  [maxinds,maxvals] = findglobalmax(Data,k,position,iref,varargin)
% 
% Description
% 
%  [maxinds,maxvals] = findglobalmax(Data) returns the max value in Data
%  and its index.
% 
%  [maxinds,maxvals] = findglobalmax(Data,k) returns the first k max values 
%  in Data and their indices. Default value is k = 1.
% 
%  [maxinds,maxvals] = findglobalmax(Data,[],'last') returns the last k max
%  values in Data and their indices. Default value is 'first'.
% 
%  [maxinds,maxvals] = findglobalmax(Data,k,[],iref) returns the first k
%  max values in Data and their indices relative to reference index iref.
%  Default value is iref = 1. maxinds are updated as maxinds + iref - 1.
% 
%  [maxinds,maxvals] = findglobalmax(Data,k,position,iref,varargin) returns
%  the `position` k max values in Data and their indices relative to
%  reference index iref with optional varargin arguments passed to the
%  'max' function. For example, max accepts a comparison object such as
%  max(A,B). In this case, use the syntax findglobalmax(A,k,pos,iref,B).
%  The largest elements in A or B are returned.
% 
% See also max, min, find, findlocalmax, findglobalmin, findlocalmin
% 
% Updates
% Jan 2023 replaced varargin and old input parsing with new one, added iref
% NOV 2022 RENAMED TO AVOID CONFLICT WITH BUILT IN OPTIM/PRIVATE

narginchk(2,5)
if nargin < 4, iref = 1; end
if nargin < 3, position = 'first'; end
if nargin < 2, k = 1; end

% % not sure I want to complicate this function but I was gonna try to support
% timetables and aggfunc would be the timestep so i could get the annual max.
% see alternative input parsing at end

% might want to use peakfinder ... also remember that this isn't a peak finding
% algo it finds the global max 

% maxinds = find(Data == max(Data,varargin{:}),k,position);
maxinds = peakfinder(Data,(max(Data)-min(Data))/100,-Inf,1,false);
% maxinds = peakfinder(Data,[],-Inf,1,false);

if isempty(maxinds); maxinds = nan; maxvals = nan; return; end

maxvals = max(Data(maxinds),varargin{:});
maxinds = find(Data == maxvals,k,position);

maxvals = Data(maxinds(:));

% figure; plot(1:numel(Data),Data,'o'); hold on;
% plot(maxinds,Data(maxinds),'o'); 

% add iref to maxinds. this supports cases where the data are passed in as
% subsets of a larger dataset and we want to add iref to maxinds so maxinds are
% relative to the start index of the larger dataset. assume that iref is the
% indice of the first value in Data relative to the unknown larger dataset,
% meaning we need to subtract 1, and default iref value is 1. 
maxinds = maxinds + iref - 1;



% if istimetable(Data) && nargin == 4
%    % here I was going to require 4 inputs and the fo
%    position = varargin{1};
%    aggfunc = varargin{2};
%    [ maxinds,maxvals,maxtimes ] = aggannualdata(Data,aggfunc);
% elseif istable(Data)
%    % regular table - unsupported but it may work to simply convert to array
%    Data = table2array(Data);
% end

% function aggData = aggannualdata(Data,aggfunc,aggvars)
% 
% allyears = unique(year(Data.Time));
% allvars = Data.Properties.VariableNames;
% 
% if nargin < 3
%    aggvars = allvars;
% end
% 
% ival = NaN(numel(allyears),numel(aggvars));
% tval = NaT(numel(allyears),numel(aggvars));
% val = NaN(numel(allyears),numel(aggvars));
% 
% for n = 1:numel(allyears)
% 
%    nyear = allyears(n);
%    idx = isbetween(Data.Time,datetime(nyear,1,1),datetime(nyear+1,1,1));
% 
%    for m = 1:numel(aggvars)
%       switch aggfunc
%          case 'min'
%             [ival(n,m),val(n,m)] = findglobalmin(Data.(aggvars{m})(idx));
%          case 'max'
%             [ival(n,m),val(n,m)] = findglobalmax(Data.(aggvars{m})(idx));
%       end
%       T = Data.Time(idx);
%       tval(n,m) = T(ival(n,m));
%    end
% end
% 
% aggData = ival;
