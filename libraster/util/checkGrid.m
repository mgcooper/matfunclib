function isRectangle = checkGrid(coords)
   %CHECKGRID Check if four grid corner coordinates form a rectangle.

   % NOTE: This is not complete. 
   
   % Calculate the pairwise distances
   distances = [];
   for i = 1:4
      for j = i+1:4
         distances = [distances, sqrt((coords(i, 1) - coords(j, 1))^2 + (coords(i, 2) - coords(j, 2))^2)];
      end
   end

   % Sort the distances
   distances = sort(distances);

   % Check if two unique distances occur twice each (sides) and two unique distances occur once each (diagonals)
   isRectangle = (distances(1) == distances(2)) && ...
      (distances(3) == distances(4)) && ...
      (distances(5) == distances(6)) && ...
      (distances(1) ~= distances(3)) && ...
      (distances(5) ~= distances(3));

   if isRectangle
      % Further check the slopes to ensure the sides are parallel
      slopes = [];
      for i = 1:4
         for j = i+1:4
            slope = (coords(j, 2) - coords(i, 2)) / (coords(j, 1) - coords(i, 1));
            slopes = [slopes, slope];
         end
      end

      % Sort the slopes
      slopes = sort(slopes, 'ComparisonMethod', 'abs');

      % Check if the two unique slopes occur twice each (indicating parallel sides)
      isRectangle = (slopes(1) == slopes(2)) && (slopes(3) == slopes(4));
   end
end
