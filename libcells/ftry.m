function fcn = ftry(tryfcn, catchfcn, varargin)
%FTRY Functional inline try/catch statement.
%
%  fcn = ftry(@tryfcn, @catchfcn, ...)
%
% See also fifelse

arguments
   tryfcn (1,1) function_handle
   catchfcn (1,1) function_handle
end

arguments (Repeating)
   varargin
end

try
   fcn = tryfcn(varargin{:});
catch ME
   fcn = catchfcn(ME, varargin{:});
end