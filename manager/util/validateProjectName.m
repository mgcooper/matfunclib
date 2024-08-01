function tf = validateProjectName(name)

   tf = isscalartext(name) && any(validatestring(name, ...
      cat(1, cellstr(projectdirectorylist), 'default')));
end
