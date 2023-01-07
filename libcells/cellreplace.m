function Cnewvals = cellreplace(Coldvals,Cnewvals)

% this is really 'vararginreplace' it assumes Coldvals and Cnewvals are cell
% arrays with name-value pairs so the values are in the index right after the
% keys (see +1 indexing below)

ichar = cellfun(@ischarlike,Coldvals);
userkeys = Coldvals(ichar);
uservals = Coldvals(find(ichar)+1);
Cnewvals(ismember(Cnewvals,Coldvals)) = Coldvals(ismember(Coldvals,Cnewvals));

% function C = cellfindreplace(C,patternfind,patternreplace)
% ichar = cellfun(@ischarlike,varargin);
% userkeys = varargin(ichar);
% uservals = varargin(find(ichar)+1);
% ifind = find(ismember(defaultkeys,userkeys));
% irepl = find(ismember(userkeys,defaultkeys));
% defaultvals(ifind) = uservals(irepl);