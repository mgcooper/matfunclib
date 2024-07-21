function tf = isncstruct(info)
   %ISNCSTRUCT Determine if input is an ncinfo struct
   %
   %  tf = isncstruct(info)
   %
   % See also: isnctable

   tf = isstruct(info) && isfield(info, 'Attributes') ...
      && isstruct(info.Attributes) && isfield(info.Attributes, 'Name');
end
