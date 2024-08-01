function tf = validateLibraryName(name)
   tf = any(validatestring(name, cellstr(gettbdirectorylist))) ...
      && isscalartext(name);
end
