
% nco suggestions:
% https://nicojourdain.github.io/students_dir/students_netcdf_nco/

% this was 'RASTER_MASTER' but i moved it here

% at some point, probably need to just use this:
% https://github.com/GenericMappingTools/gmtmex
% https://agupubs.onlinelibrary.wiley.com/doi/pdf/10.1002/2016GC006723

% but at their github they say osx install is complicated so i dferred

% list all the built-in map data
ls(fullfile(matlabroot, 'toolbox', 'map', 'mapdata'))

cd('/Applications/MATLAB_R2020a.app/toolbox/map/mapdata/')



% this confirms the order in which I flipud/permute/average is identical
% flip/rot first, then average
V       =   ncread(fname,varname);
V       =   squeeze(V);
V       =   flipud(permute(V,[2 1 3]));
V1      =   nanmean(V,3);
% average first, then flip/rot 
V       =   ncread(fname,varname);
V       =   squeeze(V);
V2      =   squeeze(nanmean(V,3));
V2      =   flipud(permute(V2,[2 1]));
Vtest   =   V2-V1;

max(Vtest(:))
min(Vtest(:))
