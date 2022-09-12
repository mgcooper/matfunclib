function changeLegLines2( l,lobj,scaleFactor )
%CHANGELEGLINES Updated for new legend behavior. Change the size of the 
% legend lines. Currently only supports lines and patches and only works 
% if legend is located in default vertical stacked position - NEED TO
% FIGURE OUT HOW TO MAKE IT WORK FOR HORIZONTAL!!

%   Detailed explanation goes here


% scaleFactor     =   .5

lpos            =   get(l,'position');

% legchilun       =   get(l,'Children'); % 2,5,8,11 are lines, 13 is patch

linesInPlot     =   findobj(lobj,'type','line');
patchInPlot     =   findobj(lobj,'type','patch');
textInPlot      =   findobj(lobj,'type','text');

plotXdata       =   get(linesInPlot,'Xdata');
patchXdata      =   get(patchInPlot,'Xdata');

% every second entry in plotXdata is the line position vector. The second
% entry in the position vector controls the width. We re-scale it by the
% supplied scale factor

numlines    =   length(plotXdata)/2;

if numlines > 0

    for n = 1:numlines

        ind         =   n*2 - 1;
        pos         =   plotXdata(ind);

        pos{1}(2)   =   pos{1}(2) * scaleFactor;

        pos         =   cell2mat(pos);

        set(linesInPlot(ind),'Xdata',pos)
    end

end

% NEED TO FIGURE OUT PATCH BEHAVIOR IN R2015
% patches are different. 4 handles per patch, second two control upper and
% lower right vertices, need to scale each. Also, the 'pos' vector will
% always consist of single numbers (unlike plot Xdata that has 2), so no
% need to deal with cells like in the above

% UPDATE: temporary fix, not 100% sure on new behaviro, but no longer need
% to loop trhough each patch. Setting it once works

numpatches  =   length(patchXdata);

if numpatches > 0

%     for n = 1:numpatches 
        
        n = 1;

        ind1    =   n*4;
        ind2    =   ind1 - 1;

        pos1    =   patchXdata{n}(ind1);
        pos2    =   patchXdata{n}(ind2);

        pos1    =   pos1 * scaleFactor;
        pos2    =   pos2 * scaleFactor;

        patchXdata{n}(ind1)    =   pos1;
        patchXdata{n}(ind2)    =   pos2;

        set(patchInPlot,'Xdata',cell2mat(patchXdata));

%     end

end

% now move the text over

textpos     =   get(textInPlot,'position');
textpos     =   cell2mat(textpos);

numtext     =   size(textpos,1);

for n = 1:numtext; 
    
    pos             =   textpos(n,:);
    pos(1,1)        =   pos(1,1) * scaleFactor + 0.015;  % first entry is the left/right position (for future notice, the second entry controls the vertical), then we add 0.015 to put some space between the marker and the text   
    textpos(n,:)    =   pos;

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
% lpos        =    get(l,'position')
% lposnew     =   [lpos(1) lpos(2) lpos(3)-offset lpos(4)]
% 
% set(l,'position',[lpos(1) lpos(2) lpos(3)-offset lpos(4)])

end

