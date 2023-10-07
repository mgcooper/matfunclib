% test_smooth

%% test 5 y values (same as default span)
y = [42 7 34 5 9];
yy2    = y;
yy2(2) = (y(1) + y(2) + y(3))/3;
yy2(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5;
yy2(4) = (y(3) + y(4) + y(5))/3;
yy = smooth (y);
assert(isequal(yy, yy2));

%% test x vector provided
x = 1:5;
y = [42 7 34 5 9];
yy2    = y;
yy2(2) = (y(1) + y(2) + y(3))/3;
yy2(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5;
yy2(4) = (y(3) + y(4) + y(5))/3;
yy = smooth (x, y);
assert(isequal(yy, yy2));

%% test span provided
y = [42 7 34 5 9];
yy2    = y;
yy2(2) = (y(1) + y(2) + y(3))/3;
yy2(3) = (y(2) + y(3) + y(4))/3;
yy2(4) = (y(3) + y(4) + y(5))/3;
yy = smooth (y, 3);
assert(isequal(yy, yy2));


%% test x vector & span provided
x = 1:5;
y = [42 7 34 5 9];
yy2    = y;
yy2(2) = (y(1) + y(2) + y(3))/3;
yy2(3) = (y(2) + y(3) + y(4))/3;
yy2(4) = (y(3) + y(4) + y(5))/3;
yy = smooth (x, y, 3);
assert(isequal(yy, yy2));

%% test method 'moving' provided
y = [42 7 34 5 9];
yy2    = y;
yy2(2) = (y(1) + y(2) + y(3))/3;
yy2(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5;
yy2(4) = (y(3) + y(4) + y(5))/3;
yy = smooth (y, 'moving');
assert(isequal(yy, yy2));

%% test x vector & method 'moving' provided
x = 1:5;
y = [42 7 34 5 9];
yy2    = y;
yy2(2) = (y(1) + y(2) + y(3))/3;
yy2(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5;
yy2(4) = (y(3) + y(4) + y(5))/3;
yy = smooth (x, y, 'moving');
assert(isequal(yy, yy2));

%% test span & method 'moving' provided
y = [42 7 34 5 9];
yy2    = y;
yy2(2) = (y(1) + y(2) + y(3))/3;
yy2(3) = (y(2) + y(3) + y(4))/3;
yy2(4) = (y(3) + y(4) + y(5))/3;
yy = smooth (y, 3, 'moving');
assert(isequal(yy, yy2));

%% test x vector, span & method 'moving' provided
x = 1:5;
y = [42 7 34 5 9];
yy2    = y;
yy2(2) = (y(1) + y(2) + y(3))/3;
yy2(3) = (y(2) + y(3) + y(4))/3;
yy2(4) = (y(3) + y(4) + y(5))/3;
yy = smooth (x, y, 3, 'moving');
assert(isequal(yy, yy2));
