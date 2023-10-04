function T = padtimetable(T,varargin)
   %PADTIMETABLE pads timetable with nan from padstart to beginning of
   %data and from end of data to padend
   %
   %  T = padtimetable(T,varargin)
   %
   %  Inputs
   %     T        =   timetable of monotonically increasing data
   %     dates    =   vector of datenums corresponding to data
   %     padstart =   date you want to start the padding
   %     padend   =   date you want to end the padding
   %
   %  Outputs
   %     T        =   padded timetable
   %
   % See also:

   p = magicParser; %#ok<*NODEF>
   p.FunctionName = mfilename;

   validT  = @(x)validateattributes(x,{'timetable'},{'nonempty'},mfilename,'T',1);
   validt1 = @(x)validateattributes(x,{'datetime'},{'nonempty'},mfilename,'t1');
   validt2 = @(x)validateattributes(x,{'datetime'},{'nonempty'},mfilename,'t2');
   validdt = @(x)validateattributes(x,{'duration'},{'nonempty'},mfilename,'dt');

   p.addRequired('T', validT);
   p.addOptional('t1', defaultt1(T), validt1);
   p.addOptional('t2', defaultt2(T), validt2);
   p.addOptional('dt', defaultdt(T), validdt);
   p.parseMagically('caller');

   hast1t2  = not(any(ismember(p.UsingDefaults,{'t1','t2'})));

   dt = p.Results.dt; % just to get rid of annoying warning

   % Main function
   T = renametimetabletimevar(T);

   if isregular(T,'time')
      Time  = t1:dt:t2;
      T     = retime(T,Time,'fillwithmissing');
      return
   elseif isregular(T,'years')
      if ~hast1t2
         t1 = datetime(year(T.Time(1)),1,1);
         t2 = datetime(year(T.Time(end)),12,1);
      end
      Time  = t1:calyears(1):t2;
      T     = retime(T,Time,'fillwithmissing');
   elseif isregular(T,'months')
      if ~hast1t2
         t1 = datetime(year(T.Time(1)),1,1);
         t2 = datetime(year(T.Time(end)),12,1);
      end
      Time  = t1:calmonths(1):t2;
      T     = retime(T,Time,'fillwithmissing');
   end

   % check for non-numeric data
   inotnum = tablevartypeindices(T,'notnumeric');

   if any(inotnum)
      varnames = T.Properties.VariableNames(inotnum);

      %       % here I was going to determine what type of data is in the
      %       % non-numeric cells and try to convert to double or categorical
      %       % depending on the type but if the data is a char then we don't know
      %       % if it's supposed to be numeirc or not
      %       for n = 1:numel(varnames)
      %          if iscell(T.(varnames{n})(1))
      %          end
      %       end

      % so instead I just convert to categorical. note that converting to
      % double will return nan, so that may solve the issue above, below I
      % check if all nan is returned and if so, convert to categorical

      try
         Ttry = tablechars2double(T);
         if all(isnan(Ttry.(varnames{1})))
            T = tablechars2categorical(T);
         end
      catch
         try
            T = tablechars2categorical(T);
         catch
            try
               T = tablecells2categorical(T);
            catch
            end
         end
      end
      warning('converting non-numeric data to numeric or categorical, function may fail');
   end

   % get the size of the data
   varnames = T.Properties.VariableNames;
   numvars = numel(varnames);

   % make sure the padstart/padend are dates
   padstart = datenum(t1);
   padend = datenum(t2);
   dates = datenum(T.Time);
   dt = datenum(dt);

   % if dt is monthly, it won't work as expected. Might be best to just
   % bite the bullet and use all datetime functions

   % get the missing dates

   missing_datesi = padstart:dt:dates(1)-dt;
   missing_datesf = dates(end)+dt:dt:padend;

   % make a nan vector same size
   numpadi = length(missing_datesi);
   numpadf = length(missing_datesf);

   % pad the data
   data_in = table2array(T);
   data_out = [nan(numpadi,numvars);data_in;nan(numpadf,numvars)];
   dates_out = [missing_datesi';dates;missing_datesf'];

   % rebuild the timetable
   Time = tocolumn(datetime(dates_out,'ConvertFrom','datenum'));
   T = timetable(Time,data_out(:,1));

   if numvars > 1
      for n = 1:numvars-1
         T = addvars(T,data_out(:,n+1));
      end
   end

   T.Properties.VariableNames = varnames;

end

function t1 = defaultt1(T)
   t1 = datetime(year(T.Time(1)),1,1,0,0,0);
end

function t2 = defaultt2(T)
   t2 = datetime(year(T.Time(end)),12,31,23,0,0);
end

function dt = defaultdt(T)
   if ~isnan(T.Properties.TimeStep)
      %       dt       = T.Properties.TimeStep;
      %       [y,m,d]  = split(dt,{'years','months','days'});
      dt = timetabletimestep(T);
   else
      dt = timetabletimestep(T);
   end
end
