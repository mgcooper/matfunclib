function [symbols, sizes] = defaultmarkers(markertype)

   arguments
      markertype (1,1) string {mustBeMember(markertype,["all","closed"])} = "all"
   end

   switch markertype
      case "all"
         symbols = {'s','h','d','o','p','x','+','<','*','>','^','v'};
         sizes = [10 12 10 10 16 12 12 10 12 10 10 10];
         % symbols = {'*','+','.','<','>','^','v','x','diamond','o','pentagram', ...
         %   'square','hexagram','|'};
      case "closed"
         symbols = {'diamond','o','pentagram','square','hexagram'};
   end

   % I don't include the marker '_' b/c it's indistinguishable from a line when
   % used as a line-marker

   % Complete list of valid Line Style and Marker values. Note that partial
   % matches are supported. Idea here is to add an option to return these as
   % individual or one complete list for cases where the calling function needs
   % them all e.g. rmMarkerArgs in scatterfit.
   % linestyles = ["-", "--", ":", "-."];
   % markers = ["o", "+", "*", ".", "x", "_", "|", "square", "diamond", ...
   %    "^", "v", ">", "<", "pentagram", "hexagram"];
end
