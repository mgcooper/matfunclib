function tf = isemptystruct(S)
   %ISEMPTYSTRUCT Logical test if struct is empty.
   %
   %  tf = isemptystruct(S)
   %
   % See also: isempty isequalstruct

   tf = isstruct(S) && ...
      (isequal(S, struct()) || isequal(S, struct.empty)) ;
end
