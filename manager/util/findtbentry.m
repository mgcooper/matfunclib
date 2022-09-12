function tbidx = findtbentry(toolboxes,tbname)
   
   tbidx = ismember(lower(toolboxes.name),lower(tbname));