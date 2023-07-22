
%% 

% Once the tests at the end of the function template are fleshed out, convert
% them to this notation for octave compatibility

%!test

% ## The %!test directive starts a test block.
% ## Lines beginning with %!<whitespace> are part of the preceeding block.

%! ## Test input validation
%! error funcname()

%! ## Test function accuracy using assert(observed, expected)
%! x = -10:10;
%! assert(funcname(x), 0);

%! ## Test function accuracy using assert(cond)
%! assert(funcname(x) == 0);

% ## Test small numbers using assert(observed, expected, tolerance)
%! observed = funcname(x);
%! expected = 0.1;
%! tol = 20*eps;
%! assert(observed, expected, tol)

% ## Test different shapes and dimensions
%! assert(funcname(magic(3), 1), [5, 5, 5])
%! assert(funcname(magic(3), 2), [5; 5; 5])

% ## Test different types
%! assert(funcname([2 8], "g"), 4)
%! assert(funcname([4 4 2], "h"), 3)
%! assert(funcname(logical([1 0 1 1])), 0.75)
%! assert(funcname(single([1 0 1 1])), single (0.75))

%%

% basic test stucture
%
% 1 input validation should test the number of inputs/outputs, input type/class,
% and any special handling (valid option names, values, etc.), including the
% possibility of "empty" and "NaN" inputs.
%
% 2 Error coverage: Ideally every call to error() in the function includes a
% test to ensure it is correctly reached and executed when the condition occurs
%
% 3 Code path coverage - Include tests for every primary code function and major
% combination of inputs to reduce the number of future bugs reported by users.
%
% 4 Tests should verify proper function output (or appropriately informative
% error message) produced by:
%  - different input shapes - scalars, vectors, arrays, or empty ([], ones(0,1),
%  and ones(1,0) are not necessarily the same!)
%  - types - numbers, booleans, strings, cells, multi-level cells, cell strings,
%  structs, etc.
%  - contents - real or complex, NaN, Inf, etc.
%
% 5 Functions that primarily rely on calling other functions with their own
% tests do not necessarily need to repeat all of the same tests. However, it may
% still be beneficial to do so if changes to the called function could produce
% errors that would not otherwise be caught by other tests.
%
% 6 Floating point calculations can cause failure of %!assert tests expecting
% exact equality. Adding a tolerance on the order of %!eps or %!eps(variable)
% should rarely be a problem and is often sufficient to circumvent the issue.
% Depending on mathematical operations, it may be appropriate to use a tolerance
% several orders of magnitude larger than eps, but care should be taken in
% setting arbitrarily large tolerances that could hide actual calculation
% errors.
%
% 7 Tests that ensure code compatibility with Matlab are very valuable for
% reducing future bug reports for incompatible behavior. Because future behavior
% of Matlab functions can and do often change, and those changes often go
% unnoticed until user bug reports appear, it can be useful to note with a
% comment which version of Matlab the test was verified against (or what the
% latest release was if the compatibility test is based on the public facing
% documentation). As always, please ensure that test code avoids the use of any
% copyrighted material.
%
% 8 Because of the automatic processing and regression tracking, xtest should
% only be used when there is an expected failure that has no related bug report.
% It is preferred that all known bugs that cause function/test failures be
% reported at bugs.octave.org so that a bug ID# is generated and a %!test
% <12345> format block can be used instead. Tests added to confirm bug fixes
% should use a %!test <*12345> block for automated regression tracking.

% NOTES

% assert, error, and warning are shorthand for !test assert, error and warning

%!assert(pi, 3.14159)         # test fails as "Abs err 2.6536e-06 exceeds tol 0 by 3e-06"
%!assert(pi, 3.14159, 1e-5)   # test passes
%!error foo()                 # test that causes any error
%!warning foo()               # test that causes any warning

% put test blocks after the %!test directive

%!test
%! a = [0 1 0 0 3 0 0 5 0 2 1];
%! b = [2 5 8 10 11];
%! for i = 1:5
%!   assert(find(a, i), b(1:i))
%! endfor

% use the fail directive to verify expected errors
%!fail(1+1, 3)

% a %!xtest block is a test that is expected to fail and continue

%!test
%!  assert(1+1, 2)
%!xtest
%!  assert(1+1, 3)


% MORE EXAMPLES

%!assert (foo (1))
%!assert (foo (1:10))
%!assert (foo ("on"), "off")
%!error <must be positive integer> foo (-1)
%!error <must be positive integer> foo (1.5)

%!demo
%! ## see how cool foo() is:
%! foo([1:100])

% assert (cond)
% assert (cond, errmsg)
% assert (cond, errmsg, …)
% assert (cond, msg_id, errmsg, …)
% assert (observed, expected)
% assert (observed, expected, tol)