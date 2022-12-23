%convert barometric pressure from hPa to kPa 
kPa = Met(:,29)/10;

%Read in shortwave(SR), reflected shortwave(RSR),longwave(LW), and
%reflected longwave(RLW)
SW=Met(:,2);
RSW=Met(:,3);
LW=Met(:,14);
RLW=Met(:,15);

%calculate the density of air dependent on air temp and pressure
Temp = Met(:,27);
l = length(Met);
for i = 1:l
r_air(i) = kPa(i)/(287.058 * (273.15 + Temp(i))) * 1000;
end


%calcualte Kat
% j = 1:8784
% K_08_num(j) = 0.622 * r_air_08(j)
% K_08_den(j) = P_08_kPa_hr(j) * 1000
% 
% for j = 1:8784
%     K_08(j) = K_08_num(j) / K_08_den(j)
% end

%calculate gamma
for i = 1:l
gamma(i) = 0.001 * kPa(i)/(0.622*2.47);
end

%calcuate delta
for j = 1:l
    c = 2508.3/((237.3+Temp(j))^2);
    e = (17.3*Temp(j));
    ee = (237.3+Temp(j));
    e = e/ee;
    delta(j) = c * exp(e);
end

%calculate saturation vapor pressure
for j = 1:l
    e = (17.3*Temp(j));
    ee = (237.3+Temp(j));
    e = e/ee;
    ea(j) = 0.611 * exp(e);
end

%calculate net radiation (NR)and convert from W/m^2 to MJ m^-2 s^-1
for j=1:l
    nr(j)=((SW(j)-RSW(j))+(LW(j)-RLW(j)));
end

%calcualate atmospheric conductance for water vapor
zv = 0.5;  %vegetation height
zd = 0.7 * zv;
zo = 0.1 * zv;
zm = 2 + zv;
z = (zm-zd)/zo;

for j = 1:l
    V = Met(j,25);
    Cat(j) = V / (6.26 * (log(z)^2));
end



%PET
for j = 1:l
    D = delta(j);
    NR = nr(j)/10^6;  
    pa = r_air(j);
    ca = 0.001;
    Ca = Cat(j);
    Can = 0.5 * 3.0 * 8.0/1000;
    Ea = ea(j);
    RH = Met(j,28)/100;
    pw = 1000;
    la = 2.47;
    g = gamma(j);
    PET(j) = (D * NR + pa * ca * Ca * Ea * (1 - RH/100))/(pw * la * (D + g*(1+ Ca/Can)));
end

%convert PET from meters(m) to millimeters(mm)and S-1 to 15 min-1
for j=1:l
    PETmm(j)=PET(j)*1000*900;
end

csvwrite('PETmm.csv',PETmm);
%  PETmmd = PET * 86400 * 1000
%  PETmmd = PETmmd'

%%%%Separate PET file into midnight to midnight files for the separate met
%%%%station deployment

% PETp301_1(:,1) = Met(find(Met(:,1) > datenum('Jul-10-2011 23:59') &  ...
%     Met(:,1) < datenum('Jul-15-2011')))
% PETp301_1(:,2) = PETmmd(find(Met(:,1) > datenum('Jul-10-2011 23:59') &  ...
%     Met(:,1) < datenum('Jul-15-2011')))   
% 
% PETp301_2(:,1) = Met(find(Met(:,1) > datenum('Aug-10-2011 23:59') &  ...
%     Met(:,1) < datenum('Aug-17-2011')))
% PETp301_2(:,2) = PETmmd(find(Met(:,1) > datenum('Aug-10-2011 23:59') &  ...
%     Met(:,1) < datenum('Aug-17-2011')))  
% 
% PETp301_3(:,1) = Met(find(Met(:,1) > datenum('Sep-28-2011 23:59') &  ...
%     Met(:,1) < datenum('Oct-29-2011')))
% PETp301_3(:,2) = PETmmd(find(Met(:,1) > datenum('Sep-28-2011 23:59') &  ...
%     Met(:,1) < datenum('Oct-29-2011')))  
% 
% PETseki(:,1) = Met(find(Met(:,1) > datenum('Jul-21-2011 23:59') &  ...
%     Met(:,1) < datenum('Aug-09-2011')))
% PETseki(:,2) = PETmmd(find(Met(:,1) > datenum('Jul-21-2011 23:59') &  ...
%     Met(:,1) < datenum('Aug-09-2011')))  
% 
% 
% days = (length(PETp301_1) / 24)
% for i = 1:days
%     n = (i-1)*24 + 1
%     m = n + 23
%     PETday1(i,1) = PETp301_1(n,1)
%     PETday1(i,2) = sum(PETp301_1(n:m,2))/24
% end
% 
% days = (length(PETp301_2) / 24)
% for i = 1:days
%     n = (i-1)*24 + 1
%     m = n + 23
%     PETday2(i,1) = PETp301_2(n,1)
%     PETday2(i,2) = sum(PETp301_2(n:m,2))/24
% end
% 
% days = (length(PETp301_3) / 24)
% for i = 1:days
%     n = (i-1)*24 + 1
%     m = n + 23
%     PETday3(i,1) = PETp301_3(n,1)
%     PETday3(i,2) = sum(PETp301_3(n:m,2))/24
% end
% 
% days = (length(PETseki) / 24)
% for i = 1:days
%     n = (i-1)*24 + 1
%     m = n + 23
%     PETday4(i,1) = PETseki(n,1)
%     PETday4(i,2) = sum(PETseki(n:m,2))/24
% end