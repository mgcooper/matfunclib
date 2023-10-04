function [X,Y] = fastgrid(X,Y)
   %FASTGRID fast creation of 2d grid from vectors X,Y in meshgrid format
   %
   %  [X,Y] = fastgrid(X,Y) works exactly like meshgrid(X,Y) for vectors X,Y
   %
   % Matt Cooper, 19-Apr-2023, https://github.com/mgcooper
   %
   % See also: meshgrid, ndgrid, fullgrid

   try
      X = repmat(full(X(:)).', numel(Y), 1);
      Y = repmat(full(Y(:)), 1, size(X, 2));
   catch
   end
end
