function poly = polyreduce(poly, numv)
   %POLYREDUCE Reduce polygon to a given number of vertices
   %
   % poly = polyreduce(poly, numv)
   %
   % Inputs
   %  poly - N x 2 array of polygon vertex coordinates
   %  numv - Required number of vertices
   %
   % Outputs
   %  poly - Reduced polygon
   %
   % Description: This code reduces the number of vertices in a closed polygon
   % to the number specified by 'num'. It does this by calculating the
   % importance of each vertex based on angle and segment length and then
   % removing the least important. The process is repeated until the desired
   % number of vertices is reached.
   %
   % Example:
   % t = 0:0.1:2*pi;
   % poly1 = [sin(t); cos(t)];
   % poly2 = polyreduce(poly1, 21);
   % poly_draw = [poly2 poly2(:,1)];
   % plot(poly_draw(1,:), poly_draw(2,:), '.-')
   % axis equal
   %
   % Coded by: Peter Bone (peterbone@hotmail.com)

   % If the poly has fewer than NUMV vertices, return it as-is.
   if size(poly, 1) <= numv
      return
   end

   numv0 = length(poly);

   % Calculate initial importance of each vertex
   imp = zeros(numv0, 1);
   for v = 1:numv0
      imp(v) = vertex_importance(v, poly, numv0);
   end

   % Iterate until desired number of vertices is reached
   while numv0 > numv

      [~, i] = min(imp(1:numv0));

      % Remove vertex with least importance
      if i < numv0
         poly(i:numv0-1, :) = poly(i+1:numv0, :);
         imp(i:numv0-1) = imp(i+1:numv0);
         vp = i;
      else
         vp = 1;
      end
      numv0 = numv0 - 1;

      % Recalculate importance for vertices neighbouring the removed one
      vm = 1 + mod(i - 2, numv0);
      imp(vp) = vertex_importance(vp, poly, numv0);
      imp(vm) = vertex_importance(vm, poly, numv0);
   end

   % Clip polygon to the final length
   poly = poly(1:numv, :);
end

function a = vertex_importance(v, poly, numv)

   % Find adjacent vertices
   vp = 1 + mod(v, numv);
   vm = 1 + mod(v - 2, numv);

   % Obtain adjacent line segments and their lengths
   dir1 = transpose(poly(v, :) - poly(vm, :));
   dir2 = transpose(poly(vp, :) - poly(v, :));
   len1 = norm(dir1);
   len2 = norm(dir2);

   % Calculate angle between vectors and multiply by segment lengths
   % This is the importance of the vertex.
   % Vertices with large angle and large segments attached are less
   % likely to be removed
   len1len2 = len1 * len2;
   a = abs(acos((dir1' * dir2) / len1len2)) * len1len2;
   %a = abs(1 - ((dir1' * dir2) / len1len2)) * len1len2;
end
