function tf = isnctable(info)
   %ISNCTABLE Determine if input is an ncinfo table
   %
   %  tf = isnctable(info)
   %
   % See also: isncstruct

   tf = istable(info) && isvariable('Attributes', info) ...
      && isstruct(info.Attributes{1}) && isfield(info.Attributes{1}, 'Name');
end
