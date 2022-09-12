function [slope,intercept,STAT]=myregr(x,y,verbose)
%MYREGR: Perform a least-squares linear regression.
%This function computes a least-square linear regression suppling several
%output information.
%
% mgc: I moved this here from old-projects/snotel, it's pretty sweet should
% incorporate it
% 
% Syntax: 	myregr(x,y)
%      
%     Inputs:
%           X - Array of the independent variable 
%           Y - Dependent variable. If Y is a matrix, the i-th Y row is a
%           repeated measure of i-th X point. The mean value will be used
%           verbose - Flag to display all information (default=1)
%     Outputs:
%           - Slope with standard error an 95% C.I.
%           - Intercept with standard error an 95% C.I.
%           - Pearson's Correlation coefficient with 95% C.I. and its
%             adjusted form (depending on the elements of X and Y arrays)
%           - Spearman's Correlation coefficient
%           - Regression Standard Error
%           - Total Variability
%           - Variability due to regression
%           - Residual Variability
%           - Student's t-Test on Slope (to check if slope=0)
%           - Student's t-Test on Intercept (to check if intercept=0)
%           - Power of the regression
%           - Modified Levene's test for homoschedasticity of residuals
%           - a plot with:
%                o Data points
%                o Least squares regression line
%                o Red dotted lines: 95% Confidence interval of regression
%                o Green dotted lines: 95% Confidence interval of new y 
%                                       evaluation using this regression.
%           - Residuals plot
%
%   [Slope]=myregr(...) returns a structure of slope containing value, standard
%   error, lower and upper bounds 95% C.I.
%
%   [Slope,Intercept]=myregr(...) returns a structure of slope and intercept 
%   containing value, standard error, lower and upper bounds 95% C.I.
%
% Example:
%       x = [1.0 2.3 3.1 4.8 5.6 6.3];
%       y = [2.6 2.8 3.1 4.7 4.1 5.3];
%
%   Calling on Matlab the function: 
%             myregr(x,y)
%
%   Answer is:
%
%                         Slope
% -----------------------------------------------------------
%      Value          S.E.                95% C.I.  
% -----------------------------------------------------------
%    0.50107        0.09667        0.23267        0.76947
% -----------------------------------------------------------
%  
%                       Intercept
% -----------------------------------------------------------
%      Value          S.E.                95% C.I.  
% -----------------------------------------------------------
%    1.83755        0.41390        0.68838        2.98673
% -----------------------------------------------------------
%  
%             Pearson's Correlation Coefficient
% -----------------------------------------------------------
%      Value               95% C.I.                  ADJ  
% -----------------------------------------------------------
%    0.93296        0.49988        0.99281        0.91620
% -----------------------------------------------------------
% Spearman's Correlation Coefficient: 0.9429
%
%                       Other Parameters
% ------------------------------------------------------------------------
%      R.S.E.                         Variability  
%      Value        Total            by regression           Residual  
% ------------------------------------------------------------------------
%    0.44358        6.07333        5.28627 (87.0407%)     0.78706 (12.9593%)
% ------------------------------------------------------------------------
%
% Student's t-test on slope=0
% ----------------------------------------------------------------
% t = 5.1832    Critical Value = 2.7764     p = 0.0066
% Test passed: slope ~= 0
% ----------------------------------------------------------------
%  
% Student's t-test on intercept=0
% ----------------------------------------------------------------
% t = 4.4396    Critical Value = 2.7764     p = 0.0113
% Test passed: intercept ~= 0
% ----------------------------------------------------------------
%  
% Power of regression
% ----------------------------------------------------------------
% alpha = 0.05  n = 6     Zrho = 1.6807  std.dev = 0.5774
% Power of regression: 0.6046
% ----------------------------------------------------------------
%
% ...and the plot, of course.
%
% SEE also myregrinv, myregrcomp
%
%           Created by Giuseppe Cardillo
%           giuseppe.cardillo-edta@poste.it
%
% To cite this file, this would be an appropriate format:
% Cardillo G. (2007) MyRegression: a simple function on LS linear
% regression with many informative outputs. 
% http://www.mathworks.com/matlabcentral/fileexchange/15473

%Input error handling
if ~isvector(x)
    error('X must be an array.');
end

if isvector(y)
    if any(size(x)~=size(y))
        error('X and Y arrays must have the same length.');
    end
