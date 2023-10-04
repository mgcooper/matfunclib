
%% plot into an axis

f = figure;
s(1) = subplot(1, 2, 1);
plot(x, y, 'k')
s(2) = subplot(1, 2, 2)
plot(x, y, 'k')
fillplot(x, y, e, c, s(1), "FaceAlpha", 0.35)

%% fillplot respects the hold state of each axes

f = figure;
s(1) = subplot(1, 2, 1);
plot(x, y, 'k'); hold on;
s(2) = subplot(1, 2, 2)
plot(x, y, 'k')
fillplot(x, y, e, c, s(1), "FaceAlpha", 0.35)

%% Plot into a figure

f1 = figure;
plot(x, y, 'k'); hold on;

f2 = figure;
plot(x, y, 'k'); hold on;

fillplot(x, y, e, c, f1, "FaceAlpha", 0.35)

%% Specify an axes or figure to plot into

f = figure;
s(1) = subplot(1, 2, 1);
plot(x, y, 'k'); hold on % without hold on, fillplot resets the axes
s(2) = subplot(1, 2, 2);
plot(x, y, 'k'); hold on
% plot into s(1)
fillplot(x, y, e, c, s(1), "FaceAlpha", 0.35) % fillplot respects the hold state
% plot into s(2), using a different patch color
fillplot(x, y, e, 'orange', s(2), "FaceAlpha", 0.35)

%% See how the hold state affects the behavior

f = figure;
s(1) = subplot(1, 2, 1);
plot(x, y, 'k'); 
s(2) = subplot(1, 2, 2);
plot(x, y, 'k')
% plot into s(1)
fillplot(x, y, e, c, s(1), "FaceAlpha", 0.35) 
% plot into s(2), using a different patch color
fillplot(x, y, e, 'orange', s(2), "FaceAlpha", 0.35)
% plotting into s(1) using built-in 'plot' resets the plot unless hold on is set
plot(s(1), x, y, 'm') % plot resets s(1)

% Instead, set hold on:
f = figure;
s(1) = subplot(1, 2, 1);
plot(x, y, 'k'); 
hold on
s(2) = subplot(1, 2, 2);
plot(x, y, 'k')
% plot into s(1)
fillplot(x, y, e, c, s(1), "FaceAlpha", 0.35) 
% plot into s(2), using a different patch color
fillplot(x, y, e, 'orange', s(2), "FaceAlpha", 0.35)
% plotting into s(1) using built-in 'plot' resets the plot unless hold on is set
plot(s(1), x, y, 'm') % plot resets s(1)



