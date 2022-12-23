function [ bestScore, bestIndex] = getBestIndex( data,imin,imax,inc,option,tolerance )
%GETBESTINDEX getBestIndex finds the index(es) of the best parameter sets
%from a list of parameters and associated objective function scores.
% 
%     [ bestScore, bestIndex] = getBestIndex( data,imin,imax,inc,option,tolerance )
% 
%   Available options include 'maximize' which returns the highest scores,
%   or 'minimize' which returns the lowest. The user can also supply a
%   'tolerance' above/below the lowest/highest score so the function will
%   return all parameter sets that score within the tolerance. This is
%   useful because for example, the 'best' NSE might be 0.85, but the
%   parameter set that scores 0.84 might be 'better' according to some
%   subjective metric like a visual inspection.

%   'DATA' = a numsitesxnumruns vector of objective function values e.g. NSE,
%   bias, rmse, or whatever you are trying to maximize/minimize

%   'MIN' = the minimum value of the objective function

%   'MAX' = the maximum value of the objective function

%   'INC' = the spacing of values between MIN and MAX i.e. the precision

%   'OPTION' = 'maximize' or 'minimize'
%   'maximize' tells the function to return the indices with the highest value.
%   'minimize' tells the function to return the indices with the lowest
%   value of the objective function.

%   'TOLERANCE' = a floating point input of user defined value. A tolerance
%   below or above the highest/lowest value of the objective function.
%   The function will return all indices above/below that value. For example,
%   if the highest score is 0.85, the 'option' is 'maximize', and the 'tolerance'
%   is .02, the indices for all scores above 0.83 will be returned.

if imin == 0 || imax == 0
   error('imin and imax must be non-zero');
end

[numsites,numruns] = size(data);

if strcmp(option,'maximize') == 1
   thresholds = imin:inc:imax;
elseif strcmp(option,'minimize') == 1
   thresholds = fliplr(imin:inc:imax);
end

A = cell(1,length(thresholds));

for n = 1:length(thresholds)

   thresh = thresholds(n);

   if strcmp(option,'maximize') == 1
      for m = 1:numsites
         a{m} = find(data(m,:) >=thresh); %#ok<*AGROW>
      end

   elseif strcmp(option,'minimize') == 1
      for m = 1:numsites
         a{m} = find(data(m,:) <=thresh);
      end
   end

   % check to see if there are any sites without any scores that satisfy
   % the threshold

   for m = 1:numel(a)
      asize(m) = numel(a{m});
   end

   % it's the first run, and at least one site has no good scores
   if n == 1 && ~isempty(find(asize==0,1))
      ismember(asize,0)
      badcol = find(ismember(asize,0));
      error(['It looks like column ' int2str(badcol) ' does not ' ...
         'have at least one score that satisfies your imax threshold ' ...
         'Try raising/lowering your threshold or excluding that data']);

   elseif isempty(find(asize==0,1)) % all sites have a good score
      % successively compare scores at each site a{1} to a{2}..a{m} to find
      % the set of indices that has a good score at ALL sites
      A{n} = a{1};
      for m = 1:numel(a)
         A{n} = intersect(A{n},a{m});
      end
      % TESTING FROM HERE
   end
end

if length(A{1}) == 0
   warning(['Your imax value is not satisfied at all locations ' ...
      'instead, this function is returning the best indices at each ' ...
      'site and associated scores.']);
   bestIndex = a;
   bestScore = thresholds(n);

else

   for n = 1:length(A)
      numgood(n) = length(A{n});
   end

   badi = find(numgood(:) == 0,1,'first');
   bestScore = thresholds(badi-1);
   bestIndex = A{badi-1};

end


%
%         % If A{n} = 0, there's no intersection, so we've reached the max/min value that
%         % is satisfied at all sites, which means the previous iteration (i.e.
%         % thresholds (n-1) is the best score, and 'b' holds those indices from
%         % the previous iteration. Unless it's the first run, meaning the
%         % sites don't share a common good index. iterations found any
%         % indices that satisfy the threshold at all sites
%
%         % it's the first threshold and there's no unique indices
%         if n == 1 && length(A{n}) == 0;
%             warning(['Your imax value is not satisfied at all locations ' ...
%                 'instead, this function is returning the best indices at each ' ...
%                 'site and associated scores.']);
%             bestIndex = a;
%             bestScore = thresholds(n);
%             break
%         % it's not the first, and there are unique indices for some threshold >
%         % threshold(1), thus if there are no unique indices for threshold(n),
%         % the previous iteration has the best global indices.
%
%         elseif n ~= 1 && length(A{n-1}) ~= 0 && length(A{n}) == 0;
%             %disp('Congrats, you''ve found the unique set');
%             bestScore = thresholds(n-1);
%             bestIndex = A{n-1};
%             break
%
%         % you made it all the way to the end of the thresholds and
%         elseif n == length(thresholds) && length(A{n}) == 0;
%             warning(['Your imax value is not satisfied at all locations ' ...
%                 'instead, this function is returning the best indices at each ' ...
%                 'site and associated scores.']);
%         end
%     end
% end


if tolerance ~= 0

   % First set the new threshold

   if strcmp(option,'maximize') == 1 % repeat the whole process for the new threshold
      thresh = bestScore - tolerance;
   elseif strcmp(option,'minimize') == 1 % repeat the whole process for the new threshold
      thresh = bestScore + tolerance;
   end

   % Now find all indices at each site that exceed that threshold
   if strcmp(option,'maximize') == 1
      for m = 1:numsites
         a{m} = find(data(m,:) >=thresh);
      end

   elseif strcmp(option,'minimize') == 1
      for m = 1:numsites
         a{m} = find(data(m,:) <=thresh);
      end
   end

   % Now, n = whatever threshold where no sites exceeded the original threshold,
   % therefore A{n} = []. Now we fill A{n} with the indices that exceed the
   % new threshold at all sites, and we end the search

   A{n} = a{1};
   for m = 1:numel(a)
      A{n} = intersect(A{n},a{m});
   end

   % bestScore still equals bestScore
   bestIndex = A{n};

end









%     for m = 1:numsites
%         a{m} = find(data(m,:) >= newthresh);
%     end
%
%     % successively compare a{1} to a{2}..a{m} i.e. each site
%     A = a{1};
%     for m = 1:numel(a);
%         A = intersect(A,a{m});
%     end
%
%     bestIndex = A;
%
% elseif tolerance ~= 0 && strcmp(option,'minimize') % repeat the whole process for the new threshold
%
%     newthresh = bestScore + tolerance;
%
%     for m = 1:numsites
%         a{m} = find(data(m,:) <= newthresh);
%     end
%
%     % successively compare a{1} to a{2}..a{m} i.e. each site
%     A = a{1};
%     for m = 1:numel(a);
%         A = intersect(A,a{m});
%     end
%
%     bestIndex = A;
%
% end
% %
% end
