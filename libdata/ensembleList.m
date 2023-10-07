function ensemble = ensembleList(varargin)
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

   numvars = nargin;
   numvalues = 0;
   numcombos = 1;

   ensemble.numvars = numvars;

   % the total # of combinations is the product of the # of unique values

   for n = 1:numvars

      % % this is here as a reminder. inputname only works if an assigned variable is
      % passed into the function, meaning I cannot pass something like:
      % ensembleList('mychar') or ensembleList(mystruct.mycellstr) because inputname
      % for both of those will be empty. Below I attempted to convert char inputs to
      % cellstrs thinking it was the reason above syntax failed.
      %    if ischarlike(varargin{n})
      %       thisvarlist = cellstr(varargin{n});
      %    else
      %       thisvarlist = varargin{n};
      %    end

      thisvarlist = varargin{n};
      thisvarName = inputname(n);
      uniquevals = unique(thisvarlist);
      numunique = numel(uniquevals);
      numvalues = numvalues + numunique;
      numcombos = numcombos * numunique;

      ensemble.suppliedvars{n} = thisvarlist;
      ensemble.uniquevalues{n} = uniquevals;
      ensemble.numunique(n) = numunique;
      ensemble.varnames{n} = thisvarName;
   end
   ensemble.numvalues = numvalues;

   % first find all the var lists with one unique value
   singlevars = find(ensemble.numunique == 1);
   multivars = find(ensemble.numunique>1);
   allcombos = string(nan(numcombos,numvars));

   % fill in the single-vars
   for n = 1:numel(singlevars)
      ivar = singlevars(n);
      allcombos(:,ivar) = string(ensemble.uniquevalues{ivar});
   end

   % fill in the multi-vars
   for n = 1:numel(multivars)
      ivar = multivars(n);
      inumunique = ensemble.numunique(ivar);
      numblocks = numcombos/inumunique;
      for m = 1:numblocks
         istart = inumunique*(m-1) + 1;
         istop = inumunique*m;
         allcombos(istart:istop,ivar) = string(ensemble.uniquevalues{ivar});
      end
      allcombos = sortrows(allcombos,ivar); % this is the key
   end

   % convert to a table and send it to the output
   allcombos = array2table(allcombos,'VariableNames',ensemble.varnames);
   ensemble.numcombos = numcombos;
   ensemble.allcombos = allcombos;
end
