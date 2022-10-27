function openfunctemplate(template)
   
   arguments
      template (1,:) char {mustBeMember(template,{'IP','MIP','ArgList'})} = 'ArgList'
   end

   open([getenv('MATLABTEMPLATEPATH') 'functemplate' template '.m']);