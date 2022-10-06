
% rather than this:
imeshline   = [];
for n = 1:numel(Line)
   imeshline = [imeshline;Line(n).iMesh];
end

% can simply do this:
imeshline = vertcat(Line(:).iMesh);

% but mght need horzcat depending on the shape of whatever is in Line(n).X

% when making a mapshape or geoshpae, if the structure passed in has
% multiple fields, they will not be in the 'metadata' strcuture where
% expected, but they can be accessed via dot notation, and when shapewrite
% is sued they will be in teh attributes as expected

% ========================================================================
% to assign fields to a structure, a for loop is usually easiest
% ========================================================================
% but here is one way:
Tnan    = find(isnan([K.b]));       % 4682 nan vals (equal across ols/mle)
rm      = num2cell(false(size([K.b]))');
[K.rm]  = rm{:};
% also see: https://blogs.mathworks.com/loren/2006/12/20/finding-strings/


% ========================================================================
% use 'extractfield' to extract field from a structure
% ========================================================================

roads   = shaperead('concord_roads.shp');
r       = roads(1:5)
names   = extractfield(r,'STREETNAME')

% OR, if all values in the field are of same numeric or logical type, use:
names   = [r(:).NumericField]

% might work in other cases too. Doesn't work for char, e.g. in a netcdf
% info structure [info.Variables.Name] doesn't work, use names =
% extractfield(info.Variables,'Name')  

% might also be a matter of the size of each name, if all chars are same
% size, might work, but extractfield handles them all . 

% IN GENERAL, if I am frustrated with a structure, try struct2table and use
% tables instead, good old fashioned matlab indexing should work: 
% https://blogs.mathworks.com/loren/2018/02/14/a-best-friend-struct2table/

% FOR example, I could not figue out how to operate o all elements of
% nonscalar struct array (e.g. as returned for a shapefile)
vars    = {'perm_mean','perm_media','perm_stdev'};
for n = 1:numel(vars)
    x1   = round(100.*[beas.(vars{n})],1); x1=x1(:);
    for m = 1:numel([beas.(vars{n})])
        beas(m).(vars{n}) = x1(m);
    end
end