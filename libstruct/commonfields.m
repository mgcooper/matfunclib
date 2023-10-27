function varargout = commonfields(varargin)
   % COMMONFIELDS Find the common field names among multiple structs.
   %
   % COMMON = COMMONFIELDS(S1, S2, ..., Sn)
   % [COMMON, I1, I2, ..., In] = COMMONFIELDS(S1, S2, ..., Sn)
   %
   % COMMON = COMMONFIELDS(S1, S2, ..., Sn) returns a cell array COMMON
   % containing the field names common to all input structs S1 through Sn.
   %
   % [COMMON, I1, I2, ..., In] = COMMONFIELDS(S1, S2, ..., Sn) also returns I1
   % through In, which are the indices of common fields in each respective input
   % struct. 
   %
   % Example:
   %   s1 = struct('a', 1, 'b', 2, 'c', 3);
   %   s2 = struct('b', 4, 'c', 5, 'd', 6);
   %   s3 = struct('c', 7, 'd', 8, 'e', 9);
   %
   %   [common, i1, i2, i3] = commonfields(s1, s2, s3);
   %   % common = {'c'}
   %   % i1 = [0 0 1]
   %   % i2 = [0 1 0]
   %   % i3 = [1 0 0]
   %
   % See also: fieldnames, numfields


   % Get field names from all input structs
   F = cellfun(@fieldnames, varargin, 'uni', 0);

   % Find common fields among all structs
   common = F{1};
   for n = 2:length(F)
      common = intersect(common, F{n}, 'stable');
   end

   % Remove empty sets:
   common = common(~cellfun('isempty', common));

   % Find the indices of common fields in each input
   indices = cell(1, length(F));
   for n = 1:length(F)
      [~, indices{n}] = ismember(F{n}, common);
   end

   % Prepare output
   varargout{1} = common;
   if nargout > 1
      [varargout{2:nargout}] = dealout(indices{:});
   end
end

% This might form the basis for an "any" or "all" option
% [opt, args, nargs] = parseoptarg(varargin, {'all', 'each'}, 'all');
% ... rest of code
% commonPerInput = cell(1, length(F));
% for n = 1:length(F)
%    commonPerInput{n} = intersect(common, F{n}, 'stable');
% end

% Original notes:
% F = cellfun(@fieldnames, varargin{:}, 'uni', 0);
% f = cellfun(@(x) intersect(x, F{1}), F, 'uni', 0);
%
% % keep the one with the least # of common fields, including zero
% f = f(argmin(cellfun('prodofsize',f)));
%
% % discard any with zero then keep the one with the least # of common fields
% f = f(~cellfun('isempty',f));
% f = f(argmin(cellfun('prodofsize',f)));

