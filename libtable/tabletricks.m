function tabletricks
   
   tipspath = [getenv('MATLABUSERPATH') 'tipsandtricks/'];
   funcpath = getenv('MATLABFUNCTIONPATH');
   open([tipspath 'table_fun.m']);
   cd([funcpath '/tables']);
   
   doc table
