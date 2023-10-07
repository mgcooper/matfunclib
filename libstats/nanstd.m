function y = nanstd(varargin)
   %NANSTD Compute the sample standard deviation, ignoring NaNs.
   %
   %
   % See also: STD, VAR, NANVAR, NANMEAN, NANMEDIAN
   y = sqrt(nanvar(varargin{:})); %#ok<NANVAR>
end
