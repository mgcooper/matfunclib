function arrowloglabel(a,b,str,varargin)

if nargin == 3
   xpct = 1/8;
   ypct = 1/5;
else
   xpct = varargin{1};
   ypct = varargin{2};
end

% for early and late, we use the early-time form to get the y position
ylims    = ylim;
xlims    = xlim;

% use the number of decades to place the labels
ndecsy   = log10(ylims(2))-log10(ylims(1));
ndecsx   = log10(xlims(2))-log10(xlims(1));

% place the label 1/2 way b/w the first and second decade
ya       = 10^(log10(ylims(1))+ypct*ndecsy);
xa       = (ya/a)^(1/b);

% make the arrow span 1/10th or so of the total number of decades
xa       = [xa 10^(log10(xa)+xpct*ndecsx)];
ya       = [ya ya];


% ta = sprintf('$b=%.2f$ ($\\hat{b}$)',b);

arrow([xa(2),ya(2)],[xa(1),ya(1)],'BaseAngle',90,'Length',14,'TipAngle',10)
text(1.03*xa(2),ya(2),str,'HorizontalAlignment','left', ...
   'fontsize',13,'Interpreter','latex')
