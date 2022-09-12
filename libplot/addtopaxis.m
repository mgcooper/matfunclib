function [ ax2 ] = addtopaxis( )
%UNTITLED24 Summary of this function goes here
%   Detailed explanation goes here
   
ax1                  =  gca;
axpos                =  plotboxpos(ax1);
ax2                  =  axes('Position', axpos,'Color', 'none');
ax2.XAxisLocation    =  'top';
ax2.YAxisLocation    =  'Right';
ax2.XLim             =   ax1.XLim;
ax2.XTick            =   ax1.XTick;
ax2.XTickLabel       =  '';

% ax2.XLim                =   ax1.XLim;
% ax2.YLim                =   ax1.YLim;
% ax2.XTick               =   ax1.XTick;
% ax2.YTick               =   ax1.YTick;
% ax2.XTickLabel          =   ax1.XTickLabel;
% ax2.YTickLabel          =   '';
% 
% set(gcf,'CurrentAxes',ax2);

% mainAxes          =  findobj(gcf,'Type','axes');
% newAxes           =  copyobj(mainAxes);
% newAxes.Position  =  mainAxes.Position;


end

