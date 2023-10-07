function [Demo, DemoSetGet] = demoSignatureFileInheritance(varargin)

   % If the class inherits from matlab.mixin.SetGet:
   DemoSetGet = DemoPropertyInheritanceSetGet();
   set(DemoSetGet, varargin{:})

   % If it does not have a set/get:
   Demo = DemoPropertyInheritance();
   for n = 1:numel(varargin)/2
      Demo.(varargin{2*n-1}) = varargin{2*n};
   end

   opts = cell2struct(varargin(2:2:end), varargin(1:2:end-1), 2);
   for field = transpose(fieldnames(opts))
      Demo.(field{:}) = opts.(field{:});
   end
   
   % Using string you can omit the brace indexing
   for field = transpose(string(fieldnames(opts)))
      Demo.(field) = opts.(field);
   end
   
end

% function Demo = demoSignatureFileInheritance(varargin)
%    Demo = DemoPropertyInheritance(varargin{:});
% end