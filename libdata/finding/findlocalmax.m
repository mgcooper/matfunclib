function [ maxinds,maxvals ] = findlocalmax( indata,k,varargin )
%FINDLOCALMAX Returns the k indici(s) of the max value and the value at
%those indices. optional arguments follow those of 'max' e.g.
%'first','last' 

% find all local max indices
maxinds = find(islocalmax(indata));

% if there is no local max, use the global max value
if isempty(maxinds)
    [maxinds,maxvals]  = findmax(indata,k,varargin{:});
    warning('no local maxima found, using global max, check edges');
    return;
end

[imax,maxvals]  = findmax(indata(maxinds),k,varargin{:});
maxinds         = maxinds(imax);

% if no local max is found, issue error
if isempty(maxinds); error('No local max found'); end

% try
%     maxinds = find(islocalmax(indata));
% catch ME
%     if strcmp(ME.identifier,'')
%         % use the global max value
%         [maxinds,maxvals]  = findmax(indata,k,varargin{:});
%         return;
%     end
% end

end

