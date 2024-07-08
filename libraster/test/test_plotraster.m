% test script for plotraster
clearvars
close all
clc

% Load test data
[X, Y, Z, R] = defaultGridData();

%% test with Z input
figure(1)
plotraster(Z, gca(figure(1)))

%% test with Z and R input
figure(2)
plotraster(Z, R, gca(figure(2)))

%% test with Z X Y input
figure(3)
plotraster(Z, X, Y, gca(figure(3)))

%% test with Z input and axis type "equal"
figure(1)
plotraster(Z, gca(figure(1)), "equal")
plotraster(Z, "equal", gca(figure(1)))

plotraster(Z, gca(figure(1)), "normal")
plotraster(Z, "normal", gca(figure(1)))

%% test with Z and R input and axis type
figure(2)
plotraster(Z, R, gca(figure(2)), "normal")
plotraster(Z, R, "normal", gca(figure(2)))

plotraster(Z, R, gca(figure(2)), "equal")
plotraster(Z, R, "equal", gca(figure(2)))

%% test with Z X Y input and axis type "normal"
figure(3)
plotraster(Z, X, Y, gca(figure(3)), "normal")
plotraster(Z, X, Y, "normal", gca(figure(3)))

plotraster(Z, X, Y, gca(figure(3)), "equal")
plotraster(Z, X, Y, "equal", gca(figure(3)))





