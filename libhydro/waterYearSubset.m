function [waterYearTime, waterYearData, indices] = waterYearSubset(waterYear, time, data)
   % waterYearSubset Subset data for a specific water year.
   %
   % This function extracts data for the specified water year from a datetime
   % vector and corresponding data matrix. The water year runs from October 1
   % of the previous year to September 30 of the target year.
   %
   % Inputs:
   %   waterYear - The target water year (e.g., 2022 for the 2022 water year,
   %               which spans October 1, 2021, to September 30, 2022).
   %   time      - An Nx1 datetime vector corresponding to the dates of the data.
   %   data      - An NxM matrix (optional), where each row corresponds to the
   %               data for each date in the datetime vector 'time'. This can
   %               contain multiple data columns, with each column representing
   %               a different variable (M >= 1).
   %
   % Outputs:
   %   waterYearTime - A datetime vector subset for the specified water year.
   %   waterYearData - A subset of the data matrix for the specified water year.
   %                   This will be empty if no data matrix is provided.
   %   indices       - A logical array indicating the indices of the datetime
   %                   vector that correspond to the specified water year.
   %
   % Example:
   %   [timeSubset, dataSubset, idx] = waterYearSubset(2022, timeVector, dataMatrix);
   %
   %   This will extract the subset of time and data corresponding to the
   %   2022 water year (October 1, 2021 - September 30, 2022).

   arguments
      waterYear
      time datetime
      data = []  % Optional data matrix
   end

   % Define the start and end of the water year
   waterYearStart = datetime(waterYear - 1, 10, 1);
   waterYearEnd = datetime(waterYear, 9, 30);

   % Find the indices of the dates that fall within the water year range
   indices = waterYearStart <= time & time <= waterYearEnd;

   % Extract the corresponding datetime rows for the water year
   waterYearTime = time(indices);

   % Extract the corresponding data rows for the water year (if data provided)
   if ~isempty(data)
      waterYearData = data(indices, :);
   else
      waterYearData = [];
   end
end
