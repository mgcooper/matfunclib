% This is very slow compared with scatteredInterpolation which I updated to
% handle nan's, so use that instead.

% NOTE: took me a while to figure this out ... but griddedInterpolant is
% completely useless b/c if there is a nan value, the interpolant will always
% produce nan there, the way to do this is to pass the X-Y for the non-nan
% values to the interpolant, then pass the X-Y for the nan values to fill them,
% so a scattered-type interpolant must be used.

% See this to understand
% https://www.mathworks.com/help/matlab/math/interpolating-gridded-data.html#bs2o5wb-1


% Note: the reason this does not work is because the data has to be 
% V(isnan(V)) = interp2(X(~isnan(V)), Y(~isnan(V)), V(~isnan(V)), X(isnan(V)), Y(isnan(V)), method);

% V(isnan(V)) = interp2(V(~isnan(V)), X(isnan(V)), Y(isnan(V)), method);

%% grid vectors
% [xvec, yvec] = gridvec(X, Y);
% V(isnan(V)) = interp2(xvec, flip(yvec), V, X(isnan(V)), Y(isnan(V)), method);

%% gridddata
% V(isnan(V)) = griddata(X(~isnan(V)), Y(~isnan(V)), V(~isnan(V)), ...
%    X(isnan(V)), Y(isnan(V)), 'linear');

%% scatteredInterpolant
% F = scatteredInterpolant(X(~isnan(V)), Y(~isnan(V)), V(~isnan(V)), 'natural');
% V(isnan(V)) = F(X(isnan(V)), Y(isnan(V)));

%% comparison

% ok = ~isnan(V);
% method = 'linear';
% F = scatteredInterpolant(X(~isnan(V)), Y(~isnan(V)), V(~isnan(V)), method);
% F(X(isnan(V)), Y(isnan(V)))
% griddata(X(ok), Y(ok), V(ok), X(isnan(V)), Y(isnan(V)), 'linear');

% for testmethod = ["linear", "nearest", "natural", "cubic", "v4"]
%    griddata(X(~isnan(V)), Y(~isnan(V)), V(~isnan(V)), ...
%    X(isnan(V)), Y(isnan(V)), testmethod)
% end


%% test extrap options

% % Based on these ... the main difference is interp2 only allows spline and
% % makima extrap, whereas griddata allows all methods and scatteredInterpolant
% % allows all but has fewer methods ... overall since this function is
% % naninterp2, it should use interp2, and another function such as "gridmissing"
% % or "nangridfill" or "gridfill" could use other options
% 
% % interp2 only allows extrapolation w/ makima and spline, both recover the
% % correct value
% [xvec, yvec] = gridvec(X, Y);
% for method = ["linear", "nearest", "cubic", "makima", "spline"]
%    test1.(method) = interp2(xvec, yvec, V, X(isnan(V)), Y(isnan(V)), method);
% end
% 
% % griddata extrapolates for all options but only linear, natural, and
% % cubic recover the correct value for the simple test case of filling in a
% % coordinate of a regular grid
% for method = ["linear", "nearest", "natural", "cubic", "v4"]
%    test2.(method) = griddata(X(~isnan(V)), Y(~isnan(V)), V(~isnan(V)), ...
%       X(isnan(V)), Y(isnan(V)), method);
% end
% 
% % linear and natural are correct, nearest is not
% for method = ["linear", "nearest", "natural"]
%    F = scatteredInterpolant(X(~isnan(V)), Y(~isnan(V)), V(~isnan(V)), method)
%    test3.(method) = F(X(isnan(V)), Y(isnan(V)));
% end
% 
% 
% 

