function varargout = shortcut_tricks(varargin)
%MATLAB_TRICKS matlab tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%% Shortcuts

% HOW TO KEYBOARD SHORTCUT TO VARIABLE WINDOW WHEN 

% programmatically create favorites:
% https://www.mathworks.com/matlabcentral/answers/411846-how-to-create-favorites-by-code-command-window

% cmd-A then cmd-I to quickly apply smart indent to entire document

% in HOME, see Favorites, create and add to quick access toolbar
% i looked everywhere and could not find a way to assign a keyboard shortcut to
% the quick access shortcuts, though

% cmd-0 sends cursor to command window
% shift-cmd-0 sends it back to the editor
% example: writing a for loop you want n=1 right away, this way you don't need
% to move to the mouse and click on the cmd wdw and type n=1

% end/start of line           cmd-arrow 
% run current selection       shift-enter
% comment line                cmd-/
% uncomment line              cmd-T
% cursor to cmd window        cmd-0
% cursor to editor            shift-cmd-0
% page open tabs              ctl-page up/down (works for editor, help, and variable tabs)
% 



% cmd-arrow moves to end or beginning of current line, so I want this to 

% MAC
% cmd-tab (keep cmd held down) to move through open apps
% shift-cmd-[ moves through open tabs in safari