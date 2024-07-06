function dt = mostfrequenttimestep(T)

   T = renametimetabletimevar(T);

   [dtcounts, dtsteps ] = groupcounts(diff(T.Time));
   dtfreq = dtcounts ./ (sum(dtcounts)+1);

   % choose the most frequent timestep for retiming
   dt = dtsteps(findglobalmax(dtfreq));
end
