function data = standardizeData(data)

% % this implements my standard naming rules.
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

             
   vars = fieldnames(data);
   
   for n = 1:numel(vars)
      
      thisvar  = vars{n};
      
      % tair, tsfc
      if any(strcmp(thisvar,{'TTH','T2M'}))
         
         data  = renameStructFields(data,thisvar,'tair');
         
      elseif any(strcmp(thisvar,{'ST'}))
         
         data  = renameStructFields(data,thisvar,'tsfc');
         
      % shortwave down
      elseif any(strcmp(thisvar,{'SWDH','SWGDN'}))
                              
         data  = renameStructFields(data,thisvar,'swd');

      % shortwave net
      elseif any(strcmp(thisvar,{'SWGNT'}))
                              
         data  = renameStructFields(data,thisvar,'swn');
         
      % longwave down
      elseif any(strcmp(thisvar,{'LWDH','LWGAB'}))
                              
         data  = renameStructFields(data,thisvar,'lwd');
         
      % longwave up
      elseif any(strcmp(thisvar,{'LWGEM'}))
                              
         data  = renameStructFields(data,thisvar,'lwu');

      % longwave net
      elseif any(strcmp(thisvar,{'LWGNT'}))
                              
         data  = renameStructFields(data,thisvar,'lwn');
         
      % ground heat flux
      elseif any(strcmp(thisvar,{'GHTSKIN'}))
         
         data  = renameStructFields(data,thisvar,'ghf');

      % albedo
      elseif any(strcmp(thisvar,{'ALH','SNICEALB'}))
         
         data  = renameStructFields(data,thisvar,'albedo');
         
     elseif any(strcmp(thisvar,{'MODIS'}))
         
         data  = renameStructFields(data,thisvar,'modis');
         
      % surface pressure
      elseif any(strcmp(thisvar,{'SP','PS'}))
         
         data  = renameStructFields(data,thisvar,'psfc');
      
      % elevtion
      elseif any(strcmp(thisvar,{'SH','HLML'}))
         
         data  = renameStructFields(data,thisvar,'elev');
         
      % wind speed
      elseif any(strcmp(thisvar,{'WSPD','SPEED'}))
         
         data  = renameStructFields(data,thisvar,'wspd');
         
      % wind direction
      elseif any(strcmp(thisvar,{'WDIR'}))
         
         data  = renameStructFields(data,thisvar,'wdir');
         
      % rel humidity
      elseif any(strcmp(thisvar,{'RH','relh'}))
         
         data  = renameStructFields(data,thisvar,'rh');
      
      % specific humitidy (if used to compute relh, need 6 digits)
      elseif any(strcmp(thisvar,{'QQH','shum','QV2M'}))
         
         data  = renameStructFields(data,thisvar,'sh');
         
      % melt, internal melt
      elseif any(strcmp(thisvar,{'MEH','meltin'}))
         
         data  = renameStructFields(data,thisvar,'melt');

      elseif any(strcmp(thisvar,{'refreeze'}))
         
         data  = renameStructFields(data,thisvar,'freeze');
         
      % snow divergence
      elseif any(strcmp(thisvar,{'sndiv'}))
         
         %data  = renameStructFields(data,thisvar,'freeze');
         
      % snowfall
      elseif any(strcmp(thisvar,{'SFH','PRECSNO'}))
                              
         data  = renameStructFields(data,thisvar,'snow');
         
      % rainfall
      elseif any(strcmp(thisvar,{'RFH'}))
                              
         data  = renameStructFields(data,thisvar,'rain');

      % total ppt
      elseif any(strcmp(thisvar,{'PRECTOTCORR','precip'}))
                              
         data  = renameStructFields(data,thisvar,'ppt');
         
      % evaporation, sublimation, condenstation
      elseif any(strcmp(thisvar,{'EVAP'}))
         
         data  = renameStructFields(data,thisvar,'evap');
      
      % runoff
      elseif any(strcmp(thisvar,{'RUH','RUNOFF'}))
         
         data  = renameStructFields(data,thisvar,'runoff');
         
      % smb
      elseif any(strcmp(thisvar,{'SMBH'}))
         
         data  = renameStructFields(data,thisvar,'smb');
         
      % sensible heat flux
      elseif any(strcmp(thisvar,{'SHFH','HFLUX'}))
         
         data  = renameStructFields(data,thisvar,'shf');
         
      % latent heat flux
      elseif any(strcmp(thisvar,{'LHFH','EFLUX'}))
         
         data  = renameStructFields(data,thisvar,'lhf');
         
      % snow depth
      elseif any(strcmp(thisvar,{'SHSN2','SNOWDP_GL'}))
         
         data  = renameStructFields(data,thisvar,'snowd');
         
      % cloud frac
      elseif any(strcmp(thisvar,{'CC'}))
         
         data  = renameStructFields(data,thisvar,'cfrac');

      % wind components
      elseif any(strcmp(thisvar,{'UUH','U2M'}))
         
         data  = renameStructFields(data,thisvar,'uwind');
         
      elseif any(strcmp(thisvar,{'VVH','V2M'}))
         
         data  = renameStructFields(data,thisvar,'vwind');
         
      end
   end
   