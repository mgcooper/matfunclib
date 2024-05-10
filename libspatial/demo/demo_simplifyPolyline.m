% Example Problems to illustrate working of simplifyPolyline()
% author Naveen Somasundaram, November 2021

%% Example #1
% Sine curve with noise
tol    = 1;
x      = 1:0.1:8*pi;
y      = sin(x) + randn(size(x))*0.1;
p      = [x' y'];
q = simplifyPolyline(p, tol);

figure
hold on
box on
plot(p(:,1), p(:,2), '-b.');
plot(q(:,1), q(:,2),'-ko');
hold off
axis equal;
legend(sprintf('original - %d points', size(p, 1)), sprintf('simplified - %d points', size(q, 1)))


%% Example #2
% Square shape with multiple points; When del = 0 the points are collinear and
% the simplification will return the simplest 5 point polyline.
tol = 1;
nP = 50; %Points per side
x = [repmat(-1, nP, 1); linspace(-1, 1, nP)'; repmat(1, nP, 1); linspace(1, -1, nP)'];
y = [linspace(-1, 1, nP)'; repmat(1, nP, 1);  linspace(1, -1, nP)'; repmat(-1, nP, 1)];

del = 0; % For exmaple set to 5e-3 to introduce some nouise in the shape
x = x + randn(size(x)) * del;
y = y + randn(size(y)) * del;

p      = [x y];
q = simplifyPolyline(p, tol);

figure
hold on
box on
plot(p(:,1), p(:,2), '-b.');
plot(q(:,1), q(:,2),'-ko');
hold off
axis equal;
legend(sprintf('original - %d points', size(p, 1)), sprintf('simplified - %d points', size(q, 1)))




