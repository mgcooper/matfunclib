function G = snowCorrection(G, timeG, S, timeS, varargin)
   %SNOWCORRECTION Correct grace storage trends for surface snow storage
   %
   %    G = grace.snowCorrection(G, timeG, SWE, timeSWE)
   %    G = grace.snowCorrection(G, timeG, SWE, timeSWE, bymonth=true)
   %    G = grace.snowCorrection(G, timeG, SWE, timeSWE, makeplot=true)
   %
   %  Description
   %
   %    G = grace.snowCorrection(G, TIME_G, S, TIME_S) 'bias corrects' GRACE
   %    terrestrial water storage anomalies G on a monthly basis for trends in
   %    snow water equivalent SWE. Snow anomalies are computed on a monthly
   %    basis by subtracting the average SWE value during the GRACE reference
   %    period (2004-2009) from the SWE data. These SWE anomalies are then
   %    subtracted from the monthly grace anomalies.
   %
   %    G = grace.snowCorrection(_, BYMONTH=TRUE) computes anomalies by month,
   %    e.g., all values for each respective month are collected, one month at a
   %    time, and their mean value (TODO: linear trend) subtracted to compute
   %    anomalies, then those anomalies are subtracted from the corresponding
   %    grace anomalies for each respective month.
   %
   %  Inputs
   %
   %    G - monthly timeseries of Grace terrestrial water storage anomalies [cm]
   %    TIMEG - Monthly datetime calendar for G
   %    S - Monthly timeseries of snow water equivalent [cm]
   %    TIMES - Monthly datetime calendar for S
   %
   %  Outputs
   %
   %    G - monthly timeseries of Grace terrestrial water storage anomalies with
   %    the SWE anomaly subtracted [cm]
   %
   % See also: annualMinMax

   % Parse inputs.
   [G, timeG, S, timeS, bymonth, makeplot] = parseinputs( ...
      G, timeG, S, timeS, mfilename, varargin{:});

   % Get indices that are nan in the original data.
   inan = isnan(G);

   % Ensure grace storage and SWE data are anomalies.
   G = grace.storage2anomaly(G, timeG);
   S = grace.storage2anomaly(S, timeS);

   if makeplot
      inputG = G;
   end

   % This computes anomalies on a month-by-month basis.
   if bymonth

      for imonth = 1:12
         monthIndices = timeG.Month == imonth;
         G(monthIndices) = anomaly(G(monthIndices)) - anomaly(S(monthIndices));

         % This is the original method, but if SWE anomalies are computed
         % by month, then Storage anomalies should be too.
         % G(monthIndices) = G(monthIndices) - anomaly(S(monthIndices));
      end
   else
      % Compute anomalies relative to the entire period:
      G = G - S;
   end

   G = setnan(G, [], inan);

   if makeplot
      trendplot(timeG, inputG, 'leg', 'no correction');
      trendplot(timeG, G, 'use', gca, 'leg', 'with correction');
   end
end

%%
function [G, timeG, SWE, timeSWE, bymonth, makeplot] = parseinputs( ...
      G, timeG, SWE, timeSWE, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.PartialMatching = true;

   parser.addRequired('G', @isnumericvector);
   parser.addRequired('timeG', @isdatetime);
   parser.addRequired('SWE', @isnumericvector);
   parser.addRequired('timeSWE', @isdatetime);
   parser.addParameter('bymonth', false, @islogicalscalar);
   parser.addParameter('makeplot', false, @islogicalscalar);
   parser.parse(G, timeG, SWE, timeSWE, varargin{:});

   bymonth = parser.Results.bymonth;
   makeplot = parser.Results.makeplot;

   t1 = dateshift(timeG(1), 'start', 'month');
   t2 = dateshift(timeG(end), 'end', 'month');
   keep = isbetween(timeSWE, t1, t2);
   [timeSWE, SWE] = deal(timeSWE(keep), SWE(keep));
   assert(numel(SWE) == numel(G))
end
