function validateboundingbox(bbox, funcname, varname, argpos)
   %VALIDATEBOUNDINGBOX Function validation for 2x2 geographic bounding box.
   %
   %  VALIDATEBOUNDINGBOX(BBOX, FUNCNAME, VARNAME, ARGPOS) validates the
   %  bounding box array BBOX is a 2-by-2 array of double with real, finite
   %  values, and that in each column the second value always exceeds the first.
   %
   % See also: checkboundingbox

   % mgc modified based on checkboundingbox
   % Copyright 1996-2011 The MathWorks, Inc.

   validateattributes(bbox, {'double'}, {'2d', 'real','nonnan', 'size', [2,2]},...
      funcname,varname,argpos);

   if ~all(bbox(1,:) <= bbox(2,:))
      error(message('libspatial:boundingbox:invalidBBoxOrder',  ...
         upper(funcname), num2str(argpos), varname));
   end
end
