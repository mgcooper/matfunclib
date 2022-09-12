function c = mycbar( width,height,location,title,label )

    narginchk(3,5)
    switch nargin
        case 3
            c = mycolorbar( width,height,location);
        case 4
            c = mycolorbar( width,height,location,title);
        case 5
            c = mycolorbar( width,height,location,title,label);
    end
            
end

