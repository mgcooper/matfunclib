function tf = isCoordinateCellVector(P)

   tf = iscell(P) && isvector(P) ...      % isCellVector
      && all(cellfun(@ismatrix, P)) ...   % isMatrixValued
      && none(cellfun(@isvector, P));
end
