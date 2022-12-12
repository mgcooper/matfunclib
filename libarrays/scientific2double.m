function [D,T] = scientific2double(C,ndigits)
%SCIENTIFIC2DOUBLE converts numbers displayed as scientific notation within
% a column, row, or table to regular notation with n digits

if ~iscell(C)
    C = num2cell(C);
end

fun = @(x) sprintf(['%0.' int2str(ndigits) 'f'], x);
D = cellfun(fun, C, 'UniformOutput',0);

% convert to column
for n = 1:length(D)
    N(n) = str2double(D{n});
end
% Convert to a table
T = cell2table(D);

