function f = macfig(varargin)
    
    % 'mac' and 'full' are identical - they fill the screen
    % 'half', 'large', and 'horizontal' fill the top half
    % 'vertical' fills the half vertically
    % 'quarter' and 'medium' are identical, they fill a quarter horizontally
    % 'small' fills 1/16
    
    
    
    validOptions = {'main','mac','full','half','large','horizontal',    ...
                    'vertical','medium','quarter','small'};
    if nargin>0
        
        if any(contains(validOptions,varargin{1}))
            
            monitor = varargin{1}; varargin=varargin(2:end);
    
            if strcmp(monitor,'main')
                f = figure('Position',[1290,107,1152,624],varargin{:});
            elseif contains(monitor,{'mac','full'})
                f = figure('Position',[0 1 1152 624],varargin{:});
            elseif contains(monitor,{'half','large','horizontal'})
                f = figure('Position',[5 500 1152 624/2],varargin{:});
            elseif contains(monitor,{'vertical'})
                f = figure('Position',[5 500 1152/2 624],varargin{:});
            elseif contains(monitor,{'quarter','medium'})
                f = figure('Position',[5 500 1152/2 624/2],varargin{:});
            elseif strcmp(monitor,'small')
                f = figure('Position',[5 500 1152/3 624/2],varargin{:});
            else
                f = figure('Position',[0 1 1152 624],varargin{:});
            end
        else
        
        
        f = figure('Position',[0 1 1152 624],varargin{:});
            
        end
        
    else
        f = figure('Position',[0 1 1152 624]);
        return;
    end
    
    
end

