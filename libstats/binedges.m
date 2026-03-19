function [edges, widths, centers, numbins] = binedges(X, varargin)
   %BINEDGES Compute histogram bin edges from common rules.
   %
   %  [EDGES, WIDTHS, CENTERS, NUMBINS] = BINEDGES(X) returns histogram bin
   %  edges, widths, centers, and number of bins for the data vector X.
   %
   %  [...] = BINEDGES(X, METHOD) uses the requested binning rule.
   %
   %  [...] = BINEDGES(X, METHOD, SCALE) uses the requested scale. SCALE may
   %  be 'linear', 'log10', or 'ln'.
   %
   %  [...] = BINEDGES(X, 'BinMethod', METHOD, 'Scale', SCALE, 'NumBins', N)
   %  supports name-value syntax. If N is provided, it overrides the rule used
   %  to choose the number of bins.
   %
   %  Supported methods:
   %    'auto', 'sqrt', 'sturges', 'rice', 'doane', 'scott', 'fd',
   %    'integers', 'equiprobable', and 'shimazaki-shinimoto'
   %
   %  Notes
   %
   %  - 'integers' is only supported on the linear scale.
   %  - For log-spaced bins, centers are geometric means and widths are not
   %    constant in the original data space.
   %
   %  See also histcounts, histogram, centers2edges, loghist

   validateattributes(X, {'numeric', 'logical'}, ...
      {'vector', 'real', 'nonempty'}, mfilename, 'X', 1)
   X = X(:);
   X = X(isfinite(X));
   if isempty(X)
      error('BINEDGES:NoFiniteData', 'X must contain at least one finite value.');
   end

   [method, scale, numbins] = parseinputs(varargin{:});
   Xrule = transform_for_scale(X, scale);

   if isempty(numbins)
      [edges, hasExplicitEdges] = compute_edges_from_method(X, Xrule, method, scale);
   else
      validateattributes(numbins, {'numeric'}, ...
         {'scalar', 'integer', 'positive'}, mfilename, 'NumBins')
      [edges, hasExplicitEdges] = deal([], false);
   end

   if ~hasExplicitEdges
      if isempty(numbins)
         numbins = calc_numbins(Xrule, method);
      end
      edges = build_uniform_edges(X, scale, numbins);
   end

   edges = reshape(edges, 1, []);
   if numel(edges) < 2
      error('BINEDGES:InvalidEdges', 'At least two unique edges are required.');
   end

   widths = diff(edges);
   numbins = numel(edges) - 1;
   centers = compute_centers(edges, scale);
end

function [method, scale, numbins] = parseinputs(varargin)
   method = 'auto';
   scale = 'linear';
   numbins = [];
   args = varargin;

   if ~isempty(args) && istextscalar(args{1}) && ~isoptionname(args{1})
      method = normalize_method(args{1});
      args = args(2:end);

      if ~isempty(args) && istextscalar(args{1}) && ~isoptionname(args{1})
         scale = normalize_scale(args{1});
         args = args(2:end);
      end
   end

   if mod(numel(args), 2) ~= 0
      error('BINEDGES:InvalidInputs', ...
         'Optional inputs must be legacy positional arguments or name-value pairs.');
   end

   for n = 1:2:numel(args)
      name = lower(string(args{n}));
      value = args{n+1};

      switch name
         case {"binmethod", "method"}
            method = normalize_method(value);
         case "scale"
            scale = normalize_scale(value);
         case {"numbins", "nbins", "n"}
            numbins = value;
         otherwise
            error('BINEDGES:UnknownOption', 'Unknown option "%s".', args{n});
      end
   end
end

function tf = isoptionname(value)
   if ~istextscalar(value)
      tf = false;
      return
   end
   value = lower(string(value));
   tf = ismember(value, ["binmethod", "method", "scale", "numbins", "nbins", "n"]);
end

function tf = istextscalar(value)
   tf = (ischar(value) && isrow(value)) || (isstring(value) && isscalar(value));
end

function method = normalize_method(value)
   method = lower(string(value));
   switch method
      case {"square-root", "square_root", "squareroot"}
         method = "sqrt";
      case {"freedman-diaconis", "freedmandiaconis"}
         method = "fd";
      case {"ss", "sshist", "shimazaki", "shimazaki-shinimoto"}
         method = "shimazaki-shinimoto";
      otherwise
         valid = ["auto", "sqrt", "sturges", "rice", "doane", "scott", ...
            "fd", "integers", "equiprobable", "shimazaki-shinimoto"];
         if ~ismember(method, valid)
            error('BINEDGES:UnknownMethod', 'Unknown binning method "%s".', value);
         end
   end
   method = char(method);
end

function scale = normalize_scale(value)
   scale = lower(string(value));
   switch scale
      case {"linear"}
         scale = "linear";
      case {"log10", "log"}
         scale = "log10";
      case {"ln", "loge"}
         scale = "ln";
      otherwise
         error('BINEDGES:UnknownScale', ...
            'Unknown scale "%s". Use ''linear'', ''log10'', or ''ln''.', value);
   end
   scale = char(scale);
