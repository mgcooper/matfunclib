function showdocs(varargin)
%SHOWDOCS show help doc in browser.
%  
% 
% 
% See also: makedocs

   try
      showdemo(varargin{1});
   catch
      if nargin==1
         disp(['Cannot find documentation for ',varargin{1},'.'])
         disp('Opening the baseflow documentaton page.')
      end
      % showdemo(default_demofile) % TODO: add as input? 
   end

end