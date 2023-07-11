clean

% i would have called it 'libmap' but too similar to mapping toolbox ... below
% is an example of splitapply from scratch based on this fex question:
% https://www.mathworks.com/matlabcentral/answers/77042-how-to-do-a-group-by-in-matlab

% note that this is a prime use case of accumarray, which i've never gotten
% around to using much

data=[10 1 2 3; 11 4 5 6;10 0 20 30; 11 4 5 6; 12 7 8 9; 17 40 50 60]
lookfor=[10; 11];
% goal is to get anwser=[10 1 22 33; 11 8 10 12]

% simple solution:
a = arrayfun( @(x) data( data(:,1)==x, :), lookfor, 'un', 0);
b = cell2mat( cellfun( @(x) [x(1) sum(x(:, 2:end), 1)], a, 'un', 0))

%% what the above is doing 

a_n = cell(numel(lookfor),1);
for n = 1:numel(lookfor)
   a_n{n,:} = data(data(:,1) == lookfor(n),:);
end

b_test = cell(numel(lookfor),1);
for m = 1:size(a_n,1)
   a_m = a_n{m,:};
   
   % each m element of a_n is guaranteed to start with lookfor(m), so a_m(1)
   % works, but a_m(randi,1) would work too, i.e., the first column is all
   % lookfor(m), then the sum(...) statement applies a function, sum, to each
   % row ... basically lookfor(m) is the key, its the first column, and the next
   % three columns are the values, and we're just summing all values for which
   % the key = lookfor(m) 
   b_test{m} = [a_m(1) sum(a_m(:,2:end),1)];
end
b_test = cell2mat(b_test);

%% do it in one loop

for n = 1:numel(lookfor)
   a_n = data(data(:,1) == lookfor(n),:);
   b_test(n,:) = [a_n(1,1) sum(a_n(:,2:end),1)];
end
b_test

%% 

data = [
   10 1 2 3
   11 4 5 6
   10 0 20 30
   11 4 5 6
   12 7 8 9
   17 40 50 60
   22 40 50 60
   22 40 50 60 ];

lookfor = [
   10
   11
   22 ];

a = arrayfun( @(n) data( data(:,1)==n, :), lookfor, 'un', 0);
b = cell2mat( cellfun( @(a) [a(1) sum(a(:, 2:end), 1)], a, 'un', 0));

% % this was the poster's method
% for k=1:numel(lookfor)
%    ii=data(ismember(data(:,1),lookfor(k)),:);
%    res(k,:)=[ii(1,1) sum(ii(:,2:end))];
% end

%% another way:

[i1,i2] = ismember(data(:,1),lookfor);
d2 = data(i1,2:end);
[j1,j2] = ndgrid(i2(i1),1:size(d2,2));
anwser = [lookfor,accumarray([j1(:),j2(:)],d2(:))];

%%

% this section based on
% https://www.mathworks.com/matlabcentral/answers/37806-groupby-of-one-column

% Since we define G,V by data(:,1), we are implicitly doing 'select by row'
[G,V] = findgroups(data(:,1));
b = [V splitapply(@(x) sum(x(:,2:end),1),data,G)];

% now select by coloumn
colselect = [2 3];
b = [V splitapply(@(x) sum(x(:,colselect),1),data,G)];

% below here explicit example of selectby

% selection - select rows by lookfor, and subset colums [2 3]
xy = data(data(:,1)==lookfor(1), [2 3]);

% or:
keycol = 1;
rowselect = lookfor(1);
colselect = [2 3];
xy = data(data(:,keycol)==rowselect, colselect);

% now apply a function to the selection:
b = [rowselect sum(xy,1)] % should match the rowselect entry in b from above

% get all possible keys
lookfor = unique(data(:,1));
xys = arrayfun( @(m) sum(data(data(:,1)==m, colselect),1), lookfor, 'un', 0 );
b = [lookfor vertcat(xys{:})];


% another way
sdata = sortrows(data);
endidx = find(diff(sdata(:,1)) ~= 0);
r = [1 endidx'; endidx' size(sdata,1)];
idx = arrayfun( @(b) r(1,b):r(2,b), 1:size(r,2), 'UniformOutput', 0 );
xys = cellfun( @(ii) data(ii,[2 3]), idx, 'UniformOutput', 0 );

vec = data(:,1);
function idx = groupidx(vec)
   vec = sortrows(vec);
   idx = [find(diff(vec) ~= 0); numel(vec)];
   
% %    me trying to adapt bfra.
%    tf = true(size(vec));
%    istart = find(diff([vec;vec(end)+1])==1)-1;
%    iend = find(diff([vec;vec(end)+1])~=1);
%    [istart iend]
end

