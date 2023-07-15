function releasefile(varargin)
%RELEASEFILE build, test and package a MATLAB toolbox
%
% releasefile(toolboxname) creates ToolboxName-vX.X.X.mtlbx in release/ folder
% 
% The release version is assumed to be up to date in the Contents.m' file.
%
% This function is a replacement for buildfile for matlab versions that do not
% support buildplan. It also does not rely on r2023a function
% matlab.addons.toolbox.ToolboxOptions 
% 
% Copyright (c) YYYY, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper 
% 
% Based on 'release' function, Copyright 2016-2020 The MathWorks, Inc.

%% Set toolbox name

if nargin < 1
   tbxname = 'foo';
else
   tbxname = varargin{1};
end

%% Get release script directory
cfdir = fileparts( mfilename( 'fullpath' ) );
tbxDir = fullfile( cfdir, 'tbx');

%% Check MATLAB and related tools, e.g.:
assert( ~verLessThan( 'MATLAB', '9.6' ), ...
   'MATLAB R2019a or higher is required to use Toolbox Tools.' )

%% Check installation
fprintf( 1, 'Checking installation...' );
v = ver( tbxname );
switch numel( v )
    case 0
        fprintf( 1, ' failed.\n' );
        error( '%s not found.', tbxname );
    case 1
        % OK so far
        fprintf( 1, ' Done.\n' );
    otherwise
        fprintf( 1, ' failed.\n' );
        error( 'There are multiple copies of ''%s'' on the MATLAB path.', tbxname );
end

%% Build documentation & examples
fprintf( 1, 'Generating documentation & examples...' );
try
    % Do something;
    fprintf( 1, ' Done.\n' );
catch e
    fprintf( 1, ' failed.\n' );
    e.rethrow()
end

%Build doc search database
try
    builddocsearchdb( fullfile( tbxDir, 'doc' ) );
catch me
    warning( me.message )
end

%% Run tests
fprintf( 1, 'Running tests...' );
[log, results] = evalc( 'runtests( fullfile( cfdir, "tests" ) )' );
if ~any( [results.Failed] )
    fprintf( 1, ' Done.\n' );
else
    fprintf( 1, ' failed.\n' );
    error( '%s', log )
end

%%  Package and rename.
fprintf( 1, 'Packaging...' );
try
    prj = fullfile( cfdir, [ tbxname, '.prj'] );
    matlab.addons.toolbox.packageToolbox( prj );
    oldMltbx = which( [tbxname '.mltbx'] );
    newMltbx = fullfile( fileparts( tbxDir ), 'releases', [tbxname ' v' v.Version '.mltbx'] );
    movefile( oldMltbx, newMltbx )
    fprintf( 1, ' Done.\n' );
catch e
    fprintf( 1, ' failed.\n' );
    e.rethrow()
end

%% Check package
fprintf( 1, 'Checking package...' );
tver = matlab.addons.toolbox.toolboxVersion( newMltbx );

if strcmp( tver, v.Version )
    fprintf( 1, ' Done.\n' );
else
    fprintf( 1, ' failed.\n' );
    error( 'Package version ''%s'' does not match code version ''%s''.', tver, v.Version )
end

%% Show message
fprintf( 1, 'Created package ''%s''.\n', newMltbx );

end %release
