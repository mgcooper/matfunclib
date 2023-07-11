function [results,details] = fexsearch(query,options)
% SEARCGMATLABCENTRAL retrieves content of the MATLAB Central for a given
% query and returns the result as a struct.
% The function uses MathWorks RESTful API to search for content.
% The API is rate limited via IP throttling. No authentication is required.
% See API documentation for more details https://api.mathworks.com/community
%
% Example
% 
% [results,details] = fexsearch("plotting",scope="matlab-answers",sort_order="created desc",created_after=datetime("2023-01-01"));
% web(results.url(1))
% T(:,["created_date","title","is_answered"])
% 
% Input Arguments:
%
%   query (string)            - Required. The search query string.
%   scope (string)            - Optional. Specify the artifact. If not specified,
%                               the scope defaults to 'matlab-answers'. 
%                               Other options include 'file-exchange','blogs','cody', 
%                               'community-highlights', and 'community-contests'.
%   tags (string)             - Optional. Specify a comma-separated list of tags. 
%   created_before (datetime) - Optional. Specify the last date in the results 
%   created_after (datetime)  - Optional. Specify the first date in the results
%   sort_order (string)       - Optional. Speficy the order of the results. 
%                               If not specified, it defaults to "relevance desc".
%                               Other options include 'created asc', 'created desc', 
%                               'updated asc','updated desc', 'relevance asc', 
%                               and 'relevance desc'.
%   page (integer)            - Optional. Specify the page to retrieve.
%                               If the 'has_more' field in the result is positive, 
%                               increment this argument to retrieve the next page.
%   count (integer)           - Optional. Specify the number of results as a value 
%                               between 1 and 50; The default is 10. 
%
% Output Arguments:
%
%   results (table)           - Table array containing summary results of the search.
%   details (struct)          - Structure array containing detailed results of the search.

% validate input arguments
arguments
    query string {mustBeNonzeroLengthText,mustBeTextScalar}
    options.scope string {mustBeMember(options.scope,["matlab-answers", ...
        "file-exchange","blogs","cody","community-highlights", ...
        "community-contests"])} = "matlab-answers";
    options.tags string {mustBeNonzeroLengthText,mustBeVector}
    options.created_before (1,1) datetime 
    options.created_after (1,1) datetime
    options.sort_order string {mustBeMember(options.sort_order,["created asc", ...
        "created desc","updated asc","updated desc","relevance asc","relevance desc"])}
    options.page double {mustBeInteger,mustBeGreaterThan(options.page,0)}
    options.count double {mustBeInteger,mustBeInRange(options.count,1,50)}
end

% API URL and endpoint
url = "https://api.mathworks.com/community";
endpoint = "/v1/search";

% convert MATLAB datetime to the internet datetime format string
if isfield(options,"created_before")
    options.created_before = string(options.created_before,"yyyy-MM-dd'T'HH:mm:ss'Z'");
end
if isfield(options,"created_after")
    options.created_after = string(options.created_after,"yyyy-MM-dd'T'HH:mm:ss'Z'");
end

% convert optional inputs into a cell array of key-value pairs
keys = fieldnames(options);
vals = struct2cell(options);
params = [keys,vals].';

% call the API
try
    details = webread(url+endpoint,"query",query,params{:});
catch ME
    rethrow(ME)
end

results = struct2table(details.items);

end

