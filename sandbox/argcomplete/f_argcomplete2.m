function [ydatavar, xgroupvar, cgroupvar] = f_argcomplete2(T,ydatavar,xgroupvar,cgroupvar)

% This is valid:
% arguments
%    T table
%    ydatavar (1,1) string { mustBeNonempty(ydatavar) }
%    xgroupvar (1,1) string { mustBeNonempty(xgroupvar) }
%    cgroupvar (1,1) string
% end

% This is not:
arguments
   T table = table()
   ydatavar (1,1) string { mustBeMember(ydatavar, getvars(T)) } = "none"
   xgroupvar (1,1) string { mustBeNonempty(xgroupvar) } = "none"
   cgroupvar (1,1) string = "none"
end

end

function varargout = getvars(T)
   varargout = T.Properties.VariableNames;
end