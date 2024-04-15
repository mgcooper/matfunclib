function [ensemble, allcombos] = ensembleList(varargin)
   %ENSEMBLELIST Create all unique combinations of values in input cell arrays.
   %
   %  ensemble = ensembleList(cellstr1, cellstr2, ..., cellstrN)
   %
   % Input: any number of cell arrays containing character strings, assigned to
   % variables in the calling workspace.
   %
   % Output: all unique combinations of the strings without repeats
   %
   % Matt Cooper, 2022, https://github.com/mgcooper
   %
   % See also:

   % Parse possible struct input in last argument
   if isstruct(varargin{end})
      numargs = nargin - 1;
      structvars = varargin{end};
      varargin = varargin(1:end-1);
      extravars = fieldnames(structvars);
      for n = 1:numel(extravars)
         varargin{end+1} = structvars.(extravars{n});
      end
   else
      numargs = nargin;
      extravars = {};
   end

   argnames = cell(numargs, 1);
   for n = 1:numargs
      argnames{n} = inputname(n);
   end
   argnames = [argnames; extravars];

   numvars = numel(argnames);
   numvalues = 0;
   numcombos = 1;

   ensemble.numvars = numvars;

   % The total # of combinations is the product of the # of unique values
   for n = 1:numvars

      % % this is here as a reminder. inputname only works if an assigned variable is
      % passed into the function, meaning I cannot pass something like:
      % ensembleList('mychar') or ensembleList(mystruct.mycellstr) because inputname
      % for both of those will be empty. Below I attempted to convert char inputs to
      % cellstrs thinking it was the reason above syntax failed.
      if ischar(varargin{n})
         thisvarlist = cellstr(varargin{n});
      else
         thisvarlist = varargin{n};
      end

      thisvarName = argnames{n};

      uniquevals = unique(thisvarlist, 'stable');
      numunique = numel(uniquevals);
      numvalues = numvalues + numunique;
      numcombos = numcombos * numunique;

      ensemble.suppliedvars{n} = thisvarlist;
      ensemble.uniquevalues{n} = uniquevals;
      ensemble.numunique(n) = numunique;
      ensemble.varnames{n} = thisvarName;
   end
   ensemble.numvalues = numvalues;
   ensemble.numcombos = numcombos;

   % First, find all the var lists with one unique value
   constants = find(ensemble.numunique == 1);
   variables = find(ensemble.numunique > 1);
   allcombos = string(nan(numcombos, numvars));

   % Fill in the constants
   for n = 1:numel(constants)
      ivar = constants(n);
      allcombos(:, ivar) = string(ensemble.uniquevalues{ivar});
   end

   % Fill in the variables (inputs that have variable arguments)
   for n = 1:numel(variables)
      ivar = variables(n);
      numunique = ensemble.numunique(ivar);
      numblocks = numcombos / numunique;
      for m = 1:numblocks
         istart = numunique * (m - 1) + 1;
         istop = numunique * m;
         allcombos(istart:istop, ivar) = string(ensemble.uniquevalues{ivar});
      end
      allcombos = sortrows(allcombos, ivar); % this is the key
   end

   % Check if this works:
   % % Fill in the unique values while maintaining their data types
   % for ivar = 1:numvars
   %    uniquevals = ensemble.uniquevalues{ivar};
   %    inumunique = ensemble.numunique(ivar);
   %    numblocks = numcombos / inumunique;
   %    blockvals = cell(numblocks, 1);
   %    for m = 1:numblocks
   %       blockvals(m) = repmat(uniquevals, numblocks, 1);
   %    end
   %    blockvals = vertcat(blockvals{:});
   %    allcombos(:, ivar) = blockvals(1:numcombos);
   % end

   % Convert to a table and send it to the output
   allcombos = array2table(allcombos,'VariableNames',ensemble.varnames);
   ensemble.allcombos = allcombos;
end

% This is an attempt to put numeric values in the allcombos table, the first
% try-catch works but I didn't finish the second part, the main issue is if the
% input variable is e.g. a 1x3 numeric array, I need to assign 1, 2, and 3 to
% three rows of allcombos, but the current method above would assing [1,2,3] to
% each row i.e., the issue is comma separated list assignment.
% function ensemble = ensembleList(varargin)
%    % ENSEMBLELIST Create all unique combinations of values in input cell arrays.
%    %
%    % ensemble = ensembleList(cellArray1, cellArray2, ..., cellArrayN)
%    %
%    % Input: any number of cell arrays containing character strings and/or
%    % numeric values, assigned to variables in the calling workspace.
%    %
%    % Output: all unique combinations of the elements without repeats
%    %
%    % See also:
%
%    numvars = nargin;
%    numvalues = 0;
%    numcombos = 1;
%
%    ensemble.numvars = numvars;
%
%    % the total # of combinations is the product of the # of unique values
%    for n = 1:numvars
%       thisvarlist = varargin{n};
%       thisvarName = inputname(n);
%
%       uniquevals = unique(thisvarlist, 'stable');
%       numunique = numel(uniquevals);
%       numvalues = numvalues + numunique;
%       numcombos = numcombos * numunique;
%
%       ensemble.suppliedvars{n} = thisvarlist;
%       ensemble.uniquevalues{n} = uniquevals;
%       ensemble.numunique(n) = numunique;
%       ensemble.varnames{n} = thisvarName;
%    end
%    ensemble.numvalues = numvalues;
%
%    % First, find all the var lists with one unique value
%    iconstant = find(ensemble.numunique == 1);
%    ivariable = find(ensemble.numunique > 1);
%    allcombos = cell(numcombos, numvars);
%
%    % Fill in the constants
%    for n = 1:numel(iconstant)
%       try
%          allcombos(:, iconstant(n)) = ensemble.uniquevalues{iconstant(n)};
%       catch
%          allcombos(:, iconstant(n)) = ensemble.uniquevalues(iconstant(n));
%       end
%    end
%
%    % Fill in the variables (inputs that have variable arguments)
%    for n = 1:numel(ivariable)
%       ivar = ivariable(n);
%       inumunique = ensemble.numunique(ivar);
%       numblocks = numcombos / inumunique;
%       for m = 1:numblocks
%          istart = inumunique * (m - 1) + 1;
%          istop = inumunique * m;
%          blockvals = repmat(ensemble.uniquevalues{ivar}, numblocks, 1);
%          try
%             allcombos(istart:istop, ivar) = blockvals((m-1)*inumunique+1:m*inumunique);
%          catch
%             allcombos{istart:istop, ivar} = blockvals((m-1)*inumunique+1:m*inumunique);
%          end
%       end
%    end
%
%    % Convert to a table and send it to the output
%    allcombos = cell2table(allcombos, 'VariableNames', ensemble.varnames);
%    ensemble.numcombos = numcombos;
%    ensemble.allcombos = allcombos;
% end

