function Data = h5readdata(fname,varargin)
   %H5READDATA Read all data in .h5 file 'f', or all vars in optional list
   %
   % Input:
   % fname - full path to .h5 file
   %
   % Optional:
   % cell array of characters that match the varialbe names in the
   % .h5 file you want to read. Default behavior reads all variables.
   %
   % warning - the data is converted to column major format
   %
   % See also:

   Info = h5info(fname);

   % create an output structure to hold the data
   Data.Info = Info;

   % get the group names
   if nargin == 1
      Groups = {Info.Groups.Name}';
   else
      Groups = varargin{1};
   end

   % read the top-level attributes
   Data = readh5attributes(Data,Info);

   % read the top-level datasets
   Data = readh5datasets(Data,Info);

   % read the datasets in each group
   Data = readh5groups(Data,Groups,Info);
end

function Data = readh5attributes(Data,Info)

   thisFile = Info.Filename;

   % get the attribute names
   Atts = {Info.Attributes.Name}';

   for n = 1:numel(Atts)

      % apparently makeValidName doesn't replace spaces with underscores,
      % so do that first
      attname = strrep(Atts{n},' ','_');
      attname = matlab.lang.makeValidName(attname,'ReplacementStyle','delete');

      Data.attributes.(attname) = h5readatt(thisFile,'/', Atts{n});
   end
end

function Data = readh5datasets(Data,Info)

   thisFile = Info.Filename;

   % get the dataset names
   Sets = {Info.Datasets.Name}';

   % read the datasets
   for n = 1:numel(Sets)

      % first replace spaces with underscores then make the varname
      varname = strrep(Sets{n},' ','_');
      varname = matlab.lang.makeValidName(varname,'ReplacementStyle','delete');

      Data.(varname) = double(h5read(thisFile,['/',Sets{n}]));
   end
end

function Data = readh5groups(Data,Groups,Info)

   thisFile = Info.Filename;

   % read the datasets in each group
   for n = 1:numel(Groups)

      thisGroup = Groups{n};

      % Each 'Group' can contain multiple datasets
      dsets = {Info.Groups(n).Datasets.Name};
      numSets = numel(dsets);

      % .h5 files store data as 1-d arrays, so multi-dimensional data will
      % be stored as multiple datasets

      % this determines if all the datasets in a group are the same size,
      % and if they are, the next step concatenates them
      samesize = true;
      if numel(dsets)>1
         thisSize = Info.Groups(n).Datasets(1).Dataspace.Size;
         for nn = 2:numel(dsets)
            thatSize = thisSize;
            thisSize = Info.Groups(n).Datasets(nn).Dataspace.Size;
            if thisSize == thatSize
               continue;
            else
               samesize = false;
               break;
            end
         end
      end

      % if all datasets are the same size, cat them
      if samesize == true

         % use next two for catting
         % catdim = numel(thisSize)+1;
         % thisDataset = []; % use

         % this creates an array of the proper size but without knowing if
         % it's 2-d or 1-d data ... might be better to just check since it
         % will either be 1-, 2-, or 3-d ... or reshape
         thisDataset = nan([thisSize numSets]);
         numdims = ndims(thisDataset);
      end

      % read in the datasets
      for m = 1:numSets

         thisSet = dsets{m};

         thisData = double(h5read(thisFile,[thisGroup '/' thisSet]));

         % this option uses catting
         % thisDataset = cat(catdim,thisDataset,thisData);

         % this option indexes into the pre-built nan array but requires
         % checking ndims
         switch numdims
            case 2
               thisDataset(:,m) = thisData;
            case 3
               thisDataset(:,:,m) = thisData;
            case 4
               thisDataset(:,:,:,m) = thisData;
            otherwise
               error('data is >4 dims')
         end

      end

      % first replace spaces with underscores then make the varname
      varname = strrep(thisGroup,' ','_');
      varname = matlab.lang.makeValidName(varname,'ReplacementStyle','delete');

      Data.(varname) = thisDataset;

      %       % try to determine if variable is a 2-d or 3-d spatial variable and if
      %       % so, rotate so it's orientied correctly
      %       if info_n.Size > 1
      %          data_n = rot90(fliplr(data_n));
      %       end
   end
end

% here I was gonna compare the ncinfo output to a few cases where I know I
% wouldn't want to rotate the data
%     % first deal with known cases
%     if ismember({info_n.Attributes.Name},'time')
%         data.(vars{n}) = data_n;
%     end

% here I was gonna do the same thing but use my ncparse output
%     % check against my ncparse function
%     if strcmp(info_n.Name,finfo.Name(n))
%         if finfo.Size(n)
%         end
%     else
