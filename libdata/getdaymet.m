function Data = getdaymet(lat,lon,vars,start_year,end_year)
   %GETDAYMET download daymet file and save to table
   %
   %  Data = getdaymet(lat,lon,vars,start_year,end_year)
   %
   % Example
   %
   % see: https://daymet.ornl.gov/web_services
   % lat = 43.7576;
   % lon = -110.9509;
   % vars = 'tmax,tmin';
   % y1 = 2000;
   % y2 = 2020;
   % Data = getdaymet(lat,lon,vars,y1,y2);
   %
   % See also

   % Example REST URL:
   url = 'https://daymet.ornl.gov/single-pixel/api/data?';

   % create comma-separated list of years
   nyrs = (end_year-start_year)+1;
   years = '';
   for n = 1:nyrs
      if n ~= nyrs
         years = [years num2str(start_year+n-1) ','];
      else
         years = [years num2str(start_year+n-1)];
      end
   end

   url = [url 'lat=' num2str(lat)];
   url = [url '&lon=' num2str(lon)];
   url = [url '&vars=' vars];      %CommaSeparatedVariables
   url = [url '&years=' years];    %CommaSeparatedYears

   % webread the data
   Data = webread(url);

   % Using StartDate, EndDate:
   % https://daymet.ornl.gov/single-pixel/api/data?lat=Latitude&lon=Longitude&vars=CommaSeparatedVariables&start=StartDate&end=EndDate
end
