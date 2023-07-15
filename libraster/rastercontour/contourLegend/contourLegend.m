function [hLeg, levMat] = contourLegend(hCont, txtCont, locLeg, hOther, ...
  txtOther, posOther)
% [hLeg, levMat] = contourLegend(hCont, txtCont, locLeg, hOther, txtOther, ...
%   posOther)
% Adds a curve description legend to a contour plot. The default description is
% the level, but you may optionally supply custom descriptions. You might also
% include descriptions of other plotted objects in the legend.
%
% INPUT:
% hCont    - a handle, or a vector of handles, to contour object(s) in the same
%            plot.
% txtCont  - an optional cell vector with strings that describes the curves,
%            should have as many items as levels ("type" = 'curves') and fill
%            intervals ("type" = 'filled'). Default descriptions are the curve
%            levels and fill intervals. Use the function with the "locLeg"
%            option 'notdrawn' to get the current levels and fill intervals from
%            "levMat".
% locLeg   - an optional string with the location of the legend. For available
%            options see help for "legend". Also supported is 'notdrawn' that
%            will not add a legend. Default is 'best'.
% hOther   - an optional handle, or a vector of handles, to other graphics
%            objects in the plot that you want to include in the legend.
%            Default is empty.
% txtOther - an optional cell vector with strings that describes the other
%            items above. Must be supplied if "hOther" is given and have as
%            many items as the length of "hOther". Default is empty.
% posOther - an optional string 'b(efore)' or 'a(fter)' that determines if the
%            description of other graphic objects comes before or after the
%            descriptions of the contours in the legend. Default is 'after'.
% 
% OUTPUT:
% hLeg     - a handle to the legend object. Use this to change the position,
%            fonts etc. for the legend.
% levMat   - a two column matrix with the contour levels limits in each row.
%            Equal limits indicate a contour curve and unequal a filled area.
%
% NOTE 1: The colors for the contours in the legend will NOT be updated if they
%         are changed in the plot, for example by changing the color map. It is
%         recommended that the legend is added after all plotting is done.
% NOTE 2: There is a strange bug, at least in R2020a. The contour levels
%         shown in the tooltip, if you click on a contour curve, will not the
%         match the levels in the legend (and the ones returned in the contour
%         data matrix).
%
% EXAMPLE:
% [X, Y, Z]  = peaks(512);
% figure
% [~, hCont] = contour(X, Y, Z, 'LineWidth', 1.5);
% contourLegend(hCont)
% figure
% [~, hCont] = contourf(X, Y, Z);
% contourLegend(hCont)
%
% See also contour, contourf, clabel, legend
%
% Version 1.1, 2022. Patrik Forssén, Karlstad University.

% Version History
% Version 1.1: Remove type and used hidden property instead
 
% Default input
if (nargin < 2), txtCont   = []; end
if (nargin < 3 || isempty(locLeg))  , locLeg   = 'best' ; end
if (nargin < 4), hOther   = []; end
if (nargin < 5), txtOther = []; end
if (nargin < 6 || isempty(posOther)), posOther = 'after'; end
 
% Default output
hLeg = [];
 
% Check input
hCont   = hCont(:);
hOther  = hOther(:);
[hAx, locLeg, hOther, txtOther, posOther] = checkInput(...
  hCont, txtCont, locLeg, hOther, txtOther, posOther);
 
% Get contour curve specification
curveSpec = contourCurves(hCont);
 
% Set 'flat' to a color specification
curveSpec = flat2color(hAx, curveSpec);
 
% Get handles to curve specification invisible dummy lines or patches
[hCurve, txtCurve, levMat] = getCurveHandles(hAx, curveSpec, txtCont);
 
% Draw legend
if (~strcmp(locLeg, 'notdrawn'))
  hLeg = drawLeg(hAx, locLeg, hCurve, txtCurve, hOther, txtOther, posOther);
end
 
