function [ data_filtered,pct_filtered,indices ] = stdv_filter( data, t, ...
               timestep, N_deviations, M_passes, no_data)
% STDV_FILTER filters out data beyond N standard deviations. Performs M
% repeat passes to correct for the sensitivity of the stdv to outliers. 
% Data will be returned in no-leap format. Computes the standard
% deviation for the provided timestep - 1 for daily, 2 for monthly i.e. if
% user provided daily, then the data is binned into each day of the year
% and the statistics are computed on the bins. If provided, the no_data
% value is set to nan;

[rows,cols]     =   size(data); %#ok<*ASGLU>

tolerance       =   N_deviations;

if cols>rows    
    data = data';
    disp('time should be in the column direction - transposing input');
end

data_filtered   =   data;

num_nan_before  =  sum(isnan(data_filtered),1);

% set the no-data values to nan
nod_inds                    =   data == no_data;
data_filtered(nod_inds)     =   nan;

switch timestep
    case 1
        t_ind       =   6;  % daily 
        timesteps   =   unique(t(:,t_ind));
    case 2
        t_ind       =   2;  % monthly
        timesteps   =   unique(t(:,t_ind));
end

% check for leap years
if timesteps == 366
    data_filtered    =   rmleapinds(data_filtered,t);
end

% update July 2020 = convert t to datetime object
if ~isdatetime(t)
    t               =   datetime(t(:,7));

for i = 1:M_passes
    for n = 1:cols
        for m = 1:length(timesteps)

            inds            =   find(t(:,t_ind) == m);
            mu(m,n,i)       =   nanmean(data_filtered(inds,n));
            sigma(m,n,i)    =   nanstd(data_filtered(inds,n));
            tol             =   repmat(tolerance*sigma(m,n,i),length(inds),1);
            outliers{m,n,i} =   find(abs(data_filtered(inds,n) - ...
                                                        mu(m,n,i)) > tol);     %#ok<*AGROW,SAGROW>

            % but the outliers indices are in reference to the length of group
            % of monthly values, not the original timeseries

            outliers{m,n,i}                     =   inds(outliers{n,m});
            data_filtered(outliers{n,m,i}(:),n) =   NaN; %#ok<FNDSB>
        end
    end
end

num_nan_after   =   sum(isnan(data_filtered),1);   

pct_filtered    =   100.*(num_nan_after - num_nan_before)./(rows*cols);

indices         =   outliers';

end

