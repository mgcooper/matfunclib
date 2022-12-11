function [xa,ya] = arrowxy(xref,yref,xpct,ypct)

% I did not finish this. there are two cases, one from plplotb where I don't
% have a function and I also don't have the x/yref points, I use the fitted ccdf
% to get the yref, the other from plotrefline where I have the y=ax^b function. 

% xref,yref are a ref point e.g. where the tip of an arrow should point

% good default values:
% xpct = 1/15;
% ypct = 1/20;

xpct = xpct/100;
ypct = ypct/100;

% for early and late, we use the early-time form to get the y position
ylims = ylim;
xlims = xlim;

% use the number of decades to place the labels
ndecsy = log10(ylims(2))-log10(ylims(1));
ndecsx = log10(xlims(2))-log10(xlims(1));

%% below here assumes we have an equation of the form y=ax^b

% place the label 1/2 way b/w the first and second decade
ya = 10^(log10(ylims(1))+ypct*ndecsy);
xa = (ya/a)^(1/b);

% make the arrow span 1/10th or so of the total number of decades
xa = [xa 10^(log10(xa)+xpct*ndecsx)];
ya = [ya ya];


%% below here assumes we know xref/yref
xpct = 10;
ypct = 10;
xpct = xpct/100;
ypct = ypct/100;


if logxy == true
   xa = [10^(log10(xref)-xpct*ndecsx) xref];
   ya = [yref yref];
else
   xa = [xref-xpct*xref xref];
   ya = [yref yref];
   
end


arrow([xa(1),ya(1)],[xa(2),ya(2)],'BaseAngle',90,'Length',8,'TipAngle',10)
text(0.95*xa(1),ya(1),ta,'HorizontalAlignment','right','FontSize',14)











