function N = numyears(Data,flag)

% % need to put this somewhere else but a method to check for complete calendar
% years: 
% % ----------------
% Y = unique(year(t));
% I = year(d.Time)==Y(end);
% D = unique(day(d.Time(I),'dayofyear'));
% 
% if numel(unique(day(d.Time(year(d.Time)==Y(end)),'dayofyear'))) < 365
% end
% % ----------------

arguments
   Data (:,:)
   flag (1,1) string {mustBeMember(flag,["calyears","noleap"])} = "calyears"
end

if istimetable(Data)
   
   Data = renametimetabletimevar(Data);
   Data = Data.Time;
   
elseif istable(Data)
   
   Data = table2array(Data);

else
   % add more cases
end

if flag == "noleap"

   try
      Data = rmleapinds(Data,Data);
   catch
      warning('no time calendar provided, dividing by 365')
   end

   N = numel(Data(:,1))/365;
else
   N = numel(Data(:,1))/365.25;
end


