function [B] = simplifyPolyline(A, tol)
   %SIMPLIFYPOLYLINE
   %
   %  [B] = simplifyPolyline(A, tol)
   %
   % simplifyPolyline() simplifies polyline to the required detail by removing
   % vertices. The detail level is controlled by tol. The simplification is done
   % by decimating the polyline to fewer number of vertices by using
   % Ramer–Douglas–Peucker algorithm.
   %
   % [B] =  simplifyPolyline(A, tol) returns a simplified polyline,
   %        B, of input polyline A.
   %
   % Input
   %   A    : polyline coordinates [nPoints x nDim]
   %   tol  : threshold distance, if the point lies outside the threshold then
   %          it is included i.e.coarser the value greater the simplification.
   % Output
   %   B    : simplified polyline coordinates [mPoints x nDim],
   %          where mPoints <= nPoints
   %
   % @author    Naveen Somasundaram, Novemeber 2021

   % mgc: had a polyshape with >100000 verts, caused matlab to freeze, tried
   % various ways to deal with it, ended up using polyreduce (see exactremap)
   % which employs an angular-based metric to determine veertex importance, but
   % the Ramer–Douglas–Peucker algo used here is more standard. i don't think I
   % use this anywhere

   nPoints = size(A, 1);
   if nPoints <= 2
      B = A;
      return
   end

   % Fetch Points
   x1 = A(1, :);             % Start Point
   x2 = A(nPoints, :);       % End Point
   x  = A(2:nPoints - 1, :); % Intermediate points

   % Find shortest distance from intermediate points (x) to line
   % segment joining (x1) and (x2)
   t = -sum((x2 - x1).* (x1 - x), 2) / sum((x2 -x1).^2);
   t = min(1, max(t, 0));
   d = sqrt(sum((x1 + t.*(x2-x1) - x).^2, 2));

   % Find largest distance and corresponding point
   [dmax, ind] = max(d);
   ind = ind + 1;

   % If dmax is greater than tol, split the line into two and repeat; else
   % return the line approximated by start and end point
   if(dmax > tol)
      B1 = simplifyPolyline(A(1:ind, :), tol);
      B2 = simplifyPolyline(A(ind:nPoints, :), tol);
      B  = [B1(1:end-1, :); B2(1:end, :)];
   else
      B  = [A(1, :); A(nPoints, :)];
   end
end

%% LICENSE
% Copyright (c) 2021, Naveen Somasundaram
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
%
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
%
% * Neither the name of  nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
