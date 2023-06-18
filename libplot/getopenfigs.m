function H = getopenfigs(H,flag)
%GETOPENFIGS get open figure graphics object handles
% 
% Syntax
% 
%  H = GETOPENFIGS() returns all open figure handles as gobjects array
%  H = GETOPENFIGS(H,'match') returns the open figure handle that matches input
%  handle H 
% 
% Example
%  H = figure;
%  Htest = getopenfigs(H,'match');
%  isequal(H,Htest)
% 
% 
% Matt Cooper, 17-Jan-2023, https://github.com/mgcooper
% 
% See also: 

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------

arguments
   H (:,1) matlab.ui.Figure
   flag (1,1) string {mustBeMember(flag,{'match','count'})} = 'match'
end

%------------------------------------------------------------------------------

allfigs = findobj(allchild(0), 'flat', 'type', 'figure');
if isempty(H)
   H = allfigs;
elseif flag == "match"
   H = allfigs(allfigs == H);
elseif flag == "count"
   H = numel(allfigs);
else
   % H = allfigs; shouldn't ever get here
end

