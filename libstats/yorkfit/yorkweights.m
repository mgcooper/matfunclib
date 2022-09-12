function W = yorkweights(sigx,sigy,rxy,b)
    
    wX  = 1./sigx.^2;
    wY  = 1./sigy.^2;
    
    if rxy == 0
        W  = (wX.*wY)./(b^2.*wY+wX);
    else
        W  = (wX.*wY)./(b^2.*wY+wX-2*b.*rxy.*sqrt(wX.*wY)); 
    end