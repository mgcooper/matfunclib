% in searchign for a faster polybuffer, I found a useful fex post. TLDR: see the
% "polygon offsetting" method in the Angus Johnson library.

% the post:
% https://www.mathworks.com/matlabcentral/answers/682828-faster-polygon-operations-than-polyshape
% 
% the poster ended up using Polygon Clipping and Offsetting by Erik Johnson:
% https://www.mathworks.com/matlabcentral/fileexchange/61329-new-polygon-clipping-and-offsetting?s_tid=prof_contriblnk
% 
% Polygon Clipping and Offsetting is a front end to Angus Johnson's polygon
% clipping and offsetting algorithms:
% http://www.angusj.com/clipper2/Docs/Overview.htm
% 
% The poster also said they modified the Erik Johnson toolbox to include some
% operations from the older (~2006) Polygon Clipper tool:
% https://www.mathworks.com/matlabcentral/fileexchange/8818-polygon-clipper?s_tid=answers_rc2-2_p5_MLT
% 
% and Bruno Long's mex insidepoly which is bassed on Darren's inpoly:
% 

% Provide a front end to Angus Johnson's polygon clipping and offsetting algorithms. 
% Two functions are provided: 
% * polyclip(x1,y1,x2,y2,method) finds the difference/intersection/xor/union (depending on "method") between two polygons 
% * polyout(x1,y1,delta,join,joininfo) outsets a polygon by distance delta, using the given corner join method (and optional joininfo specifying more details about the corner) [corner is 'round' or 'square' or 'miter']. Insetting is accomplished with a negative delta. 
% See the README.txt file for where to download Angus Johnson's clipper C++ code and for compiling instructions.