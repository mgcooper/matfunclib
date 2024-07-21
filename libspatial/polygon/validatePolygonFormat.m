function validatePolygonFormat(inputFormat, kwargs)

   arguments(Input)
      inputFormat
      kwargs.mfilename
      kwargs.argname
      kwargs.argidx
   end

   switch inputFormat

      case 'PolyshapeCellVector'

         validateattributes(P, {'cell'}, {'column'}, ...
            kwargs.mfilename, kwargs.argname, kwargs.argidx);

      case 'CoordinateCellVector'

         validateattributes(P, {'cell'}, {'column'}, ...
            kwargs.mfilename, kwargs.argname, kwargs.argidx);

      case 'CoordinateCellArray'

         validateattributes(P, {'cell'}, {'2d', 'ncols', 2}, ...
            kwargs.mfilename, kwargs.argname, kwargs.argidx);

      case 'PolyshapeVector'

         validateattributes(P, {'polyshape'}, {'column'}, ...
            kwargs.mfilename, kwargs.argname, kwargs.argidx);

      case 'CoordinateArray'

         validateattributes(P, {'numeric'}, {'2d', 'ncols', 2}, ...
            kwargs.mfilename, kwargs.argname, kwargs.argidx);

         % This still may be needed here
         % P = arraymap(@(p) p, P.regions);

         % For reference, an older method I thought was necessary
         % P = parseNanDelimitedPolygons(P);

      otherwise
         error('Unrecognized polygonFormat')
   end
end
