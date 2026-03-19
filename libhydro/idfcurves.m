function [curves, durations, periods] = idfcurves(data, kwargs)
   %IDFCURVES Generate Intensity-Duration-Frequency curves using Gumbel's method
   %
   %  [curves, durations, periods] = idfcurves(data, kwargs)
   %
   % Inputs:
   %
   %  DATA - A vector of precipitation (or similar) data (in any units) over time.
   %  DURATIONS - A vector of durations (in hours) for which IDF curves need
   %  to be calculated. Default is 1:24 for hourly data.
   %  PERIODS - A vector of return periods (in years) for the IDF analysis.
   %  TIME (optional) - A datetime vector matching the length of DATA.
   %
   % Outputs:
   %
   %  CURVES - Matrix of intensities (per hour), where each row corresponds to a return period
   %  and each column to a duration.
   %  DURATIONS - The durations used for the IDF curves (in hours).
   %  PERIODS - The return periods (in years).
   %
   % See also:

   arguments
      data double {mustBeVector, mustBeNonnegativeOrNan}
      kwargs.time {mustBeDateLike} = []
      kwargs.durations double {mustBeVector, mustBePositive} = 1:24
      kwargs.periods double {mustBeVector, mustBePositive} = [2, 5, 10, 25, 50, 100]
      kwargs.plot_curves (1, 1) logical = true
   end

   [time, durations, periods] = deal(kwargs.time, kwargs.durations, kwargs.periods);

   % Default timestep assumption (1 hour) if no time vector is provided
   if isempty(time)
      time_step = 1;
   else
      time_step = hours(diff(time(1:2)));
   end

   % Remove any durations that are shorter than the timestep
   keep = durations >= time_step;
   durations = durations(keep);

   if isempty(durations)
      error('No valid durations remain after filtering. All durations were shorter than the timestep.');
   end

   % Pre-allocate matrix for intensities
   N = length(durations);
   M = length(data) - round(max(durations) / time_step) + 1;
   intensity = zeros(M, N);

   % Compute moving sums of depth per duration, then convert to rate per hour
   for n = 1:N
      dur_hours = durations(n);
      dur_steps = max(round(dur_hours / time_step), 1);

      % Calculate the moving sum using the duration in steps
      depth = movsum(data, [dur_steps - 1, 0], 'omitnan');
      depth = depth(dur_steps:end);
      intensity(1:length(depth), n) = depth / dur_hours; % Convert to rate/hour
   end

   % Sort intensities in descending order for Gumbel analysis
   intensity = sort(intensity, 1, 'descend');

   % Calculate Gumbel parameters for each duration (c = scale, a = location)
   mu = mean(intensity, 1, 'omitnan');  % Mean of each duration column
   sd = std(intensity, 1, 'omitnan');   % Std deviation of each duration column
   c = (sqrt(6) / pi) * sd;             % Gumbel scale parameter
   a = mu - 0.577 * c;                  % Gumbel location parameter

   % Ensure no negative scale values, and use sensible limits
   c(c < 0) = 0;
   a = max(a, 0);

   % Generate IDF curves for different return periods
   curves = zeros(length(periods), N);

   for m = 1:length(periods)
      T = periods(m);
      z = -log(-log(1 - 1/T));  % Reduced variate for Gumbel distribution
      curves(m, :) = max(0, a + c * z);  % Clip to non-negative values
   end

   % Return outputs
   curves = max(curves, 0);  % Ensure non-negative values

   % Plot the IDF curves
   if kwargs.plot_curves
      idfcurveplot(durations, curves, periods)
   end

end

function mustBeNonnegativeOrNan(x)
   mustBeNonnegative(x(~isnan(x)));
end
