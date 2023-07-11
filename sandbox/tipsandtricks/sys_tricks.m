function varargout = system_tricks(varargin)
%SYSTEM_TRICKS system tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% you can invoke shell commands using !
! touch test.txt

% also see system and jsystem

% BUT, see:
% https://www.mathworks.com/matlabcentral/answers/94199-can-i-use-aliases-when-using-the-and-system-commands-from-within-matlab

% When using the ! or SYSTEM command, MATLAB forks off a non-interactive,
% non-login shell. Hence, depending on the shell being used only specific
% configuration files will be sourced.
% 
% The TCSH shell is more easily configurable for this task. To ensure that your
% aliases are recognized 
% 1. Create a ~/.cshrc file with the aliases.
% 2. Create an environment variable MATLAB_SHELL=/bin/tcsh. When using the UNIX
% or ! commands, MATLAB queries this environment variable to check if a
% particular shell choice has been made.   
% 
% Configuring a BASH shell for this task is more complicated because the
% non-interactive Bash shell does not read the ~/.bashrc file. Instead it
% queries the BASH_ENV environment variable for a file that must be executed at
% shell creation. Additionally, Bash does not expand (read substitute) aliases
% in non-interactive shells and hence one has to explicitly specify that it does
% this, to get this to work with a Bash shell     
% 
% 1. Set the variables, BASH_ENV=~/someFile and MATLAB_SHELL=/bin/bash.
% 2. Create a file ~/someFile that sets the appropriate aliases and include the
% following additional line 
% 
% shopt -s expand_aliases
% 
% Note that on a Mac, setting global environment variables like MATLAB_SHELL and
% BASH_ENV requires one to edit a PLIST-file. Instructions on how to do this are
% available here:   
% 
% https://developer.apple.com/library/archive/qa/qa1067/_index.html

system('echo $SHELL')



%% remove anything that is a directory 
list = list(~[list.isdir]);
