function data = rounddata(data)
   %ROUNDDATA custom function to round common climate model data to known precision
   %
   % This implements my standard rounding rules. need to be careful with
   % incremental vs cumulative fluxes. i round to 8 digits to be safe but if
   % storing cumulative, that won't be needed.

   % the convention below is: my convention, MAR, MERRA, RACMO

   vars = fieldnames(data);

   for n = 1:numel(vars)

      thisvar  = vars{n};

      % tair, tsfc
      if any(strcmp(thisvar,{'tair','TTH','T2M','tsfc','ST'}))
         data.(thisvar) = round(data.(thisvar), 4);

         % shortwave down/up/net, longwave down/up/net
      elseif any(strcmp(thisvar,{'swd','SWDH','SWGDN','swu','swn','SWGNT',...
            'lwd','LWDH','LWGAB','lwu','LWGEM','lwn', ...
            'LWGNT'}))
         data.(thisvar) = round(data.(thisvar), 2);

         % ground heat flux
      elseif any(strcmp(thisvar,{'ghf','GHTSKIN'}))
         data.(thisvar) = round(data.(thisvar), 2);

         % albedo
      elseif any(strcmp(thisvar,{'albedo','ALH','modis','MODIS','SNICEALB'}))
         data.(thisvar) = round(data.(thisvar), 4);

         % surface pressure
      elseif any(strcmp(thisvar,{'psfc','SP','PS'}))
         data.(thisvar) = round(data.(thisvar), 1);

         % elevtion
      elseif any(strcmp(thisvar,{'elev','SH','HLML'}))
         data.(thisvar) = round(data.(thisvar), 1);

         % wind speed
      elseif any(strcmp(thisvar,{'wspd','WSPD','SPEED'}))
         data.(thisvar) = round(data.(thisvar), 2);

         % wind direction
      elseif any(strcmp(thisvar,{'wdir','WDIR'}))
         data.(thisvar) = round(data.(thisvar), 1);

         % rel humidity
      elseif any(strcmp(thisvar,{'rh','RH','relh'}))
         data.(thisvar) = round(data.(thisvar), 2);

         % specific humitidy (if used to compute relh, need 6 digits)
      elseif any(strcmp(thisvar,{'sh','QQH','shum','QV2M'}))
         data.(thisvar) = round(data.(thisvar), 6);

         % melt, internal melt, refreeze
      elseif any(strcmp(thisvar,{'melt','MEH','meltin','freeze','refreeze'}))
         data.(thisvar) = round(data.(thisvar), 8);

         % snow divergence
      elseif any(strcmp(thisvar,{'sndiv'}))
         data.(thisvar) = round(data.(thisvar), 4);

         % snowfall, rainfall, total ppt
      elseif any(strcmp(thisvar,{'snow','SFH','PRECSNO','rain','RFH',   ...
            'ppt','PRECTOTCORR','precip'}))
         data.(thisvar) = round(data.(thisvar), 8);

         % evaporation, sublimation, condenstation
      elseif any(strcmp(thisvar,{'evap','EVAP','subl'}))
         data.(thisvar) = round(data.(thisvar), 8);

         % runoff, smb
      elseif any(strcmp(thisvar,{'runoff','RUH','RUNOFF','smb','SMBH'}))
         data.(thisvar) = round(data.(thisvar), 8);

         % sensible heat flux, latent heat flux
      elseif any(strcmp(thisvar,{'shf','SHFH','HFLUX','lhf','LHFH','EFLUX'}))
         data.(thisvar) = round(data.(thisvar), 3);

         % snow depth
      elseif any(strcmp(thisvar,{'snowd','SHSN2','SNOWDP_GL'}))
         data.(thisvar) = round(data.(thisvar), 4);

         % cloud frac
      elseif any(strcmp(thisvar,{'cfrac','CC'}))
         data.(thisvar) = round(data.(thisvar), 4);

         % wind components
      elseif any(strcmp(thisvar,{'UUH','VVH','U2M','V2M'}))
         data.(thisvar) = round(data.(thisvar), 6);

      end
   end
end
