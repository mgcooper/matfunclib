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
   ignorepaths = {
      fullfile(getenv('MATLAB_FUNCTION_PATH'), 'libtext', 'printf'); ...
      fullfile(getenv('MATLAB_FUNCTION_PATH'), 'liblogic', 'iscomplex'); ...
      fullfile(getenv('MATLAB_FUNCTION_PATH'), 'liblogic', 'ifelse'); ...
      fullfile(getenv('MATLAB_FUNCTION_PATH'), 'libstruct', 'numfields'); ...
      fullfile(getenv('MATLAB_FEX_PATH'), 'libarrays', 'foreach'); ...
      };
end
