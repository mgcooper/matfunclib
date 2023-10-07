function [ maxlim,minlim,roc,noc ] = getQApars( data )
   %GETQAPARS returns the max and min value, the max rate of change, and the
   %max number of timesteps with no change of a timeseries of data. These
   %values can be used for qa of meteorological timeseries
   %     INPUTS:     'data' a nx1 timeseries of data
   %
   %     OUTPUTS:    'max' the max value in the timeseries
   %                 'min' the min value in the timeseries
   %                 'roc' the maximum rate of change between two timesteps
   %                 'noc' the maximum number of timesteps with no change
   %
   %     These metrics are adapted from Meek and Hatfield (1994) "Data Quality
   %     Checking For Single Station Meteorological Databases" Agricultural
   %     and Forest Meteorology, Volume 69, 1994.
   %
   %     The assumption is that the data you provide is already quality
   %     controlled so it represents a reference station.
   %
   %       Author: Matt Cooper. 10/27/2014
   %
   % See also:

   % MAX and MIN limits
   maxlim = max(data);
   minlim = min(data);

   % ROC limits
   roci = NaN(size(data));
   roci(1) = 0;
   for n = 1:length(data)-1;
      roci(n+1) = data(n+1) - data(n);
   end

   roc = max(roci);

   % NOC limits. Use run length encoding function rle.m

   d_rle = rle(data);

   noc = max(d_rle{2});

   % Below is how I was going to do it initially
   % noci = NaN(size(data));
   % noci(1) = 0;
   % for n = 1:length(data)-1;
   %
   %     if data(n+1) == data(n)
   %         noci(n+1) = 1;
   %     else
   %         noci(n+1) = 0;
   %     end
   % end
end