% %% griddedInterpolant
% 
% % I am still confused about how griddedInterpolant works so don't use it
% 
% [xvec, yvec] = gridvec(X, Y);
% 
% % % this seems to work using gridvecs, but it should not work b/c the gridvecs
% % % should be in ndgrid format, not x,y
% % F = griddedInterpolant({sort(xvec(:)), sort(yvec(:))}, V, method);
% % Vtest = F(X(isnan(V)), Y(isnan(V)));
% % % V(isnan(V)) = F(X(isnan(V)), Y(isnan(V))); replace with this if it works
% 
% 
% % griddedInterpolant expects ndgrid format, where x1, x2, defines the grid
% % vectors, x1 is the y coordinates, x2 the x coordinates
% [Y2, X2] = ndgrid(sort(yvec(:)), sort(xvec(:)));
% V2 = flip(V);
% 
% % I think the key is with griddedInterpolant, V2 needs to be transposed, since
% % indexing into it assumes V(x,y) with x down columns, y over rows, as in x =
% % 1:size(V,1), y = 1:size(V,2) for the default grid. Even thought that is
% % confusing and annoying, I think it is correct
% 
% % note: since these are equal, one would think flip(V) is correct, but when V2 =
% % flip(V) is passed ot griddedInterpolant, it does not seem to work
% % isequal( flip(Y), Y2)
% % isequal( flip(X), X2)
% 
% % using gridvecs. Note: no flipping is required to build F, but to get the
% % correct xq,yq points, need to use X2, Y2
% F = griddedInterpolant({sort(yvec(:)), sort(xvec(:))}, V2, method);
% Vtest = F(Y2(isnan(V2)), X2(isnan(V2)));
% 
% % For some reason this works
% F = griddedInterpolant({sort(yvec(:)), sort(xvec(:))}, V2.', method);
% Vtest = F(Y2(isnan(V2)), X2(isnan(V2)));
% 
% % For some reason this works too
% F = griddedInterpolant({sort(yvec(:)), sort(xvec(:))}, V.', method);
% Vtest = F(Y2(isnan(V2)), X2(isnan(V2)));
% 
% % Biut this does not
% F = griddedInterpolant({sort(yvec(:)), sort(xvec(:))}, V.', method);
% Vtest = F(Y2(isnan(V.')), X2(isnan(V.')));
% 
% % passing 
% F = griddedInterpolant({sort(yvec(:)), sort(xvec(:))}, V, method);
% Vtest = F(Y(isnan(V)), X(isnan(V)))
% 
% F = griddedInterpolant({sort(yvec(:)), sort(xvec(:))}, V, method);
% Vtest = F(Y2(isnan(V2)), X2(isnan(V2)));
% % V(isnan(V)) = F(X(isnan(V)), Y(isnan(V)));
% 
% % using full grids
% 
% 
% % This does not work
% F = griddedInterpolant(Y2, X2, V2.', method)
% Vtest = F(Y2(isnan(V2.')), X2(isnan(V2.')));
% 
% % This does not work
% F = griddedInterpolant(Y2, X2, V2, method)
% Vtest = F(Y2(isnan(V2)), X2(isnan(V2)));
% 
% % This works, but note that Y = flip(Y) in my test case
% F = griddedInterpolant(Y2, X2, V2.', method)
% Vtest = F(Y2(isnan(V2)), X2(isnan(V2)));
% 
% % For some reason this works too
% F = griddedInterpolant(Y2, X2, V.', method)
% Vtest = F(Y2(isnan(V)), X2(isnan(V)));
% 

% %% one more shot trying griddedInterpolant
% 
% % V is ordered such that going down the columns is the same as going down Y and
% % holding X for that column fixed, but griddedInterpolant expects the opposite,
% % going down the columns is going over x
% 
% % griddedInterpolant expects the V data to be transposed
% V2 = transpose(V);
% 
% [Y2, X2] = ndgrid(sort(yvec(:)), sort(xvec(:)));
% 
% F = griddedInterpolant({sort(xvec(:)), sort(yvec(:))}, V, method);
% Vtest = F(X(isnan(V)), Y(isnan(V)));

% %% this is an adapted griddedinterpolnat example
% 
% % None of these work, whether sz = size(V) or sz = size(A)
% A = V';
% sz = size(V);
% xg = 1:sz(1);
% yg = 1:sz(2);
% F = griddedInterpolant({xg,yg},A,'nearest','linear');
% Vq = F(X(isnan(V)), Y(isnan(V)))
% Vq = F(Y(isnan(V)), X(isnan(V)))
% Vq = F(X(isnan(A)), Y(isnan(A)))
% Vq = F(Y(isnan(A)), X(isnan(A)))
% 
% xq = (1-5/6:5/6:sz(1))';
% yq = (1-5/6:5/6:sz(2))';
% vq = F({xq,yq});
% 
% 
% 
% A = transpose(V);
% sz = size(A);
% xg = 1:sz(1);
% yg = 1:sz(2);
% F = griddedInterpolant({xg,yg},A,'nearest','linear');
% 
% xq = (1-5/6:5/6:sz(1))';
% yq = (1-5/6:5/6:sz(2))';
% vq = F({xq,yq});

% %%
% 
% % % This was an attempt to index into the grid like with naninterp1, I did this
% % % b/c interp2 requires X,Y be fullgrids OR gridvecs, so I got the rows/cols to
% % % index into the fullgrids, but it fails b/c once indexed, they are no longer
% % % full grids, so I stopped on X
% % rows = 1:size(X,1);
% % cols = 1:size(X,2);
% % [rnan, cnan] = find(isnan(V));
% % 
% % V(rnan, cnan) = interp2(X(rows(rows~=rnan), cols(cols~=cnan)), Y(~isnan(V)), V(~isnan(V)), ...
% %    X(isnan(V)), Y(isnan(V)), method);
% 
% 
% % % This is just an exact analogy with naninterp1, i think it fails b/c X,Y are
% % not grid vectors.
% % V(isnan(V)) = interp2(X(~isnan(V)), Y(~isnan(V)), V(~isnan(V)), ...
% %    X(isnan(V)), Y(isnan(V)), method);
% 
% 
% [V,X] = linearpad(V,X);
% [V,X] = linearpad(fliplr(V),flip(X));
% 
% [V,Y] = linearpad(V.',Y);
% [V,Y] = linearpad(fliplr(V),flip(Y));
% 
% Vq = interp2(X,Y,V.',xq,yq,'linear');
% 
%    function [D,z]=linearpad(D0,z0)
%       factor=1e6;
% 
%       dz=z0(end)-z0(end-1);
%       dD=D0(:,end)-D0(:,end-1);
% 
%       z=z0;
%       z(end+1)=z(end)+factor*dz;
% 
%       D=D0;
%       D(:,end+1)=D(:,end) + factor*dD;
%    end
% 
