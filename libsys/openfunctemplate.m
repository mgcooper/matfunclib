function openfunctemplate(template)

arguments
   template (1,:) char {mustBeMember(template,{'IP','MP','OP','NP','AP'})} = 'AP'
end

open(fullfile(getenv('MATLABTEMPLATEPATH'),['functemplate' template '.m']));