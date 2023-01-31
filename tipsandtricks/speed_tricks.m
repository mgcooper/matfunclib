

% preallocate the random number arrays then index into them instead of generating each time

% always put column index as outer loop i.e.:
% for j = 
% 	for i = 
% 		A(i,j) = ...
% 	end
% end
% 
% parfor should be ok since each photon is independent. i can initialize phi_s as 2_pi.*rand(N,1) and then index into it with ps = phi_s(n), then I should also be able to create initialized vl, uz, uy, and ux since those are also not random and do not depend on prior values 
% 
% BUT since wt changes does that matter? I think not because it is within the while loop but should test to confirm
% 
% see this:
% https://www.mathworks.com/help/parallel-computing/reduction-variable.html


		


