
% when synchronizing, i think its best to first get the different
% timetables on a regular timestep, then use sycnhronize with
% 'fillwithmissing', otherwise if on different timesteps, you have to
% specificy an interpolation method with synchronize, and it seems to
% extrapolate buy default:
Flow     =  retime(FlowM,'yearly','mean');
Grace    =  retime(GraceM,'yearly','mean');
Data     =  synchronize(GraceM,FlowM,'fillwithmissing');

% for each of the 'fun' files, need a function that opens them, and also
% opens the documentation 

% operate on rows of a table
B = rowfun(func,A)
B = rowfun(func,A,Name,Value)

% need to start collecting arcane table/structure methods, see below for
% passing varargin to @func, didn't know that was possible

% Patient pateint data
load patients
% Create test table
T = table(Gender(1:5), Height(1:5), 'VariableNames', {'Gender', 'Height'});
% Group based on first column - gender column
% Modify 1 to appropriate column number
G = findgroups(T{:, 1});
% Split table based on first column - gender column
T_split = splitapply( @(varargin) varargin, T , G);
% Allocate empty cell array fo sizxe equal to number of rows in T_Split
subTables = cell(size(T_split, 1));
% Create sub tables
for i = 1:size(T_split, 1)
    subTables{i} = table(T_split{i, :}, 'VariableNames', ... 
                        T.Properties.VariableNames);
end
% Display Results
disp('Full Table:');
disp(T);
disp('Sub Table 1:');
disp(subTables{1});
disp('Sub Table 2:');
disp(subTables{2});


% emove 'Fun_' after varfun
R.Properties.VariableNames=regexprep(R.Properties.VariableNames,    ...
        'Fun_', '');
    
    
    
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% this was originally table_tricks, moving to _fun
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    
    
% i doubt this will be decipherble, but at the end of this I brute forced
% logic to determine that a series of innerjoins and ~ismember checks could
% be used to find values UNCOMMMON to a set of tables, since join
% operations only give commmon values

clean
save_data   = true;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% set paths
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
p.data  = '/Users/coop558/mydata/interface/recession/metadata/';
p.save  = '/Users/coop558/mydata/interface/recession/metadata/';
p.gages = '/Users/coop558/mydata/interface/recession/gagesII/shp/';

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% add the HyDAT regulated/unregulated information and gages II
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load([p.data 'metadata.mat'],'meta1879'); meta = meta1879; clear meta1879;
gages       = shaperead([p.gages 'gagesII_9322_sept30_2011.shp']);
gages       = struct2table(gages);
rhbn1999    = readtable([p.data 'RHBN_1999.xlsx']);
rhbn        = readtable([p.data 'RHBN_2020.xlsx']);
hynat       = readtable([p.data 'gages_unregulated.xlsx']);
hyreg       = readtable([p.data 'gages_regulated.xlsx']);

% rename 'station' field in all tables
rhbn1999    = renamevars(rhbn1999,'STATION_NUMBER','station');
rhbn        = renamevars(rhbn,'STATION_NUMBER','station');
hynat       = renamevars(hynat,'StationNumber','station');
hyreg       = renamevars(hyreg,'StationNumber','station');
gages       = renamevars(gages,'STAID','station');

% convert to categorical
rhbn1999    = convertvars(rhbn1999,'station','categorical');
rhbn        = convertvars(rhbn,'station','categorical');
meta        = convertvars(meta,'station','categorical');
hynat       = convertvars(hynat,'station','categorical');
hyreg       = convertvars(hyreg,'station','categorical');
gages       = convertvars(gages,'station','categorical');

% find rhbn1999 that are also in 

% separate rhbn into -N and -U
rhbnN       = rhbn(rhbn.RHBN_N==1,:);       % 318 'national'
rhbnU       = rhbn(rhbn.RHBN_N==0,:);       % 709 'unbalanced'

% gages in rhbn1999, hynat, and hyreg that are NOT in rhbn2020, or in each
% other, keep rhbn1999 and rhbn unique, removing duplicates from hynat/reg
rhbn1999    = rhbn1999(~ismember(rhbn1999.station,rhbn.station),:); % 48
hyreg       = hyreg(~ismember(hyreg.station,rhbn.station),:);       % 3477
hyreg       = hyreg(~ismember(hyreg.station,rhbn1999.station),:);   % 3463
hynat       = hynat(~ismember(hynat.station,rhbn.station),:);       % 3874
hynat       = hynat(~ismember(hynat.station,rhbn1999.station),:);   % 3841

