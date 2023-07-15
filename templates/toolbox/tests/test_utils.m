function testsuite = test_utils %#ok<*STOUT>
%
% Based on code in project_template, (C) Copyright 2022 Remi Gau

% The idea is this tests the functions in the utils/ folder

   try % Matlab >= 2016
      
      test_functions = localfunctions(); %#ok<*NASGU>
      
   catch % earlier versions
      
      initTestSuite;
   end
end

%% test functions

function test_get_version_smoke_test()

results = get_version();

end

function test_root_dir_smoke_test()

results = root_dir();

end

function test_is_octave_smoke_test()

results = is_octave();

end
