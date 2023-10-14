function filelist = merraSaveFilelist(pathToMerraFiles, pathToSaveList)
   %MERRASAVEFILELIST Save MERRA2 file list.
   %
   %merraSaveFilelist renames merra files with non-standard numbering due to
   %revised streams and saves a file list with the renamed files in
   %path2savelist for use with other functions to read in the merra data

   % % need to make a function based on the merra_build_wget scripts that does
   % that for any arbitrary list of variables, spatial areas, times, etc.
   % right now the vars requested are:
   % BASEFLOW,EVLAND,PRECTOTLAND,RUNOFF,SNOMAS,TWLAND,WCHANGE

   % % notes on non-standard streams:
   % the second filename part (100, 200, 300, ...) is
   % the assimilation stream. when data is reprocessed, the stream is
   % adjusted from 100 to 101, or 200 to 201, etc. such that the filenames
   % are 'MERRA2_101' rather than 'MERRA2_100', where 100 is the normal
   % filename, and 101 is the updated stream due to reprocessing

   % this can lead to inadvertant errors when reading in the data, which
   % can be avoided if one always builds explicit filenames rather than the
   % order returned by 'dir' function, but to reduce the chance of errors,
   % this function renames the reprocessed files and saves a file list

   if nargin < 2
      pathToSaveList = fileparts(mfilename('fullpath'));
   end

   fdir = pathToMerraFiles; % for compact notation in the loop

   % expected non-standard streams (might need updating in future)
   newstreams = string([101, 201, 301, 401]);
   repstreams = string([100, 200, 300, 400]);

   filelist = dir(fullfile(pathToMerraFiles, '*.nc4'));

   % replace instances of updated streams with standard numbering so the
   % filelist is in the expected order, to reduce the chance of errors
   for n = 1:numel(filelist)
      % the stream is the second filepart
      fname = filelist(n).name;
      stream = string(fname(8:10));

      if ismember(stream,newstreams)

         % build a new filename
         newfname = fname;
         newfname(8:10) = char(repstreams(stream==newstreams));

         % rename the file itself
         movefile([fdir '/' fname],[fdir '/' newfname]);

         % below i just remake the list
         % filelist(n).name = fname;
      end
   end

   % get the file list again
   filelist = dir(fullfile(fullfile(pathToMerraFiles, '*.nc4')));

   save(fullfile(pathToSaveList, 'merrafilelist.mat'),'filelist')
end
