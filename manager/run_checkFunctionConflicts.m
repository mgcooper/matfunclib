
clean

% test1: pass full path to function library
funcpath = '/Users/coop558/MATLAB/matfunclib';
conflicts = checkFunctionConflicts(funcpath);

% test 2: pass full path to function name
funcpath = '/Users/coop558/MATLAB/matfunclib/libdata/addcolumns.m';
conflicts = checkFunctionConflicts(funcpath);

% test 3: use built-in library option
conflicts = checkFunctionConflicts('library','libdata');

% test 4: use built-in function option
conflicts = checkFunctionConflicts('funcname','abline.m');




