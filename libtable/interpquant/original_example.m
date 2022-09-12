clean

% Fake temperature measurement
v        =  rand(1,60); 

 % Time samples with dropouts, e.g. t=11,12
tdata        =  [1:10 21:30 41:50 61:70 81:90 101:110];

% Time step varies slightly between measurements so add a little noise
t   =  tdata + rand(1,length(tdata))/100; 

% Time step if there were no dropouts
timestep =  median(diff(tdata)); 

% Time vector without dropouts
tq       =  min(t):timestep:max(t); 

% No NaNs, so dropouts are filled with 'fake' data
vq       =  interp1(t,v,tq); 

% How to replace fake data with NaNs if xi value is more than timeStep away from any value in t?
plot(tq,vq, 'b.', t,v, 'co'); % Show fake data between actual sample time


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % answer

clean
% Data (with t starting at -5 to demonstrate generality)
v        =  rand(1,60); % Fake temperature measurement

% Time samples with dropouts, e.g. t=11,12
tdata    =  [-5:4 21:30 41:50 61:70 81:90 101:110]; 

% Time step varies slightly between measurements so add a little noise
t        =  tdata + rand(1,length(tdata))/100; 

% Time step if there were no dropouts
timestep =  median(diff(tdata)); 

% quantise tNoise
t1       =  t(1);                    % starting time
tcount   =  round((t-t1)/timestep);  % time in units of timeStep
tindex   =  tcount + 1;                   % index of these times in array of regular times
tquant   =  t1 + timestep * tcount;       % time to nearest timeStep

% interpolate for these points only (need extrapolation for first or last)
vquant   =  interp1(t, v, tquant, 'linear', 'extrap');

% evenly spaced times for whole sequence
tq       =  linspace(tquant(1), tquant(end), tindex(end));

% output array of x values
vq       =  nan(1, tindex(end));

vq(tindex)  =  vquant;

% plot
plot(tq,vq, 'bx', t,v, 'co'); % Show fake data between actual sample time





