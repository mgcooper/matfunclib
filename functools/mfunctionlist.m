function functionlist = mfunctionlist()
   %MFUNCTIONLIST Load the functionlist for functionSignatures tab-completion
   load mfunctionlist.mat functionlist

   % this does not make it faster
   % persistent functionlist
   % if isempty(functionlist)
   %    load('mfunctionlist.mat', 'functionlist');
   % end
   % list = functionlist;
end
