function c = setcolorbar(c,varargin)
    
    switch varargin{1}
        case 'Title'
            c.Title.String  = varargin{2};
        case 'Location'
            c.Location      = varargin{2};
    end
    
    
end