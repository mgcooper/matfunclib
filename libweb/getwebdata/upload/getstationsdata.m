function v=getstationsdata(device_id,bearer)
%% read only temperature, all data values from ever
str=[...
    'curl -X GET "https://api.netatmo.com/api/getstationsdata?'...
    'device_id=',device_id,...
    '&get_favorites=','false"',...
    ' -H "accept: application/json"'...
    ' -H "Authorization: Bearer ',bearer,...
    '"'];
[~,cout] = system(str);
v = jsondecode(cout); % decode the result
if isfield(v,'error')
    return
end

clc
fprintf('station name: %s in %s\n',v.body.devices.station_name,v.body.devices.place.city);
v.body.devices.dashboard_data

for i=1:length(v.body.devices.modules)
    fprintf('module name: %s\n',v.body.devices.modules(i).module_name);
    v.body.devices.modules(i).dashboard_data
end
return
