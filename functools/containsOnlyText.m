function tf = containsOnlyText(x)
   %containsOnlyText return true if input x contains only text
   %
   %  tf = containsOnlyText(x) returns true if x is a char, string, or cell
   %  array of chars or strings, otherwise returns false.
   %
   % "text" means char, string, or cell array of chars or strings
   % "contains" means text by itself, or text contained within an array or cell
   %
   % This function is used because mustBeText doesn't check for cell arrays of
   % strings (possibly b/c iscellstr doesn't perform that check). Use it in
   % argument blocks instead of mustBeText if that case needs to be supported.
   %
   % Important: Note the following unexpected behavior (now fixed):
   %
   % test = {1, 'testchar', "teststring"}
   % containsOnlyText(test)
   %
   % ans =
   %   logical
   %    1
   %
   % This occurs b/c the concatenation step converts the double 1 to a string:
   % [test{:}]
   %
   % ans =
   %   1×3 string array
   %     "1"    "test"    "test"
   %
   % if X is a cell array of mixed types and each type can be cast
   % to string, this will return true
   %
   % See also mustContainOnlyText mustBeText ischarlike

   % replace with call to ischarlike to avoid type-casting to string in og vers
   tf = ischarlike(x);

   % Removes outer cell layer and recurses if the passed text is in a cell array
   % Text passed to next version is horizontally concatenated version.
   % tf = ischar(x) || ...
   %    isstring(x) || ...
   %    iscell(x) && ( containsOnlyText( [x{:}] ) ); %If there are layered cells
end
