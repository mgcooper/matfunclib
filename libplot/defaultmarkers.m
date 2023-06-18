function symbols = defaultmarkers(markertype)

arguments
   markertype (1,1) string {mustBeMember(markertype,["all","closed"])} = "all"
end

switch markertype
   case "all"
      symbols = {'*','+','.','<','>','^','v','x','diamond','o','pentagram', ...
         'square','hexagram','|'};
   case "closed"
      symbols = {'diamond','o','pentagram','square','hexagram'};
end

% I don't include the marker '_' b/c it's indistinguishable from a line when
% used as a line-marker