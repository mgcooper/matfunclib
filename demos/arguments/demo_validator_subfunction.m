function y = demo_validator_subfunction(x)
   arguments
      x (:, :) {mustHaveTwoOrThreeRows(x)}
   end
   y = sum(x, 'all');
end
function mustHaveTwoOrThreeRows(x)
   s = size(x, 1);
   if ~(s == 2 || s == 3)
      error('X must have either two or three rows.');
   end
end
