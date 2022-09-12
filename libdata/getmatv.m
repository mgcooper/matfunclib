function tf = getmatv(fname,vers)
   x = evalc(['type(''', fname, ''')']);
   
% it might be possible to distinguish v6 from v7 using the class, in
% testing this it appears the word 'timetable' appears in the first 100
% characters of v6 files but not v7, however 'struct' does not appear
   
   switch vers
      case '7.3'
         tf = strcmp(x(2:20), 'MATLAB 7.3 MAT-file');
      case '7'
         tf = strcmp(x(2:20), 'MATLAB 5.0 MAT-file');
      case '6'
         tf = strcmp(x(2:20), 'MATLAB 5.0 MAT-file');
%       case '4'
%          tf = strcmp(x(2:20), 'MATLAB 4 MAT-file');
   end
end