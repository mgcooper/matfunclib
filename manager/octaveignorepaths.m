function ignorepaths = octaveignorepaths()
   %OCTAVEIGNOREPATHS List path folders that Octave cannot load.
   %
   %  IGNOREPATHS = OCTAVEIGNOREPATHS() returns the folders holding
   %  functions that shadow Octave built-ins or use syntax Octave cannot
   %  parse. startup.m and funclibpath remove these folders from the path
   %  when they run in Octave.
   %
   %  Reads MATLAB_FUNCTION_PATH and MATLAB_FEX_PATH. No arguments block
   %  and no string types: Octave must parse and run this function.
   %
   % See also: startup funclibpath mconfig

   % Each entry shadows an Octave built-in or fails to parse in Octave.
   % Deliberate raw getenv, not mgetenv: startup.m calls this helper
   % before manager/util joins the path, so mgetenv is not resolvable
   % here. mconfig has already run at that point, so the values are set.
   % In any other session an empty value degrades each entry to a
   % relative fragment. The fragment still substring-matches the
   % absolute path entries it filters, so nothing resolves against cwd
   % (matfunclib-47r).
   ignorepaths = {
      fullfile(getenv('MATLAB_FUNCTION_PATH'), 'libtext', 'printf'); ...
      fullfile(getenv('MATLAB_FUNCTION_PATH'), 'liblogic', 'iscomplex'); ...
      fullfile(getenv('MATLAB_FUNCTION_PATH'), 'liblogic', 'ifelse'); ...
      fullfile(getenv('MATLAB_FUNCTION_PATH'), 'libstruct', 'numfields'); ...
      fullfile(getenv('MATLAB_FEX_PATH'), 'libarrays', 'foreach'); ...
      };
end
