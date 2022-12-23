function [ mininds,minvals ] = findlocalmin( indata,k,varargin )
%FINDLOCALMIN Returns the k indici(s) of the min value and the value at
%those indices. optional arguments follow those of 'min' e.g.
%'first','last'

% find all local min indices
mininds = find(islocalmin(indata));

% if there is no local min, use the global min value
if isempty(mininds)
    [mininds,minvals] = findmin(indata,k,varargin{:});
    warning('no local minima found, using global min, check edges');
    return;
end

[imin,minvals] = findmin(indata(mininds),k,varargin{:});
mininds = mininds(imin);

% if no local min is found, issue error
if isempty(mininds); error('No local min found'); end

% if the global min is lower than the local min, use it
globalmin = findmin(indata,1);
if all(indata(globalmin)<indata(mininds))
    if k==1
        mininds = globalmin;
        minvals = indata(globalmin);
    elseif k>1 % add the global min to the list of mininds
        mininds = [mininds;globalmin];
        minvals = [minvals;indata(globalmin)];
    end
end


% try
%     mininds = find(islocalmin(indata));
% catch ME
%     if strcmp(ME.identifier,'')
%         % use the global min value
%         [mininds,minvals]  = findmin(indata,k,varargin{:});
%         return;
%     end
% end

% figure; plot(1:numel(indata),indata); hold on;
% scatter(mininds,indata(mininds),'r','filled');
% scatter(mininds,indata(mininds),'g','filled');

