function varargout = parseoutputs(args, names, astype, mfilename)

   % generic template which would use dealout, struct2cell, cell2struct,
   % cell2table, etc. to begin adding "astype" by default to most functions.

   % I did not take note, but I recall thinking that adding a nargsout input
   % representing nargout in the calling / main function would solve problems or
   % prevent possible errors with dealout, but that might have been fixed after
   % the detailed refactoring and clarification of the correct syntax:
   %
   % varargout = dealout(CellArray)
   % or
   % [varargout{1:nargout}] = dealout(arg1, arg2, ..., argN)

   switch astype
      case 'cell'
      case 'struct'
      case 'table'
      otherwise
   end
end
