function obj = foo

% Example
% a = foo;
% a.name('I am a foo');
% a.name() -> 'I am a foo'
% 
% b = a;
% b.name() -> 'I am a foo'   % reference to the same object

% https://blogs.mathworks.com/loren/2007/08/09/a-way-to-create-reusable-tools/#comment-16367

% variables in the enclosing function are attributes
name = '';

% provide accessors for the ones you want to be 'public'
obj.name = @accessName;
   function out = accessName(in)
      if nargin, name = in; end
      out = name;
   end

% other methods change state (provide behavior)
...

end
