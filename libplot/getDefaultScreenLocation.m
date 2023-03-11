function location = getDefaultScreenLocation(w)

if nargin < 1
   w = com.mathworks.mde.array.ArrayEditor.DEFAULT_SIZE.width;
end

ssize = get(0,'ScreenSize');
% center left to right, top edge 1/3 from top of screen
screenWidth = ssize(3);
screenHeight = ssize(4);
targetPoint = [screenWidth / 2 screenHeight / 3];
x = targetPoint(1) - w / 2;
y = targetPoint(2);
location = [x y];

end