function h = inset(oldfig,newfig,varargin)

% when trying to get tileopenfigs to work I went here for a template but the
% notation i used in inset is confusing, the stuff here might be more accurate

% The function plotting figure inside figure (main and inset) from 2
% existing figures. 
% inset_size is the fraction of inset-figure size, default value is 0.35
% The outputs are the axes-handles of both.
% 
% An examle can found in the file: inset_example.m
% 
% Moshe Lindner, August 2010 (C).

   p = MipInputParser;
   p.FunctionName=mfilename;
   p.addRequired('mainhandle',@(x)isgraphics(x));
   p.addRequired('insethandle',@(x)isgraphics(x));
   p.addParameter('size',0.35,@(x)isnumeric(x));
   p.addParameter('location','nw',@(x)ischar(x));
   p.addParameter('multiplier',1,@(x)isnumeric(x));
   p.parseMagically('caller');
   %%%%%%

   size           =   size*multiplier;

   % get mainfig size
   newFig         =  figure('Position',oldfig.Position);
   oldFigAxesObj  =  findobj(oldfig,'Type','axes');
   oldLegend      =  findobj(oldfig,'Type','Legend');
   oldText        =  findall(oldfig,'Type','Annotation');
   newOldFigAxes  =  copyobj([oldFigAxesObj;oldLegend;oldText],newFig);

   for n = 1:numel(oldFigAxesObj)
      newOldFigAxes(n).Position =   oldFigAxesObj(n).Position;
   end

   % set(newMainAxes,'Position',get(mainFigAxes,'Position'))

   newFigAxesObj   =  findobj(newfig,'Type','axes');
   newFigAxes   =  copyobj(newFigAxesObj,newFig);
   
%    insetLegend    =  findobj(insetHandle,'Type','Legend');
%    newInsetAxes   =  copyobj([insetFigAxes;insetLegend],newFig);

   for n = 1:numel(newFigAxesObj)
      newFigAxes(n).Position =   newFigAxesObj(n).Position;
   end


   pos            =  get(oldFigAxesObj,'Position');

   if iscell(pos) && numel(pos)>1
      pos = pos{1};
   end

   % 1 is left/right, 2 is up/down, 3 is 

   xWest    = 0.9*(pos(1)+0.3*(pos(3)-size));
   xEast    = 0.95*(pos(1)+pos(3)-size);
   yNorth   = 0.9*(pos(2)+pos(4)-size);
   ySouth   = 1.5*(-2*pos(2)+pos(4)-size);

   switch location
       case 'ne'
          newPos = [xEast yNorth size size];
       case 'nw'
          newPos = [xWest yNorth size size];
       case 'se'
          newPos = [xEast ySouth size size];
       case 'sw'
          newPos = [xWest ySouth size size];
   end

   for n = 1:numel(newFigAxes)
      newFigAxes(n).Position = newPos;
   end

   h.figure    = newFig;
   h.mainAxes  = newOldFigAxes;
   h.insetAxes = newFigAxes;
   
   set(gcf,'CurrentAxes',newOldFigAxes(1));
   
% original xWest:
% .7*pos(1)+0.3*(pos(3)-insetSize)

% original yNorth:
% .3*pos(2)+ax(4)-inset_size

% original xEast:
% .8*pos(1)+pos(3)-insetSize

% original ySouth:
% -2*pos(2)+pos(4)-insetSize

% to move yNorth up a bit:
% .65*pos(2)+pos(4)-insetSize

end