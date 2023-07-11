function V = cellflatten(C)

try
   V = horzcat(C{:});
catch
   V = vertcat(C{:});
end

% % Cell2Vec is faster for very large cell arrays otherwise nearly identical
% V = Cell2Vec(C);