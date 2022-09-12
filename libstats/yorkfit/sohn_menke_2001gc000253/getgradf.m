function [F] = getgradf(Z,N,M,Fval)

%
% **********************************
%
% gradient matrix calculator
%
% RAS 8/01
%
% **********************************

% forms gradient matrix for non-linear maximum likelihood
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

    F=zeros(N,M);

    Na=6.022e23;   % Avogadro's #
    R=8.314;      % Gas constant, g-moles-joules

    T=Z(2*N+4);   % temp for fit
    C=-4*pi*Na/(R*T);	% constant term
    ri=Z(N+4:2*N+3);
    r0=Z(N+3);
    E=Z(N+2);
    D0=Z(N+1);
    dr=ri-r0;
    dr2=ones(N,1)*r0^2-ri.^2;
    A=exp(C*E*((r0/2)*dr.^2+(dr.^3)/3))

    m1=-ones(N,1);
    F(:,1:N)=diag(m1);	% first N-columns are -1 on diagonal, df/dDi
    F(:,N+1)=A;		% N+1 column is df/dD0
    F(:,N+2)=A*C*D0.*((r0/2)*dr.^2+(dr.^3)/3);	% N+2 column is df/dE
    F(:,N+3)=D0*C*E*A.*dr2/2;  % N+3 column is df/dr0

elseif Fval==3

    Na=6.022e23;   % Avogadro's #
    R=8.314;      % Gas constant, g-moles-joules

    T=Z(2*N+4);   % temp for fit
    C=-4*pi*Na/(R*T);     % constant term
    ri=Z(N+4:2*N+3);
    r0=Z(N+3);
    E=Z(N+2);
    D0=Z(N+1);
    Di=Z(1:N);
    dr=ri-r0;
    dr2=ones(N,1)*r0^2-ri.^2;
    fr=((r0/2)*dr.^2+(dr.^3)/3);

    m1=-ones(N,1)./Di;
    F(:,1:N)=diag(m1);    % first N-columns are -1 on diagonal, df/dDi
    F(:,N+1)=(1/D0)*ones(N,1);           % N+1 column is df/dD0
    F(:,N+2)=10^(-20)*C*fr;    % N+2 column is df/dE
    F(:,N+3)=10^(-20)*C*E*dr2/2;  % N+3 column is df/dr0

else

    error('Unrecognized Fval')

end
