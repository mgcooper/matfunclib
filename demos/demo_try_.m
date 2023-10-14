
%% Simplest case
str1 = "yes";
str2 = "no";
str3 = "maybe";

str1 = try_(@() categorical(str1));
str2 = try_(@() categorical(str2));
str3 = try_(@() categorical(str3));

%% Couldn't get it to work with variable inputs/outputs

% powers1234 = @(x) deal(x,x.^2,x.^3,x.^4)
% [X1,X2,X3,X4] = powers1234(2)

% [str1, str2, str3] = try_(@() deal(arrayfun(@(s) categorical(s), [str1, str2, str3])));

str1 = "yes";
str2 = "no";
str3 = "maybe";

result = try_(@() cellfun(@(s) categorical(s), {str1, str2, str3}));

[str1, str2, str3] = try_(@() deal(arrayfun(@(s) categorical(s), [str1, str2, str3])));

[str1, str2, str3] = try_(@() deal(@(s) categorical(s), {str1, str2, str3}));

result = try_(@() cellfun(@(s) categorical(s), {str1, str2, str3}));


result = try_(@() arrayfun(@(s) categorical(s), [str1, str2, str3]));

[s1, s2, s3] = deal(result(:))
[str1, str2, str3] = deal(try_(@() arrayfun(@(s) categorical(s), [str1, str2, str3])));

[str1, str2, str3] = deal(arrayfun(@(s) try_(@() categorical(s)), [str1, str2, str3]));

[str1, str2, str3] = deal(arrayfun(@(s) try_(@() categorical(s)), {str1, str2, str3}));