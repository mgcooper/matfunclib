
% OK I might have just realized the key to york fit, it requires thinking
% of the solution in terms of the point cloud fit, where each point itself
% has a distribution of points, so that each point has an error
% distribution with a correlation between the x/y errors on the point

% so i would neeed to generate a distribution of errors for every point,
% then assign the mean to the point, and get the correlation, but that
% would be the error would have non-zero mean

% instead, maybe the way is to generate an ensemble of estimates

%%%%%%%%%%%%%%%%%%%
% Williamsons eqn, Eqn 6 in York 1968
clean
warning off

N       = 200;
x       = 10 .* sort(rand(N,1));
y       = 5 + 2*x;% + randn(N,1).*2;
Mtrue   = [ones(N,1),x]\y;
btrue   = Mtrue(2);

% generate correlated random errors
mu      = 0;
sig     = 0.50*mean(x);
rxy     = -0.75;
R       = [1 rxy; rxy 1];
L       = chol(R);
M       = (mu + sig*randn(N,2))*L;
xerr    = M(:,1);
yerr    = M(:,2);
rxy     = corr(xerr,yerr); 

figure; myscatter(x,y); hold on; myscatter(x+xerr,y+yerr); 
legend('y with noise','x-y with error')
figure; scatterhist(xerr,yerr); title('correlated random error')


xtrue   = x;
ytrue   = y;
x       = x+xerr;
y       = y+yerr;
Mobs    = [ones(N,1),x]\y;
bobs    = Mobs(2);

Mobs2   = [ones(N,1),x]\(y-yerr);
bobs2   = Mobs2(2);

bguess  = bobs;

% with these, fzero1/2 equal yorkfit(x,y,std(xerr),std(yerr),rxy)
% wX      = 1/std(xerr)^2;
% wY      = 1/std(yerr)^2;

% with these, fzero1/2 equal yorkfit(x,y,mean(xerr),mean(yerr),rxy)
% wX      = 1/mean(xerr)^2;
% wY      = 1/mean(yerr)^2;

% with these, fzero1/2 are equal and equal yorkfit(x,y,xerr,yerr,rxy)
wX      = 1./xerr.^2;
wY      = 1./yerr.^2;

% with these, fzero1/2 are not equal and do not equal yorkfit
% wX      = mean(1./xerr.^2);
% wY      = mean(1./yerr.^2);

Ui      = x-mean(x);
Vi      = y-mean(y);
ai      = sqrt(wX.*wY);
Zi      = (wX.*wY)./(bguess^2.*wY+wX-2*bguess.*rxy.*sqrt(wX.*wY));
fnc     = @(b) b.*sum(Zi.^2.*Ui.*(Ui./wY+b.*Vi./wX-b.*rxy.*Ui./ai)) -   ...
                sum(Zi.^2.*Vi.*(Ui./wY+b.*Vi./wX-rxy.*Vi./ai));
b1      = fzero(fnc,bguess);
            
% with Zi substituted in:
fnc     = @(b) b.*sum(((wX.*wY)./(b^2.*wY+wX-2*b.*rxy.*sqrt(wX.*wY))).^2.* ...
                Ui.*(Ui./wY+b.*Vi./wX-b.*rxy.*Ui./ai)) -   ...
                sum(((wX.*wY)./(b^2.*wY+wX-2*b.*rxy.*sqrt(wX.*wY))).^2.* ...
                Vi.*(Ui./wY+b.*Vi./wX-rxy.*Vi./ai));
b2      = fzero(fnc,bguess);

ab      = yorkfit(x,y,xerr,yerr,rxy); byrk = ab(2);
ab      = yorkfit(x,y,mean(xerr),mean(yerr),rxy); byrk2 = ab(2);
ab      = yorkfit(x,y,std(xerr),std(yerr),rxy); byrk3 = ab(2);
ab      = mlefit(x,y,mean(xerr),mean(yerr)); bmle = ab(2);
ab      = pcafit(x,y); bpca = ab(2);

