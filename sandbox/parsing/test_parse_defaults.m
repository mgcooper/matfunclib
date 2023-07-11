function Defaults = test_parse_defaults(test_number, varargin)

Defaults = {'a', 'b', 'c'};

switch test_number
   case 1
      varargidx = ~cellfun('isempty',varargin);
      Defaults(varargidx) = varargin(varargidx);
   case 2
      numrequired = 1;
      numargs = nargin - numrequired;
      Defaults(1:numargs) = varargin;
   case 3
      numrequired = 1;
      numargs = nargin - numrequired;
      [Defaults(1:numargs)] = deal(varargin);
end
