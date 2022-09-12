function [t, v]=parseweather(str)
% t=datetime.empty;
v=[];
allq= strfind(str,"""");
c=0;
for i=3:2:length(allq)-8
    c=c+1;
    s=str(allq(i)+1:allq(i+1)-1);
    tt=str2double(s);
    t(c) = datetime(tt,'ConvertFrom','posixTime','TimeZone','Europe/London','Format','dd-MMM-yyyy HH:mm');
end



all1= strfind(str,"[");
all2= strfind(str,"]");
c=0;
for i=1:length(all1)
    c=c+1;
    s=str(all1(i)+1:all2(i)-1);
    v(c)=str2double(s);

end

if isnan(v)
    t=[];
    v=[];
    return
end


end

