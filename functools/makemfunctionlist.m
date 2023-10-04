function makemfunctionlist
   functionlist = string(strrepn(listallmfunctions,'.m',''));
   filename = localfile(mfilename('fullpath'), 'mfunctionlist');
   save(filename, 'functionlist')
end