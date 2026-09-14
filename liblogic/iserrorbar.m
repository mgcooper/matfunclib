function tf = iserrorbar(h)
   %ISERRORBAR Return true if input H is an errorbar object.
   %
   %  tf = iserrorbar(h) returns true if h is a
   %  matlab.graphics.chart.primitive.ErrorBar object. In Octave, no object
   %  has this class, so tf is always false.
   %
   % See also: isaxis, isfig
   tf = isa(h,'matlab.graphics.chart.primitive.ErrorBar');
end
