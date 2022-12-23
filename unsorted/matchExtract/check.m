cigPath = 'C:\Users\coopemat\Documents\MATLAB\Snowmodel\CIG\';
prismPath = 'C:\Users\coopemat\Documents\MATLAB\prism\';

load([prismPath 'prism_monthly_data']);
load ([prismPath 'prismCoords']);
load ([cigPath 'bias_correction\monthly\cig_monthly_temp_grids']);
load ([cigPath 'cigCoords']);

arcgridwrite2('prism.asc',pX,pY,prism_tdmean_monthly(:,:,1),'precision',4);
arcgridwrite2('cig.asc',cigX,cigY,cig_monthly_temp(:,:,1),'precision',4);

cig1temp = cig_monthly_temp(:,:,1);
prism1temp = prism_tdmean_monthly(:,:,1);

fname1 = 'C:\Users\coopemat\Documents\MATLAB\myFunctions\matchExtract\prism.asc';
fname2 = 'C:\Users\coopemat\Documents\MATLAB\myFunctions\matchExtract\cig.asc';

averagetemp = gridAverage(fname1,fname2);

factors1temp = averagetemp - cig1temp;

corrected1temp = cig1temp + averagetemp;