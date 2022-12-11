function structtricks

funcpath = getenv('MATLABFUNCTIONPATH');
tipspath = [funcpath 'tipsandtricks/'];
open([tipspath 'struct_fun.m']);
cd([funcpath '/structs']);
doc struct