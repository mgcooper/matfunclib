function h = cumulplot(t,y,varargin)
   
   p                 = MipInputParser;
   p.FunctionName    = 'cumulplot';
   p.PartialMatching = true;
   
   dpos  = [321 241 512 384]; % default figure size
   
   p.addRequired('t',                  @(x)isnumeric(x) || isdatetime(x));
   p.addRequired('y',                  @(x)isnumeric(x)                 );
   p.addParameter('ylabeltext',  '',   @(x)ischar(x)                    );
   p.addParameter('xlabeltext',  '',   @(x)ischar(x)                    );
   p.addParameter('titletext',   '',   @(x)ischar(x)                    );
   p.addParameter('legendtext',  '',   @(x)ischar(x)                    );
   p.addParameter('figpos',      dpos, @(x)isnumeric(x)                 );
   p.addParameter('useax',       nan,  @(x)isaxis(x)                    );
   
   p.parseMagically('caller');
   
   useax       = p.Results.useax;
   plotvarargs = unmatched2varargin(p.Unmatched);
   
   % for now, convert to datenums
   if isdatetime(t)
     %t = datenum(t);
      t = year(t);
   end
   
   inan        = isnan(y);
   ycumul      = cumsum(y,'omitnan');
   ycumul      = setnan(ycumul,inan);
   ycumul      = ycumul-ycumul(1,:);
   
   % if an axis was provided, use it, otherwise make a new figure
   if not(isaxis(useax))
      h.figure = figure('Position',figpos);
      useax    = gca;
   end
   
   if isempty(plotvarargs)
      h.plot      = plot(useax,t,ycumul,'-o'); hold on;
     %h.scatter   = myscatter(t,ycumul,rgb('green'));
   else
      h.plot      = plot(useax,t,ycumul,plotvarargs{:}); 
   end
   
   formatPlotMarkers; hold on;
  
   
   axis tight
   
   ylabel(ylabeltext); xlabel(xlabeltext); title(titletext);
   
   h.ax = gca;
