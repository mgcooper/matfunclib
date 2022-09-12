function [ data_filtered,indices ] = sdfilter( data, ...
                                            N_deviations, M_passes)

tolerance       =   N_deviations;
data_filtered   =   data;

for i = 1:M_passes
    
    mu(i)       =   nanmean(data_filtered);
    sigma(i)    =   nanstd(data_filtered);
    tol         =   repmat(tolerance*sigma(i),length(data),1);
    outliers{i} =   find(abs(data_filtered-mu(i)) > tol);     %#ok<*AGROW,SAGROW>
    
    % set outliers to nan
    data_filtered(outliers{i})   =   nan;
   
end


end

