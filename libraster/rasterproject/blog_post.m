% Matlab doesn't hold your hand when it comes to working with spatial data.
% You really have to be an expert to use their tools correctly, and
% efficiently. Like many before me, I was really frustrated with Matlab for
% not providing a built in spatial projection toolbox. It is relatively
% trivial to project vector coordinates using the mfwdtran/minvtran
% functions, but projecting raster data is substantially more nuanced.

% the first step is understanding what it means to reproject spatial data.
% When vector data is reprojected, the vertices are transformed from one
% coordinate system to a second. Since the entirety of the vector data is
% represented by the vertex coordinates, this step is all that is required.
% It can be achieved relatively painlessly using Matlab's minvtran/mfwdtran
% functions, although potential for confusion/mistakes is high:

% insert example of unprojecting to goegraphic and reprojecting to
% something else

% at the end of this post, I include an example of reprojection gone wrong,
% using a very common projection in my field of geoscience (polar climate),
% where projecting into/out of polar stereographic fails

% in contrast to vector data, projecting raster data involves several
% additional steps. Unlike vector data, which is typically stored as lists
% of x/y coordinates, raster data is stored in arrays (aka matrices, grids,
% etc.). Therefore, it makes sense that the first step is to transform the
% coordinates of the grid cells from the original coordinate system to the
% new one. This is identical to the vector transformation. But where's my
% data? (insert link to the Matworks quesiton). I think this is where a lot
% of people's understanding of what is actually going on under the hood
% stops. Like the person who made that post, where is the actual data?
% Where does it go? What has it become? 

% There are two ways to approach this problem. The fist is to build up the
% ability to reproject raster data from first principles. In part two of
% this post I will demonstrate that approach. The second is to use higher
% level functions provided by Mathworks. In part three of this post I will
% demonstrate that method. It is an interesting example of just how
% divorced from the reality of geospatial science the engineers over at
% Mathworks are. It is mind boggling how difficult they have made it for
% the average Matlab user to do something as trivial as reprojecting raster
% data, especially since they have every piece of the puzzle in place, in
% the form of high level tools. All they need to do is bring it together
% into a function, provide some documentation, and viola, they would have
% thousands of happy users. But they just can't do it, so I do it insead. 


% If you look around online, what you will find is a bunch of blog posts
% explaining the difference between as EPSG and a proj4 string, and then
% the usual stuff about interpolating categorical data vs continuous data,
% etc. The usual hand holding boring stuff that I won't be covering. What
% nobody talks about is the actual process that is going on under the hood.
% The stuff you would need to know to build your own tool in Matlab, since
% the Mathworks engineers are way too smart to realize that you need them
% to do it for you.  


