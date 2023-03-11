function data = standardizeData(data)

% TODO use validatestring to validate units and variable names

% % this implements my standard naming rules.
% % currently, I think MAR and MERRA2 are implemented.

% % for adding units:

%    % this is another way to update units but not sure what happens if
%    ismember is empty
%    varsH                            = fieldnames(Met);
%    Units(ismember(varsH,'modis'))   = {'-'};
%    Units(ismember(varsH,'QQH'))     = {'kg/kg'};
%    Units(ismember(varsH,'WSPD'))    = {'m/s'};      % wind speed
%    Units(ismember(varsH,'WDIR'))    = {'degrees'};  % wind direction
%    Units(ismember(varsH,'RH'))      = {'%'};        % rel hum
%    Units(ismember(Units,'mmWE/h'))  = {'mWE/h'};
%    Units(ismember(Units,'C'))       = {'K'};
%    Units(ismember(Units,'hPa'))     = {'Pa'};
%    Units(ismember(Units,'w/m2'))    = {'W/m2'}; % typo in the mar data?

% SEE NOTES AT END ABOUT DERVIED VARIABLES

vars = fieldnames(data);

for n = 1:numel(vars)

   thisvar  = vars{n};

   % tair, tsfc
   if any(strcmp(thisvar,{'TTH','T2M'}))

      data  = renamestructfields(data,thisvar,'tair');

   elseif any(strcmp(thisvar,{'ST'}))

      data  = renamestructfields(data,thisvar,'tsfc');

      % shortwave down
   elseif any(strcmp(thisvar,{'SWDH','SWGDN'}))

      data  = renamestructfields(data,thisvar,'swd');

      % shortwave net
   elseif any(strcmp(thisvar,{'SWGNT'}))

      data  = renamestructfields(data,thisvar,'swn');

      % longwave down
   elseif any(strcmp(thisvar,{'LWDH','LWGAB'}))

      data  = renamestructfields(data,thisvar,'lwd');

      % longwave up
   elseif any(strcmp(thisvar,{'LWGEM'}))

      data  = renamestructfields(data,thisvar,'lwu');

      % longwave net
   elseif any(strcmp(thisvar,{'LWGNT'}))

      data  = renamestructfields(data,thisvar,'lwn');

      % ground heat flux
   elseif any(strcmp(thisvar,{'GHTSKIN'}))

      data  = renamestructfields(data,thisvar,'ghf');

      % albedo
   elseif any(strcmp(thisvar,{'ALH','SNICEALB'}))

      data  = renamestructfields(data,thisvar,'albedo');

   elseif any(strcmp(thisvar,{'MODIS'}))

      data  = renamestructfields(data,thisvar,'modis');

      % surface pressure
   elseif any(strcmp(thisvar,{'SP','PS'}))

      data  = renamestructfields(data,thisvar,'psfc');

      % elevtion
   elseif any(strcmp(thisvar,{'SH','HLML'}))

      data  = renamestructfields(data,thisvar,'elev');

      % wind speed
   elseif any(strcmp(thisvar,{'WSPD','SPEED'}))

      data  = renamestructfields(data,thisvar,'wspd');

      % wind direction
   elseif any(strcmp(thisvar,{'WDIR'}))

      data  = renamestructfields(data,thisvar,'wdir');

      % rel humidity
   elseif any(strcmp(thisvar,{'RH','relh'}))

      data  = renamestructfields(data,thisvar,'rh');

      % specific humitidy (if used to compute relh, need 6 digits)
   elseif any(strcmp(thisvar,{'QQH','shum','QV2M'}))

      data  = renamestructfields(data,thisvar,'sh');

      % melt, internal melt
   elseif any(strcmp(thisvar,{'MEH','meltin'}))

      data  = renamestructfields(data,thisvar,'melt');

   elseif any(strcmp(thisvar,{'refreeze'}))

      data  = renamestructfields(data,thisvar,'freeze');

      % snow divergence
   elseif any(strcmp(thisvar,{'sndiv'}))

      %data  = renamestructfields(data,thisvar,'freeze');

      % snowfall
   elseif any(strcmp(thisvar,{'SFH','PRECSNO'}))

      data  = renamestructfields(data,thisvar,'snow'); % formerly used 'sprec'

      % rainfall
   elseif any(strcmp(thisvar,{'RFH'}))

      data  = renamestructfields(data,thisvar,'rain'); % formerly used 'rprec'

      % total ppt
   elseif any(strcmp(thisvar,{'PRECTOTCORR','precip'}))

      data  = renamestructfields(data,thisvar,'ppt');

      % evaporation (for MERRA2, may be sublimation and (?) condenstation)
   elseif any(strcmp(thisvar,{'EVAP'}))

      data  = renamestructfields(data,thisvar,'evap');

      % sublimation
   elseif any(strcmp(thisvar,{'SUH'}))

      data  = renamestructfields(data,thisvar,'subl');

      % runoff
   elseif any(strcmp(thisvar,{'RUH','RUNOFF'}))

      data  = renamestructfields(data,thisvar,'runoff');

      % smb
   elseif any(strcmp(thisvar,{'SMBH'}))

      data  = renamestructfields(data,thisvar,'smb');

      % sensible heat flux
   elseif any(strcmp(thisvar,{'SHFH','HFLUX'}))

      data  = renamestructfields(data,thisvar,'shf');

      % latent heat flux
   elseif any(strcmp(thisvar,{'LHFH','EFLUX'}))

      data  = renamestructfields(data,thisvar,'lhf');

      % snow depth
   elseif any(strcmp(thisvar,{'SHSN2','SNOWDP_GL'}))

      data  = renamestructfields(data,thisvar,'snowd');

      % cloud frac
   elseif any(strcmp(thisvar,{'CC'}))

      data  = renamestructfields(data,thisvar,'cfrac');

      % wind components
   elseif any(strcmp(thisvar,{'UUH','U2M'}))

      data  = renamestructfields(data,thisvar,'uwind');

   elseif any(strcmp(thisvar,{'VVH','V2M'}))

      data  = renamestructfields(data,thisvar,'vwind');

   end
