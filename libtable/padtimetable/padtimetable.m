function ttbl = padtimetable(ttbl,varargin)
   %PADTIMETABLE pad timetable with nan between specified dates.
   %
   %  ttbl = padtimetable(ttbl, t1, t2)
   %  ttbl = padtimetable(ttbl, t1, t2, dt)
   %
   % Description
   %  ttbl = padtimetable(ttbl, t1, t2) pads timetable with nan from t1
   %  to beginning of data and from end of data to t2.
   %
   %  Inputs
   %     ttbl = timetable of monotonically increasing data
   %     t1 = date you want to start the padding
   %     t2 = date you want to end the padding
   %     dt = timestep
   %
   %  Outputs
   %     ttbl = padded timetable
   %
   % See also:

   parser = inputParser; %#ok<*NODEF>
   parser.FunctionName = mfilename;

   validT = @(x)validateattributes(x,{'timetable'},{'nonempty'},mfilename,'ttbl',1);
   validt1 = @(x)validateattributes(x,{'datetime'},{'nonempty'},mfilename,'t1');
   validt2 = @(x)validateattributes(x,{'datetime'},{'nonempty'},mfilename,'t2');
   validdt = @(x)validateattributes(x,{'duration'},{'nonempty'},mfilename,'dt');

   parser.addRequired('ttbl', validT);
   parser.addOptional('t1', defaultt1(ttbl), validt1);
   parser.addOptional('t2', defaultt2(ttbl), validt2);
   parser.addOptional('dt', defaultdt(ttbl), validdt);
   parser.parse(ttbl, varargin{:});
   t1 = parser.Results.t1;
   t2 = parser.Results.t2;
   dt = parser.Results.dt;

   hast1t2 = not(any(ismember(parser.UsingDefaults,{'t1','t2'})));

   % Main function
   ttbl = renametimetabletimevar(ttbl);

   if isregular(ttbl, 'time')
      Time = t1:dt:t2;
      ttbl = retime(ttbl,Time,'fillwithmissing');
      return
   elseif isregular(ttbl, 'years')
      if ~hast1t2
         t1 = datetime(year(ttbl.Time(1)),1,1);
         t2 = datetime(year(ttbl.Time(end)),12,1);
      end
      Time = t1:calyears(1):t2;
      ttbl = retime(ttbl,Time,'fillwithmissing');
   elseif isregular(ttbl, 'months')
      if ~hast1t2
         t1 = datetime(year(ttbl.Time(1)),1,1);
         t2 = datetime(year(ttbl.Time(end)),12,1);
      end
      Time = t1:calmonths(1):t2;
      ttbl = retime(ttbl,Time,'fillwithmissing');
   end

   % check for non-numeric data
   inotnum = tablevartypeindices(ttbl,'notnumeric');

   if any(inotnum)
      varnames = ttbl.Properties.VariableNames(inotnum);

      % % here I was going to determine what type of data is in the
      % % non-numeric cells and try to convert to double or categorical
      % % depending on the type but if the data is a char then we don'ttbl know
      % % if it's supposed to be numeirc or not
      % for n = 1:numel(varnames)
      %    if iscell(ttbl.(varnames{n})(1))
      %    end
      % end

      % so instead I just convert to categorical. note that converting to
      % double will return nan, so that may solve the issue above, below I
      % check if all nan is returned and if so, convert to categorical

      try
         Ttry = tablechars2double(ttbl);
         if all(isnan(Ttry.(varnames{1})))
            ttbl = tablechars2categorical(ttbl);
         end
      catch
         try
            ttbl = tablechars2categorical(ttbl);
         catch
            try
               ttbl = tablecells2categorical(ttbl);
            catch
            end
         end
      end
      warning('converting non-numeric data to numeric or categorical, function may fail');
   end

   % get the size of the data
   varnames = ttbl.Properties.VariableNames;
   numvars = numel(varnames);

   % make sure the padstart/padend are dates
   padstart = datenum(t1);
   padend = datenum(t2);
   dates = datenum(ttbl.Time);
   dt = datenum(dt);

   % if dt is monthly, it won'ttbl work as expected. Might be best to just
   % bite the bullet and use all datetime functions

   % get the missing dates

   missing_datesi = padstart:dt:dates(1)-dt;
   missing_datesf = dates(end)+dt:dt:padend;

   % make a nan vector same size
   numpadi = length(missing_datesi);
   numpadf = length(missing_datesf);

   % pad the data
   data_in = table2array(ttbl);
   data_out = [nan(numpadi,numvars);data_in;nan(numpadf,numvars)];
   dates_out = [missing_datesi';dates;missing_datesf'];

   % rebuild the timetable
   Time = tocolumn(datetime(dates_out,'ConvertFrom','datenum'));
   ttbl = timetable(Time,data_out(:,1));

   if numvars > 1
      for n = 1:numvars-1
         ttbl = addvars(ttbl,data_out(:,n+1));
      end
   end
   ttbl.Properties.VariableNames = varnames;
end

function t1 = defaultt1(ttbl)
   t1 = datetime(year(ttbl.Time(1)),1,1,0,0,0);
end

function t2 = defaultt2(ttbl)
   t2 = datetime(year(ttbl.Time(end)),12,31,23,0,0);
end

function dt = defaultdt(ttbl)
   dt = timetabletimestep(ttbl);
   if ~isnan(ttbl.Properties.TimeStep)
      % dt = ttbl.Properties.TimeStep;
      % [y,m,d] = split(dt,{'years','months','days'});
      % use the dt returned by timetabletimestep until this is figured out
   else
      dt = timetabletimestep(ttbl);
   end
end
