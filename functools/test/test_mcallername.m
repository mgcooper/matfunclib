function tests = test_mcallername()

   tests = functiontests(localfunctions);
end

function test_oneOptionalValueWhichMatches(testCase)

   fnc = @() mcallername('filename');

   testCase.verifyWarningFree(fnc)
   testCase.verifyEqual(fnc(), 'runtests.m')

   fnc = @() mcallername('filename', 'STACKLEVEL', 2);
   testCase.verifyWarningFree(fnc)
   testCase.verifyEqual(fnc(), 'test_mcallername.m')

   name = mcallername('filename', 'STACKLEVEL', 1);
   testCase.verifyEqual(fnc(), 'test_mcallername.m')
end

function test_multipleOptionalValuesWhichMatch(testCase)

   % Verify this fails as it should
   fnc = @() mcallername({'fullpath', 'filename'});
   eid = 'MATLAB:InputParser:ArgumentFailedValidation';

   testCase.verifyError(fnc, eid)
end
