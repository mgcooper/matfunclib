function varargout = magic_parser_tricks(varargin)
%MAGIC_PARSER_TRICKS magic_parser tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% note: if opts is NOT included in the function input line, and IS added as
% an optional argument with addOptional, then MiP puts the correct opts
% into the workspace and one can then rummage around to find name-value
% pairs. However, if opts IS included in the function input line (which is
% helpful to remember how to use the function), and added with addOptional,
% then MiP puts the default opts into the workspace, and afaik, the opts
% that was passed in is not anywhere to be found

clean

s.input1 = 10;
s.input2 = 20;
default = 0;

p = inputParser;
addParameter(p,'input1',default)
addParameter(p,'input2',default)
parse(p,s)

p.Results



clean

s.input1 = 10;
s.input2 = 20;
default = 0;

p = magicParser;
p.addParameter('input1',default);
p.addParameter('input2',default);

p.parseMagically('caller')

