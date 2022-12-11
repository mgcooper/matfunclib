function h = boxchartcats(T,datavar,xgroupvar,cgroupvar, ...
   usegroupsx,usegroupsc,varargin)


Tcats = T(:,vartype('categorical'));

iplot = ismember(T.(cgroupvar),usegroupsc) & ...
   ismember(T.(xgroupvar),usegroupsx);

Tplot = T(iplot,:);

% remove rows that are not in usecats
allcats  = categories(Tcats.(xgroupvar));
rmcats   = allcats(~ismember(allcats,usegroupsx));
Tplot.(xgroupvar) = removecats(Tplot.(xgroupvar),rmcats);

% remove rows that are not in usecgroupcats
allcats  = categories(Tcats.(cgroupvar));
rmcats   = allcats(~ismember(allcats,usegroupsc));
Tplot.(cgroupvar) = removecats(Tplot.(cgroupvar),rmcats);


h = boxchart(Tplot.(xgroupvar),Tplot.(datavar), ...
   'GroupByColor',Tplot.(cgroupvar),varargin{:});


% 
% 
% 
% 
% cellHist = {'Hist'};
% cell45 = {'SSP545-COOL-NEAR','SSP545-COOL-FAR', ...
%    'SSP545-HOT-NEAR','SSP545-HOT-FAR'};
% cell85 = {'SSP585-COOL-NEAR','SSP585-COOL-FAR', ...
%    'SSP585-HOT-NEAR','SSP585-HOT-FAR'};
% 
% catHist = categorical(cellHist);
% cats45 = categorical(cell45);
% cats85 = categorical(cell85);
% 
% T1_45 = T1(ismember(T1.scenario,cats45),:);
% T1_85 = T1(ismember(T1.scenario,cats85),:);
% 
% T1_45.scenario = removecats(T1_45.scenario,cell85);
% T1_45.scenario = removecats(T1_45.scenario,cellHist);
% T1_85.scenario = removecats(T1_85.scenario,cell45);
% T1_85.scenario = removecats(T1_85.scenario,cellHist);
% 
% T1_45.scenario = reordercats(T1_45.scenario,{'SSP545-COOL-NEAR','SSP545-COOL-FAR', ...
%    'SSP545-HOT-NEAR','SSP545-HOT-FAR'});
% 
% if plotfigs == true
%    f1 = macfig;
%    boxchart(T1_45.scenario,T1_45.Pdiff,'GroupByColor',T1_45.season);
%    ylabel('Peak Flood Difference (%)'); title('Trenton');
%    legend('JFM','AMJ','JAS','OND');
%    
%    f2 = macfig;
%    boxchart(T2.season,T2.Pdiff);
%    ylabel('Peak Flood Difference (%)'); title('Philadelphia');
% end