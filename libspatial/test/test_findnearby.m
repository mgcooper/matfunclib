% Define some random x, y coordinates
x = rand(100, 1);
y = rand(100, 1);

% Define some query points
xq = [0.5; 0.7; 0.9];
yq = [0.6; 0.8; 0.7];

% Call the function to find the 5 nearest points
[row, col, dst, idx] = findnearby(x, y, xq, yq, 5);

% Display the results
disp(row);
disp(col);
disp(dst);
disp(idx);

% three query points, 
for n = 1:numel(xq)
   disp('query points:')
   disp([xq(n), yq(n)]);
   disp('nearest points:')
   disp([x(row(n,:)), y(row(n,:))]);
end

% five nearest points
[x(row(:)), y(row(:))]



