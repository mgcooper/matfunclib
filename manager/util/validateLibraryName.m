function tf = validateLibraryName(name)
   tf = isscalartext(name) ...
      && ~isempty(validatestring(name, cellstr(gettbdirectorylist)));
end
