function X = prepareLagPredictor(x, numlag, transform)

   if nargin < 2
      numlag = 1;
   end
   if nargin < 3
      transform = 'none';
   end

   N = length(x);
   X = NaN(N - numlag, numlag + 1);

   % Populate X with lagged versions
   for lag = 0:numlag
      X(:, lag+1) = x(1 + numlag - lag:end - lag);
   end

   % Apply transformations
   switch transform
      case 'log'
         X = log(X);
      case 'sqrt'
         X = sqrt(X);
      case 'square'
         X = X.^2;
      case 'exp'
         X = exp(X);
      case 'none'
         % Do nothing
   end
end
