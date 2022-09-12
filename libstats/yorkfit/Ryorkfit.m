% % copied/pasted from here:
% % https://stats.stackexchange.com/questions/201859/regression-when-each-point-has-its-own-uncertainty-in-both-x-and-y
% % 
% 
% tol = abs(b0)*eps #the fit will stop iterating when the slope converges to within this value
% 
% # WAVE DEFINITIONS #
% 
% Xw = 1/(Xstd^2) #X weights
% Yw = 1/(Ystd^2) #Y weights
% 
% 
% # ITERATIVE CALCULATION OF SLOPE AND INTERCEPT #
% 
% b = b0
% b.diff = tol + 1
% while(b.diff>tol)
% {
%     b.old = b
%     alpha.i = sqrt(Xw*Yw)
%     Wi = (Xw*Yw)/((b^2)*Yw + Xw - 2*b*Ri*alpha.i)
%     WiX = Wi*X
%     WiY = Wi*Y
%     sumWiX = sum(WiX, na.rm = TRUE)
%     sumWiY = sum(WiY, na.rm = TRUE)
%     sumWi = sum(Wi, na.rm = TRUE)
%     Xbar = sumWiX/sumWi
%     Ybar = sumWiY/sumWi
%     Ui = X - Xbar
%     Vi = Y - Ybar
% 
%     Bi = Wi*((Ui/Yw) + (b*Vi/Xw) - (b*Ui+Vi)*Ri/alpha.i)
%     wTOPint = Bi*Wi*Vi
%     wBOTint = Bi*Wi*Ui
%     sumTOP = sum(wTOPint, na.rm=TRUE)
%     sumBOT = sum(wBOTint, na.rm=TRUE)
%     b = sumTOP/sumBOT
% 
%     b.diff = abs(b-b.old)
%   }     
% 
%    a = Ybar - b*Xbar
%    wYorkFitCoefs = c(a,b)
% 
% # ERROR CALCULATION #
% 
% Xadj = Xbar + Bi
% WiXadj = Wi*Xadj
% sumWiXadj = sum(WiXadj, na.rm=TRUE)
% Xadjbar = sumWiXadj/sumWi
% Uadj = Xadj - Xadjbar
% wErrorTerm = Wi*Uadj*Uadj
% errorSum = sum(wErrorTerm, na.rm=TRUE)
% b.err = sqrt(1/errorSum)
% a.err = sqrt((1/sumWi) + (Xadjbar^2)*(b.err^2))
% wYorkFitErrors = c(a.err,b.err)
% 
% # GOODNESS OF FIT CALCULATION #
% lgth = length(X)
% wSint = Wi*(Y - b*X - a)^2
% sumSint = sum(wSint, na.rm=TRUE)
% wYorkGOF = c(sumSint/(lgth-2),sqrt(2/(lgth-2))) #GOF (should equal 1 if assumptions are valid), #standard error in GOF
% 
% # OPTIONAL OUTPUTS #
% 
% if(printCoefs==1)
%  {
%     print(paste("intercept = ", a, " +/- ", a.err, sep=""))
%     print(paste("slope = ", b, " +/- ", b.err, sep=""))
%   }
% if(makeLine==1)
%  {
%     wYorkFitLine = a + b*X
%   }
%  ans=rbind(c(a,a.err),c(b, b.err)); dimnames(ans)=list(c("Int","Slope"),c("Value","Sigma"))
% return(ans)
%  }




%TRANSLATED: (NOTE I CONFIRMED IDENTICAL TO MY CODE)
% % copied/pasted from here:
% % https://stats.stackexchange.com/questions/201859/regression-when-each-point-has-its-own-uncertainty-in-both-x-and-y
% % 
% 
% tol = abs(b0)*eps; %the fit will stop iterating when the slope converges to within this value
% 
% % WAVE DEFINITIONS %
% 
% Xw = 1/(Xstd^2); %X weights
% Yw = 1/(Ystd^2); %Y weights
% 
% 
% % ITERATIVE CALCULATION OF SLOPE AND INTERCEPT %
% 
% b = b0;
% b.diff = tol + 1;
% while (b.diff>tol)
% 
%     b.old   = b;
%     alpha.i = sqrt(Xw*Yw);
%     Wi      = (Xw*Yw)/((b^2)*Yw + Xw - 2*b*Ri*alpha.i);
%     WiX     = Wi*X;
%     WiY     = Wi*Y;
%     sumWiX  = sum(WiX, na.rm = TRUE);
%     sumWiY  = sum(WiY, na.rm = TRUE);
%     sumWi   = sum(Wi, na.rm = TRUE);
%     Xbar    = sumWiX/sumWi;
%     Ybar    = sumWiY/sumWi;
%     Ui      = X - Xbar;
%     Vi      = Y - Ybar;
%     
%     Bi      = Wi*((Ui/Yw) + (b*Vi/Xw) - (b*Ui+Vi)*Ri/alpha.i);
%     wTOPint = Bi*Wi*Vi;
%     wBOTint = Bi*Wi*Ui;
%     sumTOP  = sum(wTOPint, na.rm=TRUE);
%     sumBOT  = sum(wBOTint, na.rm=TRUE);
%     b       = sumTOP/sumBOT;
% 
%     b.diff  = abs(b-b.old);
% end
% 
%    a = Ybar - b*Xbar;
%    wYorkFitCoefs = c(a,b);
% 
% % ERROR CALCULATION %
% Xadj        = Xbar + Bi;
% WiXadj      = Wi*Xadj;
% sumWiXadj   = sum(WiXadj, na.rm=TRUE);
% Xadjbar     = sumWiXadj/sumWi;
% Uadj        = Xadj - Xadjbar;
% wErrorTerm  = Wi*Uadj*Uadj;
% errorSum    = sum(wErrorTerm, na.rm=TRUE);
% b.err       = sqrt(1/errorSum);
% a.err       = sqrt((1/sumWi) + (Xadjbar^2)*(b.err^2));
% wYorkFitErrors = c(a.err,b.err);
% 
% % GOODNESS OF FIT CALCULATION %
% lgth = length(X)
% wSint = Wi*(Y - b*X - a)^2
% sumSint = sum(wSint, na.rm=TRUE)
% wYorkGOF = c(sumSint/(lgth-2),sqrt(2/(lgth-2))) %GOF (should equal 1 if assumptions are valid), %standard error in GOF