end

function Xrule = transform_for_scale(X, scale)
   switch scale
      case 'linear'
         Xrule = X;
      case 'log10'
         if any(X <= 0)
            error('BINEDGES:NonpositiveData', ...
               'Log-scaled binning requires strictly positive data.');
         end
         Xrule = log10(X);
      case 'ln'
         if any(X <= 0)
            error('BINEDGES:NonpositiveData', ...
               'Log-scaled binning requires strictly positive data.');
         end
         Xrule = log(X);
   end
end

function [edges, hasExplicitEdges] = compute_edges_from_method(X, Xrule, method, scale)
   edges = [];
   hasExplicitEdges = false;

   switch method
      case 'auto'
         if strcmp(scale, 'linear')
            [~, edges] = histcounts(X, 'BinMethod', 'auto');
            hasExplicitEdges = true;
         end

      case 'integers'
         if ~strcmp(scale, 'linear')
            error('BINEDGES:IntegerScaleMismatch', ...
               'The ''integers'' binning method only supports the linear scale.');
         end
         [~, edges] = histcounts(X, 'BinMethod', 'integers');
         hasExplicitEdges = true;

      case 'equiprobable'
         numbins = calc_numbins(Xrule, method);
         q = linspace(0, 100, numbins + 1);
         edges = prctile(X, q);
         edges = unique(edges, 'stable');
         hasExplicitEdges = true;
   end
end

function numbins = calc_numbins(X, method)
   N = numel(X);
   if N <= 1
      numbins = 1;
      return
   end

   switch method
      case 'auto'
         [~, edges] = histcounts(X, 'BinMethod', 'auto');
         numbins = numel(edges) - 1;

      case 'sqrt'
         numbins = ceil(sqrt(N));

      case 'sturges'
         numbins = ceil(log2(N) + 1);

      case 'rice'
         numbins = ceil(2 * N^(1/3));

      case 'doane'
         g = skewness(X);
         sig_g = sqrt(6 * (N - 2) / ((N + 1) * (N + 3)));
         numbins = ceil(1 + log2(N) + log2(1 + abs(g) / sig_g));

      case 'scott'
         width = 3.49 * std(X, 0) * N^(-1/3);
         numbins = width_to_numbins(X, width);

      case 'fd'
         width = 2 * iqr(X) * N^(-1/3);
         numbins = width_to_numbins(X, width);

      case 'integers'
         [~, edges] = histcounts(X, 'BinMethod', 'integers');
         numbins = numel(edges) - 1;

      case 'equiprobable'
         numbins = ceil(2 * N^(2/5));

      case 'shimazaki-shinimoto'
         numbins = sshist_numbins(X);

      otherwise
         error('BINEDGES:UnknownMethod', 'Unknown binning method "%s".', method);
   end

   numbins = max(1, round(numbins));
end

function numbins = width_to_numbins(X, width)
   rangeX = max(X) - min(X);
   if rangeX == 0 || width <= 0 || ~isfinite(width)
      numbins = 1;
   else
      numbins = ceil(rangeX / width);
   end
end

function edges = build_uniform_edges(X, scale, numbins)
   switch scale
      case 'linear'
         xmin = min(X);
         xmax = max(X);
         if xmin == xmax
            delta = max(0.5, abs(xmin) * 0.5 + eps(xmin));
            edges = [xmin - delta, xmax + delta];
         else
            edges = linspace(xmin, xmax, numbins + 1);
         end

      case {'log10', 'ln'}
         if strcmp(scale, 'log10')
            xmin = floor(log10(min(X)));
            xmax = ceil(log10(max(X)));
            if xmin == xmax
               xmin = xmin - 0.5;
               xmax = xmax + 0.5;
            end
            edges = 10 .^ linspace(xmin, xmax, numbins + 1);
         else
            xmin = floor(log(min(X)));
            xmax = ceil(log(max(X)));
            if xmin == xmax
               xmin = xmin - 0.5;
               xmax = xmax + 0.5;
            end
            edges = exp(linspace(xmin, xmax, numbins + 1));
         end
   end
end

function centers = compute_centers(edges, scale)
   switch scale
      case 'linear'
         centers = edges(1:end-1) + diff(edges) / 2;
      case {'log10', 'ln'}
         centers = sqrt(edges(1:end-1) .* edges(2:end));
   end
end

function numbins = sshist_numbins(X)
   if numel(X) <= 1 || max(X) == min(X)
      numbins = 1;
      return
   end

   maxBins = min(200, max(10, ceil(sqrt(numel(X))) * 4));
   candidates = 2:maxBins;
   costs = nan(size(candidates));
   xmin = min(X);
   xmax = max(X);

   for n = 1:numel(candidates)
      nb = candidates(n);
      edges = linspace(xmin, xmax, nb + 1);
      counts = histcounts(X, edges);
      width = (xmax - xmin) / nb;
      k = mean(counts);
      v = var(counts, 1);
      costs(n) = (2 * k - v) / (width ^ 2);
   end

   [~, idx] = min(costs);
   numbins = candidates(idx);
end
