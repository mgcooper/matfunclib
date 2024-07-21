% TEST_LIBSTRUCT test suite for libstruct

% Define test data


% Create a layered struct
% S = struct('field1', 'value1', 'field2', 'value2'); %
%
% S.S2 = S;

%
S.a = 1:10;
S.b = 2:11;
S.c = 3:12;

% clarit on non-scalar struct assignmment

% this doesn't work:
% [s(1:10).a] = 1:10;

% this works
S = arrayfun(@(x) struct('a', x), 1:10);
S = arrayfun(@(s, y) setfield(s, 'b', y), S, 2:11);
S = arrayfun(@(s, y) setfield(s, 'c', y), S, 3:12);

% loop method
clear S
S = struct();
for n = 1:10
   S(n).a = n;
   S(n).b = n+1;
   S(n).c = n+2;
end

% Deal method
clear S
a = num2cell(1:10);
b = num2cell(2:11);
c = num2cell(3:12);
[S(1:10).a] = deal(a{:});
[S(1:10).b] = deal(b{:});
[S(1:10).c] = deal(c{:});

% Note: this puts 1:10 in each element
[S(1:10).a] = deal(1:10);

%% test addstructfields

% % say fields is a 10x1 array, and S is a 10x1 struct, these put the 10x1 array
% 'fields' in each row of S:
% [S.(fieldname)] = deal(fields);
% [S(:).(fieldname)] = deal(fields);
% [S(1:numel(fields)).(fieldname)] = deal(fields);
% [S(:).(fieldname)] = deal(num2cell(fields));

% % whereas this will put the individual values in each row, as desired:
% C = num2cell(fields);
% [S(:).(fieldname)] = deal(C{:});
%
% % and these will fail:
% [S(1:numel(fields)).(fieldname)] = fields;
% [S.(fieldname)] = fields;
% S(:).(fieldname) = deal(fields);
% S.(fieldname) = deal(fields);

if isempty(newfieldnames)
   % newfieldnames = cellstr(inputname(2));
   newfieldnames = cellstr('newfieldname'); % Jul 2024 temporary fix to inputname

elseif ischar(newfieldnames) || isstring(newfieldnames)
   newfieldnames = cellstr(newfieldnames);
end

% add a non-scalar field to a non-scalar struct with identical # of elements,
% assume we want each element of fields to be in a row of S
if numel(S) == numel(fields) && ~isscalar(S)
   for n = 1:numel(newfieldnames)
      C = num2cell(fields);
      [S(:).(newfieldnames{n})] = deal(C{:});
   end
end

% if iscell(fields);
%    fields = fields{:};
% end


% could go about it like this:
% switch class(field)
%
%    case 'cell'
%       [S.(fieldname)] = field{:};
%
%    case 'double'
%       [S.(1:numfeatures).(fieldname)]  = deal(field);
% end


%% test catstructs

% for reference, this is how two struct's would be catted
S1 = A;
S2 = S;
f = fieldnames(S1); % assume fieldnames are identical in S1 and S2
S3 = cell2struct(cellfun(@vertcat,struct2cell(S1),       ...
   struct2cell(S2),'uni',0),f);

% or like this:
for field = string(fieldnames(S1).')
   S4.(field) = [S1.(field); S2.(field)];
end

% or
S5 = catstructfields(S1, S2);

isequal(S3,S4)
isequal(S4,S5)

a = S3.saved.idx
b = S4.saved.idx
isequal(S4,S5)


% Note: I added this, it only works if A and S have identical fieldnames,
% which is not the intention of this fucntion
A = cell2struct(cellfun(@vertcat, struct2cell(A),       ...
   struct2cell(S), 'uni', 0), fieldnames(A));


%% test catstructfields

% % Example 1: cat two structs with identical field names
%
% % for reference, this creates a non-scalar struct
% % S1 = struct('a',[1,2,3],'b',[4,5,6],'c',{'dog','cat'});
%
% S1.a = [1,2,3];
% S1.b = [4,5,6];
% S1.c = {'dog','cat'};
%
% S2.a = [4,5,6];
% S2.b = [1,2,3];
% S2.c = {'fish','horse'};
%
% % Example 2: cat two structs with identical field names
% S3.e = [7,8,9];
% S3.f = [true,false,false];
% S3.g = {'fish','horse'};
%
% S4.a = [7,8,9];
% S4.b = [false,true,true];
% S4.g = {'bird','mouse'};
% S4.h = [1,2,3];
%
% F = cellfun(@fieldnames,{S1,S2,S3,S4},'uni',0);

% F = cellfun(@fieldnames,varargin,'uni',0);

% % mgc - this is where I strted, tyring to use the ones that ARE equal instead of
% % demanding they are all equal
% assert(isequal(F{:}),'All structures must have the same field names.')

% % this finds the common fieldnames, then discards any with zero, and use the
% % remaining one with the least number of common filed
% f = cellfun(@(x) intersect(x,F{1}),F,'uni',0);
% f = f(~cellfun('isempty',f));
% f = f(argmin(cellfun('prodofsize',f)));
%
% % from here I could use the common fields

% this says which fieldnames are equal to the first set of fieldnames
% f = cellfun(@(x) isequal(x,F{1}),F,'uni',0);



%% test mergestructs

%   Example:
%   S.one = 1;
%   T.two = 2;
%   mergestructs(S,T)
%
%   ans =
%   struct with fields:
%     one: 1
%     two: 2

%% test commonfields

F = cellfun(@fieldnames,varargin,'uni',0);
f = cellfun(@(x) intersect(x,F{1}),F,'uni',0);

% keep the one with the least # of common fields, including zero
f = f(argmin(cellfun('prodofsize',f)));

% discard any with zero then keep the one with the least # of common fields
f = f(~cellfun('isempty',f));
f = f(argmin(cellfun('prodofsize',f)));

%% this was a function checkfieldnames I removed from the repo

% function tf = checkfieldnames(varargin)
% this checks if all structs in varargin have equal fieldnames

% this doesn't work and i'm moving on

N=numel(varargin);
tf=false(N,1);
for n=1:N
   for m=n+1:N
      tf(n) = tf(n) || isequal(fieldnames(varargin{n}),fieldnames(varargin{m}));
      %tf(m) = tf(n);
   end
end

% % this checks if all structs in varargin are equal (fieldnames and values)
% N=numel(varargin);
% Z=false;
% for n=1:N
%    for m=n+1:N
%       Z = Z || isequal(varargin{n},varargin{m});
%    end
% end

