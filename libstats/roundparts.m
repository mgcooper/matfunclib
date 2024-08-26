function rounded_parts = roundparts(parts, method, kwargs)
   %ROUNDPARTS Rounds parts to ensure they sum to 100% using various methods.
   %
   %    rounded_parts = ROUNDPARTS(parts)
   %    rounded_parts = ROUNDPARTS(parts, method)
   %    rounded_parts = ROUNDPARTS(parts, method, binedges=binedges)
   %
   %  Description:
   %
   %    ROUNDED_PARTS = ROUNDPARTS(PARTS) takes a vector of parts (percentages)
   %    and rounds them such that the sum of the rounded values is 100%.
   %
   %    ROUNDED_PARTS = ROUNDPARTS(PARTS, METHOD) applies the specified rounding
   %    method. Available methods include:
   %       - 'Hamilton': Largest Remainder Method (default)
   %       - 'Jefferson': D'Hondt Method
   %       - 'Webster': Sainte-Laguë Method
   %       - 'Adams': Smallest Remainder Method
   %
   %    Background on Methods:
   %       - **Hamilton's Method** (Largest Remainder or Hare Quota): This
   %         method first rounds down the parts and then distributes the
   %         remaining percentage points to the parts with the largest
   %         remainders. It is commonly used in proportional representation
   %         voting systems.
   %
   %       - **Jefferson's Method** (D'Hondt Method): This is a highest averages
   %         method that divides each part by a sequence of divisors
   %         (1,2,3,...). The parts with the largest resulting quotients are
   %         assigned the additional percentage points. It tends to favor larger
   %         parts and is also used in electoral systems.
   %
   %       - **Webster's Method** (Sainte-Laguë Method): Another highest
   %         averages method, but it uses divisors of 1, 3, 5, etc., which
   %         provides a more balanced approach compared to Jefferson's method.
   %         It is also used in proportional representation but gives smaller
   %         parts a better chance to receive additional percentage points.
   %
   %       - **Adams's Method** (Smallest Remainder Method): This method rounds
   %         up the parts first and then removes the excess from the parts with
   %         the smallest remainders. It is less common and tends to favor
   %         smaller parts.
   %
   %    ROUNDED_PARTS = ROUNDPARTS(_, BINEDGES=BINEDGES) allows for binning
   %    of the parts before rounding. The 'binedges' should be a vector
   %    specifying the edges of the bins. The function will sum the parts within
   %    each bin, round the bin sums to ensure they sum to 100%, and then
   %    distribute the rounded values back to the individual parts within each
   %    bin.
   %
   %  Inputs:
   %
   %    parts    - A vector of percentages that sum to 100% before rounding.
   %    method   - (Optional) A string specifying the rounding method.
   %    binedges - (Optional) A vector specifying bin edges.
   %
   %  Outputs:
   %
   %    rounded_parts - A vector of rounded percentages summing to 100%.
   %
   %  Example:
   %
   %    parts = [30.2, 20.8, 49.0];
   %    rounded_parts = roundparts(parts);
   %
   %    parts = [10.1, 20.2, 30.3, 39.4];
   %    binedges = [0, 30, 40];
   %    rounded_parts = roundparts(parts, 'Jefferson', 'binedges', binedges);
   %
   % See also:

   arguments
      parts (:, 1) double {mustBeNonempty}
      method (1, :) char {...
         mustBeMember(method, {'Hamilton', 'Jefferson', 'Webster', 'Adams'})} ...
         = 'Hamilton'
      kwargs.sum (1, 1) double = 100
      kwargs.binedges (:, 1) double = []
   end
   binedges = kwargs.binedges;

   % Handle binning if binedges are provided
   if ~isempty(binedges)
      [~, ~, bins] = histcounts(parts, binedges);
      binned_parts = accumarray(bins(:), parts(:));
      binned_parts = roundparts(binned_parts, method, "sum", kwargs.sum);

      % Distribute rounded bin values back to individual parts
      rounded_parts = zeros(size(parts));
      for n = 1:numel(binned_parts)
         in = bins == n;
         binned_sum = sum(parts(in));
         if binned_sum > 0
            rounded_parts(in) = (parts(in) / binned_sum) * binned_parts(n);
         end
      end
      rounded_parts = round(rounded_parts);
      return
   end

   switch lower(method)
      case 'hamilton'
         rounded_parts = hamilton_method(parts, kwargs.sum);
      case 'jefferson'
         rounded_parts = jefferson_method(parts, kwargs.sum);
      case 'webster'
         rounded_parts = webster_method(parts, kwargs.sum);
      case 'adams'
         rounded_parts = adams_method(parts, kwargs.sum);
   end
end

function rounded_parts = hamilton_method(parts, total)
   % Initial rounding down
   integers = floor(parts);
   remainders = parts - integers;

   % Calculate how much is left to reach 100%
   deficit = total - sum(integers);

   % Sort indices by remainder (largest to smallest)
   [~, indices] = sort(remainders, 'descend');

   % Distribute the deficit
   rounded_parts = integers;
   rounded_parts(indices(1:deficit)) = rounded_parts(indices(1:deficit)) + 1;
end

function rounded_parts = jefferson_method(parts, total)
   % Implement Jefferson's (D'Hondt) method
   divisors = 1:total;
   quotients = parts ./ divisors;
   [~, idx] = sort(quotients(:), 'descend');
   idx = mod(idx(1:total) - 1, numel(parts)) + 1;
   rounded_parts = accumarray(idx, 1, [numel(parts), 1]);
end

function rounded_parts = webster_method(parts, total)
   % Implement Webster's (Sainte-Laguë) method
   divisors = 2*(0:(total-1)) + 1;
   quotients = parts ./ divisors;
   [~, idx] = sort(quotients(:), 'descend');
   idx = mod(idx(1:total) - 1, numel(parts)) + 1;
   rounded_parts = accumarray(idx, 1, [numel(parts), 1]);
end

function rounded_parts = adams_method(parts)
   % Initial rounding up
   ceiling_parts = ceil(parts);
   remainders = ceiling_parts - parts;

   % Calculate how much needs to be removed to reach 100%
   surplus = sum(ceiling_parts) - 100;

   % Sort indices by remainder (smallest to largest)
   [~, indices] = sort(remainders, 'ascend');

   % Distribute the surplus
   rounded_parts = ceiling_parts;
   rounded_parts(indices(1:surplus)) = rounded_parts(indices(1:surplus)) - 1;
end
