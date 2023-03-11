function [tf, itab] = istab(textline)
%ISTAB detect "tab" characters in a char or string textline
% 
% [tf, itab] = istab(textline) returns logical tf TRUE if tabs are present,
% or FALSE if tabs are not present. Optionally returns the positions of the
% tab(s) in the line of chars. 
% 
% Example
% 
% 
% Matt Cooper, 03-Feb-2023, https://github.com/mgcooper
% 
% See also

% didn't finish this b/c need a way to figure out if tabs are spaces and if so how many

validateattributes(textline,{'char','string'},{'notempty'},mfilename,'textline',1);

% need a way to figure out if tabs are spaces and if so how many
tf = (textline==sprintf('\t'));

% Find the positions in line where tabs exist.
itab = find(tf);

if isempty(itab), itab=[]; end

% Return only logical 1 or 0, however many tabs there are in line.
tf = tf(find(tf));

if ~isempty(tf), tf=tf(1); end
if isempty(tf), tf=logical(0); end
% Display the logical result for tab existence.
if tf, 1==1, end
if ~tf, 1==2, end
return