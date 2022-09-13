clean

filename    =   'catchment_2016_Behar_2016070715202_maximum_polygon.prj';
isURL       =   false;

% Try to open the PRJ file.  If it's not there, that's OK.
fileID      =   fopen(filename,'r');    
str         =   fgetl(fileID);

segments    =   strings(0);
remain      =   str;

while (remain ~= "")
   [tag,remain] = strtok(remain, '["",]');
   segments = [segments ; tag];
end


%% This is copied from arcgridread

function coordinateSystemType = coordinateSystemTypeFromProjectionFile(filename, isURL)

% Determine the name of the PRJ file, if it exists.
[pathstr, name, ext] = fileparts(filename);
if isequal(lower(ext),ext)
    prjExtension = '.prj';
else
    prjExtension = '.PRJ';
end

if isURL
    prjfilename = [pathstr, '/', name, prjExtension];
else
    prjfilename = fullfile(pathstr, [name prjExtension]);
end

% Try to open the PRJ file.  If it's not there, that's OK.
try
    allowURL = isURL;
    [fileToRead, isURL] = internal.map.checkfilename(prjfilename, mfilename, [], allowURL);
    fileID = fopen(fileToRead,'r');
catch e
    if ~any(strcmp(e.identifier, {'map:checkfilename:invalidFilename','map:checkfilename:invalidURL'}))
        rethrow(e)
    else
        fileID = -1;
    end
end

% If the PRJ file was opened, determine coordinateSystemType from its first
% line.  Otherwise set coordinateSystemType to 'unspecified'.
if fileID ~= -1
    try
        coordinateSystemType = coordinateSystemTypeFromLine1(fileID);
    catch e
        closeFile(fileID, isURL)
        throw(e)  
    end
    closeFile(fileID, isURL)
else
    coordinateSystemType = 'unspecified';
end
end

%--------------------------------------------------------------------------

function coordinateSystemType = coordinateSystemTypeFromLine1(fileID)
% Use line 1 in the PRJ file to determine the coordinate system type.
% Return 'geographic' if we find something like this (ignoring case):
% 'Projection GEOGRAPHIC'.  If the tag 'Projection' is present with any
% other value, return 'planar'.  If the 'Projection' tag is missing, return
% 'unspecified'.

line1 = fgetl(fileID);
[tag, value] = strtok(line1);
if strcmpi(tag,'Projection')
    value = strtrim(deblank(value));
    if strcmpi(value, 'GEOGRAPHIC')
        coordinateSystemType = 'geographic';
    else
        coordinateSystemType = 'planar';
    end
else
    coordinateSystemType = 'unspecified';
end

end
