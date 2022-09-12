clean

% b     = volume attenuation (equal to scattering for non-absorbing sphere)
% Qsca  = scatering efficiency
% N     = number of bubbles in volume Vw of water
% Vw    = volume of water

% taken together:
% b = Qsca * N/Vw * s

% the fraction of air in the volume of water is the number of bubbles times
% the volume of each bubble divided by the volume of water:
% f     = Vair/Vw = N*v/Vw, where v = volume of bubble
% Therefore, 


% f   = 0.9;
% b1  = Qsca.*N./Vw.*s;
% b2  = 2.*f.*s./v;


%%%%%%% check scattering size parameter against their reported results

wavl        = (300:2000)*1e-9;      % 300-2000 nm
reff        = 650e-6;               % 650 um
chi_scat    = 2*pi*reff./wavl;

figure; semilogy(wavl,chi_scat); hline(100); legend('1 nm','1 um','1 mm')

% % this is to validate the geometric optics (or maybe the ADT)
% wavl = (300:2000)*1e-9;
% Deff = [1e-9;1e-6;1e-3];
% xe  = pi.*Deff./wavl;
% figure; semilogy(wavl,xe); hline(50); legend('1 nm','1 um','1 mm')

% so thy report reff about 1/2 a millimeter, whihc puts them in the GO
% regime, but what are realistic air bubble sizes?

% Dadic reports the following:
ssa = [1.91,820; 1.04,847; 0.57,878; 0.36,894; 0.17,894; 0.15,882];
for n = 1:length(ssa)
    rbub(n) = ssa2bubsize(ssa(n,1),ssa(n,2));
    xe(n)   = 2*pi*rbub(n)/900e-9;
    if xe(n) > 100
        disp('GO ok')
    end
end
xe
rbub*1000 % milimeters
rbub*2000 % milimeters, diameter, for comparison with Fig. 10

% play with lower densities
1000*ssa2bubsize(ssa(n,1),0.8*ssa(n,2));

% cook reports reff about 650 um, so convert that to mm to check w/Dadic
650e-6*1000

% that is pretty similar


rho = 400:1:917;
rb1 = 1e-4;
rb2 = 1e-3;
rb3 = 1e-2;
plot(rho,3/(917*rb1).*(917./rho-1)); hold on;
plot(rho,3/(917*rb2).*(917./rho-1));
plot(rho,3/(917*rb3).*(917./rho-1));
xlabel('density'); ylabel('SSA'); 
legend('r_{bub} = 0.1mm', 'r_{bub} = 1.0mm','r_{bub} = 10mm');

% compute sigma_a using ADT
load(setpath('GREENLAND/field/2018/data/processed/20july/d_coefficients/Kabs.mat'));
load(setpath('GREENLAND/field/2018/data/processed/20july/f_iops/mie_iops.mat'));
rg      = 10e-3;     % 1 mm particle radius
Ag      = pi*rg*rg;
Vg      = 4/3*pi*rg*rg*rg;
% ka    = Kabs.interp.kabs;
% wavl  = Kabs.interp.wavl;
ka      = iops.kice.kabs;
omeg    = iops.kice.omeg;
wavl    = iops.kice.wavl;
sige    = 2*Ag;
siga    = Ag*(1-exp(-4/3*rg.*ka));
siga    = Ag*(1-exp(-ka*Vg/Ag));

figure; plot(wavl,siga); hold on;
xlabel('wavl'); ylabel('\sigma_a');
set(gca,'YScale','log');

figure; 
plot(wavl,siga); hold on;
plot(wavl,iops.kice.siga);
xlabel('wavl'); ylabel('\sigma_a');
set(gca,'YScale','log');
legend('ADT','MIE')


% compare omega
figure; 
plot(wavl,1-siga./sige); hold on;
plot(wavl,iops.kice.omeg);
xlabel('wavl'); ylabel('\omega');
set(gca,'YScale','log');
legend('ADT','MIE')

figure; 
plot(wavl,siga./sige); hold on;
plot(wavl,1-iops.kice.omeg);
xlabel('wavl'); ylabel('1-\omega');
set(gca,'YScale','log');
legend('ADT','MIE')

