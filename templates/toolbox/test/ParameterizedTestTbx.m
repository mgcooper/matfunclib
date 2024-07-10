classdef ParameterizedTestTbx < matlab.unittest.TestCase
   % ParameterizedTestTbx contains a set of 4 simple tests:
   %     1) an equality test for a setup string variable
   %     2) an equality test for a leap year date
   %     3) a negative test for an invalid date format input
   %     4) a negative test for a correct date format but an invalid date
   %     5) an equality test for a non-leap year date using the alternate
   %        dateFormat (COMMENTED OUT)
   %
   % Notes:
   %     A) A negative test verifies that the code errors/fails in an
   %        expected way (e.g., the code gives the right error for a
   %        specific bad input)
   %     B) The 5th test is included for completeness, but is commented
   %        out to illustrate missing code coverage in continous
   %        integration (CI) systems

   properties (TestParameter)
      % SetupOption = {'install','uninstall','dependencies','addpath','savepath','rmpath','delpath'};
      % VariableName = {'X','Y','T'};
      % MethodName = {'add', 'multiply'};
      % ParameterValue = {1.0, 1.5}; % linear and non-linear
      % PowerLawExponent = {1.5, 2.0, 2.5, 3.0, 3.5};
      % CoefficientValue = {10, 100, 1000};
      % MinimumEventDuration = {3,6,9};
   end

   methods (Test)

%       %-------------------------------------------
%       %-------------------------------------------
%       function test_func1(testCase, MethodName)
% 
%          % import the test data
%          data = tbx.internal.generateTestData();
% 
%          % Calculate expected result
%          dx = x-[nan; x(1:end-1)];
%          dt = (t(2)-t(1));
%          dxdtExpected = dx./dt;
% 
%          % Get the actual result
%          [~,dxdtActual] = tbx.getdxdt(t, x, [], MethodName);
% 
%          % Verify that the actual result matches the expected result
%          testCase.verifyEqual(dxdtActual,dxdtExpected)
% 
%       end
% 
%       %-------------------------------------------
%       %-------------------------------------------
%       function test_func2(testCase, ParameterValue, MethodName)
% 
%          % define values to generate the test data
%          x0 = 100;
%          t = 1:100;
%          a = 1e-2;
%          b = ParameterValue;
% 
%          % generate the test data
%          [x, dxdt] = tbx.util.generateTestData(a,b,x0,t);
% 
%          % fit the data
%          switch MethodName
%             case {'mean','median'}
%                Fit = tbx.fitab(x,dxdt,MethodName,'order',b);
%             otherwise
%                Fit = tbx.fitab(x,dxdt,MethodName);
%          end
% 
%          % Get the expected result
%          abExpected = [a;b];
% 
%          % Get the actual result
%          abActual = Fit.ab;
% 
%          % Verify that the actual result matches the expected result
%          testCase.verifyEqual(abActual,abExpected,'RelTol',[0.01; 0.01])
% 
%       end
% 
%       %-------------------------------------------
%       %-------------------------------------------
%       function test_func3(testCase, PowerLawExponent)
% 
%          % generate power-law distributed test data
%          x = (1-rand(10000,1)).^(-1/(PowerLawExponent-1));
% 
%          % compute the fit
%          [~, alphaActual] = tbx.plfitb(x);
% 
%          % Verify that the actual result matches the expected result
%          testCase.verifyEqual(PowerLawExponent,alphaActual,'AbsTol',0.1);
% 
%       end
% 
%       %-------------------------------------------
%       %-------------------------------------------
%       function test_func4(testCase, ParameterValue)
% 
%          % make test data
%          xmin = 1;
%          xmax = 100;
%          a = 1;
%          b = ParameterValue;
% 
%          % compute the expected result
%          switch ParameterValue
%             case 1.0
%                SminExpected = 1/a*xmin;
%                SmaxExpected = 1/a*xmax;
% 
%             case 1.5
%                SminExpected = 1/a/(2-b).*(xmin.^(2-b));
%                SmaxExpected = 1/a/(2-b).*(xmax.^(2-b));
%          end
% 
%          % get the actual result
%          [SminActual,SmaxActual] = tbx.aquiferstorage(a,b,xmin,xmax);
% 
%          % Verify that the actual result matches the expected result
%          testCase.verifyEqual([SminExpected,SmaxExpected],[SminActual,SmaxActual]);
% 
%       end
% 
%       %-------------------------------------------
%       %-------------------------------------------
%       function test_eventfinder(testCase, MinimumEventDuration)
% 
%          % I don't need this many examples, but I keep this one for now b/c it
%          % shows how to make up the dummy cosine data
% 
%          nmin = MinimumEventDuration;
% 
%          % this should work in general, as long as prec is used consistently
%          prec = 3; % precision, controls how large the test vectors are
%          dpi = 10^-prec;
% 
%          % generate synthetic data
%          t = -2*pi:dpi:2*pi;
%          x = 1 + sin(t);
% 
%          % find the maxima and minima (where d/dt sin(t) == 0)
%          idx = find(abs(round(cos(t),prec))==0);
%          idx = transpose(reshape(idx,2,[])); % [istart istop]
% 
%          tExpected = cell(numel(idx)/2, 1);
%          xExpected = cell(numel(idx)/2, 1);
%          for n = 1:numel(idx)/2
%             ievent = idx(n,1)+2 : idx(n,2)-1;
%             tExpected{n,1} = transpose(t(ievent));
%             xExpected{n,1} = transpose(x(ievent));
%          end
% 
%          % get the actual result
%          [tActual,qActual] = tbx.eventfinder(t,x,[],'nmin',nmin,'fmax',0, ...
%             'rmax',0,'rmin',0,'rmconvex',false,'rmnochange',false,'rmrain',false);
% 
%          % Verify that the actual result matches the expected result
%          testCase.verifyEqual([tExpected,xExpected],[tActual,qActual]);
%       end
% 
%       %-------------------------------------------
%       %-------------------------------------------
%       function test_basinname(testCase, PlaceName)
% 
%          % get the place name from the database
%          ActualName = tbx.placename(PlaceName);
% 
%          % Verify that the actual result matches the expected result
%          testCase.verifyEqual(PlaceName, ActualName);
% 
%       end

   end
end
