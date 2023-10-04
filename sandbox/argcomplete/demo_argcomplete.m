clean

% need to have chars, strings, and tabular in the workspac

T1 = table;
T1.test1 = 1;
T1.test2 = 2;
T1.test3 = 3;
T2 = T1;

c1 = 'one'; 
c2 = 'two';
c3 = 'three';

s1 = "one";
s2 = "two";
s3 = "three";

% this works if ydatavar, xgroupvar, and cgroupvar are required, ordered, or
% positional, but the variables are shown as "optional" if ordered or positional
% are used, 
f_argcomplete2(T1, "test1", "test2", "test3") 

f_argcomplete2(T2, "test1", "test2", "test3"

% if I use a char, then the auto complete goes away after the first one
% barchartcats(T2, 'test3',     )