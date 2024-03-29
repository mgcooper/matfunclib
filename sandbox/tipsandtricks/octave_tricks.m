function varargout = octave_tricks(varargin)
%OCTAVE_TRICKS octave tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%% packages

% in addition to official packages, user packages here:
% https://wiki.octave.org/Category:Packages

% octave og developer website:
% https://jweaton.org

% check ajanke's github

%% notable incompatibilities

% UPDATE: I am getting warnings that cannot be suppressed if a function that
% shadows an octave built in has an arguments block, which make octave
% unuseable, so i've moved any such functions to folders and removed them from
% path on startup e.g. ifelse, see startup.m
% looks like arguments block might be supported (passed over i.e. no error) in
% octave 7+: 
% https://hg.savannah.gnu.org/hgweb/octave/rev/c19f8cbe0fd5

% accessing private/ folders in package namespaces
% https://savannah.gnu.org/bugs/?45444
% also see: https://github.com/amroamroamro/test_functions_scope

% Octave tips
% 
% Don’t use:
% - fit and related curve fitting toolbox functions e.g. prepareCurveData
% - import 
% - PartialMatching w/ inputParser
% - islocalmax / islocalmin
% - texlabel
% 
% Do use:
% - KeepUnmatched true if passing the entire Results sruct to a subsequent
% function that takes identical parameters and using StructExpand true. This
% might also be required in Matlab, but it came up in baseflow wrapevents trying
% to pass the opts = parser.Results to getevents b/c opts had T,Q,R which octave
% complained were not valid arguments to the function, which took forever to
% diagnose. 
% 
% Replace:
% - matlab unit test framework with script-based tests:
% https://www.mathworks.com/help/matlab/matlab_prog/ways-to-write-unit-tests.html 
% also see: https://www.scivision.dev/matlab-octave-compatible-runtests/
% - gobjects with empty array
% - ax. notation with set(get,…)
% - contains with ismember
% - smoothdata with movmean, movemedian, etc
% - somestring == “teststring” with strcmp(somestring,'teststring')
% - ‘nw’ with ‘northwest’ and similar
% 
% Careful with
% - package. notation (in general due to path issues)
% - Datetime, timetables, strings (limit support with tablicous)
% - Strings / chars
% - logical operators esp. | vs || , & vs && (i.e. short circuit)
% 
% General tips:
% - instead of structs/tables, use a cell array of variable names and regular numeric arrays and helper functions to display them when needed 
% - Use @if possible instead of char to avoid single vs double quote issues eg plotyy(x,y,x,z,@plot,@scatter)
   
% Search and replace:
% fit
% contains
% gobjects
% ax. notation
% open <funcname> without .m does not work in octave
% 

%% 

% this is basically useless because it issues warnings for stuff as simple as
% 'plot' because plot depends on subfucntions that octave doesn't support
% warning ('on', 'Octave:matlab-incompatible')