% Output
if (nargout == 0)
  clear hLeg
end
 
end
 
 
 
function hLeg = drawLeg(hAx, locLeg, hCurve, txtCurve, hOther, txtOther, ...
  posOther)
 
hItem   = hCurve;
txtItem = txtCurve;
if (~isempty(hOther))
  % Add
  switch posOther
    case 'before'
      hItem   = [hOther  ; hItem];
      txtItem = [txtOther; txtItem];
    case 'after'
      hItem   = [hItem  ; hOther];
      txtItem = [txtItem; txtOther];
  end
end
 
% Draw the legend
hLeg = legend(hAx, hItem, txtItem, 'Location', locLeg);
 
end
 
 
 
function [hCurve, txtCurve, levMat] = getCurveHandles(hAx, curveSpec, ...
  txtCont)
 
% Function name
funName = mfilename;
 
% Number of curves
nCurves  = size(curveSpec, 1);
% Unique levels
unLev  = unique(cell2mat(curveSpec(:, 1)));
levMat = [];
for curveNo = 1 : nCurves
  currLev  = curveSpec{curveNo, 1};
  currType = curveSpec{curveNo, 5};
  switch currType
    case 'curves'
      levMat = [levMat; currLev, currLev];
    case 'filled'
      currLevInd = find(unLev == currLev, 1, 'first');
      if (currLevInd == length(unLev))
        levMat = [levMat; currLev, inf];
      else
        levMat = [levMat; currLev, unLev(currLevInd+1)];
      end
  end
end
levMat = unique(levMat, 'rows');
levMat = sortrows(levMat, [1 2]);
 
% Make a default text cell
unLevCell = cell(size(levMat, 1), 1);
for levNo = 1 : size(levMat, 1)
  currInt = levMat(levNo, :);
  if (currInt(1) == currInt(2))
    unLevCell{levNo} = num2str(currInt(1));
  else
    if (~isfinite(currInt(2)))
      unLevCell{levNo} = ['> ', num2str(currInt(1))];
    else
      unLevCell{levNo} = [num2str(currInt(1)), ' to ', num2str(currInt(2))];
    end
  end
end
 
% Check legTxt if supplied
nUn = size(levMat, 1);
if (~isempty(txtCont))
  if (length(txtCont) > nUn)
    warnStr = ['Input 3, "txtCont", contains to many strings (should ', ...
      'contain ', num2str(nUn), '). Extra entries will be ignored'];
    warning([funName, ':TooManyStrings'], warnStr)
    txtCont = txtCont(1:nUn);
  elseif (length(txtCont) < nUn)
    warnStr = ['Input 3, "txtCont", contains too few strings (should ', ...
      'contain ', num2str(nUn), '). Will use default for missing items'];
    warning([funName, ':TooFewStrings'], warnStr)
    txtCont(end+1:nUn) = unLevCell(length(txtCont)+1:end);
  end
else
  % Default
  txtCont = unLevCell;
end
 
% Plot dummy lines/patches
hold(hAx, 'on');
txtCurve = cell(nCurves, 1);
hCurve   = gobjects(nCurves, 1);
nanVec   = [NaN, NaN, NaN, NaN];
for curveNo = 1 : nCurves
  currCurve = curveSpec(curveNo, :);
  currLev   = currCurve{1};
  switch currCurve{5}
    case 'curves'
      levInd = find(levMat(:, 1) == currLev & levMat(:, 2) == currLev, ...
        1, 'first');
      hCurve(curveNo) = plot(hAx, NaN, 'LineStyle', currCurve{2}, ...
        'LineWidth', currCurve{3}, 'Color', currCurve{4});
    case 'filled'
      levInd = find(levMat(:, 1) == currLev & levMat(:, 2) > currLev, ...
        1, 'first');
      hCurve(curveNo) = patch(hAx, nanVec, nanVec, currCurve{4});
  end
  txtCurve{curveNo} = txtCont{levInd};
