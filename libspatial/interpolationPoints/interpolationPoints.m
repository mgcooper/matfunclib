function Points = interpolationPoints(poly,xgrid,ygrid,buffer,newRes,varargin)
   %INTERPOLATIONPOINTS Build grid of query points inside polygon.
   %
   %  Points = interpolationPoints(poly,xgrid,ygrid,buffer,newRes) returns
   %  POINTS, a structure containing coordinates in XGRID/YGRID found in POLY
   %  and new query points XQ/YQ with horizontal resolution NEWRES resampled
   %  from the found XGRID/YGRID points. Optional argument BUFFER extends the
   %  search space around POLY.
   %
   % See also: pointsInPoly resamplingCoords

   % parse inputs
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addParameter('makeplot',false,@islogical);
   parser.addParameter('plotvar',ones(size(xgrid)),@isnumeric);
   parser.addParameter('pointinterp',false,@islogical);
   parse(parser,varargin{:});
   opts = parser.Results;

   % First find coordinates of xgrid/ygrid within poly+buffer, then
   % build a new grid with spacing newRes and clip the new grid points
   % that exist with the poly (w/o buffer).

   % get the coarse resolution points inside the poly + buffer
   Mask = pointsInPoly(xgrid,ygrid,poly,'buffer',buffer);

   % create a sampling grid at fine resolution
   xmin = min(Mask.xpolyb);
   xmax = max(Mask.xpolyb);
   ymin = min(Mask.ypolyb);
   ymax = max(Mask.ypolyb);

   if opts.pointinterp
      % interpolate to the centroid of the polygon
      [xq,yq] = poly.centroid;
      Maskq = pointsInPoly(xq,yq,poly,'buffer',0);
   else
      % interpolate to a high-resolution grid
      [xq,yq] = resamplingCoords([xmin xmax],[ymin ymax],newRes);
      % clip the points within the polygon (using a buffer of 0)
      Maskq = pointsInPoly(xq,yq,poly,'buffer',0);
      xq = xq(Maskq.inpoly);
      yq = yq(Maskq.inpoly);
   end

   % verify by plotting the lakes and the 100-m points inside them
   if opts.makeplot

      idx = Mask.inpolyb;
      h.figure = macfig('size','horizontal');

      % plot the entire region
      h.subplot(1) = subplot(1,3,1);
      h.grid(1) = scatter(xgrid,ygrid,12,opts.plotvar(:),'filled'); hold on;
      h.poly(1) = plot(poly);
      h.ax(1) = gca;
      title('grid points available for interpolation')
      legend('grid points','poly');

      % plot the points captured by the bounding box
      h.subplot(2) = subplot(1,3,2);
      h.grid(2) = scatter(xgrid(idx),ygrid(idx),60,'filled'); hold on;
      labelpoints(xgrid(idx),ygrid(idx),num2str(find(idx)));
      h.poly(2) = plot(poly);
      h.ax(2) = gca;
      title('grid points used for interpolation')
      legend('grid points','poly');

      % check the high-res grid cells used to interpolate
      h.subplot(3) = subplot(1,3,3);
      h.grid(3) = scatter(xq,yq,20,'filled'); hold on;
      h.poly(3) = plot(poly);
      h.ax(3) = gca;
      title('interpolation points for catchment-scale runoff');
      legend('grid points','poly');

      % if point interpolation is requested, modify the plot
      if opts.pointinterp
         scatter(h.subplot(1),xq,yq,100,rgb('red'),'filled');
         scatter(h.subplot(2),xq,yq,100,rgb('red'),'filled');
         scatter(h.subplot(3),xq,yq,100,rgb('red'),'filled');
         labelpoints(xq,yq,'point interpolation');
      end

      Points.h = h;
   end

   Points.xq = xq;
   Points.yq = yq;
   Points.maskq = Maskq;
   Points.xinbuffer = xgrid(Mask.inpolyb);
   Points.yinbuffer = ygrid(Mask.inpolyb);
   Points.maskbuffer = Mask;
end
