function N = figcount()
   %FIGCOUNT Count the number of open figures
   %
   %  N = figcount()
   %
   % See also getopenfigs
   
   h =  findobj('type', 'figure');
   N = length(h);
end
