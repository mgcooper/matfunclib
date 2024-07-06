function [lon, lat, dataGrids] = ncorient(lon, lat, dataGrids)

   arguments (Input)
      lon = []
      lat = []
   end
   arguments (Input, Repeating)
      dataGrids
   end
   arguments (Output)
      lon
      lat
   end
   arguments (Output, Repeating)
      dataGrids
   end

   % Ensure lon/lat are full-grids oriented as row-major
   lon = reshape(sort(unique(lon(:)),'ascend'), 1, []);
   lat = reshape(sort(unique(lat(:)),'ascend'), [], 1);
   [lon, lat] = ndgrid(lon, lat);

   % Apply the standard re-orientation to obtain column-major, north-up grids.
   lon = flipud(permute(lon, [2, 1]));
   lat = flipud(permute(lat, [2, 1]));

   % Process each data grid
   for n = numel(dataGrids):-1:1
      dataGrids{n} = flipud(permute(dataGrids{n}, [2, 1, 3]));
   end
end

% function verify(lon, lat)
%    % Given a known 2d lon, lat grid already oriented , this can be used to test
%    X = reshape(sort(unique(lon(:)),'ascend'),1,[]);
%    Y = reshape(sort(unique(lat(:)),'ascend'),[],1);
%    [X, Y] = ndgrid(X, Y);
%    X = flipud(permute(X, [2, 1]));
%    Y = flipud(permute(Y, [2, 1]));
%    isequal(X(:), lon(:))
%    isequal(Y(:), lat(:))
% end
