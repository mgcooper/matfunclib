function tf = istablelike(T)
   %ISTABLELIKE Return true if input T is a table or timetable.
   %
   %  tf = istablelike(T) returns true if T is a table or a timetable.
   %
   % Note: istablelike will be deprecated on upgrade to R2021 or whichever
   % release has istabular.
   tf = istable(T) | istimetable(T);
end
