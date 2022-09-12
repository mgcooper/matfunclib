function T = interpquant(t,v,timestep)

% https://www.mathworks.com/matlabcentral/answers/232423-how-to-interpolate-and-leave-nans-if-long-gaps

% say the majority of timesteps in the raw data are 15 minut, but there are
% a bunch of 30 minute steps, and then some much bigger gaps like months,
% and we want to interpolate the 15 minute data to 30 minute, built-in
% retime will interpolate across the big gaps. The method below is a way to
% build a 30 minute calendar, interpolate onto it, and then only keep the
% values that had data to begin with.

% But, if the new timestep is the shortest one i.e. 15 min in the example
% above, there will be gaps that shouldn't be there, like if the og data
% was posted at 00:22, 00:52, 01:22, 01:52, and so on, and then later in
% teh timeseries the data is posted at 00:05, 00:20, 00:35, and so on, and
% then we resample to a regular 00:15, 00:30, 00:45, the values for the
% 00:22, ..., set won't have new values every fifteen minutes.

% The reason is becuase of tcount/tindex ... they will go like 1,3,5, ...
% such that tquant won't exactly have timestep spacing. 
% I think I could work with tquant prior to interp1 call use runlength type
% methods to find the jumps and make it regular, but for now i think 
   
% the method to build a regular calendar w missing data

t1       =  t(1);                      % starting time
tcount   =  round((t-t1)/timestep);    % time in units of timeStep
tindex   =  tcount + 1;                % index of these times in array of regular times
tquant   =  t1 + timestep * tcount;    % time to nearest timeStep
t2       =  tquant(end);               % last time
numsteps =  tindex(end);

% interpolate for these points only (need extrapolation for first or last)
vquant   =  interp1(t,v,tquant,'linear','extrap');

% evenly spaced times for whole sequence
% tq       =  linspace(tquant(1), tquant(end), tindex(end));
% vq       =  nan(1, tindex(end));

tq       =  linspace(t1,t2,numsteps);
vq       =  nan(1,numsteps);           % output array of x values

vq(tindex)  =  vquant; 
vq          =  vq(:); 
tq          =  tq(:);

T           =  timetable(vq,'RowTimes',tq);