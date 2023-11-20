%TEST_TODATETIME test todatetime

ogformat = format;
job = onCleanup(@() format(ogformat));
format shortG

datetoday = datetime('today');

% Note: for YYYYMMDD format, the datetime equivalent will use hour 1, 

% Define test data
testdata.datetime.t1 = datetime(0, 1, 1, 0, 0, 0);
testdata.datetime.t2 = datetime(1000, 1, 1, 0, 0, 0);
testdata.datetime.t3 = datetime(2022, 1, 1, 0, 0, 0);

testdata.datenum.t1 = datenum(datetime(0, 1, 1, 0, 0, 0));
testdata.datenum.t2 = datenum(datetime(1000, 1, 1, 0, 0, 0));
testdata.datenum.t3 = datenum(datetime(2022, 1, 1, 0, 0, 0));

testdata.yyyymmdd.t1 = 00000101;
testdata.yyyymmdd.t2 = 10000101;
testdata.yyyymmdd.t3 = 20220101;

% Below here trying to get today date in YYYYMMDD format, easy enough but
% decided to just use a recent date for t3

% testdata.datetime.t3 = datetoday;
% testdata.datenum.t3 = datenum(datetoday);

% testdata.yyyymmdd.t3 = string(datetoday);

% string(testdata.datetime.t1)
% thismonth = month(datetoday);
% thisday = day(datetoday);
% if thismonth < 10
% 
% end
% testdata.datetime.t3 = cat(2, year(now), month(now), day(now));

%% test datenum day 1 of year 0

[t, ~, dtype] = todatetime(testdata.datenum.t1);

assertEqual(testdata.datetime.t1, t)
assertEqual('datenum', dtype)

%% test datenum day 1 of year 1000

[t, ~, dtype] = todatetime(testdata.datenum.t2);

assertEqual(testdata.datetime.t2, t)
assertEqual('datenum', dtype)

%% test datenum day 1 of year 2020
[t, ~, dtype] = todatetime(testdata.datenum.t3);

assertEqual(testdata.datetime.t3, t)
assertEqual('datenum', dtype)

%% test yyyymmdd day 1 of year 0

% This will return whatever datenum(101) is, this could be recast as an
% assertError
[t, ~, dtype] = todatetime(testdata.yyyymmdd.t1);

assertEqual(datetime(datenum(101), "ConvertFrom", "datenum"), t)
assertEqual('datenum', dtype)

%% test yyyymmdd day 1 of year 1000
[t, ~, dtype] = todatetime(testdata.yyyymmdd.t2);

assertEqual(testdata.datetime.t2, t)
assertEqual('yyyymmdd', dtype)

%% test yyyymmdd day 1 of year 2020
[t, ~, dtype] = todatetime(testdata.yyyymmdd.t3);

assertEqual(testdata.datetime.t3, t)
assertEqual('yyyymmdd', dtype)



% %% Test function accuracy
% 
% % Test function accuracy using assert
% expected = [];
% returned = todatetime( );
% assert(isequal(returned, expected));
% 
% % Test function accuracy using assert with tolerance
% tol = 20*eps;
% assert(abs(returned - expected) < tol);
% 
% % Test with edge cases (Inf, NaN, very large/small numbers)
% assert(isnan(todatetime(NaN)));
% assert(isinf(todatetime(Inf)));
% assert(abs(todatetime(1e200) - 1e200) < 1e-10); % replace with theoretical result
% 
% %% Test error handling
% 
% % This uses the custom local functions to mimic the testsuite features like
% % verifyError in a script-based testing framework. See the try-catch versions
% % further down for another way to test error handling.
% 
% testdiag = "description of this test";
% eid = 'matfunclib:libname:todatetime';
% 
% % verify failure
% assertError(@() todatetime('inputs that error'), eid, testdiag)
% 
% % verify success
% assertSuccess(@() todatetime('inputs that dont error'), eid, testdiag)
% 
% %% Test type handling
% 
% % Test different types, if the function is expected to handle them
% 
% expected = []; % add expected value for double type
% assert(isequal(todatetime(X), expected));
% 
% expected = []; % add expected value for single type
% assert(isequal(todatetime(single(X)), single(expected)));
% 
% expected = []; % add expected value for logical type
% assert(isequal(todatetime(logical(X)), expected));
% 
% expected = []; % add expected value for int16 type
% assert(isequal(todatetime(int16(X)), expected)); % int16
% 
% %% Test dimension handling
% 
% % Test different dimensions
% assert(isequal(todatetime([2 3]), [4 6])); % 1D array
% assert(isequal(todatetime([2 3; 4 5]), [4 6; 8 10])); % 2D array
% 
% %% Test empty inputs
% try
%    todatetime();
%    error('Expected an error for empty inputs, but none was thrown');
% catch ME
%    assert(strcmp(ME.identifier, 'MATLAB:minrhs'));
% end
% 
% %% Test invalid inputs
% try
%    todatetime('invalid');
%    error('Expected an error for invalid inputs, but none was thrown');
% catch ME
%    % if arguments block is used:
%    assert(strcmp(ME.identifier, 'MATLAB:validation:UnableToConvert'));
%    % otherwise, might be:
%    % assert(strcmp(ME.identifier, 'MATLAB:invalidInput'));
% end
% 
% %% Test too many input arguments
% try
%    todatetime(1,2,3,4,5,6,7);
%    error('Expected an error for too many inputs, but none was thrown');
% catch ME
%    assert(strcmp(ME.identifier, 'MATLAB:TooManyInputs'));
% end
