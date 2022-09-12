function copyfunctemplate(newfuncpath)

   src = [getenv('MATLABTEMPLATEPATH') 'functemplate.m'];
   copyfile(src,newfuncpath);
   
% note: unlike copyjsontemplate, this accepts the filename, which already
% has _tmp appended in the case of an existing function, so there isn't any
% need to have an option to 'appendfunc' or similar