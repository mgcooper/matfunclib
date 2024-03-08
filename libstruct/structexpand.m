function namedvalues = structexpand(S,varargin)
   %STRUCTEXPAND Convert struct of name-value pairs to varargin-like cell array
   %
   %
   % See also parser2varargin, namedargs2cell, cellexpand, struct2varargin,
   % stringexpand
   %
   % NOTE this does exactly what namedargs2cell (and struct2varargin) does

   opts = optionParser('asstring',varargin(:));

   if opts.asstring == true
      namedvalues = reshape(transpose([string(fieldnames(S)), struct2cell(S)]),1,[]);
   else
      namedvalues = reshape(transpose([fieldnames(S) struct2cell(S)]),1,[]);
   end
end
