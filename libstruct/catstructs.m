function A = catstructs(A, S, opts)
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
   opts.asscalar (:,1) {logical} = false
end

% cat structs
if opts.asscalar == true

   % Note: I added this, it only works if A and S have identical fieldnames,
   % which is not the intention of this fucntion
   A = cell2struct(cellfun(@vertcat, struct2cell(A),       ...
      struct2cell(S), 'uni', 0), fieldnames(A));
else
   
   j = length(A) + 1;
   f = fieldnames(S);
   for n = 1:length(f)
      A(j).(f{n}) = S.(f{n});
   end
end
