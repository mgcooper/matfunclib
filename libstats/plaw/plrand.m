function plnum = plrand(N,alpha,xmin)

    % p(x)=(alpha-1)*x^(-alpha)
    plnum = xmin.*(1-rand(N,1)).^(1/(-alpha+1));
end