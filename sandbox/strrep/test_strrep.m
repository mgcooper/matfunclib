
%% strrep vs replace

% strrep operating on a character array
str1 = 'Hello, World!';
newStr1 = strrep(str1, 'World', 'MATLAB');  % Returns 'Hello, MATLAB!'

% replace operating on a string array
str2 = "Hello, World!";
newStr2 = replace(str2, 'World', 'MATLAB');  % Returns "Hello, MATLAB!"

% replace handling multiple patterns
str3 = "Hello, World! Goodbye, World!";
newStr3 = replace(str3, {'Hello', 'World'}, {'Hi', 'MATLAB'});  % Returns "Hi, MATLAB! Goodbye, MATLAB!"

%% strrepi

% I want Y = X to be replaced with MSG = STR
% I don't want YYYY to be replaced with MSGMSGMSGMSG

str = 'Y = X';
old = 'Y';
new = 'MSG';
str = strrepi(str, old, new)                    % MSG = X
old = 'X';
new = 'STR';
str = strrepi(str, old, new)                    % MSG = STR

% simple demo of what I don't want
str = 'YYYY';
str = strrepi(str, 'Y', 'MSG')                  % MSGMSGMSGMSG

% none of these work b/c strrepi does not match full word
old = 'Y';
new = 'MSG';
str = strrepi('YYYY', old, new)                 % MSGMSGMSGMSG
str = strrepi(lower('YYYY'), old, new)          % MSGMSGMSGMSG
str = strrepi('YYYY', old, lower(new))          % msgmsgmsgmsg
str = strrepi(lower('YYYY'), old, lower(new))   % msgmsgmsgmsg

%% strepn 

% use strrepn to simplify inputs for this case
str = 'Y = X';
str = strrepn(str, 'Y', 'MSG', 'X', 'STR')      % MSG = STR

% lower
str = 'y = x';
str = strrepn(str, 'Y', 'MSG', 'X', 'STR')      % y = x

% simple demo of what I don't want
str = 'YYYY';
str = strrepn(str, 'Y', 'MSG', 'X', 'STR')      % MSGMSGMSGMSG

% lower - does not replace
str = 'y = x';
str = strrepn(str, 'Y', 'MSG', 'X', 'STR')      % y = x

% strrpn uses strrep which is case sensitive so it does not replace 2 and 4
old = 'Y';
new = 'MSG';
str = strrepn('YYYY', old, new)                 % MSGMSGMSGMSG
str = strrepn(lower('YYYY'), old, new)          % yyyy
str = strrepn('YYYY', old, lower(new))          % msgmsgmsgmsg
str = strrepn(lower('YYYY'), old, lower(new))   % yyyy

%% strrepin

% use strrepn to simplify inputs for this case
str = 'Y = X';
str = strrepin(str, 'Y', 'MSG', 'X', 'STR')      % MSG = STR

% lower - does replace
str = 'y = x';
str = strrepin(str, 'Y', 'MSG', 'X', 'STR')      % MSG = STR

% strrpin uses strrepi which is NOT case sensitive so it DOES replace 2 and 4
old = 'Y';
new = 'MSG';
str = strrepin('YYYY', old, new)                % MSGMSGMSGMSG
str = strrepin(lower('YYYY'), old, new)         % MSGMSGMSGMSG
str = strrepin('YYYY', old, lower(new))         % msgmsgmsgmsg
str = strrepin(lower('YYYY'), old, lower(new))  % msgmsgmsgmsg

%% regexprep

str = 'Y = X';
str = regexprep(str, '\<Y\>', 'MSG')
str = regexprep(str, '\<X\>', 'STR')            % MSG = STR

% lower - does NOT replace
str = 'y = x';
str = regexprep(str, '\<Y\>', 'MSG')
str = regexprep(str, '\<X\>', 'STR')            % y = x

% regexprep is NOT case sensitive so it DOES replace 2 and 4
str = regexprep(str, ['\<' old '\>'], new)

old = 'Y';
new = 'MSG';
str = strrepin('YYYY', old, new)                 % MSGMSGMSGMSG
str = strrepin(lower('YYYY'), old, new)          % MSGMSGMSGMSG
str = strrepin('YYYY', old, lower(new))          % msgmsgmsgmsg
str = strrepin(lower('YYYY'), old, lower(new))   % msgmsgmsgmsg





ans =
    'Hello World Hi'  % only 'hello' is replaced, not 'Hello'
