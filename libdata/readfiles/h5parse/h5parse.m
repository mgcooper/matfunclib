function S = h5parse(fname)
   %PARSEh5 Parses a h5 file - variable names, attributes, dimensions
   %
   % S = h5parse(fname) returns the variable names, attributes, dimensions,
   % into a matlab structure S that is slightly more useful than the
   % standard output of h5info
   %
   % this isn't finished, and may not be that useful, but if i want to finish
   % it, return to readfiles

   % also see: 'h5vars.m' which is just a wrapper for extractfield

   Info = h5info(fname);
   S = table;
   S.Name = (string({Info.Groups.Name}))';
   nvars = length(S.Name);

   % h5 has top-level 'Groups', 'Datasets', and 'Attributes'
   % 'Groups' is comparable to .nc 'Variables', I think, and below I replaced
   % instances of 'Info.Variables(n). ...' with 'Info.Groups(n). ...'

   for n = 1:nvars

      S.Filename{n} = Info.Filename;

      %    % NOTE: these are the .nc standard att's, need to update with .h5 ones
      %     % get the names of the attributes
      %     if isempty(Info.Groups(n).Attributes)
      %         S.LongName{n} = nan;
      %         S.Units{n} = nan;
      %         S.Size{n} = nan;
      %         S.FillValue{n} = nan;
      %         S.Filename{n} = Info.Filename;
      %         continue
      %     else
      %         atts = (string({Info.Groups(n).Attributes.Name}))';
      %     end
      %
      %     % if a longname exists, put it in the structure, else put nan
      %     ilongname = find(strcmp('long_name',atts));
      %     if isempty(ilongname)
      %         S.LongName{n} = nan;
      %     else
      %         long_n = Info.Groups(n).Attributes(ilongname).Value;
      %         if isempty(long_n)
      %             S.LongName{n} = nan;
      %         else
      %             S.LongName{n} = long_n;
      %         end
      %     end
      %
      %     % if units exists, put it in the structure, else put nan
      %     iunits = find(strcmp('units',atts));
      %     if isempty(iunits)
      %         S.Units{n} = nan;
      %     else
      %         units_n = Info.Groups(n).Attributes(iunits).Value;
      %         if isempty(units_n)
      %             S.Units{n} = nan;
      %         else
      %             S.Units{n} = units_n;
      %         end
      %     end
      %
      %     % if the size attribute exists, put it in the structure, else put nan
      %     size_n = Info.Groups(n).Size;
      %     if isempty(size_n)
      %         S.Size(n) = {Info.Groups(n).Size};
      %     else
      %         S.Size(n) = {Info.Groups(n).Size};
      %     end
      %
      %     % if the fill value exists, put it in the structure, else put nan
      %     fill_n = Info.Groups(n).FillValue;
      %     if isempty(fill_n)
      %         S.FillValue{n} = nan;
      %     elseif ischar(fill_n)
      %         if strcmp(fill_n,'')
      %             S.FillValue{n} = nan;
      %         else
      %             S.FillValue{n} = Info.Groups(n).FillValue;
      %         end
      %     elseif isnumeric(fill_n)
      %         S.FillValue{n} = Info.Groups(n).FillValue;
      %     end
   end
end
