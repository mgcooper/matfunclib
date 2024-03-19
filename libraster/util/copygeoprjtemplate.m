function copygeoprjtemplate(geoshpfname)
   %COPYGEOPRJTEMPLATE Copy .prj file to shapefile destination.
   %
   %  copygeoprjtemplate(geoshpfname)
   % 
   % See also:

   if contains(geoshpfname,'.shp')
      geoshpfname = strrep(geoshpfname,'.shp','.prj');
   elseif contains(geoshpfname,'.') && ~contains(geoshpfname,{'.shp','.prj'})
      error('uknown file extension');
   elseif ~contains(geoshpfname,'.')
      geoshpfname = [geoshpfname '.prj'];
      disp('appending .prj to filename');
   end

   src = fullfile(getenv('MATLABUSERPATH'), ...
      'matfunclib/templates/geoprojtemplate.prj');
   copyfile(src, geoshpfname);
end
