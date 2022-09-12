clean

pd = makedist('ExtremeValue');
% x = randn(100000,1);
% x = evrnd(20,10,100000,1);
x = exprnd(20,100000,1);

figure; histogram(x); hold on;

i = 0;
threex = 1;
while sum(threex)>0
    i = i+1;
    stdx = std(x);
    threex = x>3*stdx | x < -3*stdx;
    x(threex) = [];
end

histogram(x);