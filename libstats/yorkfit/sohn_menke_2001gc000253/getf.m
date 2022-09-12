function [f] = getf(Z,N,M,Fval)

%
% **********************************
%
% function calculator
%
% RAS 8/01
%
% **********************************

% calculates function value for non-linear maximum likelihood
% routine MLEiter
%
% inputs are;
% (1) Z, vector with all data required to calculate F
% (2) N, #rows in F
% (3) M, #columns in F
% (4) Fval, an index describing the nature of the governing equation
%

% Fval=1 is a straight line equation
% Fval=2 is the crysal-melt partition coefficient equation

if Fval==2

    f=zeros(N,1);

    Na=6.022e23;	% Avogadro's #
    R=8.314;	% Gas constant, g-moles-joules

    T=Z(2*N+4);	% temp for fit
    C=-4*pi*Na/(R*T);	% constant term
    Di=Z(1:N);
    ri=Z(N+4:2*N+3);
    r0=Z(N+3);
    E=Z(N+2);
    D0=Z(N+1);
    dr=ri-r0;
    A=exp(C*E*((r0/2)*dr.^2+(dr.^3)/3));

    f=D0*A-Di;

elseif Fval==3

    f=zeros(N,1);

    Na=6.022e23;  % Avogadro's #
    R=8.314;      % Gas constant, g-moles-joules

    T=Z(2*N+4);   % temp for fit
    C=-4*pi*Na/(R*T);     % constant term
    Di=Z(1:N);
    ri=Z(N+4:2*N+3);
    r0=Z(N+3);
    E=Z(N+2);
    D0=Z(N+1);
    dr=ri-r0;
    A=10^(-20)*C*E*((r0/2)*dr.^2+(dr.^3)/3);

    f=log(D0)+A-log(Di);

else

    error('Unrecognized Fval')

end
