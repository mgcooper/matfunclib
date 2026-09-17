classdef testPredictlm < matlab.unittest.TestCase
   %TESTPREDICTLM Unit tests for predictlm.
   %
   % predictlm must match predict of the fitted LinearModel at any query
   % points. The t and F quantiles use the residual degrees of freedom of
   % the fit, not the number of query points. A struct with the model
   % values must give the same result as the LinearModel.

   properties (TestParameter)
      % The predictlm bound type and the predict 'Prediction' value that
      % gives the same bounds.
      boundtype = struct( ...
         'confidence', {{'confidence', 'curve'}}, ...
         'prediction', {{'prediction', 'observation'}})
      % Pointwise or simultaneous bounds.
      simultaneous = struct('pointwise', false, 'simultaneous', true)
      % Query points that differ from the fit points. Two query points gave
      % NaN bounds when the quantiles used numel(x)-2.
      xquery = struct('threePoints', [10; 20; 30], 'twoPoints', [5; 45])
      % Struct model inputs that predictlm reads in place of the
      % LinearModel: the LinearModel field names, or the older Octave
      % regression struct with coeffs, vcov, mse, and dfe.
      structtype = struct('modelStruct', 'modelStruct', ...
         'coeffsStruct', 'coeffsStruct')
   end

   properties
      % The LinearModel that each test evaluates.
      mdl
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so predictlm resolves from the repo
         % root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end

      function fitModel(testCase)
         % Fit one line with a deterministic scatter, so the residual
         % degrees of freedom (48) differ from every query point count.
         x = (1:50)';
         y = 2 + 0.5 * x + sin(x);
         testCase.mdl = fitlm(x, y);
      end
   end

   methods (Test)
      function testMatchesPredict(testCase, boundtype, simultaneous, xquery)
         % predictlm returns the predict response and bounds at query
         % points that were not used to fit the model.
         [type, prediction] = boundtype{:};
         alpha = 0.05;
         tolerance = 1e-10;

         [ypred_expected, yconf_expected] = predict(testCase.mdl, ...
            xquery, 'Alpha', alpha, 'Prediction', prediction, ...
            'Simultaneous', simultaneous);
         [ypred_returned, yconf_returned] = predictlm(testCase.mdl, ...
            xquery, alpha, type, simultaneous);

         testCase.verifyEqual(ypred_returned, ypred_expected, ...
            'AbsTol', tolerance)
         testCase.verifyEqual(yconf_returned, yconf_expected, ...
            'AbsTol', tolerance)
      end

      function testStructInput(testCase, structtype, boundtype, simultaneous)
         % A struct model input gives the same response and bounds as the
         % LinearModel. predictlm picks the fields by the input type, so
         % the result does not depend on MATLAB or Octave.
         [type, prediction] = boundtype{:};
         xpoints = [5; 45];
         alpha = 0.1;
         tolerance = 1e-10;

         [ypred_expected, yconf_expected] = predict(testCase.mdl, ...
            xpoints, 'Alpha', alpha, 'Prediction', prediction, ...
            'Simultaneous', simultaneous);
         stats = modelstruct(testCase.mdl, structtype);
         [ypred_returned, yconf_returned] = predictlm(stats, xpoints, ...
            alpha, type, simultaneous);

         testCase.verifyEqual(ypred_returned, ypred_expected, ...
            'AbsTol', tolerance)
         testCase.verifyEqual(yconf_returned, yconf_expected, ...
            'AbsTol', tolerance)
      end
   end
end

function stats = modelstruct(mdl, structtype)
   %MODELSTRUCT Copy the LinearModel MDL into a STRUCTTYPE struct.
   %
   % 'modelStruct' copies the LinearModel field names that predictlm reads.
   % 'coeffsStruct' builds the older Octave regression struct: coeffs
   % columns hold the estimate, standard error, lower and upper 95% bounds,
   % t statistic, and p-value.
   switch structtype
      case 'modelStruct'
         stats.Coefficients.Estimate = mdl.Coefficients.Estimate;
         stats.CoefficientCovariance = mdl.CoefficientCovariance;
         stats.MSE = mdl.MSE;
         stats.DFE = mdl.DFE;
      case 'coeffsStruct'
         stats.coeffs = [mdl.Coefficients.Estimate, ...
            mdl.Coefficients.SE, coefCI(mdl), ...
            mdl.Coefficients.tStat, mdl.Coefficients.pValue];
         stats.vcov = mdl.CoefficientCovariance;
         stats.mse = mdl.MSE;
         stats.dfe = mdl.DFE;
   end
end
