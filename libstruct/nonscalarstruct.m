function S = nonscalarstruct(S,varargin)
%NONSCALARSTRUCT convert scalar struct to non-scalar struct
% 
%  S = NONSCALARSTRUCT(S) description
%  S = NONSCALARSTRUCT(S,'name1',value1) description
%  S = NONSCALARSTRUCT(S,'name1',value1,'name2',value2) description
%  S = NONSCALARSTRUCT(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 10-Mar-2023, https://github.com/mgcooper
% 
% See also

% input checks
narginchk(1,1)

% valid options
% validopts = {''}; % can be a single char
% opts = optionParser(validopts,varargin(:)); 

% For now, this only supports conversion
S = table2struct(struct2table(S));











