function T = rmoutliersbygroup(T,groupvars,datavars,method)

    if ~iscell(datavars) 
        if ischar(datavars)
            datavars = cellstr(datavars);
        else
%             T = []; return; % need to exit
        end 
    end
    
    if ~iscell(groupvars)
        if ischar(groupvars)
            datavars = cellstr(datavars);
        else
        end
    end
        
    func    = @(x) isoutlier(x,method);
    T       = sortrows(T,groupvars);
    Tnan    = varfun(func,T,    'InputVariables',       datavars,       ...
                                'GroupingVariables',    groupvars       );
    Tnan    = sortrows(Tnan,groupvars);
    
    % if there are multiple datavars, need to get all unique nan inds
    i2      = [];
    for i = 1:length(datavars)
        i2  = [i2;find(Tnan.(['Fun_' datavars{i} ]))];
    end
    i2      = unique(i2);
    T(i2,:) = [];
    
    % here, unlike rmnanbygroup, we don't want to remove all the values
    % that match groupvars, since we only want to remove outliers within
    % groups. I should probably change the function name to
    % rmnanacrossgroups and rmoutlierswithingroups
    
    % additioanl notes:
    % compare the first 10 rows of Tnan and T to make sure they are sorted
    %     test1 = T(1:10,{'method','deriv','event','year','station'});
    %     test2 = Tnan(1:10,{'method','deriv','station'});
    % note - because Tnan only has 'groupvars', I can only use the overlapping
    % vars, but I checked outside this function by using the full set of
    % groupvars and this confirms the sorting is identical:
    % test1 = T(:,{'method','deriv','event','year','station'});
    % test2 = Tnan(:,{'method','deriv','event','year','station'});
    % isequal(test1,test2)
    
    % for reference:
%     TG          = T(:,{'method','deriv'});
%     [G,~]       = findgroups(TG);
%     b_outliers  = splitapply(@(x){isoutlier(x)},T.b,G);
    

end

