function data = genCurveData(opts)
    
    xmu     = opts.x.mu_data;
    xmuerr  = opts.x.mu_err;
    ymuerr  = opts.y.mu_err;
    xsigerr = opts.x.sig_err;
    ysigerr = opts.y.sig_err;
    N       = opts.N;
    Nboot   = opts.Nboot;
    
    % create an ensemble of data with random errors
    x       = xmu .* sort(rand(N,1));
    y       = opts.a + opts.b*x;
    xerr    = normrnd(xmuerr,xsigerr,N,Nboot);
    yerr    = normrnd(ymuerr,ysigerr,N,Nboot);
    rxy     = arrayfun(@(k) corr(xerr(:,k),yerr(:,k)),1:Nboot,'Uni',1);

    data.x      = x;
    data.y      = y;
    data.xerr   = xerr;
    data.yerr   = yerr;
    data.xobs   = x+xerr;
    data.yobs   = y+yerr;
    data.rxy    = rxy;
    data.X      = [ones(size(x)),x];
    data.Xobs   = [ones(size(x)),data.xobs];
    
end

