function ycoords = boxchartydata(data, varargin)
   %BOXCHARTYDATA Compute y coordinates of boxchart

   data = data(:);
   data = data(~isnan(data));
   N = numel(data);

   boxline = median(data, varargin{:});
   boxedge = [quantile(data, 0.25) quantile(data, 0.75)];
   iqrange = diff(boxedge);
   outliers = data(...
      data < boxedge(1) - 1.5 * iqrange   || ...   % lower outliers
      data > boxedge(2) + 1.5 * iqrange   ); ...   % upper outliers

   if isempty(outliers)
      whiskers = [min(data) max(data)];
   else
      whiskers = [min(outliers) max(outliers)];
   end

   notches = boxline + [-(1.57 * iqrange)/sqrt(N) (1.57 * iqrange)/sqrt(N)];

   ycoords.boxline = boxline;
   ycoords.boxedge = boxedge;
   ycoords.notches = notches;
   ycoords.iqrange = iqrange;
   ycoords.whiskers = whiskers;
   ycoords.outliers = outliers;
end
