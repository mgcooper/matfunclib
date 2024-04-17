function fields = ncdefaults(option)

   switch lower(option)

      case "attributes"

         % These are variable attributes. Several are missing, add later.
         fields = ["standard_name", "long_name", "units", "axis", ...
            "coordinates", "positive", "calendar"];

      case "global"

         % These are global attributes
         fields = ["title", "institution", "source", ...
            "history", "references", "comment", "Conventions"];

      case ["axes", "axis"]

         fields = ["X", "Y", "Z", "T"];

      case ["dimensions", "dimension", "dims"]

         % These are standard names
         fields = ["longitude", "latitude", "depth", "time"];
   end
end
