function structtricks
   
   tipspath = [getenv('MATLABUSERPATH') 'tipsandtricks/'];
   funcpath = getenv('MATLABFUNCTIONPATH');
   open([tipspath 'struct_fun.m']);
   cd([funcpath '/structs']);
   doc struct