% pytting this here temporarily
ri  = 0.01;
rhoi = 850;
ssa1 = 3/(rhoi*ri)
ssa2 = 4*pi*ri*ri/rhoi





% define a number density of air bubbles as a function of radius

r   = exprnd(0.001);




% the difference between using trapz and just summing is that summing
% assumes a piece-wise constant relationship i.e. a discrete number of
% known values, whereas trapz is approximating a continuous function

% note: technically nr = nr./dr and there should b a .*dr in each integral
rhoi    = 917;
r       = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0];
nr      = [15  14  12  10  10  9   7   7   4   1];
phi     = sum(4*pi.*r.^2)/sum(rhoi*4/3*pi.*r.^3)
%phi    = 3/rhoi*trapz(1./r.*nr)
chk     = 3/rhoi*trapz(r.^2.*nr)/trapz(r.^3.*nr)
chk     = trapz(3.*r.^2.*nr)/trapz(rhoi.*r.^3.*nr)

SA      = sum(4.*pi.*r.^2.*nr)      % exact total surface area
SAchk   = trapz(4*pi.*r.^2.*nr)     % approximate total surface area
A       = sum(pi.*r.^2.*nr)         % exact total x-sectional area
Achk    = trapz(pi.*r.^2.*nr)       % approximate total x-sectional area
V       = sum(4/3*pi.*r.^3.*nr)     % exact total volume
Vchk    = trapz(4/3*pi.*r.^3.*nr)   % approximate total volume
reSA    = 3*V/SA                    % effective radius in terms of V/SA
reA     = 3/4*V/A                   % effective radius in terms of V/A
ssa     = SA/rhoi/V                 % exact SSA 
ssachk  = SAchk/rhoi/Vchk           % approximate SSA 
ssaSA   = 3/reSA/917                % SSA from effective radius
ssaA    = 3/reA/917                 % SSA from effective radius


n       = numel(r);

figure; plot(r,4.*pi.*r.^2.*nr)

ssa = 3/reSA/917
chk = trapz(3/pi*1./r.*dr)

% plot the size distribution
figure; plot(r,nr)

wmean(r,nr./sum(nr))
trapz(r.*dr)



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% for bubbly ice, the average distance traveled by a photon through the ice
% is 4/ssa/rho, or 4*r/3*rhoi/(rhoi-rho). the absorption coefficient is
% then the absorption of pure ice times this distance divided by the total
% distance, which I showed is just rho/rhoi, which is the value used by
% Mullen and Warren and Dadic, so this confirms that there is no path
% lengthening due to scattering on bubbles, 
% 

r       = linspace(1e-4,1e-3,100);
rho     = 800;
rhoi    = 917;

figure; 
plot(r,4/3*(rhoi/(rhoi-rho)).*r);
hline(rho./rhoi)





rho     = 600:917;
figure; plot(rho,rhoi./(rhoi-rho));
xlabel('density');
ylabel('dB/dG')
xlim([600 880])


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% define two combinations of bubble density 

rho1    = 400;
rho2    = 800;
ssa     = 1.35;

r1      = ssa2bubsize(ssa,rho1)
r2      = ssa2bubsize(ssa,rho2)





%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% choose de or not and load the data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

use_dE  = true;
path    = setpath('GREENLAND/field/2018/data/processed/20july/f_iops/');

if use_dE == true
    load([path 'mie_iops_dE.mat']);
else
    
end

ka      = iops.kabs.kabs;
omeg    = iops.kabs.omeg;
wavl    = iops.kabs.wavl;
asym    = iops.kabs.asym;
sige    = iops.kabs.sige;
sigs    = iops.kabs.sigs;
kext    = iops.kabs.afec;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% plot the effective scattering coeff
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
figure; 
plot(wavl,sigs.*(1-asym))
xlabel('wavelength'); ylabel('effective scattering coefficient (1/m)');
figformat

figure; 
subplot(1,2,1);
plot(wavl,100./(sigs.*(1-asym))); hold on;
plot(wavl,100./(sige.*(1-asym)))
plot(wavl,100./kext)
set(gca,'YScale','log');

xlabel('wavelength'); ylabel('effective scattering length (cm)');


subplot(1,2,2);
plot(wavl,100./(sigs.*(1-asym))); hold on;
plot(wavl,100./(sige.*(1-asym)))
plot(wavl,100./kext)
xlabel('wavelength'); ylabel('effective scattering length (cm)');

