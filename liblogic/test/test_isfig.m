function tests = test_isfig
   tests = functiontests(localfunctions);
end

function testFigureHandle(testCase)
   f = figure;
   tf = isfig(f);
   delete(f);
   verifyTrue(testCase, tf);
end

function testUiFigureHandle(testCase)
   f = uifigure;
   tf = isfig(f);
   delete(f);
   verifyTrue(testCase, tf);
end

function testNonFigureHandle(testCase)
   a = axes;
   tf = isfig(a);
   delete(a);
   verifyFalse(testCase, tf);
end

function testNumericNotFigure(testCase)
   tf = isfig(5);
   verifyFalse(testCase, tf);
end

function testEmptyInput(testCase)
   tf = isfig([]);
   verifyFalse(testCase, tf);
end

function testInfInput(testCase)
   tf = isfig(Inf);
   verifyFalse(testCase, tf);

   tf = isfig(-Inf);
   verifyFalse(testCase, tf);
end

function testMultipleFigures(testCase)
   f1 = figure;
   f2 = figure;
   tf = isfig(f1, f2);
   delete(f1);
   delete(f2);
   verifyEqual(testCase, tf, [true true]);
end
