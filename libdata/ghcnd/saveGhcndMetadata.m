function saveGhcndMetadata(varargin)

   if nargin < 1
      savedata = false;
   end

   Meta = readtable('ghcnd-stations.xlsx');
   varnames = Meta.Properties.VariableNames;
   [~,txt] = xlsread('ghcnd-stations.xlsx');
   Meta.GSNFLAG = txt(2:end,7);
   Meta.HCNFLAG = txt(2:end,8);

   % save the station name and station id list separately for autocomplete
   stationlist = [Meta.STATION]';
   stationnames = [Meta.NAME]';

   if savedata == true
      save(localfile(mfilename("fullpath"), 'ghcndmetadata.mat'), 'Meta');
      save(localfile(mfilename("fullpath"), 'ghcndstations.mat'), 'stationlist', 'stationnames');
   end

   % these work:
   % sum(~ismissing(Meta.HCNFLAG))
   % sum(~ismissing(Meta.GSNFLAG))

   % not sure we want this
   % Meta.GSNFLAG = categorical(Meta.GSNFLAG);
   % Meta.HCNFLAG = categorical(Meta.HCNFLAG);

   % thought this might work if categorical
   % sum(~isnan(Meta.HCNFLAG))

   % other stuff I tried
   %
   % fSTATION = '%s';
   % fLAT = '%7.4f';
   % fLON = '%8.4f';
   % fELEV = '%5.1f';
   % fSTATE = '%s';
   % fNAME = '%s';
   % fGSN = '%s';
   % fHCN = '%s';
   % fWMOID = '%d\n';
   % fspec = [fSTATION fLAT fLON fELEV fSTATE fNAME fGSN fHCN fWMOID];
   %
   % fid = fopen('ghcnd-stations.txt','r');
   %
   % test = fscanf(fid,fspec);
   %
   % fspec = '%s %7.4f %8.4f %5.1f %s %s %s %d\n';
   %
   % %
   % fspec = '%s%f%f%f%s%s%s%s%d';
   % Meta = readtable('ghcnd-stations.txt','Format',fspec,'HeaderLines',0);
   %
   % % fid = fopen('ghcnd-stations.txt','r');
   % % fspec = '%12s %7.4f %8.4f %6.1f %31s %8s %5d\n';
   % % test = fscanf(fid,fspec);
   % %
   % % fspec = '%s %7.4f %8.4f %6.1f %s %s %d\n';
   % % test = fscanf(fid,fspec);
   % %
   % % fspec = '%12c\n';
   % % test = fscanf(fid,fspec);
   % %
   % % test = readlines('ghcnd-stations.txt');
end
