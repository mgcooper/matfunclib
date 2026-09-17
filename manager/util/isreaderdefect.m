function tf = isreaderdefect(ME)
   %ISREADERDEFECT True when a registry read error is a code or schema defect.
   %
   %  tf = isreaderdefect(ME) is true for the error classes that a readable
   %  registry file never produces. Those are a missing function on the
   %  path, a MAT file without the expected variable, and a registry CSV
   %  that lost some of its columns. The missing variable is
   %  MATLAB:nonExistentField, or Octave's invalid-indexing error whose
   %  message says the structure has no such member. The registry readers
   %  rethrow these rather than fall back to a backup. A backup would
   %  satisfy the read with stale data and hide the defect (audit MEDIUM
   %  27, 29, 30 and LOW 50).
   %
   % See also: readprjdirectory, readtbdirectory

   defects = {'MATLAB:nonExistentField', ...
      'matfunclib:readtbdirectory:schemaDrift', 'MATLAB:load:variableNotFound'};
   octavemissing = strcmp(ME.identifier, 'Octave:invalid-indexing') && ...
      contains(ME.message, 'has no member');
   tf = isundefinedfunction(ME) || any(strcmp(ME.identifier, defects)) || ...
      octavemissing;
end
