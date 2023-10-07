function changeLegLines(lobj, scaleFactor)
   %CHANGELEGLINES change length of lines in legend by scaleFactor
   %
   % Change the size of the legend lines. Currently only supports lines and patches
   % and only works if legend is located in default vertical stacked position.
   %
   % Updated for new legend behavior.
   %
   % Todo: FIGURE OUT HOW TO MAKE IT WORK FOR HORIZONTAL
   %
   % Example
   %
   % figure;
   % plot(1:10, 1:10);
   % [l, lobj] = legend('test');
   % changeLegLines2(lobj, 0.5)
   %
   % See also getlegend, setlegend

   if nargin < 2 || isempty(scaleFactor); scaleFactor = 0.5; end

   if isa(lobj, 'matlab.graphics.illustration.Legend')
      % Need a check to determine if lobj is the pre-2015 version of lobj.
      pre2015 = true;

      % pre2015, use object returned by: lobj = legend(...), need the children:
      lobj = get(lobj,'Children'); % 2,5,8,11 are lines, 13 is patch

      % function to find the line index in the Xdata, and the number of patches
      fLineIndex = @(n) n*2;
      fNumPatches = @(N) length(N)/4;

   elseif isa(lobj, 'matlab.graphics.primitive.Data')
      % new behavior, use lobj from: [l, lobj] = legend(...)
      pre2015 = false;

      % function to find the line index in the Xdata, and the number of patches
      fLineIndex = @(n) n*2 - 1;
      fNumPatches = @(N) length(N);
   end

   % Get the lines, patches, and text in the legend
   linesInPlot = findobj(lobj,'type','line');
   patchInPlot = findobj(lobj,'type','patch');
   textInPlot = findobj(lobj,'type','text');

   % Get the Xdata of the lines and patches in the legend
   plotXdata = get(linesInPlot,'Xdata');
   patchXdata = get(patchInPlot,'Xdata');

   % every 2nd entry in plotXdata is the line position vector. The 2nd entry in the
   % position vector controls the width. Re-scale it by the supplied scale factor

   numlines = length(plotXdata)/2;
   if numlines > 0
      for n = 1:numlines
         ind = fLineIndex(n);
         pos = plotXdata(ind);
         pos{1}(2) = pos{1}(2) * scaleFactor;
         pos = cell2mat(pos);
         set(linesInPlot(ind),'Xdata',pos)
      end
   end

   % patches are different. 4 handles per patch, second two control upper and
   % lower right vertices, need to scale each. Also, the 'pos' vector will
   % always consist of single numbers (unlike plot Xdata that has 2), so no
   % need to deal with cells like in the above

   numpatches = fNumPatches(patchXdata);

   if numpatches > 0

      if pre2015 == true
         for n = 1:numpatches
            ind1 = n*4;
            ind2 = ind1 - 1;
            pos1 = patchXdata(ind1);
            pos2 = patchXdata(ind2);
            pos1 = pos1 * scaleFactor;
            pos2 = pos2 * scaleFactor;
            patchXdata(ind1) = pos1;
            patchXdata(ind2) = pos2;
            set(patchInPlot,'Xdata',patchXdata);
         end

      else
         % No loop needed based on limited tests. Not 100% sure if this works in
         % all cases.
         n = 1;
         ind1 = n*4;
         ind2 = ind1 - 1;
         pos1 = patchXdata{n}(ind1);
         pos2 = patchXdata{n}(ind2);
         pos1 = pos1 * scaleFactor;
         pos2 = pos2 * scaleFactor;
         patchXdata{n}(ind1) = pos1;
         patchXdata{n}(ind2) = pos2;
         set(patchInPlot,'Xdata',cell2mat(patchXdata));
      end
   end

   % now move the text over
   textpos = get(textInPlot,'position');

   try
      % Think this is pre-2015 behavior
      textpos = cell2mat(textpos);
   catch
   end

   numtext = size(textpos,1);

   for n = 1:numtext
      % pos(1,1) controls the left/right position, pos(1,2) controls the vertical.
      % add 0.015 to put some space between the marker and the text.
      pos = textpos(n,:);
      pos(1,1) = pos(1,1) * scaleFactor + 0.015;
      textpos(n,:) = pos;
      set(textInPlot(n),'position',textpos(n,:))
   end


   % playing around with trying to resize the box, for some reason when I
   % reset the 3rd position entry which should control the width of the box,
   % it is applying the offset to the first position entry which is bizarre.
   % might just need to close and restart matlab for some reason.
   % offset = scaleFactor*pos(1,1)
   %
   % offset = .1
   %
   %
   % lpos = get(l,'position')
   % lposnew = [lpos(1) lpos(2) lpos(3)-offset lpos(4)]
   %
   % set(l,'position',[lpos(1) lpos(2) lpos(3)-offset lpos(4)])
end