sprintf('%s%.2f%','true: ',btrue)
sprintf('%s%.2f%','ols w/x-error: ',bobs)
sprintf('%s%.2f%','fzero1: ',b1)
sprintf('%s%.2f%','fzero2: ',b2)
sprintf('%s%.2f%','york: ',byrk)
sprintf('%s%.2f%','york w/mean: ',byrk2)
sprintf('%s%.2f%','york w/std: ',byrk3)
sprintf('%s%.2f%','mle: ',bmle)
sprintf('%s%.2f%','pca: ',bpca)



% Zi = ((wX.*wY)./(b^2.*wY+wX-2*b.*rxy.*sqrt(wX.*wY)))









% %%%%%%%%%%%%%%%%%%%
% % Williamsons eqn, Eqn 6 in York 1968
% clean
% warning off
% 
% N       = 200;
% x       = 10 .* sort(rand(N,1));
% y       = 5 + 2*x + randn(N,1).*2;
% Mtrue   = [ones(N,1),x]\y;
% btrue   = Mtrue(2);
% 
% % generate correlated random errors
% mu      = 0;
% sig     = 0.10*mean(x);
% rxy     = -0.75;
% R       = [1 rxy; rxy 1];
% L       = chol(R);
% M       = (mu + sig*randn(N,2))*L;
% xerr    = M(:,1);
% yerr    = M(:,2);
% rxy     = corr(xerr,yerr); 
% 
% figure; myscatter(x,y); hold on; myscatter(x+xerr,y+yerr); 
% legend('y with noise','x-y with error')
% figure; scatterhist(xerr,yerr); title('correlated random error')
% 
% 
% xtrue   = x;
% ytrue   = y;
% x       = x+xerr;
% y       = y+yerr;
% Mobs    = [ones(N,1),x]\y;
% bobs    = Mobs(2);
% 
% Mobs2   = [ones(N,1),x]\(y-yerr);
% bobs2   = Mobs2(2);
% 
% bguess  = bobs;
% wX      = 1./xerr.^2;
% wY      = 1./yerr.^2;
% Ui      = x-mean(x);
% Vi      = y-mean(y);
% ai      = sqrt(wX.*wY);
% Zi      = (wX.*wY)./(bguess^2.*wY+wX-2*bguess.*rxy.*sqrt(wX.*wY));
% fnc     = @(b) b.*sum(Zi.^2.*Ui.*(Ui./wY+b.*Vi./wX-b.*rxy.*Ui./ai)) -   ...
%                 sum(Zi.^2.*Vi.*(Ui./wY+b.*Vi./wX-rxy.*Vi./ai));
% b1      = fzero(fnc,bguess);
%             
% % with Zi substituted in:
% fnc     = @(b) b.*sum(((wX.*wY)./(b^2.*wY+wX-2*b.*rxy.*sqrt(wX.*wY))).^2.* ...
%                 Ui.*(Ui./wY+b.*Vi./wX-b.*rxy.*Ui./ai)) -   ...
%                 sum(((wX.*wY)./(b^2.*wY+wX-2*b.*rxy.*sqrt(wX.*wY))).^2.* ...
%                 Vi.*(Ui./wY+b.*Vi./wX-rxy.*Vi./ai));
% b2      = fzero(fnc,bguess);
% 
% ab      = yorkfit(x,y,xerr,yerr,rxy); byrk = ab(2);
% ab      = yorkfit(x,y,mean(xerr),mean(yerr),rxy); byrk2 = ab(2);
% ab      = yorkfit(x,y,std(xerr),std(yerr),rxy); byrk3 = ab(2);
% ab      = mlefit(x,y,mean(xerr),mean(yerr)); bmle = ab(2);
% ab      = pcafit(x,y); bpca = ab(2);
% 
% sprintf('%s%.2f%','true: ',btrue)
% sprintf('%s%.2f%','ols w/x-error: ',bobs)
% sprintf('%s%.2f%','fzero1: ',b1)
% sprintf('%s%.2f%','fzero2: ',b2)
% sprintf('%s%.2f%','york: ',byrk)
% sprintf('%s%.2f%','mle: ',bmle)
% sprintf('%s%.2f%','pca: ',bpca)
% sprintf('%s%.2f%','york w/mean: ',byrk2)
% sprintf('%s%.2f%','york w/std: ',byrk3)
% 
% 
% 
% % Zi = ((wX.*wY)./(b^2.*wY+wX-2*b.*rxy.*sqrt(wX.*wY)))
