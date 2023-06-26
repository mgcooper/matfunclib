function [x, y] = gridCoords(nrows, ncols, xll, yll, cellsize)
%GRIDCOORDS returns the x y coordinates of the centroid of each cell in a
%grid, since arcmap won't do this as far as I can figure out

rows = 1:nrows;
cols = 1:ncols;


y = (yll + (rows.*cellsize - .5*cellsize));
x = (xll + (cols.*cellsize - .5*cellsize));

end

