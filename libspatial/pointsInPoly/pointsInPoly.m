function Points = pointsInPoly(x,y,poly,varargin)
%POINTSINPOLY extracts x,y points that are within poly + buffer

%     Author: matt cooper (matt.cooper@pnnl.gov)
    
% % For reference, what this is doing:
%     box     =   polyshape(lonbox,latbox);
%     in      =   inpolygon(lon,lat,lonbox,latbox);
%     varin   =   var(in);
%     latin   =   lat(in);
%     lonin   =   lon(in);

% % then interpolationPoints resamples latin/lonin to high-resolution
%   and clips the points to the polygon. 

   p                = inputParser;
   p.FunctionName   = 'pointsInPoly';

   addRequired(p,'x',@(x)isnumeric(x));
   addRequired(p,'y',@(x)isnumeric(x));
   addRequired(p,'poly',@(x)isa(x,'polyshape'));
   addParameter(p,'buffer',nan,@(x)isnumeric(x));
   addParameter(p,'xbuffer',nan,@(x)isnumeric(x));
   addParameter(p,'ybuffer',nan,@(x)isnumeric(x));
   addParameter(p,'makeplot',false,@(x)islogical(x));
   addParameter(p,'bufferbox',true,@(x)islogical(x));
  %addParameter(p,'pointinterp',false);
   
   parse(p,x,y,poly,varargin{:});
   
   buffer      = p.Results.buffer;
   xbuffer     = p.Results.xbuffer;
   ybuffer     = p.Results.ybuffer;
   bufferbox   = p.Results.bufferbox;
   makeplot    = p.Results.makeplot;
  %pointinterp = p.Results.pointinterp;
  
  % decided it doesn't make sense to have a pointinterp option, instead
  % that is in interpolationPoints
  
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
% feb 2022, new method buffers the bounding box, much faster for complex
% catchment polgyons with many vertices which are very slow with polybuffer

dobuffer = false;

% first determine if any buffering is requested
if notnan(buffer) || notnan(xbuffer) || notnan(ybuffer)
   
   dobuffer = true;

   % check for x/y buffer and issue errors if incombatible with other options
   if (isnan(xbuffer) && notnan(ybuffer)) || (notnan(xbuffer) && isnan(ybuffer))
      error(['both xbuffer and ybuffer are required if either are specified. ' ...
      newline ' use default option ''buffer'' for constant buffer distance'])
   end

   % if x/ybuffer is requested, only bufferbox is supported
   if notnan(xbuffer) && bufferbox == false
      error('x/y buffer option only supported for option ''bufferbox''')
   end

end

% the logic is: 
%  if bufferbox is requested, make a bounding box
%     if x/y buffer is requested, extend the box in the x-y direction
%        in this case, set buffer to zero, the box is now buffered
%     if not, use the value of buffer to buffer the box
%  ifnot, buffer the poly

% deal with the buffer box
if dobuffer == true && bufferbox == true
   
   [xb,yb]  =  boundingbox(poly);
   
   % if x/ybuffer is requested, buffer the bbox in the x-y directions
   if notnan(xbuffer)
      xb       =  [xb(1)-xbuffer xb(2)+xbuffer];
      yb       =  [yb(1)-ybuffer yb(2)+ybuffer];
      buffer   =  0;
   end
   % we set buffer to zero b/c x/ybuffer already applied, this way we can
   % make xrect/yrect and call polyshape for the x/ybuffer and buffer cases
   
   % convert the bbox to a polyshape
   xrect    =  [xb(1) xb(2) xb(2) xb(1) xb(1)];
   yrect    =  [yb(1) yb(1) yb(2) yb(2) yb(1)];

   % buffer the box
   polyb    =  polybuffer(polyshape(xrect,yrect),buffer); 
   
elseif dobuffer == true && bufferbox == false
   
   % buffer the provided polyshape
   polyb    =   polybuffer(poly,buffer);
end

% figure; plot(poly); hold on; plot(xrect,yrect);    

% find the points in the poly
   xp      =   poly.Vertices(:,1);
   yp      =   poly.Vertices(:,2);
   inp     =   inpolygon(x,y,xp,yp);

   % assign output
   Points.poly       = poly;
   Points.xpoly      = xp;
   Points.ypoly      = yp;
   Points.inpoly     = inp;

% find the points in the poly + buffer 
if dobuffer == true

   xpb     =   polyb.Vertices(:,1);
   ypb     =   polyb.Vertices(:,2);
   inpb    =   inpolygon(x,y,xpb,ypb);
        
   % assign output    
   Points.polyb      = polyb;
   Points.xpolyb     = xpb;
   Points.ypolyb     = ypb;
   Points.inpolyb    = inpb;
   
else
   
   % assign inpoly to inpolyb consistent syntax outside the function i.e.
   % for no buffer, inpolyb = inpoly, but outside the function we can
   % always use inpolyb
   Points.polyb      = poly;
   Points.xpolyb     = xp;
   Points.ypolyb     = yp;
   Points.inpolyb    = inp;
   
end
       
    
if makeplot == true
   
   figure; 
   if dobuffer == true
      plot(polyb); hold on; plot(poly); 
   else
      plot(poly); hold on;
   end
   
   if dobuffer == true
      scatter(x(inpb),y(inpb),'filled');
      scatter(x(inp),y(inp),'filled');
      legend('buffer','poly','in buffer','in poly',...
            'numcolumns',4,'location','northoutside');
   else
      scatter(x(inp),y(inp),'filled');
      legend('poly','in poly',...
            'numcolumns',2,'location','northoutside');
   end
      
end

end

