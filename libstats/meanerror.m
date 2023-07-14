function [ mae ] = meanerror( observed, predicted, varargin )
%MEANERROR compute the mean absolute error
%   
% [ mae ] = meanerror( observed, predicted ) computes the mean absolute error
% between observed, predicted.
% 
% [ mae ] = meanerror( observed, predicted , _) accepts all inputs to SUM
% (matlab builtin, try `doc sum`)
% 
% Example
% x = 1:10; y = 2:11;
% mean_error(x, y) % should equal 1
% 
% Add nan
% x(2) = nan;
% mean_error(x, y) % should equal nan
% mean_error(x, y, 'omitnan') % should equal 1
% 
% Example with matrices
% x = repmat(1:10, 10, 1); y = repmat(2:11, 10, 1); 
% mean_error(x, y, 2) % should be a vector of ones of size 10x1
% mean_error(x, y, 1) % should be a row of ones of size 1x10
% 
% Add nans
% x(magic(3)*11) = nan; y(magic(3)*11) = nan; 
% mean_error(x, y, 2) % should be 10x1 vector all nan except the last elem = 1
% mean_error(x, y, 1) % should be 1x10 vector all nan except the first elem = 1
% mean_error(x, y, 'all') % should be scalar nan
% 
% mean_error(x, y, 2, 'omitnan') % should be 10x1 vector all equal to 1
% mean_error(x, y, 1, 'omitnan') % should be 1x10 vector all equal to 1
% mean_error(x, y, 'all', 'omitnan') % should equal 1
% 
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
% 
% See also nashsutcliffe, rmse, nanbias, stderr, sum

narginchk(2, Inf)

dif = predicted-observed;
ssz = ones(size(dif)); ssz(isnan(dif)) = nan;
mae = sum(dif, varargin{:})./sum(ssz,varargin{:});

% if nargin < 3 || isempty(dim), dim = 1; tovec = true; end
% 
% if tovec
%    predicted = predicted(:);
%    observed = observed(:);
% end
% 
% dif = predicted-observed;
% mae = sum(dif, dim, 'omitnan')/sum(~isnan(dif(:)),1);
end

