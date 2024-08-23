function tf = validateProjectName(name)
   tf = isscalartext(name) && ~isempty(validatestring(name, ...
      cat(1, cellstr(projectdirectorylist), 'default')));
end
