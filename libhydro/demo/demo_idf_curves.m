clean

filepath = fullfile(getenv('MATLAB_FUNCTION_PATH'), 'libhydro', 'data');
filename = 'wh1996_2010m.xlsx';
filename = fullfile(filepath, filename);

data = readtable(filename);

precip = data.Rainfall_mm_;
time = data.DateTime_AST_;

% clean up the data
missing_values = [7777, 6999];
precip(ismember(precip, missing_values)) = nan;

%%
idfcurves(precip);

%% provide the timestep

idfcurves(precip, time=time);

%% interpolate to 15 minute and

% Define the 15-minute time vector
time_15m = time(1):hours(1)/4:time(end) + hours(1) - minutes(15);

% Interpolate precipitation data and divide by 4
precip_15 = interp1(time, precip, time_15m) ./ 4;

% Compute the idf curves
idfcurves(precip_15, time=time_15m);

ylim([0 0.7])

