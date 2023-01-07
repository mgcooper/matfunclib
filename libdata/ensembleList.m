function ensemble = ensembleList(varargin)
%ENSEMBLELIST create list of ensemble members with all unique combinations of
%values in input cell arrays. Note: all inputs must be assigned cellstr arrays.
% 
%  ensemble = ensembleList(varargin)
% 
% Input: any number of cell arrays containing character strings, assigned to
% variables in the calling workspace.
% Output: all unique combinations of the strings without repeats
% 
% Matt Cooper, 2022, https://github.com/mgcooper
% 
% See also:

numvars     = nargin;
numvalues   = 0;
numcombos   = 1;

ensemble.numvars  = numvars;

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
   uniquevals  = unique(thisvarlist);
   numunique   = numel(uniquevals);
   numvalues   = numvalues + numunique;
   numcombos   = numcombos * numunique;

   ensemble.suppliedvars{n}   = thisvarlist;
   ensemble.uniquevalues{n}   = uniquevals;
   ensemble.numunique(n)      = numunique;
   ensemble.varnames{n}       = thisvarName;
end
ensemble.numvalues = numvalues;

% first find all the var lists with one unique value
singlevars  = find(ensemble.numunique==1);
multivars   = find(ensemble.numunique>1);
allcombos   = string(nan(numcombos,numvars));

% fill in the single-vars
for n = 1:numel(singlevars)
   ivar = singlevars(n);
   allcombos(:,ivar) = string(ensemble.uniquevalues{ivar});
end

% fill in the multi-vars
for n = 1:numel(multivars)
   ivar        = multivars(n);
   inumunique  = ensemble.numunique(ivar);
   numblocks   = numcombos/inumunique;
   for m = 1:numblocks
      istart   = inumunique*(m-1) + 1;
      istop    = inumunique*m;
      allcombos(istart:istop,ivar) = string(ensemble.uniquevalues{ivar});
   end
   allcombos = sortrows(allcombos,ivar); % this is the key
end

% convert to a table and send it to the output
allcombos = array2table(allcombos,'VariableNames',ensemble.varnames);
ensemble.numcombos   = numcombos;
ensemble.allcombos   = allcombos;


% need to divide the total number of


%    % if we knew the ones that
%
%    test  = ["mar","skin","ice","2015","2016","mer","rac","mod"];
%    p     = unique(uniqueperms(test),'rows');
%
%    test = ["skin","ice","2015","2016","mer","rac","mod"];
%
%
%    p1 = unique(uniqueperms(["skin","2015","mer","rac","mod"]),'first');
%
%    allVars  = string(nan(numvalues,1));
%    varCount = 0;
%    for n = 1:numvars
%       ivarCount   = ensemble.numunique(n);
%       varstrs     = string(ensemble.uniquevalues{n});
%
%       allVars(varCount+1:varCount+ivarCount) = varstrs;
%
%       varCount    = varCount+ivarCount;
%    end
%
%    % get the total number of combinations
%    USE   = ensemble.numunique>1;
%    C     = nchoosek(sum(ensemble.numunique(USE)),max(ensemble.numunique(USE)))
%
% %    % put all unique values into one list
% %    for n = 1:ensemble.numvars
% %
% %       uniqueVars  = ensemble.uniquevlues{n};
% %
% %
% %    end
% %
% %    for n = 1:ensemble.numvars
% %
% %       thisVar = ensemble.suppliedvars{n};
% %
% %    end
% %
% %
% %    a  = [1; 2; 3]
% %    b  = 12;
% %    c  = [5;6];
% %    d  = 11;
% %    e  = 17;
% %    vars{1}  = a;
% %    vars{2}  = b;
% %    vars{3}  = c;
% %    vars{4}  = d;
% %    vars{5}  = e;
% %    for n = 1:numvars
% %
% %
% %    end
% %
% %
% %    % the problem with this is not knowing ahead of time the numels
% %    [Cx,Bx,Ax] = ndgrid(1:numel(C),1:numel(B),1:numel(A));
% %
% %    D = strcat(A(Ax(:)),'-',B(Bx(:)),'-',C(Cx(:))
% %
% %       % I need to
% %
% %    c12         =  cellfun(@(x,y) [num2str(x) y],A(:,1),A(:,2),'un',0);
% %    [y,ii,ind]  =  unique(c12); %Problem
% %    c           =  accumarray(ind,1);
% %    F           =  [A(ii,:)  num2cell(c)]
%
%
%
%
%
%
%
%
%
%
%