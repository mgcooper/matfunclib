function x1 = nancat(dim, x, opts)
   %NANCAT Concatenation with missing-value padding.
   %
   %  X = nancat( DIM, x1, x2, x3, ...)
   %  X = nancat( DIM, x1, x2, x3, padvalue=padvalue)
   %  X = nancat( DIM, x1, x2, x3, padvalue=padvalue, alignend=alignend)
   %
   % Works just like cat. Doesn't complain if x2 is longer or shorter than x1,
   % it simply pads the one that is shorter with nans. Works with arbitrary
   % number of dimensions.
   %
   % 'padvalue', VAL  (defaults to standard missing value based on class)
   %        VAL specifies a single value that is used to fill unused space.
   %        It should be the same class as the items being concatenated,
   %        and it can't be a vector or matrix.
   % 'alignend'
   %        Logical scalar indicating whether to align each item at the end or
   %        beginning of its dimension. Default is false (align at beginning of
   %        each dimension).
   %
   % Note - nancat deals with cell arrays and character arrays.
   %        the default padding for cells = { []  [] ... }, and chars = ' '.
   %        If any concatenands are cells, the output is a cell.
   %        If any of the concatenands are numeric, they are turned into cell
   %        arrays with num2cell.
   %        -- if the first operand isn't a cell, but later ones are, we
   %        default to padding with { [nan] }, rather than { [] }.
   %
   % (c) sanjay manohar 2007
   % Updated April 2024 for modern matlab by Matt Cooper.

   % % Note, this is how I cat-padded two datetime vectors using catpad
   % flag1 = ones(size(T1))';
   % flag2 = 2 * ones(size(T2))';
   % Tflag = catpad(1, flag1, flag2);
   % T = NaT(size(Tflag), 'TimeZone', 'UTC');
   % T(Tflag == 1) = T1;
   % T(Tflag == 2) = T2;
   % T = transpose(T);
   % T.TimeZone = 'UTC';

   arguments
      dim (1, 1) {mustBeNumeric}
   end
   arguments (Repeating)
      x
   end
   arguments
      opts.padvalue = []
      opts.alignend = 0
   end

   if nargin == 2
      return % nothing to concatenate
   end

   alignend = opts.alignend;
   padvalue = opts.padvalue;

   % Get first argument and default padding value
   x1 = x{1};
   if isempty(opts.padvalue)
      padvalue = getMissingValue(class(x1));
   end

   % Special case - datetime. Must pad with NaT with identical timezone.
   if isdatetime(x1)
      TimeZone1 = x1.TimeZone;
      padvalue.TimeZone = TimeZone1;
   end

   % Handle any additional special cases here, before defining makepadding.

   % create padding of a given size
   makepadding = @(sz) repmat( padvalue, sz );

   for n = 2:length(x) % for each operand
      xN = x{n}; % concatenate xN onto x1

      % Special case - datetime. Must pad with NaT with identical timezone.
      if isdatetime(xN)
         TimeZoneN = xN.TimeZone;
         if ~strcmp(TimeZone1, TimeZoneN)
            warning( ...
               'TimeZones do not match, shifting all dates to match X1 TimeZone')
            xN.TimeZone = TimeZone1;
         end
      end

      if iscell(x1) && isnumeric(xN)
         xN = num2cell(xN);
      end % convert xN to cell

      if iscell(xN) && isnumeric(x1)
         x1 = num2cell(x1);
         padvalue = cell(padvalue);
      end % switch to cell mode

      size1 = size(x1);
      sizeN = size(xN);

      if all(size1 == 0)
         x1 = xN;
         continue
      end % earlier operands were empty?

      if length(size1) > length(sizeN)
         sizeN = [sizeN ones(1, length(size1)-length(sizeN))];

      elseif length(sizeN) > length(size1)
         size1 = [size1 ones(1, length(sizeN)-length(size1))];
      end % ensure same number of dimensions.

      uneqdim = find(~(sizeN==size1)); % for each of the unequal dimensions

      for m = 1:length(uneqdim)

         if uneqdim(m) == dim
            continue
         end % (except for the one you're catting along)

         d = uneqdim(m);

         if size1(d) > sizeN(d) % xN is too small: add nans to d if it's shorter
            difsize = size1(d)-sizeN(d); % difference in size along dimension d
            addsize = size(xN);
            addsize(d) = difsize;

            if alignend
               xN = cat(d, makepadding( addsize ), xN);
            else
               xN = cat(d, xN, makepadding( addsize ));
            end

         elseif sizeN(d) > size1(d) % x1 is too small

            difsize = sizeN(d)-size1(d); % difference in size along dimension d
            addsize = size(x1);
            addsize(d) = difsize;

            if alignend
               x1 = cat(d, makepadding( addsize ), x1);
            else
               x1 = cat(d, x1, makepadding( addsize ));
            end
         end
      end
      x1 = cat(dim, x1, xN);
   end
end
