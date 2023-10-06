% To remove a Matlab trailing whitespace in the editor
% Original Author: Sam Roberts
% http://stackoverflow.com/questions/19770347/how-to-auto-remove-trailing-whitespaces-on-save-in-matlab
% Modified by Mark Harfouche to remember cursor location
%
%
% Temp variable for shortcut. Give it an unusual name so it's unlikely to
% conflict with anything in the workspace.
shtcutwh__ = struct;

% Check that the editor is available.
if ~matlab.desktop.editor.isEditorAvailable
   return
end

% Check that a document exists.
shtcutwh__.activeDoc = matlab.desktop.editor.getActive;
if isempty(shtcutwh__.activeDoc)
   return
end

% save the old cursor location
shtcutwh__.Selection = shtcutwh__.activeDoc.Selection;

% Get the current text.
shtcutwh__.txt = shtcutwh__.activeDoc.Text;

% Remove trailing whitespace from each line.
shtcutwh__.lines = deblank(regexp(shtcutwh__.txt,'[^\n]*(\n)|[^\n]*$', 'match'));

% remove the trailing blank lines
for n = length(shtcutwh__.lines):-1:1
   if length(shtcutwh__.lines{n}) == 0
      shtcutwh__.lines(n) = [];
   else
      break
   end
end

% Reconcatenate lines.
shtcutwh__.addNewline = @(x)sprintf('%s\n',x);

shtcutwh__.lines = cellfun(shtcutwh__.addNewline, shtcutwh__.lines, 'UniformOutput', false);

% If you always want to add a newline at the end of the file, comment this line out
% Remove the last newline character
shtcutwh__.lines{end}(end) = '';

shtcutwh__.newtxt = horzcat(shtcutwh__.lines{:});

% Set the current text.
shtcutwh__.activeDoc.Text = shtcutwh__.newtxt;

% Place the cursor back
shtcutwh__.activeDoc.Selection = shtcutwh__.Selection;

% Delete temp variable.
clear shtcutwh__
