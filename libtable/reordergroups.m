function [G,idx] = reordergroups(G,neworder)

% % Turns out I was confused as to how reordercats works, see icom msd plot
% peaks script. I thought i needed to actually reorder a table with categorical
% column to get boxchart to plot in order of unique categories, so this fucntion
% does that, but actually reordercats sets an underlying property which is
% picked up by boxchart ... but it may still be useful to have a function like
% this that reorders a table 

% % this is what I thought would work, it actually rearranges the table order
% [G,ID]   = findgroups(T1.scenario);
% neworder = [1,3,7,5,9,2,6,4,8];
% [G,idx]  = reordergroups(G,neworder);
% T1       = T1(idx,:);
% [~,ID]   = findgroups(T1.scenario);

N = numel(unique(G));
G2 = nan(size(G));
idx = nan(size(G));

for n = 1:N
   ifind = find(G==n);
   irepl = find(G==neworder(n));
   G2(ifind,:) = G(irepl,:);
   idx(ifind) = irepl;
end
