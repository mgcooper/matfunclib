function data = defaultCurveData

    opts.a          = 5;
    opts.b          = 2;
    opts.N          = 100;
    opts.Nboot      = 1000;
    opts.x.mu_data  = 10;
    opts.x.mu_err   = 1;
    opts.x.sig_err  = 2;
    opts.y.mu_err   = 1;
    opts.y.sig_err  = 2;
    opts.corr_err   = 0.75;
    data            = genCurveData(opts);
end