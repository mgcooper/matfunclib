function [tbname, wid, msg] = validatetoolbox(tbname,funcname,argname,argnum)
   %VALIDATETOOLBOX Validate toolbox is in directory.
   %
   %  TBNAME = VALIDATETOOLBOX(TBNAME,FUNCNAME,ARGNAME,ARGNUM) Validates that
   %  TBNAME is a toolbox in the toolbox directory and returns its value. Use
   %  FUNCNAME, ARGNAME, ARGNUM to generate an error message with the calling
   %  function name, argument name, and argument number.
   %
   %  [TBNAME, WID, MSG] = VALIDATETOOLBOX(TBNAME,FUNCNAME,ARGNAME,ARGNUM) Also
   %  returns a warning ID and warning message to issue in the calling function.
   %
   % See also:

   wid = [];
   msg = [];

   if isstring(tbname)
      if ~isscalar(tbname)
         eid = 'MATFUNCLIB:manager:nonScalarToolboxName';
         msg = 'toolbox names must be scalar text';
         throwAsCaller(MException(eid, msg));
      else
         tbname = char(tbname);
      end
   end

   if ~istoolbox(tbname)

      % error if the toolbox is not in the directory
      eid = 'MATFUNCLIB:manager:toolboxNotFound';
      msg = 'toolbox not found in directory, use addtoolbox to add it';
      throwAsCaller(MException(eid, msg));
   end

   % check active state
   if isactive(tbname) && strcmp(funcname, 'activate')
      wid = 'MATFUNCLIB:manager:toolboxAlreadyActive';
      msg = [tbname ' toolbox is already active'];
      % warnAsCaller(wid, msg);
      return

   elseif ~isactive(tbname) && strcmp(funcname, 'deactivate')
      wid = 'MATFUNCLIB:manager:toolboxNotActive';
      msg = [tbname ' toolbox is not active'];
      return
   end
end

% This was the original function. It is negated by the elseif ~istoolbox block
% above, need to decide which to use ... update ... this still plays a role,
% e.g. whne calling deactivate on an inactive toolbox, would get here. In
% that case, we don't actually want an error, we want a warning at most, and
% can just use ~isactive in the calling function, but just noting it here
% that there is a case where we get here

% tblist = gettbdirectorylist;
% tbname = validatestring(tbname,tblist,funcname,argname,argnum);
