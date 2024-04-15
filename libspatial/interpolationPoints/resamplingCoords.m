function [xq,yq] = resamplingCoords(xbounds,ybounds,gridRes)
   %RESAMPLINGCOORDS creates new x,y coordinates to resample onto
   %
   %  [XQ, YQ] = resamplingCoords(XBOUNDS, YBOUNDS, GRIDRES) generates query grids
   %  XQ, YQ with horizontal resolution GRIDRES and uniform coverage of the sample
   %  space defined by XBOUNDS, YBOUNDS.
   %
   %
   % See also

   bbox = [min(xbounds) min(ybounds); max(xbounds) max(ybounds)];
   Rbox = bbox2R(bbox,gridRes);
   [xq,yq] = R2grid(Rbox);
   xq = xq(:);
   yq = yq(:);
end
