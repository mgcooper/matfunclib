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
   %  A failure to reverse one entry warns and continues: teardown must
   %  not leave the remaining entries stranded in the ledger.
   %
   % Written in Octave-compatible style (no arguments block); part of the
   % manifest layer, which must run under Octave per the DesignSpec.
   %
   % See also: resolveprojectdeps, depledger, workoff

   narginchk(1, 1)
   projectname = char(projectname);

   entries = depledger('list', projectname);
   for k = 1:numel(entries)
      try
         if strcmp(entries(k).kind, 'toolbox')
            deactivate(entries(k).name);
         else
            deactivate(entries(k).name, 'asproject', true);
         end
      catch teardownErr
         warning('matfunclib:teardownprojectdeps:deactivateFailed', ...
            'Could not deactivate dependency %s (%s).', ...
            entries(k).name, teardownErr.message);
      end
   end
   depledger('clear', projectname);
end
