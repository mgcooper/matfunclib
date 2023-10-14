function choices = tablecompletions(tbl, options)
   %TABLECOMPLETIONS Generate completions from table variables.
   %
   % This function returns the variable names from tbl. If tbl is a timetable,
   % it includes the RowTimes dimension name. Use the output of this function
   % to generate tab-completion choices in a json file for a function that
   % accepts a tabular input argument and restrict subsequent arguments to the
   % table variables.
   %
   %
   % See also:

   % This function inspired by tableVariablesForTabCompletion
   %   Copyright 2021-2022 The MathWorks, Inc.
   %
   % cd(fullfile(matlabroot, ...
   %    'toolbox/matlab/specgraph/+matlab/+graphics/+chart/+internal'))
   %

   arguments
      tbl {istabular}
      options.rownames = false;
      options.rowtimes = true;
      options.selectby = string.empty()
      options.vartype = string.empty()
      % options.vartype (1,1) string = ""
   end

   choices = {};
   
   if istabular(tbl)
      if ~isempty(options.vartype)
         assert(isscalartext(options.vartype))
         try
            tbl = tbl(:, vartype(options.vartype));
         catch ME
            
         end
      end
      if ~isempty(options.selectby)
         % This requires care b/c there could be many unique values, but this
         % function is only used for function development and the 'selectby'
         % option should only ever be called from the functionSignatures file
         choices = groupmembers(tbl, options.selectby);
         if iscategorical(choices)
            if ~isordinal
               choices = string(choices);
            else
               choices = cat2double(choices);
            end
         end
         
      else
         choices = tbl.Properties.VariableNames;
         choices = appendRowNames(tbl, choices, options);
         choices = appendRowTimes(tbl, choices, options);
      end

   elseif all(isprop(tbl, 'SourceTable'), 'all')
      % A vector of objects might be passed in and if they all have
      % SourceTable property, return the common varaibles for all of them.
      % This is used for tab completion for the 'set' command.
      args = namedargs2cell(options);
      choices = tablecompletions(tbl(1).SourceTable, args{:});

      for t = tbl(:)'
         newChoices = tablecompletions(t.SourceTable, args{:});
         choices = intersect(choices, newChoices);
      end
   end
end
%% Local functions
function choices = appendRowNames(tbl, choices, options)
   if options.rownames && isa(tbl, 'table') 
      if ~isempty(tbl.Properties.RowNames)
         choices = [tbl.Properties.RowNames(:)' choices];
      end
   end
end
function choices = appendRowTimes(tbl, choices, options)
   if options.rowtimes && isa(tbl, 'timetable')
      choices = [tbl.Properties.DimensionNames(1) choices];
   end
end
