function S = catstructfields(dim, varargin)
%CATSTRUCTFIELDS concatenate two or more struct arrays with common field names
% 
% 
% See also:

F = cellfun(@fieldnames,varargin,'uni',0);
assert(isequal(F{:}),'All structures must have the same field names.')
T = [varargin{:}];
S = struct();
F = F{1};
for k = 1:numel(F)
   S.(F{k}) = cat(dim,T.(F{k}));
end

% % for reference, this is how two struct's would be catted
% f = fieldnames(S1); % assume fieldnames are identical in S1 and S2
% S = cell2struct(cellfun(@vertcat,struct2cell(S1),       ...
%    struct2cell(S2),'uni',0),f);
% % or like this:
% for i = 1:numel(f)
%    S.(f{i}) = [S1.(f{i});S2.(f{i})];
% end


%% Below here is me trying to improve on this

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

