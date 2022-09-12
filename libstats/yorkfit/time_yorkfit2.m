clean
test_york1  = true;
test_york2  = false;

Nruns   = 10000;
N       = 200;
x       = 10 .* sort(rand(N,1));
y       = 5 + 2*x;

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
x       = x+xerr;
y       = y+yerr;

if test_york1 == true
    t1      = zeros(Nruns,1);
    yorkfit(x,y,xerr,yerr,rxy);
    for i = 1:Nruns
        tic
        yorkfit(x,y,xerr,yerr,rxy);
        tmp1 = toc; t1(i) = tmp1; clear tmp1
    end
    mean(t1) % 0.00036718
end

if test_york2 == true
    t2      = zeros(Nruns,1);
    yorkfit2(x,y,xerr,yerr,rxy);
    for i = 1:Nruns
        tic
        yorkfit2(x,y,xerr,yerr,rxy);
        tmp2 = toc; t2(i) = tmp2; clear tmp2
    end
    mean(t2) % 0.0017047
end



% for i = 1:Nruns
%     tic
%     yorkfit(x,y,xerr,yerr,rxy);
%     tmp1 = toc; t1(i) = tmp1; clear tmp1
%     
%     tic
%     yorkfit2(x,y,xerr,yerr,rxy);
%     tmp2 = toc; t2(i) = tmp2; clear tmp2
% end
% 
% mean(t1)
% mean(t2)
% mean(t1)/mean(t2)

