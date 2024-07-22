function varargout = call_dealout2(varargin)

   if nargin < 1
      option = 1;
   else
      option = varargin{1};
      varargin = varargin(2:end);
   end

   mat1 = magic(1);
   mat2 = magic(2);
   mat3 = magic(3);
   mat4 = magic(4);

   arg1 = num2cell(mat1, 1);
   arg2 = num2cell(mat2, 2);
   arg3 = num2cell(mat3, 2);
   arg4 = num2cell(mat4, 2);

   switch option
      case 1
         varargout = dealout2(arg1, arg2, arg3);
      case 2
         varargout = dealout2({arg1, arg2, arg3});
      case 3
         % more outputs than inputs, depending on how many are called
         varargout = dealout2(arg1);
      case 4
         [varargout{1:nargout}] = dealout2(arg1, arg2, arg3);
      case 5
         [varargout{1:nargout}] = dealout2({arg1, arg2, arg3});
      case 6
         % more outputs than inputs, depending on how many are called
         [varargout{1:nargout}] = dealout2(arg1);
   end
end