% whittle gages down to AK
gages       = gages(ismember(gages.AGGECOREGI,'Alaska'),:); % 87 gages
gagesnat    = gages(ismember(gages.CLASS,'Ref'),:);         % 67 ref
gagesreg    = gages(ismember(gages.CLASS,'Non-ref'),:);     % 20 non-ref
metagages   = innerjoin(meta,gages,'Keys','station');       % 62 in meta
metagagesnat = innerjoin(meta,gagesnat,'Keys','station');   % 51 ref
metagagesreg = innerjoin(meta,gagesreg,'Keys','station');   % 11 non-ref

% repeat for rhbn
metarhbn    = innerjoin(meta,rhbn,'Keys','station');        % 769 in meta
metarhbnU   = innerjoin(meta,rhbnU,'Keys','station');       % 519 unbalanced
metarhbnN   = innerjoin(meta,rhbnN,'Keys','station');       % 250 national
metarhbn1999= innerjoin(meta,rhbn1999,'Keys','station');    % 32 in meta

% repeat for hydat
metahyreg   = innerjoin(meta,hyreg,'Keys','station');       % 606 in meta
metahynat   = innerjoin(meta,hynat,'Keys','station');       % 370 in meta

% then there are 67-51=16 reference gagesII gages that aren't in meta, and
% 318-250=68 rhbn-N gages, and 709-519=190 rhbn-U gages that aren't in meta

% rhbn + rhbn1999 + gages + hyreg + hynat = 1839
% 769+32+62+606+370 = 1839 gages, leaving 1879-1839 = 40 unaccounted for

% we want each table to be unique, check for uniquness
idx         = ismember(rhbn.station,gages.station); sum(idx)
idx         = ismember(rhbn.station,rhbn1999.station); sum(idx)
idx         = ismember(rhbn.station,hynat.station); sum(idx)
idx         = ismember(rhbn.station,hyreg.station); sum(idx)
idx         = ismember(gages.station,rhbn.station); sum(idx)
idx         = ismember(gages.station,hynat.station); sum(idx)
idx         = ismember(gages.station,hyreg.station); sum(idx)
idx         = ismember(gages.station,rhbn1999.station); sum(idx)
idx         = ismember(hynat.station,hyreg.station); sum(idx)
idx         = ismember(hynat.station,rhbn1999.station); sum(idx)
idx         = ismember(hyreg.station,rhbn1999.station); sum(idx)

% this is confusing because it says there are 40 gages that are not in meta
% OR rhbn, rhbn1999, gages, hynat, and hyreg, but the steps above confirm
% there are all but 8 gages accounted for
tmp         = unique(vertcat(rhbn.station,rhbn1999.station,             ...
                        gages.station,hynat.station,hyreg.station));
idxout      = ~ismember(meta.station,tmp); sum(idxout)
idxin       = ismember(meta.station,tmp); sum(idxin)
tmp         = meta(idxout,:);

% of the 40 that are 'out', how many are in gages?
tmp2        = innerjoin(tmp,gages,'Keys','station'); height(tmp2)
% none, as expected, check the others
tmp2        = innerjoin(tmp,hynat,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,hyreg,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,rhbn,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,rhbn1999,'Keys','station'); height(tmp2)

% check the ones that are already subsets of the main ones above
tmp2        = innerjoin(tmp,metagages,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,metagagesnat,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,metagagesreg,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,metahynat,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,metahyreg,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,metarhbn,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,metarhbn1999,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,metarhbnN,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,metarhbnU,'Keys','station'); height(tmp2)

% this confirms there are 32 rhbn1999 gages in meta, and none are in rhbn
idx         = ismember(meta.station,rhbn1999.station); sum(idx)
idx         = ismember(rhbn.station,rhbn1999.station); sum(idx)

% check for uniqueness
tmp         = unique(meta.station); height(meta)-length(tmp)
tmp         = unique(rhbn.station); height(rhbn)-length(tmp)
tmp         = unique(rhbn1999.station); height(rhbn1999)-length(tmp)
tmp         = unique(hynat.station); height(hynat)-length(tmp)
tmp         = unique(hyreg.station); height(hyreg)-length(tmp)
tmp         = unique(gages.station); height(gages)-length(tmp)

tmp2        = innerjoin(tmp,rhbn,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,rhbn1999,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,gages,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,hynat,'Keys','station'); height(tmp2)
tmp2        = innerjoin(tmp,hyreg,'Keys','station'); height(tmp2)    
    
    