end


% % BELOW ARE NOTES FROM A_PREPROC SCRIPTS IN THE RUNOFF PROJECT. THESE WERE IN
% THE README FILE I MADE IN SEASIDE WHEN TRYING TO ORGANZIE ALL THOSE SCRIPTS. 
% %  derived variables for MAR:
% 
%     % turn the variable list into a table
%     varnames            =   fieldnames(mr);
%     unitsn              =   [varnames (mar.units(1:nvars))'];
%     clear mar
%     
%     % cycle back through and compute derived variables
%     
%     % get shortwave up
%     mr.swu              =   mr.swd.*mr.albedo;
%     unitsn(end+1,1:2)   =   {'swu','W/m2'};
%     
%     % get net shortwave
%     mr.swn              =   mr.swd-mr.swu;
%     unitsn(end+1,1:2)   =   {'swn','W/m2'};
%     
%     % get net turbulent heat flux
%     mr.thf              =   mr.shf + mr.lhf;
%     unitsn(end+1,1:2)   =   {'thf','W/m2'};
%     
%     % get total precipitation
%     mr.prec             =   mr.sprec + mr.rprec;
%     unitsn(end+1,1:2)   =   {'prec','mWE/h'};
%     
%     % get refreezing ignoring condesation
%     mr.refreeze         =   mr.melt + mr.rprec - mr.runoff;
%     unitsn(end+1,1:2)   =   {'refreeze','mWE/h'};
%     
%     % get snow erosion 
%     mr.sdrift           =   mr.prec - mr.subl - mr.runoff - mr.smb;
%     unitsn(end+1,1:2)   =   {'sdrift','mWE/h'};
%     
%     % get wind speed/direction
%     [wspd,wdir]         =   wind_dir_from_zonal_components(mr.uwind,mr.vwind);
%     mr.wspd             =   wspd;
%     mr.wdir             =   wdir;
%     unitsn(end+1,1:2)   =   {'wspd','m/s'};
%     unitsn(end+1,1:2)   =   {'wdir','degrees'};
%     
%     % get 2m relative humidity - use merra surface pressure
%     mr.shum             =   mr.shum./1000;
%     iunits              =   find(strcmp(unitsn,'shum'));
%     unitsn(iunits,2)    =   {'kg/kg'};
%     mr.rh               =   sh2rh(mr.shum,merra.psfc,mr.tair+273.15);
%     mr.rh(mr.rh>100)    =   100;
%     unitsn(end+1,1:2)   =   {'rh','%'};
%     
%     % round some of the data 
%     for i = 1:length(unitsn)
%         vari            =   string(unitsn(i,1));
%         unitsi          =   unitsn(i,2);
%         if strcmp(unitsi,'W/m2')
%             mr.(vari)   =   roundn(mr.(vari),-1);
%         elseif strcmp(unitsi,'-')
%             mr.(vari)   =   roundn(mr.(vari),-4);
%         elseif strcmp(unitsi,'C')
%             mr.(vari)   =   roundn(mr.(vari),-2);
%         elseif strcmp(unitsi,'m/s')
%             mr.(vari)   =   roundn(mr.(vari),-1);
%         elseif strcmp(unitsi,'degrees')
%             mr.(vari)   =   roundn(mr.(vari),0);
%         end
%     end
%    
%     % reorder alphabetically
%     mr                  =   orderfields(mr);
%     unitsn              =   sortrows(unitsn,1);
% 
% 	% add dates to first so size(unitsn,2) == numvars
%     unitsn              =   [{'dates','hrs'};unitsn];
%     