function obj = readapikey(API_Key)

% copied from yair altman's code, just a placeholder in case thi scomes on
% handy, expecting to use it to read a .env file ... actually that was just hte
% api_key part, then i realized this could form the basis for a generic getdata
% function that reads web cata

if nargin < 1  % API_Key not provided
   error('MATLAB:matfunclib:API_Key', 'API_Key must be specified to connect to DATAPROVIDER')
end

if isfile(API_Key)  % filename provided rather than direct API key
   [fid, errMsg] = fopen(API_Key,'rt');
   if fid < 0
      error('MATLAB:matfunclib:API_Key', 'Cannot read API key from %s: %s', API_Key, errMsg);
   end
   API_Key = strtrim(strtok(char(fread(fid,'*char')')));
   fclose(fid);
end
obj.API_Key = API_Key;


if nargin > 1  % Timeout specified
   obj.Timeout = timeout;
end

if nargin > 2  % URL specified
   obj.URL = url;
end

% %% Connect to AV and download some data to test the connection
% try
%    obj.quotes('MSFT');
% catch err
%    error('MATLAB:AlphaVantage:Connect', 'Cannot connect to AlphaVantage using the specified API key. Please visit https://www.alphavantage.co/support/#api-key to get a valid AlphaVantage API key.')
% end
% end
