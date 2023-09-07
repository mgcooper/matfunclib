% optionals must be declared if other optionals follow them% sadly, none of these appear to work:

% f1(1, ~)
% f1(1, ~, 1)
% f1(1, [], 1)

% test 2
% f2(1, ~)
% f2(1, ~, 1)
% f2(1, [], 1)


% f2(~, 1)
% f2(1, ~, 1)
% f2(1, [], 1)