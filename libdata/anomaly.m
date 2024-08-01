function [anoms, norms, pctdif, pctanom] = anomaly(data, norms, timedim)
   %ANOMALY Compute climatological anomalies and normals of column-wise data
   %
   %  [anoms, norms, pctdif, pctanom] = anomaly(data, norms, timedim)
   %
   % Inputs
   %    DATA - A vector or array of data. If DIM is not provided, it is assumed
   %    that DATA is organized columnwise i.e. with time down the first
   %    dimension.
   %
   %    NORMS - A vector of "normals" - the reference period averages to be
   %    subtracted from DATA. If not supplied, the average over the time
   %    dimension is used to convert DATA to anomalies.
   %
   %    TIMEDIM - the time dimension along which normals are computed. The
   %    default value is DIM=1.
   %
   % Matt Cooper, 2022, https://github.com/mgcooper
   %
   % See also: gridanomaly

   % Parse inputs
   if ~ismatrix(data)
      error('input must be a vector or 2d array organized as columns of data')
   end

   if nargin < 3
      timedim = 1;
   end

   if timedim == 2
      data = transpose(data);
   end

   % Convert to columns and get the normals if not provided.
   if isvector(data)
      data = data(:);
   end

   if nargin < 2 || isempty(norms)
      norms = mean(data, 1, 'omitnan'); % take the average of each column
   end

   anoms = data - norms;
   ratio = anoms ./ norms;
   pctdif = 100 * ratio;
   pctanom = 100 + pctdif;
   % pctanom = 100 * data ./ normal;

   if timedim == 2
      [anoms, norms, pctdif, pctanom] = deal(anoms', norms', pctdif', pctanom');
   end
end
