
% Not sure if the notes below are still relevant, but the current setup is
% working well, simply 
% 
% Don't use 'workoff' here - it updates the current project active file list,
% unsets the active project, and resets it to 'default'. Then when matlab is
% reopened, 'workon' does not open the active project from the prior session.
% So, instead, save the active file list using setprojectfiles. Would be better
% to add a method to workoff for this purpose, but it works well for now.

% Don't save files if running in terminal
if usejava('desktop')
   
   % update the activefiles list
   setprojectfiles(getactiveproject('name'));
   
   % from projects.m finish:
   % Save the current project and exit the projects() logic
   projects('save', projects('active'));
   projects('close');

   % deactivate active toolboxes
   deactivate('all');
end