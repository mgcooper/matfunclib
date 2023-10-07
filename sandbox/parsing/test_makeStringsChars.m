
% Note the following unexpected behavior:
test = {1, 'testchar', "teststring", {1}, {'testcellstr', "testcellstr"}};
containsOnlyText(test)

% ans =
%   logical
%    1

% This occurs b/c the concatenation step converts the double 1 to a string:
[test{:}]

% ans = 
%   1×5 string array
%     "1"    "testchar"    "teststring"    "1"    "testcellstr"

%% compare with matlab.graphics.internal.convertStringToCharArgs

ret = convertStringsToChars(test)
[ret{:}] = convertStringsToChars(test{:})
ret = matlab.graphics.internal.convertStringToCharArgs(test)

%% ischarlike

ischarlike(test)
ischarlike(test{:}) % note: test{:} but step in to ischarlike and it gets all the values
ischarlike(test(:))

ischarlike(test, 'all')
ischarlike(test{:}, 'all') 
ischarlike(test(:), 'all')


ischarlike({"test1", "test2"}, 'all')
ischarlike({"test1", {"test2"}}, 'all')


matlab.internal.datatypes.isCharString(test)
matlab.internal.datatypes.isCharString(test{:})
matlab.internal.datatypes.isCharString(test(:))

%% casting to strings / chars

% This does not convert the strings in the cells to chars
test = convertStringsToChars(test);

% This says the number of outputs must match the number of inputs
[test{1:numel(test)}] = convertStringsToChars(test);

% This works, but does not convert layered cells, which is an exotic edge case
% that most likely does not need to be handled
[test{1:numel(test)}] = convertStringsToChars(test{:});


% Use ischarlike to get the charlike indexes
tf = ischarlike(test, 'each');

% This fails b/c tostring won't convert the layered cell
test = tostring(test(tf))

% This works, but converts the numbers to strings
[test{1:numel(test)}] = tostring(test{:})

% So subset first, then send it in
test = {1, 'testchar', "teststring", {1}, {'testcellstr', "testcellstr"}};
tf = ischarlike(test, 'each');
test = test(tf);
[test{1:numel(test)}] = tostring(test{:})


%%

% Mixture, including correct one
[opt, args] = parseoptarg(test, 'testchar')

% single numeric, not including the right one
[opt, args] = parseoptarg({1}, 'testchar')

% Single char, including the right one
[opt, args] = parseoptarg({'testchar'}, 'testchar')

%% 

% More exotic types fail:
% test = {1, 'testchar', "teststring", polyshape(1,1)};
% containsOnlyText(test)



