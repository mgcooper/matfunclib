function T = tablecleaner(T,varargin)
% TABLECLEANER clean table data
%
%  T = tablecleaner(T,varargin)
%
% See also

p           =  magicParser;

%    validtime   =  @(x)validateattributes(x,{'timetable','table','numeric'},       ...
%                   {'nonempty'},'tablecleaner','T',1);
%    validreg    =  @(x)validateattributes(x,{'logical'},                 ...
%                   {'nonempty'},'tablecleaner','regularize');
%    validnewt   =  @(x)validateattributes(x,{'datetime','duration'},     ...
%                   {'nonempty'},'tablecleaner','newtime');
%    validmethod =  @(x)validateattributes(x,{'char'},                    ...
%                   {'nonempty'},'tablecleaner','method');
%    validrow    =  @(x)validateattributes(x,{'char'},                    ...
%                   {'nonempty'},'tablecleaner','whichrow');
%
%
%    p.addRequired(    'T',                       validtime   );
%    p.addParameter(   'regularize',  false,      validreg    );
%    p.addParameter(   'newtime',     NaT,        validnewt   );
%    p.addParameter(   'method',      'linear',   validmethod );
%    p.addParameter(   'whichrow',    'first',    validrow    );

p.addRequired(    'T',                       @(x)istable(x)|istimetable(x));
p.addParameter(   'regularize',  false,      @(x)islogical(x));
p.addParameter(   'newtime',     NaT,        @(x)isdatetime(x)|isduration(x)|iscalendarduration(x));
p.addParameter(   'method',      'linear',   @(x)ischar(x));
p.addParameter(   'whichrow',    'first',    @(x)ischar(x));

% use first row as default when replacing duplicates

p.parseMagically('caller');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% make sure the time dimension is called 'Time'
T  = renametimetabletimevar(T);

% convert non-numeric values to categorical
T  = tablechars2categorical(T);

% set variable continuity (sets to default 'unset' value)
T  = settablevariablecontinuity(T);


% get some initial qa-qc informatoin
if istimetable(T)
   QA.isregular = isregular(T);
end
QA.issorted       = issorted(T);
QA.ismissing      = ismissing(T);
QA.nummissing     = sum(QA.ismissing);
QA.duplicates     = getduplicatetimes(T);
QA.numduplicates  = numel(QA.duplicates);

% clean
[T,QA] = cleantable(QA,T,whichrow,regularize,newtime,method);

% add the QA info to the table properties
T = addprop(T,{'QA'},{'table'});
T.Properties.CustomProperties.QA = QA;


function [T,QA] = cleantable(QA,T,whichrow,regularize,newtime,method)

% for retiming, I think I want to go in this order:
% 1. deal with duplicates
% 2. retime to a regular step, without filling missing gaps, meaning only
% values bracketed on either side by a valid value within the new timestep
% window are interpolated
% 3. fill misssing chunks

% Part 1: stuff we do regardless of retime

% remove missing entries
T     = sortrows(T,'Time');
ok    = ~ismissing(T.Time);
T     = T(ok,:);

% find unique times and unique timesteps
uniquetimes = unique(T.Time);

[dtcounts,  ...
   dtsteps ]   = groupcounts(diff(T.Time));
dtfreq      = dtcounts./(sum(dtcounts)+1);

% choose the most frequent timestep for retiming
mostfrequentstep     = dtsteps(findmax(dtfreq));

% save this information
QA.uniquetimes       = uniquetimes;
QA.dtcounts          = dtcounts;
QA.dtsteps           = dtsteps;
QA.dtfreq            = dtfreq;
QA.mostfrequentstep  = mostfrequentstep;
QA.retimehistory     = 'removed duplicate values with: retime(T,uniquetimes,''first'')';

% do a limited retime to remove duplicate values
switch whichrow
   case 'first'   % actual method is 'next' see retime documentation
      T = retime(T,uniquetimes);

   case 'last'    % actual method is 'previous' see retime documentation
      T = retime(T,uniquetimes,'previous');

   case 'mean'
      T = retime(T,uniquetimes,'mean');
end

% Part 2: stuff we do if we retime to a new timestep

if regularize == true

   if ~isduration(newtime) && isnat(newtime)

      % no new time/step provided, use most frequent one
      T  = interptimetable(T,mostfrequentstep,method);

      % warning if two unique timesteps occur with >40% frequency
      if sum(dtfreq>0.40) > 2
         QA.warning  = 'two unique timesteps occur with >40% frequency';
      end

   else  % either a new time or a new timestep was provided

      T  = interptimetable(T,newtime,method);

      % % this is the method before I wrote interptimetable, which does the
      % % datetime vs duration testing itself
      %          if isdatetime(newtime)     % a new time was provided
      %             T  = retime(T,newtime,'linear');
      %          elseif isduration(newtime) % a new time step was provided
      %             T  = retime(T,'regular','linear','TimeStep',newtime);
      %          end
      % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

      % NOTE: I think to use 'daily' syntax need:
      % T      = retime(T,'daily','linear');
      % so would need option to pass in duration or char

      % ALSO: might not be worth it to get all this fucntionality in
      % here b/c the retime method is also important e.g., 'linear' or
      % 'mean' (or 'sum' for some quantities)

   end

   newstep  = T.Properties.TimeStep;
   QA.newtimestep = newstep;

end

function dupes = getduplicatetimes(T)

dupes = sort(T.Time);
TF    = (diff(dupes) == 0);
dupes = dupes(TF);
dupes = unique(dupes);
