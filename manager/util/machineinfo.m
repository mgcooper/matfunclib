function machineinfo()
   %MACHINEINFO Return machine info
   %
   %  machineinfo()
   % 
   % See also: computer
   
   % My machine:
   % MacBook Pro (16-inch, 2019)
   % Processor: 2.4 GHz 8-Core Intel Core i9
   % Memory: 64 GB 2667 MHz DDR4
   % Graphics: AMD Radeon Pro 5600M 8 GB

   % version(-lapack) returns the same info as version(-blas) PLUS the lapack vers
   str = [newline ...
      "MacBook Pro (16-inch, 2019)" newline ...
      "Processor: 2.4 GHz 8-Core Intel Core i9" newline ...
      "Memory: 64 GB 2667 MHz DDR4" newline ...
      "Graphics: AMD Radeon Pro 5600M 8 GB" newline ...
      ... "Math Kernel Library (blas): " version('-blas') newline ...
      "Math Kernel Library: " version('-lapack') newline ...
      newline];

   fprintf('%s',str)

   % -in your version of the help type in "Math Kernel Library"
   % -https://www.mathworks.com/matlabcentral/answers/2178-how-to-know-what-version-of-mkl-is-matlab-using
end
