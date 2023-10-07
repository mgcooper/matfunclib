function f = commonfields(varargin)

   error([mfilename ' is not functional'])

   % NOTE: need to decide on the two options which would require an optional
   % argument that would need ot be removed from varargin using isstruct most
   % likely

   F = cellfun(@fieldnames,varargin,'uni',0);
   f = cellfun(@(x) intersect(x,F{1}),F,'uni',0);

   % keep the one with the least # of common fields, including zero
   f = f(argmin(cellfun('prodofsize',f)));

   % discard any with zero then keep the one with the least # of common fields
   f = f(~cellfun('isempty',f));
   f = f(argmin(cellfun('prodofsize',f)));
end
