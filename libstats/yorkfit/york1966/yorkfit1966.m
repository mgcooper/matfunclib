
% don't use standard error formulas from york 1966, also eq. 12 in york
% 1968 for sigb (standard error slope) is incorrect, instead use the ones
% in york 2004. After reading Mahon 1996, I am unable to find better
% expressions than the ones in york 2004, which use the adjusted points and
% his 'unified' framework, 

% OK I might have just realized the key to york fit, it requires thinking
% of the solution in terms of the point cloud fit, where each point itself
% has a distribution of points, so that each point has an error
% distribution with a correlation between the x/y errors on the point

% this shows that yorkfit is about twice as slow, but then aftr more tests
% this may not be the case, also roots gets stuck sometimes, it only works
% on polynomials, not sure why its geting stuck, could use fzero but then
% need to specify the function

% more importantly, when i subsittue roots into yorkfit (yorktest3), it is
% slower than standard yorkfit, meanign roots slows it down

% note, the reason the explicit soltuions don't agree with york/mle/pcafit
% is because they need to be solved iteratively, except for the fully
% explicit version with no initial guess on b, that returns the answer with
% fzero immediately

% NOTE: this is all from York 1966, which is valid when x/y errors are
% uncorrelated. York 1968 (cited as York 1969) is where he introduced the
% correlation.


clean
warning off

N = 200;
x = 10 .* sort(rand(N,1));
y = 5 + 2*x + randn(N,1).*2;
M = [ones(N,1),x]\y;

% york's 1966 solution, with no iteration
bguess  = 3; % use OLS
Ui      = x-mean(x);
Vi      = y-mean(y);
wX      = 1;
wY      = 1;
Wi      = (wX.*wY)/(bguess^2.*wY+wX);

% try writing out the full equation
opts = optimset('PlotFcns',{@optimplotx,@optimplotfval});
% Wi  = (wX.*wY./(b^2.*wY+wX));

% Eq. 20 with no initial guess i.e., Wi substituted in:
fnc = @(b) b^3.*sum(((wX.*wY./(b^2.*wY+wX))).^2.*Ui.^2./wX) -           ...
            b^2.*2.*sum(((wX.*wY./(b^2.*wY+wX))).^2.*Ui.*Vi./wX) -      ...
            b*(sum(((wX.*wY./(b^2.*wY+wX))).*Ui.^2) -                   ...
            sum(((wX.*wY./(b^2.*wY+wX))).^2.*Vi.^2./wX)) +              ...
            sum(((wX.*wY./(b^2.*wY+wX))).*Ui.*Vi);
    
b1  = fzero(fnc,bguess);

% Eq. 20 with Wi precomputed with b-guess
c1  = sum(Wi.*Wi.*Ui.*Ui./wX);
c2  = -2*sum(Wi.*Wi.*Ui.*Vi./wX);
c3  = -(sum(Wi.*Ui.*Ui)-sum(Wi.*Wi.*Vi.*Vi./wX));
c4  = sum(Wi.*Ui.*Vi);

fnc = @(b) c1.*b^3 + c2.*b^2 + c3.*b + c4;
b2  = fzero(fnc,bguess);
b2b = roots([c1,c2,c3,c4]); b2b = b2b(3);

% copied from inside yorktest1
alpha   = (2*sum(Wi.*Wi.*Ui.*Vi./wX))/(3*sum(Wi.*Wi.*Ui.*Ui./wX));
beta    = (sum(Wi.*Wi.*Vi.*Vi./wX)-sum(Wi.*Ui.*Ui))/(3*sum(Wi.*Wi.*Ui.*Ui./wX));
gamma   = -sum(Wi.*Ui.*Vi)/sum(Wi.*Wi.*Ui.*Ui./wX);
c1      = 1;
c2      = -3.*alpha;
c3      = 3.*beta;
c4      = -gamma;

fnc     = @(b) c1.*b^3 + c2.*b^2 + c3.*b + c4;
b3      = fzero(fnc,bguess);
b3b     = real(roots([c1,c2,c3,c4])); b3b = b3b(3);


% so yorkfit and mlefit agree on b=2.18, but roots and fzero give 2.08
ab  = yorkfit(x,y,1,1); b4 = ab(2);
ab  = mlefit(x,y,1,1); b5 = ab(2);
ab  = pcafit(x,y); b6 = ab(2);
ab  = yorktest1(x,y,1,1); b7 = ab(2);

sprintf('%s%.2f%','fzero1: ',b1)
sprintf('%s%.2f%','fzero2: ',b2)
sprintf('%s%.2f%','roots2: ',b2b)
sprintf('%s%.2f%','fzero3: ',b3)
sprintf('%s%.2f%','roots3: ',b3b)
sprintf('%s%.2f%','yorkfit: ',b4)
sprintf('%s%.2f%','mlefit: ',b5)
sprintf('%s%.2f%','pcafit: ',b6)
sprintf('%s%.2f%','yorktest1: ',b7)




% % since Wi is a 
% fnc1    = @(b) sum(Wi.*(a+b.*X-Y));
% fnc2    = @(b) sum(Wi.*(a.*X+b.*X.^2-X.*Y))-sum(Wi.^2.*((b./wx).*(a+b.*X-Y).^2));



% % the roots of this equation give b:
% alpha   = (2*sum(Wi.*Wi.*Ui.*Vi./wX))/(3.*sum(Wi.*Wi.*Ui.*Ui./wX));
% beta    = (sum(Wi.*Wi.*Vi.*Vi./wX)-sum(Wi.*Ui.*Ui))/(3*sum(Wi.*Wi.*Ui.*Ui./wX));
% gamma   = -sum(Wi.*Ui.*Vi)/sum(Wi.*Wi.*Ui.*Ui./wX);
% c1      = 1;
% c2      = -3.*alpha;
% c3      = 3.*beta;
% c4      = -gamma;
% bsoln   = real(roots([c1 c2 c3 c4])); % c1*b^3 + c2*b^2 + c3*b + gamma = 0;
% 
% % using york's iterative method
% js      = [0,1,2];
% cosphi  = (alpha^3-3/2*alpha*beta+1/2*gamma)/((alpha^2-beta)^(3/2));
% phi     = acos(cosphi);
% btest   = alpha + 2*sqrt((alpha^2-beta))*cos(1/3*(phi+2*pi*js));
% % york says b3 is always the right one, but for roots, this is b(2)


for j = 1:1000
    tic;
    ab1 = yorktest1(x,y,1,1);    % iteration with roots
    t1(j) = toc;
end

for j = 1:1000
    tic;
    ab2 = yorktest2(x,y,1,1);    % compact notation
    t2(j) = toc;
end
    
% this puts the roots solution into yorkfit
for j = 1:1000
    tic;
    ab3 = yorktest3(x,y,1,1);
    t3(j) = toc;
end

% standard yorkfit
for j = 1:1000
    tic;
    ab4 = yorkfit(x,y,1,1);
    t4(j) = toc;
end

mean(t1)
mean(t2)
mean(t3)
mean(t4)