figformat

% figure; plot(wavl,1./(sigs.*(1-0.92)))

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% get the 'propagation length'
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% this shows the scattering length compared with the propagation length:
cp  = sqrt(3.*siga.*sigs.*(1-asym));

macfig;
% subplot(1,2,1);
plot(wavl,100./sigs);  hold on;
plot(wavl,100./(sigs.*(1-asym)));
% plot(wavl,100./cp)
plot(wavl,100./kext)

% set(gca,'YScale','log')
ylabel('length scale (cm)')
xlabel('wavelength (nm)')
legend('$\ell_b=\frac{1}{b}$','$\ell_e=\frac{1}{b_e}=\frac{1}{b(1-g)}$', ...
        '$\ell_p=\frac{1}{\sqrt{3ab_e}}$')
% legend('$\ell_e=\frac{1}{b(1-g)}$','$\ell_p=\frac{1}{\sqrt{3ab_e}}$', ...
%         '$\ell_{ext}=\frac{1}{k_{ext}}$','$\ell_{sig_e}=\frac{1}{\sigma_e}$')

% subplot(1,2,2);
% plot(wavl,100./(sigs.*(1-asym))); hold on;
% plot(wavl,100./cp)
% plot(wavl,100./kext)
% plot(wavl,100./sige)
% legend('$\ell_e=\frac{1}{b(1-g)}$','$\ell_p=\frac{1}{\sqrt{3ab_e}}$', ...
%         '$\ell_{ext}=\frac{1}{k_{ext}}$','$\ell_{sig_e}=\frac{1}{\sigma_e}$')
% ylabel('length scale (cm)')
figformat

% legend('effective scattering length, $\ell_e = \frac{1}{b_s(1-g)}$')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
macfig; 
subplot(2,2,1);
plot(wavl,sigs.*(1-asym)); hold on;
plot(wavl,sqrt(3.*siga.*sigs.*(1-asym)));
legend('$b_e = b(1-g)$','$c_p = \sqrt{3ab_e}$');
ylabel('coefficient (m$^{-1}$)');
title('log scale')
set(gca,'YScale','log')

subplot(2,2,2);
plot(wavl,sigs.*(1-asym)); hold on;
plot(wavl,sqrt(3.*siga.*sigs.*(1-asym)));
legend('$b_e = b(1-g)$','$c_p = \sqrt{3ab_e}$');
ylabel('coefficient (m$^{-1}$)');
title('linear scale')
set(gca,'YScale','linear')

subplot(2,2,3);
plot(wavl,100./(sigs.*(1-asym))); hold on;
plot(wavl,100./(sqrt(3.*siga.*sigs.*(1-asym))));
legend('$\lambda_e = \frac{1}{b(1-g)}$','$\lambda_p = \frac{1}{\sqrt{3ab_e}}$');
ylabel('length (cm)');
title('log scale')
set(gca,'YScale','log')

subplot(2,2,4);
plot(wavl,100./(sigs.*(1-asym))); hold on;
plot(wavl,100./(sqrt(3.*siga.*sigs.*(1-asym))));
legend('$\lambda_e = \frac{1}{b(1-g)}$','$\lambda_p = \frac{1}{\sqrt{3ab_e}}$');
ylabel('length (cm)');
title('linear scale')
set(gca,'YScale','linear')

figformat

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% now set g arbitrarily to 0.75
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
g = 0.75;

figure; 
subplot(1,2,1);
plot(wavl,sigs.*(1-g)); hold on;
plot(wavl,sqrt(3.*siga.*sigs.*(1-g)));
legend('$b_e = b(1-g)$','$c_p = \sqrt{3ab_e}$');
set(gca,'YScale','log')

subplot(1,2,2);
plot(wavl,sigs.*(1-g)); hold on;
plot(wavl,sqrt(3.*siga.*sigs.*(1-g)));
legend('$b_e = b(1-g)$','$c_p = \sqrt{3ab_e}$');
set(gca,'YScale','linear')
figformat



% sige    = 2*Ag;
% siga    = Ag*(1-exp(-4/3*rg.*ka));
% siga    = Ag*(1-exp(-ka*Vg/Ag));




