clc
clear all


% all information is from https://dev.netatmo.com


% you need a valid user id with Netatmo:
email='';
password = '';

% you will also need to have a registed 'project' with them, but it's just
% a formality. See here: https://dev.netatmo.com/apps/createanapp
client_id = '';
client_secret= '';

% finally you need to have your own netatmo station of course and you need
% to find out it's MAC address. I did it by trying out all the connected
% devices on my computer using arp -a. There is probably a cleverer way
% use https://dnschecker.org/ to find vendor and look for netatmo
inside_id='';   


init=1;
if init
    bearer=test_netatmo_communication(email,password,client_id,inside_id,client_secret);
else
    load bearer bearer
end
% the outside ID can be obtained subsequently from the station data rad with
% 'getstationdata'. I want to read from my outside module
v=getstationsdata(inside_id,bearer);
outside_id=v.body.devices.modules(1).x_id;  %


%% read a few temperature values and display them
% type='humidity';
type='temperature';
% type='pressure';
% type='co2';
% type='noise';
% type='rain';
% type='guststrength';
% type='';
% type='';

% scale='5min';
% scale='30min';
scale='1hour';
% scale='1day';
% scale='1week';

datebegin=datetime(2015,1,1,0,0,0);
dateend=datetime(2020,6,29,21,0,0);
[times,values]=getmeasure(inside_id,inside_id,scale,type,bearer,datebegin,dateend);
figure(1)
clf
plot(times,values,'.-')
xlabel('time')
ylabel(type);



