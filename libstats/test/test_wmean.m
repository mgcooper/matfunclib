function tests = test_wmean
   tests = functiontests(localfunctions);

   % Note, if all weights are equal, the weighted mean is identical to the mean.
end

% Trivial case: all weights are equal
function test_vector_input(testCase)
   x = [1 2 3];
   w = [1 1 1];
   y = wmean(x, w);
   expected = mean(x);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Non-trivial weights
function test_vector_nontrivial_weights(testCase)
   x = [1 2 3];
   w = [1 2 3];
   y = wmean(x, w);
   expected = (1*1 + 2*2 + 3*3) / (1 + 2 + 3);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Trivial weights, multiple dimensions
function test_matrix_input(testCase)
   x = [1 4; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w);
   expected = mean(x, 1);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Non-trivial weights, multiple dimensions
function test_matrix_nontrivial_weights(testCase)
   x = [1 4; 2 5; 3 6];
   w = [1 2; 3 4; 5 6];
   y = wmean(x, w);
   expected = sum(x .* w) ./ sum(w);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Trivial weights, dimension specified
function test_dim_specified(testCase)
   x = [1 4; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w, 2);
   expected = mean(x, 2);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Non-trivial weights, dimension specified
function test_dim_specified_nontrivial_weights(testCase)
   x = [1 4; 2 5; 3 6];
   w = [1 2; 3 4; 5 6];
   y = wmean(x, w, 2);
   expected = sum(x .* w, 2) ./ sum(w, 2);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with 'all' specified
function test_all_specified(testCase)
   x = [1 4; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w, 'all');
   expected = mean(x(:));
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with 'all' specified and non-trivial weights
function test_all_specified_nontrivial_weights(testCase)
   x = [1 4; 2 5; 3 6];
   w = [1 2; 3 4; 5 6];
   y = wmean(x, w, 'all');
   expected = sum(x(:) .* w(:)) / sum(w(:));
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with outtype specified
function test_outtype_specified(testCase)
   x = single([1 4; 2 5; 3 6]);
   w = single([1 1; 1 1; 1 1]);
   y = wmean(x, w, 'double');
   expected = double(mean(x, 1));
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with nanflag specified dim 1
function test_nanflag_specified_dim1(testCase)
   x = [1 NaN; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w, 'omitnan');
   expected = mean(x, 'omitnan');
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with nanflag not specified dim 1
function test_nanflag_not_specified_dim1(testCase)
   x = [1 NaN; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w);
   expected = mean(x);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Confirm failure with nanflag not specified dim 1
function test_nanflag_not_specified_dim1_failure(testCase)

   % This is the expected result if the weights are not set nan where x is nan
   x = [1 NaN; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w);
   expected = sum(x .* w, 'omitnan') ./ sum(w, 'omitnan');
   verifyNotEqual(testCase, y, expected);
end

% Test with nanflag specified dim 2
function test_nanflag_specified_dim2(testCase)
   x = [1 NaN; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w, 2, 'omitnan');
   expected = mean(x, 2, 'omitnan');
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Confirm failure with nanflag not specified dim 2
function test_nanflag_not_specified_dim2_failure(testCase)

   % This is the expected result if the weights are not set nan where x is nan
   x = [1 NaN; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w);
   expected = sum(x .* w, 2, 'omitnan') ./ sum(w, 2, 'omitnan');
   verifyNotEqual(testCase, y, expected);
end

% Test with vecdim specified
function test_vecdim_specified(testCase)
   x = [1 4; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w, [1, 2]);
   expected = mean(x(:));
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with outtype and nanflag specified
function test_outtype_nanflag_specified(testCase)
   x = single([1 NaN; 2 5; 3 6]);
   w = single([1 1; 1 1; 1 1]);
   y = wmean(x, w, 2, 'omitnan', 'double');
   expected = mean(x, 2, 'omitnan', 'double');
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with outtype, nanflag, and vecdim specified
function test_outtype_nanflag_vecdim_specified(testCase)
   x = single([1 NaN; 2 5; 3 6]);
   w = single([1 1; 1 1; 1 1]);
   y = wmean(x, w, [1, 2], 'omitnan', 'double');
   expected = mean(x, [1, 2], 'omitnan', 'double');
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with dim specified for 3D matrix
function test_dim_3D_matrix(testCase)
   x = cat(3, [1 4; 2 5; 3 6], [7 10; 8 11; 9 12]);
   w = cat(3, [1 1; 1 1; 1 1], [1 1; 1 1; 1 1]);
   y = wmean(x, w, 3);
   expected = mean(x, 3);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with vecdim specified for 3D matrix
function test_vecdim_3D_matrix(testCase)
   x = cat(3, [1 4; 2 5; 3 6], [7 10; 8 11; 9 12]);
   w = cat(3, [1 1; 1 1; 1 1], [1 1; 1 1; 1 1]);
   y = wmean(x, w, [1, 2]);
   expected = mean(x, [1, 2]);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with 'includenan' flag
function test_includenan_flag(testCase)
   x = [1 NaN; 2 5; 3 6];
   w = [1 1; 1 1; 1 1];
   y = wmean(x, w, 'includenan');
   expected = mean(x, 'includenan');
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with vecdim specified for 3D array with different dimension
function test_vecdim_3D_matrix_diff_dim(testCase)
   x = cat(3, [1 4; 2 5; 3 6], [7 10; 8 11; 9 12]);
   w = cat(3, [1 1; 1 1; 1 1], [1 1; 1 1; 1 1]);
   y = wmean(x, w, [1, 3]);
   expected = mean(x, [1, 3]);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test with dim specified for 4D array
function test_dim_4D_matrix(testCase)
   x = rand(4, 3, 2, 5);
   w = ones(size(x));
   y = wmean(x, w, 4);
   expected = mean(x, 4);
   verifyEqual(testCase, y, expected, 'AbsTol', 1e-10);
end

% Test where weights are zeros and x contains NaNs
function test_weights_zero_nans_in_x(testCase)
   x = [1, 2, NaN];
   w = [0, 0, 0];
   expected = 'libstats:wmean:allZeroWeights';
   verifyError(testCase, @() wmean(x, w), expected);
end
