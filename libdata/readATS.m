function data = readATS(fname)
   %READATS Read ATS data file

   % note: the table variable names are strings, which allows them to have
   % spaces and non-standard characters, but also means indexing into them is
   % done using data.("var") rather than data.var. This is the first time I
   % encountered this behavior and I might want to change it, but it's good to
   % know b/c sometimes I want the units in the varnames, rather than stored
   % in the Properties.

   opts = detectImportOptions(fname,'FileType','delimitedtext');
   opts.Delimiter = {' '};
   opts.CommentStyle = {'#'};

   % read the data
   data = readtable(fname,opts,'ReadVariableNames',false);
   vars = table2array(data(1,:));               % get the headers
   vars = arrayfun(@(x) strrep(x,'"',''),vars); % remove the ""
   data = data(3:end,:);                        % remove the headers
   % 2:end would just remove headers, 3:end removes the first day which is
   % '0' seconds, so i assume that is an initial condition timestep and
   % the second timestep is the end of the first day

   % test
   vars = string(vars);

   data.Properties.VariableNames = vars;

   % the data comes in as strings, convert to double
   for n = 1:numel(vars)
      data.(vars{n}) = cellfun(@str2double,(data.(vars{n})));
   end

   secperday = 60*60*24;
   data.("time [s]") = data.("time [s]")./secperday;

   itime = strcmp(data.Properties.VariableNames,"time [s]");

   % extract units from the variable names
   units = cell(size(vars));
   for n = 1:numel(vars)
      unit_n = extractBetween(vars{n},'[',']');
      if isempty(unit_n)
         unit_n = nan;
      end
      units{n} = unit_n;
   end

   units = string(units);

   % convert variables that are in mols to kg
   for n = 1:numel(vars)
      if contains(units(n),'mol')
         data_n = data.(vars{n});
         data.(vars{n}) = mols2kgH20(data_n);
         units(n) = strrep(units(n),'mol','kg');
         vars(n) = strrep(vars(n),'mol','kg');
      end
   end

   % define units
   data.Properties.VariableNames = vars;
   data.Properties.VariableUnits = units;

   % easier to set this at the end than above, then pull out vars again
   data.Properties.VariableNames(itime) = "time [days]";
end