else
    if any(length(x)~=size(y,1))
        error('the length of X and the rows of Y must be equal.');
    end
end

if nargin==2
    verbose=1;
else
    verbose=logical(verbose);
end

x=x(:);
if isvector(y)
    yt=y(:); %columns vectors
else
    yt=mean(y,2);
end

if ~issorted(x) %x must be monotonically crescent 
    z=[x yt];
    z=sortrows(z,[1 2]);
    x=z(:,1);     
    yt=z(:,2);
    clear z
end

ux=unique(x); 
if length(ux)~=length(x)
    uy=zeros(size(ux));
    for I=1:length(ux)
        c=sum(x==ux(I));
        if c==1
            uy(I)=yt(x==ux(I));
        else
            uy(I)=mean(yt(x==ux(I)));
        end
    end
    x=ux(:); yt=uy(:); 
    clear uy I
end
clear ux

xtmp=[x ones(length(x),1)]; %input matrix for regress function
ytmp=yt;

%regression coefficients
[p,pINT,R,Rint] = regress(ytmp,xtmp);

%check the presence of outliers
outl=find(ismember(sign(Rint),[-1 1],'rows')==0);
if ~isempty(outl) 
    fprintf(['These points are outliers at 95%% fiducial level: ' repmat('%i ',1,length(outl)) '\n'],outl); 
    reply = input('Do you want to delete outliers? Y/N [Y]: ', 's');
    disp(' ')
    if isempty(reply) || upper(reply)=='Y'
        ytmp(outl)=[]; xtmp(outl,:)=[];
        [p,pINT,R] = regress(ytmp,xtmp);
    end
end

xtmp(:,2)=[]; %delete column 2
%save coefficients value
m(1)=p(1); q(1)=p(2);

n=length(xtmp); 
xm=mean(xtmp); xsd=std(xtmp);

%standard error of regression coefficients
%Student's critical value
if isvector(y)
    cv=tinv(0.975,n-2); 
else
    cv=tinv(0.975,sum(size(y))-3);
end
m(2)=(pINT(3)-p(1))/cv; %slope standard error
m=[m pINT(1,:)]; %add slope 95% C.I.
q(2)=(pINT(4)-p(2))/cv; %intercept standard error
q=[q pINT(2,:)]; %add intercept 95% C.I.

%Pearson's Correlation coefficient
[rp,pr,rlo,rup]=corrcoef(xtmp,ytmp);
r(1)=rp(2); r(2)=realsqrt((1-r(1)^2)/(n-2)); r(3)=rlo(2); r(4)=rup(2); 
%Adjusted Pearson's Correlation coefficient
r(5)=sign(r(1))*(abs(r(1))-((1-abs(r(1)))/(n-2)));

%Spearman's Correlation coefficient
[rx]=tiedrank(xtmp);
[ry]=tiedrank(ytmp);
d=rx-ry;
rs=1-(6*sum(d.^2)/(n^3-n));

%Total Variability
ym=polyval(p,xm);
vtot=sum((ytmp-ym).^2);

%Regression Variability
ystar=ytmp-R;
vreg=sum((ystar-ym).^2);

%Residual Variability
vres=sum(R.^2);

%regression standard error (RSE)
if isvector(y)
    RSE=realsqrt(vres/(n-2));
else
    if ~isempty(outl) && (isempty(reply) || upper(reply)=='Y')
        y2=y; y2(outl)=[];
        RSE=realsqrt((vres+sum(sum((y2-repmat(ytmp,1,size(y,2))).^2)))/(sum(size(y2))-3));
    else
        RSE=realsqrt((vres+sum(sum((y-repmat(yt,1,size(y,2))).^2)))/(sum(size(y))-3));
    end
end

%Confidence interval at 95% of regression
sy=RSE*realsqrt(1/n+(((xtmp-xm).^2)/((n-1)*xsd^2)));
cir=[ystar+cv*sy ystar-cv*sy];

%Confidence interval at 95% of a new observation (this is the confidence
%interval that should be used when you evaluate a new y with a new observed
%x)
sy2=realsqrt(sy.^2+RSE^2);
cir2=[ystar+cv*sy2 ystar-cv*sy2];

