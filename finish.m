% Don't call 'workoff' because it sets the active project to 'default'. 
% Then when matlab is reopened, 'workon' does not open whichever project was
% active when matlab was closed. Instead, use setprojectfiles to update the
% activefiles list.  TODO: add a method to workoff for this purpose.
% Note that if workoff did not set the project to 'default', then if workoff was
% called during an active session and matlab was later closed, setprojectfiles
% would override the activefiles list of the project that was active when
% workoff was called. 

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