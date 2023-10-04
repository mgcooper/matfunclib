function T = rmnanbygroup(T,groupvars,datavars)
    
    % this finds occurrences of datavars that are nan, checks the value of
    % each of groupvars at that occurence, and sets all other indices with
    % the same groupvars nan. This is desirable if you have a table of
    % experimental results, and if a trial of one group is nan, it is
    % important to set the corresponding trial of all other groups nan
    
    % notes specific to recession:
    % for nan removal, we want any event at one station that yields nan for
    % any method to be set nan across all other methods for that event at
    % that station. by grouping by station/year/event, rmnanbygroup finds
    % all nan b values, and then finds all other indices with the same
    % station/year/event, and sets them nan

    if ~iscell(datavars) 
        if ischar(datavars)
            datavars = cellstr(datavars);
        else
            % need to exit
        end 
    end
    
    if ~iscell(groupvars)
        if ischar(groupvars)
            datavars = cellstr(datavars);
        else
        end
    end
        
    
    T       = sortrows(T,groupvars);
    Tnan    = varfun(@isnan,T,  'InputVariables',       datavars,       ...
                                'GroupingVariables',    groupvars       );
    Tnan    = sortrows(Tnan,groupvars);
    
    % if there are multiple datavars, need to get all unique nan inds
    i1      = T(:,groupvars);
    i2      = [];
    for i = 1:length(datavars)
        i2  = [i2;find(Tnan.(['isnan_' datavars{i} ]))];
    end
    i2      = T(unique(i2),groupvars);
    i3      = ismember(i1,i2);
    T(i3,:) = [];
    
    % this is how I had it with one datavar
    % i2  = unique(T(Tnan.(['isnan_' datavars{1} ]),groupvars));
    
    % if one knew the number of unique sets , they could substitue it for 8
%     icheck      = sum(i3)-height(i2)*8; %8=nmethods*nderiv;

end
