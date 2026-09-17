function rotatedLogLogText(xtxt,ytxt,txt,slope,axpos,varargin)
   %ROTATEDLOGLOGTEXT Add rotated text label to log-log axis
   %
   % rotatedLogLogText(xtxt,ytxt,txt,slope,axpos,textopts)
   %
   %  rotatedLogLogText(xtxt, ytxt, txt, slope, axpos) places the latex
   %  string txt at data coordinates (xtxt, ytxt) on the current axes. It
   %  rotates the text by slope*atand(yfactor/xfactor) degrees, where
   %  xfactor = axpos(1)/(decades in xlim) and
   %  yfactor = axpos(2)/(decades in ylim). slope is an empirical rotation
   %  factor tuned per figure layout. Trailing arguments textopts pass
   %  through to the text function and override the default text options.
   %
   % See also: text

   % https://stackoverflow.com/questions/52928360/rotating-text-onto-a-line-on-a-log-scale-in-matplotlib

   % to add text, need the slope in figure space
   xlimits = xlim;
   ylimits = ylim;
   xfactor = axpos(1)/(log10(xlimits(2))-log10(xlimits(1)));
   yfactor = axpos(2)/(log10(ylimits(2))-log10(ylimits(1))); % slope adjustment
   txtangle = slope*atand(yfactor/xfactor); % adjust angle

   text(xtxt,ytxt,txt,                    ...
      'HorizontalAlignment','center',     ...
      'VerticalAlignment', 'bottom',      ...
      'FontSize',12,                      ...
      'rotation',txtangle,                ...
      'Interpreter','latex',              ...
      varargin{:} ...
      );
end