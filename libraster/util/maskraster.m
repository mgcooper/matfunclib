function [Z, mask, info] = maskraster(Z, mask, kwargs)
   %MASKRASTER Apply mask to raster
   %
   % Function to mask a 3D matrix based on specified conditions.
   %
   % Inputs:
   %   Z - 3D numeric matrix with dimensions corresponding to lat x lon x time
   %   mask - Initial mask to apply (optional)
   %   kwargs - Struct with fields:
   %       MaskType - Choice of masking method: 'stdv' or 'nodata'
   %       sigmaThreshold - Threshold for standard deviation masking
   %       noDataValue - Value to use for 'nodata' masking
   %
   % Outputs:
   %   Z - Masked data matrix with extreme or specified values set to NaN
   %   mask - Logical matrix indicating the locations of removed values
   %   info - Table containing statistics on the number and percentage of masked
   %   pixels
   %
   % See also: plotraster

   arguments (Input)
      Z (:, :, :) {mustBeNumericOrLogical}

      mask {mustBeImplicitlyExpandable(mask, Z)} = false(size(Z))

      kwargs.MaskType (1, :) string { ...
         mustBeMember(kwargs.MaskType, ["stdv", "nodata"]) ...
         } ...
         = "stdv"

      % Not implemented
      % kwargs.dim (1, 1) { ...
      %    mustBeInteger, ...
      %    mustBeInRange(kwargs.dim, 1, 3)...
      %    }

      kwargs.sigmaThreshold {mustBeNumeric, mustBeScalarOrEmpty} = 3
      kwargs.noDataValue = -9999
      
      kwargs.invertMask = false
   end

   % If mask is not provided or all true/false, compute the requested mask type
   if all(~mask(:)) || all(mask(:))
      mask = computeMask(Z, kwargs.MaskType, kwargs);
   end

   % Validate the mask is the same size as Z or can be expanded to the third dim
   assert(ndims(mask) == ndims(Z) || ndims(mask) == ndims(Z) - 1, ...
      'Mask dimensions must match data dimensions or be 2D for 3D data');

   % If the mask is 2d and the data is 3d, apply it to all pages of dim 3
   if ndims(mask) == ndims(Z) - 1
      mask = repmat(mask, 1, 1, size(Z, 3));
   end

   % Apply the mask by setting masked values to NaN
   if kwargs.invertMask
      Z(mask) = NaN; % assume logical true means drop
   else
      Z(~mask) = NaN; % assume logical true means keep
   end

   % Calculate statistics
   totalPixels = numel(Z(:));
   numMasked = sum(mask(:));
   percentMasked = 100 * numMasked / totalPixels;

   % Prepare the stats table
   info = table(numMasked, percentMasked, ...
      'VariableNames', {'NumberMasked', 'PercentMasked'});
end

function mask = computeMask(Z, MaskType, kwargs)
   switch MaskType
      case "stdv"
         mask = computeStdvMask(Z, kwargs.sigmaThreshold);
      case "nodata"
         mask = computeNodataMask(Z, kwargs.noDataValue);
      otherwise
         error('Unrecognized mask option')
   end
end

function mask = computeStdvMask(Z, sigmaThreshold)

   % Calculate the mean across the third dimension (time)
   mu = nanmean(Z, 3);

   % Global mean and standard deviation
   mu_global = nanmean(mu(:));
   sd_global = nanstd(mu(:));

   % Create the mask based on the sigma threshold
   mask = abs(mu - mu_global) < sigmaThreshold * sd_global;
end

function mask = computeNodataMask(Z, noDataValue)
   % Mask wherever noDataValue occurs
   mask = ~any(Z == noDataValue, 3);
end

% function Z = applyMask(Z, mask, pageApplyFlag)
%
%    % This would be added back to main or computed here:
%    % pageApplyFlag = ndims(mask) == ndims(Z) - 1;
%
%    % Flatten data for easy indexing and set masked values to NaN
%    [numrows, numcols] = size(Z, [1, 2]);
%    Z = reshape(Z, numrows * numcols, []);
%
%    if pageApplyFlag
%       Z(mask(:), :) = NaN;
%    else
%       Z(mask) = NaN;
%    end
%    Z = reshape(Z, numrows, numcols, []);
% end
