classdef DemoPropertyInheritance
   %DEMOPROPERTYINHERITANCE Demonstrate class property inheritance.

   properties
      Property1
      Property2
      Property3
   end

   methods
      function obj = DemoPropertyInheritance()
      end

      function obj = setProperty1(Value1)
         obj.Property1 = Value1;
      end
      
      function obj = setProperty2(Value2)
         obj.Property2 = Value2;
      end
      
      function obj = setProperty3(Value3)
         obj.Property3 = Value3;
      end
   end
end