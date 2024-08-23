function [G,idx] = reordergroups(G,neworder)
   %REORDERGROUPS Reorder categorical groups.

   % Turns out I was confused as to how reordercats works, see icom msd plot
   % peaks script. I thought i needed to actually reorder a table with
   % categorical column to get boxchart to plot in order of unique categories,
   % so this function does that, but actually reordercats sets an underlying
   % property which is picked up by boxchart ... but it may still be useful to
   % have a function like this that reorders a table

   % % this is what I thought would work, it actually rearranges the table order
   % [G,ID]   = findgroups(T1.scenario);
   % neworder = [1,3,7,5,9,2,6,4,8];
   % [G,idx]  = reordergroups(G,neworder);
   % T1       = T1(idx,:);
   % [~,ID]   = findgroups(T1.scenario);

   % A useful comment from fex:
   %
   % MATLAB seems to remember that there were additional categories not
   % included": Think about categorical this way: it lets you define the entire
   % universe of possible values. That complete universe is there even if no
   % elements of the categorical array contain some of the possible values. So,
   % e.g., you can count up elements, and find out that while you have 35 smalls
   % and 26 larges, you have no mediums. That's what sets categorical apart form
   % an array of strings.
   %
   % If you want unused categories to go away (and in many cases, you don't) use
   % removecats.

   % This is the "what I thought would work" example generalized.
   % [G, ID] = findgroups(tbl.(varname));
   % [G, idx] = reordergroups(G, neworder);
   % tbl = tbl(idx, :);
   % [~, ID] = findgroups(tbl.(varname));

   N = numel(unique(G));
   G2 = nan(size(G));
   idx = nan(size(G));

   for n = 1:N
      ifind = find(G==n);
      irepl = find(G==neworder(n));
      G2(ifind,:) = G(irepl,:);
      idx(ifind) = irepl;
   end
end
