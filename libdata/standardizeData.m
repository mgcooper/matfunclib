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

      data  = renamestructfields(data,thisvar,'snow');

      % rainfall
   elseif any(strcmp(thisvar,{'RFH'}))

      data  = renamestructfields(data,thisvar,'rain');

      % total ppt
   elseif any(strcmp(thisvar,{'PRECTOTCORR','precip'}))

      data  = renamestructfields(data,thisvar,'ppt');

      % evaporation, sublimation, condenstation
   elseif any(strcmp(thisvar,{'EVAP'}))

      data  = renamestructfields(data,thisvar,'evap');

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
