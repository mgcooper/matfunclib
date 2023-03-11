function openfunctemplate(template)

arguments
   template (1,:) char {mustBeMember(template,{'IP','MP','ArgList'})} = 'ArgList'
end

open(fullfile(getenv('MATLABTEMPLATEPATH'),['functemplate' template '.m']));