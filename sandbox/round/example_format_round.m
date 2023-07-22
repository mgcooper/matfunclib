
x = rand(3);

clc
format default
[x 100+x]
[x 100+x 1e5.*x]

clc
format default
format short
format compact
[x 100+x]
[x 100+x 1e5.*x]

clc
format default
format shortG
[x 100+x]
[x 100+x 1e5.*x]

clc
format default
format shortG
format compact
[x 100+x]
[x 100+x 1e5.*x]


clc
format default
format long
[x 100+x]
[x 100+x 1e5.*x]

clc
format default
format long
format compact
[x 100+x]
[x 100+x 1e5.*x]

clc
format default
format longG
format compact
[x 100+x]
[x 100+x 1e5.*x]

%%

format short
[round(1123.123, 3) round(1123.123, -3)]
[round(1.123, 3) round(1.123, -3)]
[round(0.33323,3) round(0.33323,-3)]

[round(1123.123, 0) roundn(1123.123, 0)]
[round(1.123, 0) roundn(1.123, 0)]
[round(0.33323, 0) roundn(0.33323, 0)]







