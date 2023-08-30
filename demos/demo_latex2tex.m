

xstr = bfra.getstring('Q','units',true)
ystr = bfra.getstring('dQdt','units',true)

xstr = latex2tex(xstr)
ystr = latex2tex(ystr)

xlabel(xstr, 'Interpreter', 'tex')
ylabel(ystr, 'Interpreter', 'tex')


ltxt = bfra.aQbString([0.0000001 1],'printvalues',true);
ltxt = latex2tex(ltxt)
% ltxt = strrep(ltxt, '$','')

legend(ltxt, 'Interpreter', 'tex')

varsym = '\tau';
ytxt = ['$p(' varsym '\ge x)$'];

ytxt = latex2tex(ytxt)