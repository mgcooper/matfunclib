function [ mae ] = mean_error( observed, predicted )
%MEAN_ERROR computes the mean absolute error
%   Detailed explanation goes here

mae     =   nansum(predicted-observed)/sum(~isnan(predicted),1);
end