%display results
if verbose==1
    disp('REGRESSION SETTING X AS INDEPENDENT VARIABLE')
    tr=repmat('-',1,80);
    fprintf('\t\t\t\tSlope\n')
    disp(tr)
    fprintf('Value\t\tS.E.\t\t\t   95%% C.I.\n')
    disp(tr)
    fprintf('%0.4f\t\t%0.4f\t\t%0.4f\t\t\t%0.4f\n',m)
    disp(tr)
    disp(' ')
    fprintf('\t\t\t\tIntercept\n')
    disp(tr)
    fprintf('Value\t\tS.E.\t\t\t   95%% C.I.\n')
    disp(tr)
    fprintf('%0.4f\t\t%0.4f\t\t%0.4f\t\t\t%0.4f\n',q)
    disp(tr)
    disp(' ')
    fprintf('\t\t\tPearson''s Correlation Coefficient\n')
    disp(tr)
    fprintf('Value\t\tS.E.\t\t\t   95%% C.I.\t\t\tADJ\n')
    disp(tr)
    fprintf('%0.4f\t\t%0.4f\t\t%0.4f\t\t\t%0.4f\t\t%0.4f\n',r)
    disp(tr)
    disp(' ')
    fprintf('Spearman''s Correlation Coefficient: %0.4f\n',rs)   
    disp(' ')
    fprintf('\t\t\t\tOther Parameters\n')
    disp(tr)
    fprintf('R.S.E.\t\t\t\tVariability\n')
    fprintf('Value\t\tTotal\t\tBy regression\t\tResidual\n')
    disp(tr)
    fprintf('%0.4f\t\t%0.4f\t%0.4f (%0.1f%%)\t%0.4f (%0.1f%%)\n',RSE,vtot,vreg,vreg/vtot*100,vres,vres/vtot*100)
    disp(tr)
    disp(' ')
    disp('Press a key to continue'); pause; disp(' ')
 
    %test on slope
    t=abs(m(1)/m(2)); %Student's t
    disp('Student''s t-test on slope=0')
    disp(tr)
    if pr(2)<1e-4
        fprintf('t = %0.4f\tCritical Value = %0.4f\tp = %0.4e\n',t,cv,pr(2))
    else
        fprintf('t = %0.4f\tCritical Value = %0.4f\tp = %0.4f\n',t,cv,pr(2))
    end
    if t>cv
        disp('Test passed: slope ~= 0')
    else
        disp('Test not passed: slope = 0')
        m(1)=0;
    end
    try
        powerStudent(t,n-1,2,0.05)
    catch ME
        disp(ME)
         disp('I am trying to download the powerStudent function by Antonio Trujillo Ortiz from FEX')
         [F,Status]=urlwrite('http://www.mathworks.com/matlabcentral/fileexchange/2907-powerstudent?controller=file_infos&download=true','powerStudent.zip');
         if Status
             unzip(F)
             powerStudent(t,n-1,2,0.05)
         end
         clear F Status
    end
    %test on intercept
    t=abs(q(1)/q(2)); %Student's t
    p=(1-tcdf(t,n-2))*2; %p-value
    disp('Student''s t-test on intercept=0')
    disp(tr)
    if p<1e-4
        fprintf('t = %0.4f\tCritical Value = %0.4f\tp = %0.4e\n',t,cv,p)
    else
        fprintf('t = %0.4f\tCritical Value = %0.4f\tp = %0.4f\n',t,cv,p)
    end
    if t>cv
        disp('Test passed: intercept ~= 0')
    else
        disp('Test not passed: intercept = 0')
        q(1)=0;
    end
    powerStudent(t,n-1,2,0.05)
    %Power of regression
    Zrho=0.5*reallog((1+abs(r(1)))/(1-abs(r(1)))); %normalization of Pearson's correlation coefficient
    sZ=realsqrt(1/(n-3)); %std.dev of Zrho
    pwr=1-tcdf(1.96-Zrho/sZ,n-2)*2; %power of regression
    disp('Power of regression')
    disp(tr)
    fprintf('alpha = 0.05  n = %d\tZrho = %0.4f\tstd.dev = %0.4f\n',n,Zrho,sZ)
    fprintf('Power of regression: %0.4f\n',pwr)
    disp(tr)
    disp(' ')
    %Test for homoschedasticity of residuals (Modified Levene's test)
    xme=median(xtmp);
    e1=R(xtmp<=xme); me1=median(e1); d1=abs(e1-me1); dm1=mean(d1); l1=length(e1);
    e2=R(xtmp>xme);  me2=median(e2); d2=abs(e2-me2); dm2=mean(d2); l2=length(e2);
    gl=(l1+l2-2); S2p=(sum((d1-dm1).^2)+sum((d2-dm2).^2))/gl;
    t=abs(dm1-dm2)/realsqrt(S2p*(1/l1+1/l2)); cv=tinv(0.975,gl); 
    p=(1-tcdf(t,gl)); %p-value
    disp('Modified Levene''s t-test for homoshedasticity of residuals')
    disp(tr)
    if p<1e-4
        fprintf('t = %0.4f\tCritical Value = %0.4f\tp = %0.4e\n',t,cv,p)
    else
        fprintf('t = %0.4f\tCritical Value = %0.4f\tp = %0.4f\n',t,cv,p)
    end
    if t>cv
        disp('Test not passed: Residuals are not homoschedastic')
    else
        disp('Test passed: Residuals are homoschedastic')        
    end
    
    %plot regression
    subplot(1,2,1); 
    if isvector(y)        
        plot(x,yt,'bo',xtmp,ystar,xtmp,cir,'r:',xtmp,cir2,'g:');
    else       
        hold on
        plot(x',yt,'LineStyle','none','Marker','o','MarkerEdgeColor','b')
        plot(xtmp,ystar,'k',xtmp,cir,'r:',xtmp,cir2,'g:');
        hold off
    end
    axis square
    txt=sprintf('Red dotted lines: 95%% Confidence interval of regression\nGreen dotted lines: 95%% Confidence interval of new y evaluation using this regression');
    title(txt)
    %plot residuals
    subplot(1,2,2);
    xl=[min(x) max(x)];
    plot(xtmp,R,'bo',xl,[0 0],'k-',xl,[RSE RSE],'g--',xl,[-RSE -RSE],'g--',...
        xl,1.96.*[RSE RSE],'m--',xl,-1.96.*[RSE RSE],'m--',...
        xl,2.58.*[RSE RSE],'r--',xl,-2.58.*[RSE RSE],'r--')
    axis square
    n=length(xtmp);
    sx=sum(xtmp);
    sy=sum(ytmp);
    sx2=sum(xtmp.^2);
    sy2=sum(ytmp.^2);
    sxy=sum(xtmp.*ytmp);
    mx=mean(xtmp);
    my=mean(ytmp);
    vx=var(xtmp);
    vy=var(ytmp);
    lambda=vx/vy;
    devx=sx2-sx^2/n;
    devy=sy2-sy^2/n;
    codev=sxy-sx*sy/n;
    
    regrym=devy/codev;
    regryq=-regrym*(mx-codev/devy*my);
    disp(' ')
    disp('REGRESSION SETTING Y AS INDEPENDENT VARIABLE')
    disp(tr)
    fprintf('Slope: %0.4f\t\tIntercept: %0.4f\n',regrym,regryq)
    disp(tr)
    
    demingm=(devy-((1/lambda)*devx))/(2*codev)+realsqrt(((devy-((1/lambda)*devx))/(2*codev))^2+(1/lambda));
    demingq=my-demingm*mx;
    disp(' ')
    disp('DEMING''S REGRESSION')
    disp(tr)
    fprintf('Lambda: %0.4f\t\tSlope: %0.4f\t\tIntercept: %0.4f\n',lambda,demingm,demingq)
    disp(tr)
end

switch nargout
    case 1
        slope.value=m(1);
        slope.se=m(2);
        slope.lv=m(3);
        slope.uv=m(4);
    case 2
        slope.value=m(1);
        slope.se=m(2);
        slope.lv=m(3);
        slope.uv=m(4);
        intercept.value=q(1);
        intercept.se=q(2);
        intercept.lv=q(3);
        intercept.uv=q(4);
    case 3
        slope.value=m(1);
        slope.se=m(2);
        slope.lv=m(3);
        slope.uv=m(4);
        intercept.value=q(1);
        intercept.se=q(2);
        intercept.lv=q(3);
        intercept.uv=q(4);
        STAT.rse=RSE;
        STAT.cv=cv;
        STAT.n=n;
        STAT.xm=mean(x);
        STAT.ym=ym;
        STAT.sse=sum((xtmp-xm).^2);
        STAT.r=r;
end