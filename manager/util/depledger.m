function varargout = depledger(op, owner, kind, name)
   %DEPLEDGER Session ledger of dependencies activated by the resolver.
   %
   %  depledger('record', owner, kind, name) records that resolving OWNER
   %  activated the dependency NAME of KIND ('project' or 'toolbox').
   %
   %  entries = depledger('list', owner) returns OWNER's entries, newest
   %  first (the reverse of activation order, which is teardown order), as
   %  a struct array with fields kind and name. Returns an empty struct
   %  array with those fields when OWNER has no entries.
   %
   %  depledger('clear', owner) forgets OWNER's entries.
   %
   % The ledger only ever holds state transitions the resolver caused:
   % dependencies that were already active are never recorded, so workoff
   % teardown cannot deactivate anything the user activated manually.
   % Session-scoped by design (persistent variable): the ledger dies with
   % the session, matching the path state it mirrors.
   %
   % Written in Octave-compatible style (no arguments block); part of the
   % manifest layer, which must run under Octave per the DesignSpec.
   %
   % See also: resolveprojectdeps, workon, workoff

   narginchk(2, 4)
   persistent ledger
   if isempty(ledger)
      ledger = struct('owner', {}, 'kind', {}, 'name', {});
   end

   op = char(op);
   % Owner keys are case-insensitive, matching every manager registry
   % lookup (getprjidx, findtbentry, validatestring), so a project
   % activated as 'ALPHA' tears down under its canonical 'alpha'.
   owner = lower(char(owner));

   switch op
      case 'record'
         narginchk(4, 4)
         kind = char(kind);
         if ~any(strcmp(kind, {'project', 'toolbox'}))
            error('matfunclib:depledger:badKind', ...
               'kind must be ''project'' or ''toolbox'', got ''%s''.', kind);
         end
         ledger(end+1) = struct( ...
            'owner', owner, 'kind', kind, 'name', char(name));

      case 'list'
         mine = strcmp({ledger.owner}, owner);
         entries = rmfield(ledger(mine), 'owner');
         varargout{1} = entries(end:-1:1);

      case 'clear'
         ledger = ledger(~strcmp({ledger.owner}, owner));

      otherwise
         error('matfunclib:depledger:badOp', ...
            'op must be ''record'', ''list'', or ''clear'', got ''%s''.', op);
   end
end
