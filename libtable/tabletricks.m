function tabletricks

funcpath = getenv('MATLABFUNCTIONPATH');
tipspath = fullfile(funcpath,'tipsandtricks');
open(fullfile(tipspath,'table_fun.m'));
cd(fullfile(funcpath,'tables'));

doc table
