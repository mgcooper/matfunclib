function varargout = defaultGridData(varargin)
   %DEFAULTGRIDDATA Load, save, or view default gridded data
   %
   %  [X, Y] = defaultGridData()
   %  [X, Y, Z] = defaultGridData()
   %  [X, Y, Z, R] = defaultGridData()
   %  [_] = defaultGridData('load')
   %  defaultGridData('save')
   %  defaultGridData('plot')
   %
   % See also: validateGridData

   if nargin < 1
      option = 'load';
   else
      option = varargin{1};
   end
   
   switch option
      case 'save'
         try
            [Z, R] = readgeoraster('example_cells.tif');
         catch
            error('example_cells.tif not found')
         end
         [X, Y] = R2grid(R);

         save("data/gridded.mat", "X", "Y", "Z", "R")

      case 'load'
         load('gridded.mat', 'X', 'Y', 'Z', 'R')

      case 'plot'

         load('gridded.mat', 'X', 'Y', 'Z', 'R')
         plotraster(Z, X, Y)
         % rastersurf(Z, R)
         % plotraster(Z)
      otherwise
         error('unrecognized option')
   end
   [varargout{1:nargout}] = dealout(X, Y, Z, R);
end