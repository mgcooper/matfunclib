function deblankEquals(varargin)
%DEBLANKEQUALS remove all but one blank surrounding equals signs
% 
% Select text from the editor and run this function to replace equals sign
% You may add a shortcut to this function in the Matlab toolbar
%
% Matt Cooper, modifed based on alignEquals by Alessandro Masullo - 2014

% Get the selected text in the active editor
aed = matlab.desktop.editor.getActive;
sel = aed.Selection;

startSel = matlab.desktop.editor.positionInLineToIndex(aed, sel(1), sel(2));
endSel = matlab.desktop.editor.positionInLineToIndex(aed, sel(3), sel(4));

allText = aed.Text;
PreText = allText(1:startSel-1);
PosText = allText(endSel+1:end);

% Selected text
SelText = allText(startSel:min(endSel,numel(allText)));

% Split selected text in lines
Lines = strsplit(SelText,newline,'CollapseDelimiters',false);

% Text parsing
for n = 1:numel(Lines)
   % Check if contains equals
   if ~isempty(strfind(Lines{n},'='))
      
      % Remove the spaces before and after the first equal sign
      % Lines{n} = regexprep(Lines{n},'\s*=\s*',' = ','once');
      
      % Modified to handle expressions containing = signs. Second pass fixes
      % replacement of == with =  =.
      Lines{n} = regexprep(Lines{n},'\s*(~=|=|==|>=|<=)\s*',' $1 ');
      Lines{n} = regexprep(Lines{n},'=  =','==');
      
      % Tried to do ... continuataions but not worth the hassle since sometimes
      % they start lines

   end
end

% Align the text
newLines = '';
for n = 1:numel(Lines)
   newLines = [newLines, Lines{n}, newline];
end

% Replace the text. end-1 is to delete the last \n in AlignedText
aed.Text = [PreText newLines(1:end-1) PosText];

% Re-select the text
[sel(3), sel(4)] = matlab.desktop.editor.indexToPositionInLine(aed, numel([PreText newLines(1:end-1)]));
aed.Selection = sel;


