% Calculate FAO version of Penman-Monteith potential evapotranspiration
% Based on Allen et al. 1998, "Crop Evapotranspiration: Guidelines for Computing Crop Water Requirements", Ch. 2-4.
function [pet, Rn, Rs] = PET_priestley_taylor(tmax, tmin, tdmean, lat, alt, coast, years)

% INPUTS:
% tmax: average daily maximum temperature (deg C) [12 x number of years]
% tmin: average daily minimum temperature (deg C) [12 x number of years]
% lat: latitude (decimal degrees)
% alt: elevation above sea level (m)
% coast: 0 (not coast) or 1 (coast)

% For testing:
% load('C:\Users\Matthew\Documents\Publications\Dannenberg_et_al_TR-PNW-PPT\UpperColumbia_PRISM.mat');
% tmax = PRISM.Tmax';
% tmin = PRISM.Tmin';
% tdmean = tmin - randn(size(tmin));
% lat = 40;
% alt = 1000;
% years = 1895:2012;

% Number of years
nyrs = size(tmax, 2);

% Calculate atmospheric pressure
P = 101.3 * ((293-0.0065*alt)/293)^5.26;

% Psychometric constant (kPa / deg C)
gamma = 0.000665 * P;

% Mean temperature
tmean = (tmax + tmin)/2;

% Slope of saturation vapor pressure curve at T (using tmean) (kPa / deg C)
DELTA = 4098 * (0.6108 * exp(17.27*tmean ./ (tmean+237.3))) ./ (tmean+237.3).^2;

% Actual vapor pressure (kPA) and vapor pressure deficit (kPa)
ea = 0.6108 * exp(17.27 * tdmean ./ (tdmean + 237.3));

% Extraterrestrial radiation
phi = lat * pi/180;
J = 1:365;
dr = 1 + 0.033 * cos(2*pi*J/365);
delta = 0.409 * sin(2*pi*J/365 - 1.39);
omega = acos(-tan(phi)*tan(delta));
Ra_daily = (1440/pi)*0.0820*dr.*(omega.*sin(phi).*sin(delta) + cos(phi)*cos(delta).*sin(omega));
days_in_month = [31 28 31 30 31 30 31 31 30 31 30 31];
Ra = NaN(12,1);
for month = 1:12
    last_day = sum(days_in_month(1:month));
    first_day = last_day - days_in_month(month) + 1;
    Ra(month) = mean(Ra_daily(first_day:last_day));
end
Ra = repmat(Ra, 1, nyrs);

% Now for leap year...
J = 1:366;
dr = 1 + 0.033 * cos(2*pi*J/365);
delta = 0.409 * sin(2*pi*J/365 - 1.39);
omega = acos(-tan(phi)*tan(delta));
Ra_daily = (1440/pi)*0.0820*dr.*(omega.*sin(phi).*sin(delta) + cos(phi)*cos(delta).*sin(omega));
days_in_month = [31 29 31 30 31 30 31 31 30 31 30 31];
Ra_leap = NaN(12,1);
for month = 1:12
    last_day = sum(days_in_month(1:month));
    first_day = last_day - days_in_month(month) + 1;
    Ra_leap(month) = mean(Ra_daily(first_day:last_day));
end
idx = find(rem(years, 4) == 0);
Ra(:, idx) = repmat(Ra_leap, 1, length(idx));

% Incident solar radiation from mean daily temperature range (Allen et al.
% pp. 60-62)
if coast==1
    kRs = 0.19;
else
    kRs = 0.16; % Should be 0.19 for coastal regions
end
Rs = kRs * sqrt(tmax-tmin) .* Ra;

% Clear-sky solar radiation
Rso = (0.75 + 2*10^-5*alt) * Ra;

% Net shortwave radiation
alpha = 0.23; % Albedo (should probably find a way to vary this as a function of vegetation and season)
Rns = (1-alpha) * Rs;

% Net longwave radiation
sigma = 4.903 * 10^-9; % Stefan-Boltzman constant: MJ/K^4/m^2/day
Rnl = sigma * (((tmax+273.16).^4 + (tmin+273.16).^4)/2) .* (0.34-0.14*sqrt(ea)) .* (1.35 * (Rs ./ Rso) - 0.35);

% Net radiation
Rn = Rns - Rnl;

% Reference ET (Priestley-Taylor model)
pet = 0.408 * 1.26 * (DELTA./(DELTA+gamma)) .* Rn;

days_in_month = repmat([31 28 31 30 31 30 31 31 30 31 30 31]', 1, nyrs);
days_in_month(2, rem(years, 4) == 0) = 29;
pet = pet .* days_in_month;

end



