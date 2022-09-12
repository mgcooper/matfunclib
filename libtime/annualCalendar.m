function calendar = annualCalendar(year,varargin)
    
    % varargin is either dt as a datetime or a string describing dt
    
    dt  = varargin{1};
    
    if isduration(dt) % assume it's the timestep
        
        dt  = hours(dt);
        
        if dt==24
            
            t1  = datetime(year,1,1);
            t2  = datetime(year,12,31);
            dt  = caldays(1);
            
        else
            
            t1  = datetime(year,1,1,0,0,0);
            t2  = datetime(year,12,31,24-dt,0,0);
            
            dt  = hours(dt);
        end
        
    else
       
        
        switch dt

            case {'daily','day'}
                
                t1  = datetime(year,1,1);
                t2  = datetime(year,12,31);
                dt  = caldays(1);

            case {'hourly','hour'}
                t1  = datetime(year,1,1,0,0,0);
                t2  = datetime(year,12,31,23,0,0);
                dt  = hours(1);

        end
        
    end

    calendar = t1:dt:t2;
    calendar = calendar(:);
    