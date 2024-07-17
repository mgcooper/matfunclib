function tests = test_isaxis
   tests = functiontests(localfunctions);
end

function testAxesHandle(testCase)
   f = figure;
   a = axes;
   tf = isaxis(a);
   delete(f);
   verifyTrue(testCase, tf);
end

function testNonAxesHandle(testCase)
   f = figure;
   tf = isaxis(f);
   delete(f);
   verifyFalse(testCase, tf);
end

function testMultipleAxes(testCase)
   f = figure;
   a1 = axes;
   a2 = axes;
   tf = isaxis(a1, a2);
   delete(f);
   verifyEqual(testCase, tf, [true true]);
end

function testNumericNotAxes(testCase)
   tf = isaxis(123);
   verifyFalse(testCase, tf);
end

function testEmptyInput(testCase)
   tf = isaxis([]);
   verifyFalse(testCase, tf);
end

function testInfInput(testCase)
   tf = isaxis(Inf);
   verifyFalse(testCase, tf);

   tf = isaxis(-Inf);
   verifyFalse(testCase, tf);
end
