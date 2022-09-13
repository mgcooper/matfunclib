% the function requires X Y be 2-d grids of lat/lon or x/y. the function
% can deal with the situation where the grids are oriented S-N or N-S and
% E-W or W-E, but it cannot currently deal with rotated grids i.e. the size
% of X and Y must match the size of whatever data is being referenced. to
% deal with rotation, I cant just check the orientation and the size of the
% data because of the case where it is rotated by multiples of 180o. 