function [index, value] = argmin(varargin)
   %ARGMIN Index of minimum valued element.
   %
   % I = ARGMIN(X)
   % I = ARGMIN(X, [], DIM)
   % I = ARGMIN(X, [], NANFLAG)
   % I = ARGMIN(X, [], DIM, NANFLAG)
   % [I, M] = ARGMIN(_)
   %
   % I = ARGMIN(X, [], 'all')
   % I = ARGMIN(X, [], VECDIM)
   % I = ARGMIN(X, [], 'all', NANFLAG)
   % I = ARGMIN(X, [], VECDIM, NANFLAG)
   % [I, M] = ARGMIN(X, [], 'all', _)
   %
   % See documentation for MIN for additional syntax options.
   %
   % I = ARGMIN(X) returns the index I of the minimum valued element of X,
   % such that X(I) == MIN(X(:)). For vectors, ARGMIN(X) is a scalar index.
   % For matrices, ARGMIN(X) is a row vector containing the indices of the
   % minimum valued elements for each column of X, such that X(I) == MIN(X, [], 1).
   %
   % I = ARGMIN(X, DIM) returns the index I of the minimum valued element
   % of X along the dimension specified by DIM.
   %
   % ARGMIN accepts the same inputs as the built-in MIN function.
   % See the documentation for MIN to understand the requirements for each syntax.
   %
   % Example:
   %     X = [2 8 4;
   %          7 3 9];
   %     argmin(X, [], 1)
   %     argmin(X, [], 2)
   %
   % See also ARGMAX, MIN, MAX

   [value, index] = min(varargin{:});
end

%% To not support the MIN (A, B) syntax:

% Add this to the function body:

% secondInputNotEmpty = false;
% if ~isempty(varargin{2})
%    varargin = [varargin(1), [], varargin(2:end)];
% end

% Then remove the [] from the syntax documentation.

%%
% Started to parse inputs, see wmean for a method that could be converted to
% a general purpose function for parsing these types of input patterns,
% common to mean, median, min, max, in some cases w/o the second []
% comparison input i.e. sort.
% if nargin == 1
%    dim = 1;
% end

% For the simplest case where no matter the input return a scalar, which
% might be more in keeping with the 'argmin' concept:
% [value, index] = min(x(:), varargin{:});

% But the user can simply pass in x(:).
