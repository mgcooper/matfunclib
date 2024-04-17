function [index, value] = argmax(varargin)
   %ARGMAX Index of minimum valued element.
   %
   % I = ARGMAX(X)
   % I = ARGMAX(X, [], DIM)
   % I = ARGMAX(X, [], NANFLAG)
   % I = ARGMAX(X, [], DIM, NANFLAG)
   % [I, M] = ARGMAX(_)
   %
   % I = ARGMAX(X, [], 'all')
   % I = ARGMAX(X, [], VECDIM)
   % I = ARGMAX(X, [], 'all', NANFLAG)
   % I = ARGMAX(X, [], VECDIM, NANFLAG)
   % [I, M] = ARGMAX(X, [], 'all', _)
   %
   % See documentation for MAX for additional syntax options.
   %
   % I = ARGMAX(X) returns the index I of the minimum valued element of X,
   % such that X(I) == MAX(X(:)). For vectors, ARGMAX(X) is a scalar index.
   % For matrices, ARGMAX(X) is a row vector containing the indices of the
   % minimum valued elements for each column of X, such that X(I) == MAX(X, [], 1).
   %
   % I = ARGMAX(X, DIM) returns the index I of the minimum valued element
   % of X along the dimension specified by DIM.
   %
   % ARGMAX accepts the same inputs as the built-in MAX function.
   % See the documentation for MAX to understand the requirements for each syntax.
   %
   % Example:
   %     X = [2 8 4;
   %          7 3 9];
   %     argmax(X, [], 1)
   %     argmax(X, [], 2)
   %
   % See also ARGMAX, MAX, MAX

   [value, index] = max(varargin{:});
end
