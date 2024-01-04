function figure_close_test()
   % When you try to close figure windows, MATLAB for Mac sometimes gives you
   % the rainbow cursor of death and hangs up. A walkaround is to turn off
   % apps that use Mac's Accessibility API. Go to System Preferences >
   % Security & Privacy > Privacy > Accessibility and unmark some apps there.
   %
   % This script is helpful to identify the apps that cause the problem.
   %
   % (1) Run this script. If it finishes without any problems, you don't have
   %     the "can't close a figure" issue. Lucky you! If your MATLAB hangs up
   %     or becomes sluggish, go to (2).
   %
   % (2) Turn off an app shown in Accessibility and go to (3).
   %
   % (3) Run this script again. If you finished it without any problems, then
   %     it is likely that the app you just turned off interferes with MATLAB.
   %     So, it should be turned off while you use MATLAB (and ask MathWorks
   %     to fix this long-standing issue). If you got some problems while
   %     running this script, go back to (2) and turn off another app.

   % mgc notes: I granted matlab full disk access, and one by one removed all
   % accessibility api permissions (Settings -> Privacy -> Accessibility). I
   % also closed all apps that had permission e.g. teams, iterm. I closed magnet
   % first since that causd problems previously. Nothing worked as far as
   % getting this script to stop hanging. Unfortunately, I did not pursue
   % general work before turning back on the permissions since I need them on,
   % the goal was to figure out which app is the source of the problem. So, if
   % the issue persissts, just don't make figures and close them, may also be
   % related to having live scripts open. 
   % https://www.mathworks.com/matlabcentral/answers/710913-matlab-r2020b-freezes-when-closing-figure-intel-macos-big-sur
   % 
   clearvars
   close all

   for i = 1 : 10
      fprintf('%d: ',i)
      for j = 1 : 10
         fprintf('%d ',j)
         figure;
         plot([0,1,2],[0,1,2])
      end
      close all;
      fprintf('--- All figures closed\n')
   end
end