function [ bp ] = multiBoxplot( xdim, varargin )
%MULTIBOXPLOT Allows you to plot multiple boxplots on one figure easily.
%   Accepts any number of inputs, can be of varying lengths as well
%   XDIM specifies which dimension of the data should be on the x axis

[a,b,c] = size(varargin{1});

x = [];
g = [];

for m = 1:length(varargin);
    
    if xdim == 1;
        
        for n = 1:a;
            
            x1 = varargin{m}(n,:);

            g1 = n*ones(size(x1));
            
            x = [x x1];
            
            g = [g g1];
            
        end
        
    end
            
    if xdim == 2;
        
        for n = 1:b;
            
            x1 = varargin{m}(:,n);

            g1 = n*ones(size(x1));
            
            x = [x;x1];
            
            g = [g;g1];
            
        end
        
    end

end

bp = boxplot(x,g);