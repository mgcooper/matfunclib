function copyStartupFileToStartupPath
   src = [getenv('MATLABFUNCTIONPATH') 'startup.m'];
   dst = [userpath '/startup.m'];
   
   copyfile(src,dst)