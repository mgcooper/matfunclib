function tf = isCoordinateCellArray(P)

   tf = iscell(P) && ismatrix(P) ...      % isCellMatrix
      && all(all(cellfun(@isvector, P))); % isVectorValued
end
