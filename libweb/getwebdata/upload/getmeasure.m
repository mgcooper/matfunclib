function [alltimes,allvalues]=getmeasure(device_id,module_id,scale,type,bearer,date_begin,date_end)
% this is an enhanced version of the API caller, I can get as many values
% back as I want!

st=posixtime(date_begin);
ed=posixtime(date_end);

switch scale
    case '5min'
        nr_min=5;
    case '30min'
        nr_min=30;
    case '1hour'
        nr_min=60;
    case '1day'
        nr_min=1440;
    case '1week'
        nr_min=10080;
end

start_time=st;
finished=0;
alltimes=[];
allvalues=[];
while ~finished   % loop through all
    end_time=start_time+1024*nr_min*60;
    repeat=0;
    
    %% read only temperature, all data values from ever
    str=[...
        'curl -X GET "https://api.netatmo.com/api/getmeasure?'...
        'device_id=',device_id,...
        '&module_id=',module_id,...
        '&scale=',scale,...
        '&type=',type,...
        '&date_begin=',num2str(start_time),...
        '&date_end=',num2str(end_time),...
        '&optimize=false'...
        '&real_time=false"',...
        ' -H "accept: application/json"'...
        ' -H "Authorization: Bearer ',bearer,...
        '"'];
    [~,cout] = system(str);
    
    
    
    
    %     pp='curl -X GET "https://api.netatmo.com/api/getmeasure?device_id=70:ee:50:1f:6d:26&module_id=02:00:00:63:12:82&scale=30min&type=temperature&optimize=false&real_time=false" -H "accept: application/json" -H "Authorization: Bearer 540a0aaa1877593db6a9271a|7e2cf74cfd71a12cb46ef99ef1b6414d"';
    %     [~,cout2] = system(pp);
    %
    
    if contains(cout,'Invalid access token') || contains(cout,'Access token expired')
        error('needed to create new access token!');
    else
        if contains(cout,'error')
            repeat=1;
            disp('server error, repeat');
        end
    end
    
    if ~repeat
        
        [times, values]=parseweather(cout);
        alltimes=[alltimes, times];
        allvalues=[allvalues, values];
        
        start_time=end_time+nr_min*60;
        if start_time>ed
            finished=1;
        end
    end
end

return