function teardownprojectdeps(projectname)
   %TEARDOWNPROJECTDEPS Deactivate what resolving PROJECTNAME activated.
   %
   %  teardownprojectdeps(projectname) walks PROJECTNAME's depledger
   %  entries newest-first (reverse activation order) and reverses each:
   %  toolbox dependencies through deactivate, project dependencies
   %  through the asproject path-removal mirror. The ledger only holds
   %  transitions the resolver caused, so manually activated toolboxes
   %  and dependencies that were already active before resolution are
   %  never touched. Clears the ledger for PROJECTNAME when done.
   %
   %  A failure to reverse one entry warns and continues. The ledger keeps
   %  only the entries whose reversal failed, so a second call retries
   %  them and does not tear down reversed entries again. An
   %  UndefinedFunction from deactivate is one code defect. The walk
   %  stops, the ledger keeps that entry and the unattempted ones, and
   %  the function rethrows the error once.
   %
   % Written in Octave-compatible style (no arguments block); part of the
   % manifest layer, which must run under Octave per the DesignSpec.
   %
   % See also: resolveprojectdeps, depledger, workoff

   narginchk(1, 1)
   projectname = char(projectname);

   entries = depledger('list', projectname);
   failed = false(numel(entries), 1);
   fatal = [];
   for k = 1:numel(entries)
      try
         if strcmp(entries(k).kind, 'toolbox')
            deactivate(entries(k).name);
         else
            deactivate(entries(k).name, 'asproject', true);
         end
      catch teardownErr
         % A missing function (MATLAB or Octave) is one shared code
         % defect, not a per-entry failure. The walk stops, the ledger
         % below records this entry and the unattempted ones as still
         % owned, and rethrow(fatal) raises it once (audit MEDIUM 33).
         if isundefinedfunction(teardownErr)
            fatal = teardownErr;
            failed(k:end) = true;
            break
         end
         warning('matfunclib:teardownprojectdeps:deactivateFailed', ...
            'Could not deactivate dependency %s (%s).', ...
            entries(k).name, teardownErr.message);
         failed(k) = true;
      end
   end

   % The ledger is the only record of what resolution activated, so the
   % entries whose reversal failed stay in it for a retry (audit LOW 54).
   % Reversed entries leave it, so a dependency the user activates again
   % by hand is not torn down as resolver-owned. depledger has no
   % per-entry removal. This code clears the ledger and records the failed
   % entries again in their original activation order (the list is newest
   % first).
   depledger('clear', projectname);
   kept = entries(failed);
   for k = numel(kept):-1:1
      depledger('record', projectname, kept(k).kind, kept(k).name);
   end
   if ~isempty(fatal)
      rethrow(fatal)
   end
   if any(failed)
      warning('matfunclib:teardownprojectdeps:ledgerKept', ...
         ['teardownprojectdeps: %s keeps %d dependency ledger entries ' ...
         'whose reversal failed; run teardownprojectdeps again to retry.'], ...
         projectname, numel(kept));
   end
end