end
 
end
 
 
 
function curveSpec = flat2color(hAx, curveSpec)

% Unique levels
unLev = unique(cell2mat(curveSpec(:, 1)));
 
% Get color mapping
colMap = hAx.Colormap;
nCol   = size(colMap, 1);
colLim = hAx.CLim;
 
if (length(unLev) == 1)
  % Special, uses the middle color
  colNo = round(nCol/2);
else
  % Linear interpolation
  pp    = polyfit(colLim, [1 nCol], 1);
  colNo = round(polyval(pp, unLev));
end
% Possibly map to last and first color
colNo(unLev < colLim(1))   = 1;
colNo(unLev > colLim(end)) = nCol;
% Safeguard...
colNo(colNo < 1   ) = 1;
colNo(colNo > nCol) = nCol;
 
% Curves with 'flat'
flatInd = find(cellfun(@ischar, curveSpec(:, 4)));
for flatNo = flatInd(:)'
  levNo = find(curveSpec{flatNo, 1} == unLev, 1, 'first');
  curveSpec{flatNo, 4} = colMap(colNo(levNo), :);
end
 
% Only want unique rows
curveSpec = uniqueCellRows(curveSpec);
 
end
 
 
 
function curveSpec = contourCurves(hCont)

% Must be called...
drawnow
 
% Column 1 : level
% Column 2 : LineStyle
% Column 3 : LineWidth
% Column 4 : LineColor ('flat' or RGB triplet)
% Column 5 : type
curveSpec = cell(0, 5);
for objNo = 1 : length(hCont)
  currObj     = hCont(objNo);
  lineStyle   = currObj.LineStyle;
  lineWidth   = currObj.LineWidth;
  if (~isempty(currObj.FacePrims))
    % Undocumented!
    type      = 'filled';
    lineColor = 'flat';
  else
    type      = 'curves';
    lineColor = currObj.LineColor;
  end
  levVec      = currObj.LevelList;
  for levNo = 1 : length(levVec)
    currLev   = levVec(levNo);
    cellRow   = {currLev, lineStyle, lineWidth, lineColor, type};
    curveSpec = [curveSpec; cellRow]; 
  end
end
 
% Only want unique rows
curveSpec = uniqueCellRows(curveSpec);
 
end
 
 
 
function [CU, keepInd, rmMap] = uniqueCellRows(C)
% Get unique cell rows
 
nRows = size(C, 1);
rmMap = 1 : nRows;
rmInd = [];
for refNo = 1 : nRows
  if (ismember(refNo, rmInd)), continue, end
  refRow = C(refNo, :);
  for compNo = refNo+1 : nRows
    if (ismember(compNo, rmInd)), continue, end
    compRow = C(compNo, :);
    if (isequal(refRow, compRow))
      rmInd = [rmInd; compNo];
      rmMap(compNo) = refNo;
    end
  end
end
 
% Trim
keepInd = setdiff(1:nRows, rmInd);
CU = C(keepInd, :);
 
end
 
 
 
%--------------------------------CHECK INPUT------------------------------------
function [hAx, locLeg, hOther, txtOther, posOther] = checkInput(...
  hCont, txtCont, locLeg, hOther, txtOther, posOther)
 
% Function name
funName = mfilename;
 
% 1: hCont
errStr = ['Input 1, "hCont", should be graphic handle(s) to ', ...
  'contour objects in the same plot'];
if (any(~ishandle(hCont)))
  error([funName, ':WrongInput'], errStr)
end
iscontour = @(h) isgraphics(h, 'contour');
if (any(~iscontour(hCont)))
  error([funName, ':WrongInput'], errStr)
end
[res, hAx] = checkSameAxes(hCont);
if (~res)
  error([funName, ':WrongInput'], errStr)
end
  
