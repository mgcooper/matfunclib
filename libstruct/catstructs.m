function A = catstructs(A, S)
%CATSTRUCTS Concatenates dissimilar structures (i.e. of different fields)
%   structure S will be appended to structure array A, even if they do not
%   contain the same fields. Dissimilar fields will be set to an empty array.
%
%   Note: For similar structures (i.e. containing all same fields), this
%   function is equivalent to A = [A S] (assuming A is a row vector),
%   to A = [A;S] (assuming A is a column vector), or, more generally,
%   to A = cat(1+isrow(A), A, S)
%
%   Example:
%   A(1).first = 1;
%   A(1).second = "one";
%   A(2).first = 2;
%   A(2).second = "two";
%   S.third = 'third';
%   A = catstructs(A,S);
%   struct2table(A)
%
%   ans =
%        first           second          third
%     ____________    ____________    ____________
%
%     {[       1]}    {["one"   ]}    {0×0 double}
%     {[       2]}    {["two"   ]}    {0×0 double}
%     {0×0 double}    {0×0 double}    {'third'   }
%
%   Inputs:
%   A       one dimensional structure array (can be empty)
%   S       structure to add to structure array A
%
%   Output:
%   A       concatenation of input structure array and structure

arguments
   A(:,:) struct {isvector}
   S(1,1) struct
end

j = length(A) + 1;
f = fieldnames(S);
for i = 1:length(f)
   A(j).(f{i}) = S.(f{i});
end


% % for reference, this is how two struct's would be catted
% f = fieldnames(S1); % assume fieldnames are identical in S1 and S2
% S = cell2struct(cellfun(@vertcat,struct2cell(S1),       ...
%    struct2cell(S2),'uni',0),f);
% % or like this:
% for i = 1:numel(f)
%    S.(f{i}) = [S1.(f{i});S2.(f{i})];
% end

