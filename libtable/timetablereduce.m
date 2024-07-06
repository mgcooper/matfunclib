function NewData = timetablereduce(Data,varargin)
   %TIMETABLEREDUCE Statistically reduce timetable data to mean, std, and ci
   %
   % NewData = timetablereduce(Data,'keeptime',true) keeps the time column in
   % the case of single vector input and returns the vector with new header 'mu'
   %
   % See also: stderror

   % Parse inputs
   [Data, dim, alpha, keeptime] = parseinputs(Data, mfilename, varargin{:});

   % NOTE: I don't recall finishing this function. If it is finished, combine
   % with aggannualdata function to allow return of min, max in addition to the
   % aggfunc's here.

   Data = renametimetabletimevar(Data);
   Time = Data.Time;

   % If the table has one column this returns the same data but renames the
   % column header 'mu' and imputes nan for all other statistics. mainly for
   % convencience if this function is used in a loop over tables of differing
   % size, some of whcih may have only one column so data reduction is not
   % meaningful but the table headers need to be consistent for other parts of
   % the code
   if width(Data) == 1 && keeptime == true
      NewData = settablevarnames(Data, {'mu'});
      SE = nan(height(Data), 1);
      CI = nan(height(Data), 1);
      PM = nan(height(Data), 1);
      sigma = nan(height(Data), 1);
      NewData = addvars(NewData, SE, CI, PM, sigma);
      return
   end

   % There was enough difference between this function and the one in peakflows
   % that I wasn't sure which is most up to date, but since stderr has a "dim"
   % keyword, I think peakflows was.
   NewData = reduceOneTable(Data, Time, alpha, dim);

   % This archives the version that was here until they can be definitively
   % reconciled
   NewData = reduceOneTableArchive(Data, Time, alpha, dim);

   % copy over properties (might not work, if fails, fix brace indexing)
   if ~isempty(Data.Properties.VariableUnits)
      NewData.Properties.VariableUnits = Data.Properties.VariableUnits{1};
   elseif ~isempty(Data.Properties.VariableContinuity)
      NewData.Properties.VariableContinuity = Data.Properties.VariableContinuity{1};
   end
end

function [Data, dim, alpha, keeptime] = parseinputs(Data, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;

   parser.addRequired( 'Data', @istimetable);
   parser.addOptional( 'dim', 2, @isnumericscalar);
   parser.addParameter('alpha', 0.32, @isnumeric);
   parser.addParameter('keeptime', true, @islogical);
   parser.parse(Data,varargin{:});

   Data = parser.Results.Data;
   dim = parser.Results.dim;
   alpha = parser.Results.alpha;
   keeptime = parser.Results.keeptime;
end

function NewData = reduceOneTable(Data, Time, alpha, dim)

   [SE, CI, PM, mu, sigma] = stderr(table2array(Data), ...
      'alpha', alpha, 'dim', dim);

   if isscalar(mu) || dim == 1
      Time = mean(Time);
   end

   if dim == 2
      CIL = CI(:, 1);
      CIH = CI(:, 2);
   else
      CIL = CI(1, :);
      CIH = CI(2, :);
   end

   % Ensure all quantities are columns
   [mu, sigma, SE, CIL, CIH, PM] = deal(...
      mu(:), sigma(:), SE(:), CIL(:), CIH(:), PM(:));

   if dim == 2
      NewData = timetable(Time, mu, sigma, SE, CIL, CIH, PM);

   elseif dim == 1
      NewData = table(mu, sigma, SE, CIL, CIH, PM, ...
         'RowNames', Data.Properties.VariableNames);
   end
end

function T = renametimetabletimevar(T)
   %RENAMETIMETABLETIMEVAR rename the time variable in table T to 'Time'
   %
   %  T = renametimetabletimevar(T)
   %
   % See also:

   dims = T.Properties.DimensionNames;

   if string(dims{1}) ~= "Time"
      T.Properties.DimensionNames{1} = 'Time';
   end
end

function NewData = reduceOneTableArchive(Data, Time, alpha, dim)

   if dim == 2
      % compute mean, stderr, ci, etc
      [SE,CI,PM,mu,sigma] = stderr(table2array(Data),'alpha',alpha);
   elseif dim == 1
      [SE,CI,PM,mu,sigma] = stderr(transpose(table2array(Data)), ...
         'alpha',alpha);
   end

   CIL = CI(:,1); CIH = CI(:,2);

   if isscalar(mu) || dim == 1
      Time = mean(Time);
   end

   if dim == 2
      NewData = timetable(Time,mu,sigma,SE,CIL,CIH,PM);
   elseif dim == 1
      NewData = table(mu,sigma,SE,CIL,CIH,PM, ...
         'RowNames',Data.Properties.VariableNames);
   end
end
