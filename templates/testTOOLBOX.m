
% Uninstalling mltbx SLM - Shape Language Modeling
% Uninstalling mltbx geom3d
% Uninstalling mltbx Medical Image Processing Toolbox
% Uninstalling mltbx 2D Unsteady convection-diffusion-reaction problem
% Uninstalling mltbx Pack & Unpack variables to & from structures with enhanced functionality
% Uninstalling mltbx GUI Layout Toolbox
% Uninstalling mltbx Numerical Computing with MATLAB
% Uninstalling mltbx labelpoints
% Uninstalling mltbx Adaptive Robust Numerical Differentiation

[prefs,others] = tbParsePrefs('config');
configPath     = [prefs.toolboxRoot '/ToolboxRegistry/configurations/'];
configFile     = [configPath 'labelpoints.json'];

% setup the config for labelpoints

% this installs the .m fex file
% url      = ['https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/' ...
%             'e5ab52cd-4a80-11e4-9553-005056977bd0/c855d348-cd53-4ed6-9d6a-4e0baf31d44c/packages/zip'];

% this installs the toolbox
url      = ['https://www.mathworks.com/matlabcentral/mlc-downloads/downloads' ...
            '/e5ab52cd-4a80-11e4-9553-005056977bd0/4.1.1/packages/mltbx/labelpoints.m.mltbx'];

record   = tbToolboxRecord(   'name',     'labelpoints',             ...
                              'type',     'webget',                  ...
                              'url',       url);

% tbDeployToolboxes('config', record);   % this didn't work

% try writeConfig first, then deploy
tbWriteConfig(record, 'configPath', configFile);

% still doesn't work, maybe I misunderstand what it's supposed to do
% tbDeployToolboxes('configPath', configFile);

% this works, but doens't install the toolbox
tbUse('labelpoints')

% see more info here
% https://github.com/ToolboxHub/ToolboxToolbox/wiki/Toolbox-Records-and-Types

