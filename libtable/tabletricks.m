function tabletricks
   
   funcpath = getenv('MATLABFUNCTIONPATH');
   tipspath = [funcpath 'tipsandtricks/'];
   open([tipspath 'table_fun.m']);
   cd([funcpath '/tables']);
   
   doc table
