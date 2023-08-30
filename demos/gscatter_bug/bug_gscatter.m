x = 1:5;
y = 1:5;
c = categorical(1:5);
gscatter(x, y, c, [], 's'); % works
gscatter(x, y, c, [], 'square'); % fails


x = 1:5;
y = 1:5;
c = categorical(1:5);
symbols = {'square','hexagram','diamond','pentagram'};

figure;
for n = 1:numel(symbols)
   s = symbols{n};
   gscatter(x, y, c, [], s(1));
   % gscatter(x, y, c, [], s);
end
