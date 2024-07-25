function [cells, names] = structToCell(S)
   names = fieldnames(S);
   cells = struct2cell(S);
end
