
function Data = standardizeData(Data)

   
   
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ADD DERIVED QUANTITIES
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [Data,Units] = computeDerivedValues(Data,Units,Time)

% % % % % % % % % % % % % % % % % % % % % % % %    
% % below is from mar
% % % % % % % % % % % % % % % % % % % % % % % %    
   
   % compute wind speed/direction    
  [wspd,wdir]  = windDirFromZonalComponents(Data.uwind,Data.vwind);

% wind speed   
   Data.wspd      =  round(wspd,2);
   Units(end+1)   =  {'m/s'};

% wind direction      
   Data.wdir      =  round(wdir,1);
   Units(end+1)   =  {'degrees'};

% rel hum
   Data.rh        =  round(sh2rh(Data.shum,Data.psfc,Data.tair),2);
   Units(end+1)   =  {'%'};

% shortwave up
   Data.swu       =  Data.swd.*Data.albedo;
   Units(end+1)   =  {'W/m2'};
    
% longwave up
   Data.lwu       =  0.98 .* 5.6696e-08 .* Data.tsfc.^4;
   Units(end+1)   =  {'W/m2'};
   
% net shortwave   
   Data.swn       =  Data.swd - Data.swu;
   Units(end+1)   =  {'W/m2'};
    
% longwave up
   Data.lwn       =  Data.lwd - Data.lwu;
   Units(end+1)   =  {'W/m2'};
   
% net turbulent heat flux
   Data.thf       =   Data.shf + Data.lhf;
   Units(end+1)   =   {'W/m2'};
    
% net radiation
   Data.netr      =   Data.swn + Data.lwn;
   Units(end+1)   =   {'W/m2'};

% add a calendar of datenums
	Data.date      = tocolumn(datenum(Time));
   Units(end+1)   = {'datenum'};
   
   
% % % % % % % % % % % % % % % % % % % % % % % %    
% % below is from racmo:
% % % % % % % % % % % % % % % % % % % % % % % % 

    Data.swu    = Data.swsd - Data.swsn;    % shortwave up
    Data.albedo = Data.swu ./ Data.swsd;    % albedo
    Data.thf    = Data.senf + Data.latf;    % net turbulent heat flux
    Data.netr   = Data.swsn + Data.lwsn;    % net radiation
    Data.date   = datenum(Time);            % add a calendar of datenums

% 14 hourly variables + 8 cumulative mass fluxes + MODIS + four computed
% hourly variables + dates = 

% add units for the derived variables
    Units(end+1) = {'W/m2'};            % shortwave up
    Units(end+1) = {'reflectivity'};    % racmo albedo
    Units(end+1) = {'W/m2'};            % net turbulent heat flux
    Units(end+1) = {'W/m2'};            % net radiation
    Units(end+1) = {'datenum'};         % dates
    
% this is only possible with the 'surface' data I thnk    
   %Data.rain   = Data.prec-Data.subl-Data.sdrift-      ...
   %                Data.smb-Data.melt+Data.refreeze;   % rainfall
   %Data.snow   = Data.prec + Data.rain;               % snowfall
   
%   Units(end+1) = {'m/h'};
%   Units(end+1) = {'m/h'}; 
    
end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% RENAME VARS AND ROUND DATA
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Data = renameAndRoundData(Data,Units,varNames)

% % % % % % % % % % % % % % % % % % % % % % % %    
% % below is from mar
% % % % % % % % % % % % % % % % % % % % % % % % 

% rename variables according to my naming conventions and round the data

   oldVars     =  Data.Properties.VariableNames;
   newVars     =  {  'tair','shum','uwind','vwind','swd','lwd','albedo', ...
                     'snow','rain','melt','runoff','shf','lhf','smb', ...
                     'snowd','cfrac','tsfc','psfc','modis'};
                     
    if numel(newVars) ~= numel(oldVars)
        warning('the number of new vars is different than old vars');
    end
 
% the loop ensures the order doesn't have to match the order of the table
% (But the order of oldVars and newVars must match!)

    for n = 1:numel(oldVars)
        
        Data = renamevars(Data,oldVars{n},newVars{n});
        
    end
    
% % % % % % % % % % % % % % % % % % % % % % % %    
% % below is from racmo:
% % % % % % % % % % % % % % % % % % % % % % % % 

% rename variables according to my naming conventions and round the data

% the reason this is done after computeDerivedVars is because renamevars
% works on tables and i guess i wanted to wait to convert to table but i
% think i can do it in the other order see saveMerraData

% note - this is bad practice, should do a strcmp and only rename if the
% old var I don't want matches the new one

    newVars = {'lhf','lwd','lwn','meltin','precip','refreeze','runoff',...
                'shf','smb','sndiv','melt','subl','swd','swn'};
            
    for m = 1:numel(newVars)
        Data = renamevars(Data,varNames{m},newVars{m});
    end
                    
    % round some of the data
    for m = 1:length(Units)
        var = Data.Properties.VariableNames{m};
        if strcmp(Units{m},'W/m2')
            Data.(var) = round(Data.(var),2);
        elseif strcmp(Units{m},'-')
            Data.(var) = round(Data.(var),3);
        end
    end
    
    
% % % % % % % % % % % % % % % % % % % % % % % %    
% % below is from merra:
% % % % % % % % % % % % % % % % % % % % % % % % 
    
% rename variables according to my naming conventions and round the data

% type them out to ensure the order of oldVars matches newVars
    oldVars = 	{'SPEED','EVAP','PRECTOTCORR','HLML','GHTSKIN',      ...
                 'PRECSNO','HFLUX','EFLUX',                          ...
                 'RUNOFF','SNOMAS_GL','SNOWDP_GL','ASNOW_GL','SNICEALB',...
                 'LWGAB','SWGNT','LWGNT','SWGDN','LWGEM',              ...
                 'U2M','T2M','PS','V2M','QV2M','MODIS'};
    
    newVars = 	{'wspd','evap','ppt','elev','ghf','snow','shf','lhf', ...
                'runoff','swe','snowd','fsca','albedo',             ...
                'lwd','swn','lwn','swd','lwu',                      ...
                'uwind','tair','psfc','vwind','shum',               ...
                'modis'};
                
    if numel(newVars) ~= numel(oldVars)
        warning('the number of new vars is different than old vars');
    end
    
% the loop ensures the order doesn't have to match the order of the table
    for n = 1:numel(oldVars)
        
        Data = renamevars(Data,oldVars{n},newVars{n});
        
    end
    
    
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ADD METADATA
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Data = addMetaData(Data,Units,sData,sUnits)
    
% add the x,y location, and elevation as metadata
    Data    =   addprop(Data, { 'X','Y','Lat','Lon','Elev','Slope',   ...
                                'ScalarUnits'},{'table','table',      ...
                                'table','table','table','table','table'});
                            
% update the properties
%   data.Properties.VariableNames                = newvars;
    Data.Properties.VariableUnits                = Units;
    Data.Properties.CustomProperties.X           = sData.X;
    Data.Properties.CustomProperties.Y           = sData.Y;
    Data.Properties.CustomProperties.Lat         = sData.LAT;
    Data.Properties.CustomProperties.Lon         = sData.LON;
    Data.Properties.CustomProperties.Elev        = sData.ELEV;
    Data.Properties.CustomProperties.Slope       = nan;
    Data.Properties.CustomProperties.ScalarUnits = sUnits; 
    
% finally, do some basic checks for out-of-bound or non-physical values
    Data     = metchecks(Data,false);
    
    
end
