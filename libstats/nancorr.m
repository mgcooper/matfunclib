function [Rho,Pval] = nancorr( X,Y,varargin )
   %NANCORR Compute the sample correlation coefficient for data with NaNs
   %
   %  [Rho,Pval] = nancorr( X,Y,varargin )
   %
   %  X is the one series, Y is another.
   %
   % See also: nanbias, nansmooth, nanmovmean

   % NOTE: check the fex version copied beneath the function. Also, might call
   % corrcoef instead of corr.
   
   X=X(:);
   Y=Y(:);

   if length(X) ~= length(Y)
      error('The samples must be of the same length')
   end

   nanindsx = find(isnan(X));
   nanindsy = find(isnan(Y));
   naninds  = unique([nanindsx;nanindsy]);

   X(naninds) = [];
   Y(naninds) = [];

   [Rho,Pval] = corr(X,Y,varargin{:});
end

% function [coef, t, n] = nancorr(A, B)
%    %NANCORR - Pearson correlation coefficient
%    %  version 1.0.1
%    %
%    %  coef = NANCORR(A, B) is equivalent to
%    %  coef = corr(A, B, 'rows','pairwise'),
%    %  but NANCORR works much faster.
%    %
%    %  [coef, t, n] = NANCORR(A, B)
%    %  INPUT:
%    %    A, B - input matrices, single or double, with equal number of rows
%    %
%    %  OUTPUT:
%    %    coef - matrix of Pearson correlation coefficients
%    %    t    - matrix of t-statistics
%    %    n    - matrix containing the number of defined values
%    %
%    % NOTES
%    %  pvalue can be calculated as 2*tcdf(-abs(t), n - 2)
%    %
%    % CHANGELOG
%    % v1.0.1 - stops underflow/overflow in calculations of standard errors
%    %          (sx, sy) causing the output to become complex
%    %Am, Ap: m=missing elements, p=present elements
%    Am=~isfinite(A); Bm=~isfinite(B);
% 
%    if strcmp(class(A), 'single')
%       Ap=single(~Am); Bp=single(~Bm);
%    else
%       Ap=double(~Am); Bp=double(~Bm);
%    end
%    % zero out nan elements
%    A(Am)=0; B(Bm)=0;
%    % code one of the formulas from https://en.wikipedia.org/wiki/Pearson_correlation_coefficient
%    % this procedure might be numericaly unstable for large values,
%    % it might be reasonable to center each column before calling nancorr.
%    xy = A' * B;          % sum x_i y_i
%    n  = Ap' * Bp;        % number of items defined both in x and y
% 
%    mx = A' * Bp ./ n;    % mean values in x, calculated across items defined both in x and y
%    my = Ap' * B ./ n;    % mean values in y, calculated across items defined both in x and y
% 
%    x2 = (A.*A)' * Bp;    % sum x^2_i, calculated across items defined both in x and y
%    y2 = Ap' * (B.*B);    % sum y^2_i, calculated across items defined both in x and y
% 
%    % sx, sy - standard deviations
%    sx = x2 - n .* (mx.^2); sx(sx<0)=0; sx=sqrt(sx);
%    sy = y2 - n .* (my.^2); sy(sy<0)=0; sy=sqrt(sy);
% 
%    coef = (xy - n .* mx .* my) ./ (sx .* sy);      % correlation coefficient
%    t    = coef .* sqrt((n - 2) ./ (1 - coef.^2));  % t-test statistic
% end