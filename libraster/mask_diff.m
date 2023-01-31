
% to plot binary images with different colors to see where they differ, for example two masks
V0 = V1; 
V0(:) = 255; % this was blank right side of = sign, not sure what was here, prob 255?
V1(V1) = 255;
V2(V2) = 255;
AA(A & ~B & ~C) = 255; % red is 255 where the triangle exists and the others don't
BB(B & ~C) = 255; % green is 255 where the circle exists and parallelogram does not
CC(C) = 255; % blue parallelogram on top
out = cat(3,AA,BB,CC);