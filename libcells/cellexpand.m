function varargout = cellexpand(C)
% function C = cellexpand(C)
% function C = cellexpand(C,flag1,flag2,options)
%CELLEXPAND general description of function
% 
%  C = CELLEXPAND(C) description
%  C = CELLEXPAND(C,'flag1') description
%  C = CELLEXPAND(C,'flag2') description
%  C = CELLEXPAND(___,'options.name1',options.value1,'options.name2',options.value2) description
%        The default flag is 'plot'. 
% 
% Example
%  opts is a name-value struct, structexpand converts to a varargin-like cell,
%  cellexpand converts it to a list like varargin{:}
%  foo(cellexpand(structexpand(opts))
% 
% Matt Cooper, 01-Feb-2023, https://github.com/mgcooper
% 
% See also

%% input parsing
arguments
   C (:,:) cell
end

% UPDATE jun 2023 - see dealout, it might solve this problem, the key is using
% nargout on both sides, and passing in all possible outputs as a comma
% separated list as inputs which goes on the right side 

% NOTE this doesn't work quite as expected b/c the expansion is not storable in
% a variable it has the format:
% ans = 
%  C{1}
% 
% ans = 
%  C{2}
% 
% ans = 
%  C{3}
% 
% and so forth, but it may work as a shortcut to passing args to functions

% what i thought would work
% C = C{:};

% stuff that doesnt work
% C = deal(C{:});
% [C] = deal(C{:});


% this provides a string array but still doesn't work for passing to functions
% C = [C{:}];
% C = horzcat(C{:}); same

% varargout versions

% dont work
% varargout(1:nargout) = deal(C{:});

% this works if nargout matches the number of elements in C
% varargout(1:nargout) = deal(C);
% [varargout(1:nargout)] = deal(C); % same

if nargout < 1
   varargout{1} = horzcat(C{:}); 
%    varargout{1} = horzcat(string(C))
else
   for n = 1:nargout
      varargout{n} = C{n};
   end
end

% this is interesting but it just creates one string object so not name-vals
% strjoin(string(C),",")
