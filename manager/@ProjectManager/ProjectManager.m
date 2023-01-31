classdef ProjectManager
   %PROJECTMANAGER Summary of this class goes here
   %   Detailed explanation goes here

%    https://stackoverflow.com/questions/27077642/matlab-classes-getter-and-setters

   properties
      ProjectList
   end

   methods
      function obj = untitled27(inputArg1,inputArg2)
      %UNTITLED27 Construct an instance of this class
      %   Detailed explanation goes here
      obj.Property1 = inputArg1 + inputArg2;
      end

      function outputArg = method1(obj,inputArg)
      %METHOD1 Summary of this method goes here
      %   Detailed explanation goes here
      outputArg = obj.ProjectList + inputArg;
      end
   end
end