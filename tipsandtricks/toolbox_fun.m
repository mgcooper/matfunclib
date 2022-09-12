

% This is a fantastic contribution and I thank you profusely for building it. That said, I have some constructive feedback. For long-time Matlab users, this represents a big disruption to the standard way of doing things. 
% 
% 1) It would be helpful to warn first-time users that on startup, ToolboxToolbox will uninstall all existing installed toolboxes. 
% 2) It would be helpful to include an example of how to create a configuration file for a toolbox located on the FEX, rather than Github (Note: I eventually found this buried in the wiki, but given that your recommended installation steps remove all installed toolboxes, which inevitably will contain many FEX-only installs, it behooves you to highlight this upfront, or provide an easy method for a user to re-install these toolboxes)
% 
% 
% 
% sampleRepo = tbToolboxRecord('name', 'sample-repo', 'flavor', 'v0.1', 'type', 'git', 'url', 'https://github.com/ToolboxHub/sample-repo.git');
% jsonlab = tbToolboxRecord('name', 'jsonlab-mcfe', 'type', 'webget', 'url', 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/33381/versions/22/download/zip');
% tbDeployToolboxes('config', [sampleRepo jsonlab]);

% https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/e5ab52cd-4a80-11e4-9553-005056977bd0/4.1.1/packages/labelpoints.m.mltbx
% 	
% https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/e5ab52cd-4a80-11e4-9553-005056977bd0/4.1.1/packages/mltbx/labelpoints.m.mltbx
