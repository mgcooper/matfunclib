function Qext = vdhscat(a,d,m,n,wl)
%VDHSCAT computes the van de Hulst approximation of the extinction
%efficiency as a faster/simpler alternative to Mie theory

% this came from:
% Maren Anna Brandsrud, Reinhold Blümel, Johanne Solheim, Eirik A.
% Magnussen, Eivind Seim, Achim Kohler, "Does chaotic scattering affect the
% extinction efficiency in quasi-spherical scatterers?," Proc. SPIE 11359,
% Biomedical Spectroscopy, Microscopy, and Imaging, 113590C (1 April 2020);
% doi: 10.1117/12.2556390

% note that the equations below are for a circle, not sure how to extend to
% sphere. also probably a better way to sum over the bessel functions, but
% it works, i tested varying n from 1:100000 and it converges around 100

% k = angular wave number   [radians/meter]
% a = radius
% m = refractive index

% ----------------- test values
a       = 0.0001;       % .1 mm
wl      = 600e-9;       % 600 nm
m       = 1.31;         % ice
% ----------------- test values

k       = 2*pi/wl;
rho     = 2*k*a*(m-1);

% ----------------- zeroth order bessel
J0      = besselj(0,rho);

% sum over 100
J       = 0;
for n = 1:100000
    ord     = 2*n;
    j       = 1/(4*n*n-1);
    J2n     = besselj(ord,rho);
    J       = J+J2n*j;
end

Qext    = 2-2*J0+4*J;

end

