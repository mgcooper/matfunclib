function tf = isscalarnan(x)
   tf = isscalar(x) && ~isstruct(x) && isnan(x);
end
