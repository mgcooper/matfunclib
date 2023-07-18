% See notes in optionParser for how it could be as test_optionparser

validopts = {'opt1', 'opt2', 'opt3'}

opts = test_optionparser(validopts, 'opt1', 'opt2', 1, {'ts'})

%%

a = 1; b = 2;
c = test_magicparser(a, b, 'param', true)

clear p
p = magicParser;
p.addRequired('c',@isnumeric);
p.addOptional('d','default',@ischar)
p.parseMagically('caller');