% 2: txtCont
if (~isempty(txtCont))
  if (ischar(txtCont)), txtCont = {txtCont}; end
  txtCont = txtCont(:);
  errStr  = 'Input 2, "txtCont", should be a cell array with strings';
  tFun    = @(x) ischar(x) & isvector(x);
  if (any(~cellfun(tFun, txtCont)))
    error([funName, ':WrongInput'], errStr)
  end
end
 
% 3: locLeg
validStr = {...
  'north'
  'south'
  'east'
  'west'
  'northeast'
  'northwest'
  'southeast'
  'southwest'
  'northoutside'
  'southoutside'
  'eastoutside'
  'westoutside'
  'northeastoutside'
  'northwestoutside'
  'southeastoutside'
  'southwestoutside'
  'best'
  'bestoutside'
  'none'
  'notdrawn'};
errStr = 'Input 3, "locLeg", should be a valid legend position string';
if (~ischar(locLeg) && ~isvector(locLeg))
  error([funName, ':WrongInput'], errStr)
end
locLeg = validatestring(locLeg, validStr, funName, 'locLeg', 3);
 
% 4: hOther
if (~isempty(hOther))
  errStr = ['Input 4, "hOther", should be graphic handle(s) to ', ...
    'objects in the same plot as the contours'];
  if (any(~ishandle(hOther)))
    error([funName, ':WrongInput'], errStr)
  end
  if (~checkSameAxes(hOther, hAx))
    error([funName, ':WrongInput'], errStr)
  end
  
  % 5: txtOther
  if (ischar(txtOther)), txtOther = {txtOther}; end
  txtOther = txtOther(:);
  errStr   = 'Input 5, "txtOther", should be a cell array with strings';
  tFun     = @(x) ischar(x) & isvector(x);
  if (any(~cellfun(tFun, txtOther)))
    error([funName, ':WrongInput'], errStr)
  end
  if (length(txtOther) > length(hOther))
    warnStr = ['Input 5, "txtOther", contains to many strings (should ', ...
      'contain ', num2str(length(hOther)), '). Extra entries will be ignored'];
    warning([funName, ':TooManyStrings'], warnStr)
    txtOther = txtOther(1:length(hOther));
  elseif (length(txtOther) < length(hOther))
    warnStr = ['Input 5, "txtOther", contains too few strings (should ', ...
      'contain ', num2str(length(hOther)), '). Missing items will be ignored'];
    warning([funName, ':TooFewStrings'], warnStr)
    hOther = hOther(1:length(txtOther));
  end
  
  % 6: posOther
  validStr = {'before', 'after'};
  errStr   = 'Input 6, "posOther", should be string ''before'' or ''after''';
  if (~ischar(posOther) && ~isvector(posOther))
    error([funName, ':WrongInput'], errStr)
  end
  posOther = validatestring(posOther, validStr, funName, 'posOther', 6);
end
 
end
 
 
 
function [res, hAx] = checkSameAxes(hVec, hAx)
% Checks if graphic objects belong to the same axes
 
% Default input
if (nargin < 2), hAx = []; end  % Reference axes
 
hVec    = hVec(:);
axesVec = gobjects(1, length(hVec)+length(hAx));
for objNo = 1 : length(hVec)
  currObj = hVec(objNo);
  while (1)
    parent = currObj.Parent;
    if (strcmp(parent.Type, 'axes'))
      axesVec(objNo) = parent;
      break
    elseif (strcmp(parent.Type, 'root'))
      % All the way up to the root
      res = false;
      return
    end
    currObj = parent;
  end
end
if (isempty(axesVec)) , return, end
if (~isempty(hAx)), axesVec(end) = hAx; end
 
% Check if all axes are the same
res   = true;
refAx = axesVec(1);
for axNo = 2 : length(axesVec)
  currAx = axesVec(axNo);
  if (~isequal(refAx, currAx))
    res = false;
    return
  end
end
 
% Set output
hAx = axesVec(1);
 
end