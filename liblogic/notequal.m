function TF = notequal(X1,X2)
%NOTEQUAL general description of function
% 
%  TF = NOTEQUAL(X) description
%  TF = NOTEQUAL(X,'flag1') description
%  TF = NOTEQUAL(X,'flag2') description
%  TF = NOTEQUAL(___,'options.name1',options.value1,'options.name2',options.value2) description
%        The default flag is 'plot'. 
% 
% Example
% 
% 
% Matt Cooper, 03-Feb-2023, https://github.com/mgcooper
% 
% See also

TF = ~isequal(X1,X2);