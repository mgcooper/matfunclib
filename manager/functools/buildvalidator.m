function validator = buildvalidator(varname,classes,attributes,        ...
   funcname,argindex)

% abandoned this b/c the values don't get put into the handle properly

classes = {'timetable'};
attributes  = {'nonempty'}
funcname = 'trimtimetable';
varname = 'T';
argindex = 1;

validator = @(x)validateattributes(x,{classes(:)},attributes,   ...
   {funcname},varname,argindex);