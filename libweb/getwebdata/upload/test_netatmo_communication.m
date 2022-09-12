function bearer=test_netatmo_communication(email,password,client_id,device_id,client_secret,bearer)
% test the basic communication, if I can log in and if the token is still
% valid. If not, creates a new token and return

if nargin < 6
    try
        load bearer bearer
    catch
        bearer=create_new_bearer(email,password,client_id,client_secret); % create a new one straight away
        save bearer bearer   % save the new one
    end
end

% check for token validity
% read the station info
v=getstationsdata(device_id,bearer);

if isfield(v,'error') && (isequal(v.error.message,'Invalid access token') || isequal(v.error.message,'Access token expired'))
    bearer=create_new_bearer(email,password,client_id,client_secret);
    save bearer bearer   % save the new one
    error('needed to create new access token (bearer). Start again!');
else
    if isfield(v,'error')
        error('other error: %s',v.error.message);
    end
end
disp('communication with server successful');
disp('reading data from station');
fprintf('station name: %s in %s\n',v.body.devices.station_name,v.body.devices.place.city);