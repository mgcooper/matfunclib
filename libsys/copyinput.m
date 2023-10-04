function msg = copyinput(cmd)
   %COPYINPUT copy command window input (or output of function) to clipboard
   %
   %  msg = COPYINPUT() requests user input
   %  msg = COPYINPUT(input) copies input to clipboard
   %
   % Example
   %  msg = copyinput(upper('mynewfunc.m'))
   %
   %
   % Matt Cooper, 18-Jan-2023, https://github.com/mgcooper
   %
   % See also

   clipboard('copy',cmd);
   msg = clipboard('paste');
end
