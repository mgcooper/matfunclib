% the bioinformatics toolbox has a false discoverey rate method the
% function is mafdr.m

% [fdr, q, pi0, rs] = mafdr(p, varargin)

% in general, the toolbox has lots of other potentially useful functions
% e.g. check 'randfeatures'


%{ 
problems with tables. say you have a large dataset, and you perform group
summary calculations. Then you define a new group, and perform group
summaries that are now groups of the first set of groups. The mean and
standard deviation are not the same as the mean/standard deviation of the
true group, meaning all the individual samples within the second-level
groups

%}

clean

% next step: pick which meta vars to add to groupings
save_data   = false;
rmnans      = true;
rmouts      = true;

p.data  = '/Users/coop558/mydata/interface/recession/K_values/';
p.meta  = '/Users/coop558/mydata/interface/recession/metadata/';
p.save  = '/Users/coop558/mydata/interface/recession/K_values/';

% the problem with groupsummaries is that you can end up taking the mean of
% the population, and then taking another mean, which masks the true 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% load the data, convert to table, remove nan, remove outliers
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load([p.data 'K_event_sept']);
load([p.meta 'metaRHBN']); meta = metaRHBN; clear metaRHBN;
% load([p.meta 'metadata'],'meta1879'); meta = meta1879; clear meta1879;

%% convert to table
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
T           = struct2table(K); clear K
T.order     = [];
T.method    = categorical(T.method);
T.deriv     = categorical(T.deriv);
T.station   = categorical(T.station);
T.year      = categorical(T.year);
T.event     = categorical(T.event);

%% remove nans
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
groupvars   = {'station','year','event'};
datavars    = {'b','a'};
if rmnans == true
    T = rmnanbygroup(T,groupvars,datavars); % 4682 nans (equal ols/mle)
end

% 118320 total, 59608 nans in the new dataset! need to figure out why 

%% remove outliers
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
groupvars   = {'station','method','deriv'};
datavars    = 'b';
method      = 'quartiles';
if rmouts == true
    T = rmoutliersbygroup(T,groupvars,datavars,method); % 675 for 'quartiles'
end

% 2603 outliers in the new dataset

% remove negative b values
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% sum(T.b<0)  % 454 b values < 0, or 29 after outlier removal

%% add latitude and other metadata to T
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
meta.station    = categorical(meta.station);
jvars           = {'lat','lon','darea','fracna','prec','airt',          ...
                                    'snow','perm','remark','RHBN_N'};
T               = innerjoin(T,meta, 'Keys','station',                   ...
                                    'RightVariables',jvars);
T.year          = double(T.year);
years           = unique(T.year); clear meta


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% build groupings
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

K       = T(T.method=='mle' & T.deriv=='ETS',:); clear T
years   = [K.year];
lats    = [K.lat];
stats   = {'mean','median','std'};
vars    = {'b','a','rsq','lat','lon','darea','fracna','prec',       ...
                                    'airt','snow','perm','year'};

latb    = [(42.5:0.5:69.5)' (45.5:0.5:72.5)'];
yrb     = [(1:67)' (5:71)'];
nlat    = size(latb,1);
nyrs    = size(yrb,1);

% average a,b in each latbin for each year, and then move
    % over the years and regress the trend
    
% I need to get all events within the bin, meaning all stations, all
    % events, and average over them
    
for i = 1:nlat
    
    Ki  = K(lats>=latb(i,1)&lats<latb(i,2),:);
    Kg  = groupsummary(Ki,'year',{'mean','std'},{'a','b'});
    % Kg has average a/b values for each year within this latitude bin,
    % meaning the events for each statioin are already averaged, so 
    
%     atest = 
    
    % to get the sample standard deviation of each lat / year bin, I either
    % need to move groupsummery into the nyrs loop and add the year bins,
    % or pull out the raw data above
    
    for j = 1:nyrs
        
        % one method
        ybins   = [yrb(j,1), yrb(j,2)];
        Kgj     = groupsummary(Ki,'year',ybins,{'mean','std'},{'a','b'});
        
        % but I think this is better
        Kji     = Ki(Ki.year>=yrb(j,1) & Ki.year<=yrb(j,2),:);
        
        
        Sa(i,j) = std(Kji.a);
        Sb(i,j) = std(Kji.b);
        Ua(i,j) = mean(Kji.a); % compare these with Kj below
        Ub(i,j) = mean(Kji.b);
        

        Kj      = Kg(Kg.year>=yrb(j,1) & Kg.year<=yrb(j,2),:);
        a(i,j)  = mean(Kj.mean_a);
        b(i,j)  = mean(Kj.mean_b);
        astd(i,j)  = std(Kj.mean_a);
        bstd(i,j)  = std(Kj.mean_b);
        N1(i,j) = length(Kj.mean_a);
        N2(i,j) = sum(Kj.GroupCount);
    end
end








% for overlapping bins, the method below would work, except the categorical
% bin variables disc_lat and disc_year are ordinal and so they cannot be
% concatenatied

% this might help
% test    = discretize(Ki.b,Ki.lat,lbins);

k = 0;        
for i = 1:nlat
    
    Ki  = K(lats>=latb(i,1)&lats<latb(i,2),:);
    
    lbins   = [latb(i,1), latb(i,2)];
    Kgi     = groupsummary(Ki,'lat',lbins,{'mean','std'},{'a','b'});
    Kgi.key = 1;
    
    for j = 1:nyrs
        ybins   = [yrb(j,1), yrb(j,2)]; k = k+1;
        Kgj     = groupsummary(Ki,'year',ybins,{'mean','std'},{'a','b'});
        Kgj     = Kgj(1,:); Kgj.key = 1;
        Kij     = innerjoin(Kgi,Kgj,'Keys','key','LeftVariables','disc_lat');
        Kg(k,:) = Kij;
%         if i==1 && j==1; Kg  = Kij; else; Kg = [Kg;Kij]; end
    end
end


ybins   = [yrb(j,1), yrb(j,2)];
        Kgj     = groupsummary(Ki,'year',ybins,{'mean','std'},{'a','b'});
        Sa2(i,j) = Kgj.std_a(1);
        Sb2(i,j) = Kgj.std_b(1);
        Ua2(i,j) = Kgj.mean_a(1);
        Ub2(i,j) = Kgj.mean_b(1);
        N2(i,j)  = Kgj.GroupCount(1);
        % using this method requires checking if the first row is the
        % disc_year we want, b/c if there are no samples in that bin, it
        % only returns the values for all the other years, so it's better
        % to just use the method below
        
        Sa(i,j) = std(Kgj.mean_a);
        Sb(i,j) = std(Kgj.b);
        Ua(i,j) = mean(Kgj.a); % compare these with Kj below
        Ub(i,j) = mean(Kgj.b);
        
        
