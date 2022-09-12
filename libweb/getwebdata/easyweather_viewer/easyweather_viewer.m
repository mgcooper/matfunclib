function easyweather_viewer(filename)
% EASYWEATHER_VIEWER: Displays data from the Easyweather weather station.
% This program reads a report file from the Easyweather WH-1080 and
% greates a graphical user interface for viewing the data
%
% filename is the name of the file saved from the "record" screen in the
% Easyweather software
%
% Are Mjaavatten, march 2018
    
    if nargin < 1
        filename = 'EasyWeather.csv';
    end
    [t,data,headers,units,rbstrings,rbvars] = read_easyweather(filename);
    if ~verLessThan('Matlab','8.4')
        time = datetime(t, 'ConvertFrom', 'datenum');
        tt = time;  % datetime gives better time axis ticklabels
    else
        tt = t;
    end
    N = length(t);
    
%%  Replace columns for "24 hour rainfall" and "Month raionfall" by 
    % cumulative rain per calendar day and month
    monthcolumn = strcmp(headers, 'Month Rainfall');
    hourcolumn = strcmp(headers, 'Hour Rainfall');
    daycolumn = strcmp(headers, '24 Hour Rainfall');
    monthend = findchange(t,'mm');
    for i = 1:length(monthend)-1
        ix = monthend(i)+1:monthend(i+1);
        data(ix,monthcolumn) = cumsum(data(ix,hourcolumn));
    end 
    headers{monthcolumn} = 'Calendar month';
    dayend = findchange(t,'DD');
    for i = 1:length(dayend)-1
        ix = dayend(i)+1:dayend(i+1);
        data(ix,daycolumn) = cumsum(data(ix,hourcolumn));
    end        
    headers{daycolumn} = 'Calendar day';
    ncols = size(data,2);
    
    tspan = [t(1),t(end)];  % Plotting interval
    iplot = 1:N;            % Indices of plotting interval
    
%%   Create GUI:
    figwidth = 634;
    figheight = 469;
    linestyle = repmat({'-'},[ncols,1]);
    linestyle{rbvars{end}} = '.';   % Wind direction
    margins = [80,50,240,100]; % Axes margins left, bottom, right, top
    f = figure('position',[403   197   figwidth   figheight],...
        'color',[0.9400 0.9400 0.9400]);
    set(f,'ResizeFcn',@resize)
    axes('units','pixels','position',[margins(1:2),figwidth-margins(3),...
        figheight-margins(4)]);

    n_items = length(headers);
    cblist = cell(n_items,1);      % Checkbox list  
    ngroups = length(rbvars);  % rbvars{i} lists variables for group i
    radiobuttons = cell(ngroups,1);
    ypos = zeros(ngroups,1);
    xpos = margins(1) - margins(3) +figwidth + 10;
    ypos(1) = margins(2) - margins(4) + figheight;
    for j = 1:ngroups
        radiobuttons{j} = uicontrol('style','radiobutton','position',...
                [xpos,ypos(j),200,20],'string',rbstrings{j},...
                'callback',@set_group,'userdata',j);
        for i = 1:length(rbvars{j})
            cblist{rbvars{j}(i)} = uicontrol('style','checkbox',...
                'position',[figwidth-130,ypos(j)-25*i,130,20],...
                'string',headers{rbvars{j}(i)},...
                'callback',@check_uncheck,'userdata',j); 
        end
        ypos(j+1) = ypos(j) - 20 - length(rbvars{j})*30;
    end
   
    colors = get(gca,'colororder');

    uicontrol('style','text','position',...
                [90,figheight-40,70,20],'string','Start date:',...
                'FontSize',10);
    uicontrol('style','edit','position',...
                [160,figheight-38,70,20],'string',datestr(tspan(1),...
                'yyyy-mm-dd'),'callback',@set_tspan,'userdata',1);
    uicontrol('style','text','position',...
                [250,figheight-40,70,20],'string','End date:',...
                'FontSize',10);            
    uicontrol('style','edit','position',...
                [320,figheight-38,70,20],'string',datestr(tspan(2),...
                'yyyy-mm-dd'),'callback',@set_tspan,'userdata',2);   

%% Callbacks            
    function check_uncheck(source,~)
        % Checkbox callback.
        rb = get(source,'userdata');
        set(radiobuttons{rb},'value',true);  % Activate radiobutton
        set_group(radiobuttons{rb});  
    end

    function resize(~,~)
        % Figure resize callback
        pos = get(gcf,'Position');
        width = pos(3);
        height = pos(4);
        for ii = 1:length(radiobuttons);
            pos = get(radiobuttons{ii},'Position');
            pos(1) = width-140;
            set(radiobuttons{ii},'Position',pos)
        end
        for ii = 1:length(cblist)
            if ~isempty(cblist{ii})
                pos = get(cblist{ii},'Position');
                pos(1) = width-130;
                set(cblist{ii},'Position',pos);
            end
        end
        pos = get(gca,'position');
        pos(3) = width-240;
        pos(4) = height - 100;
        set(gca,'position',pos);
    end

    function set_tspan(source,~)
        % Callback for the start and end date edit boxes
        k = get(source,'userdata');
        date = get(source,'String');
        try
            tspan(k) = datenum(date);
            if diff(tspan) <= 0
                warndlg('The start date must be before the end date');
            end
            iplot = find(t>=tspan(1) & t<= tspan(2));
            plot_group;
        catch
            warndlg('Invalid date')
        end
    end

    function set_group(source,~)
        % Update radio buttons
        rb = get(source,'userdata');
        % Reset any other radio buttons
        for jj = 1:length(radiobuttons)
            if jj~= rb
                 set(radiobuttons{jj},'value',false);
            end
        end
        plot_group;
    end

%%  Plotting
    function plot_group
        % Draw graphs for all active variables for the active group
        cla;
        hold off
        for rb = 1:length(radiobuttons)
            val = get(radiobuttons{rb},'Value');
            if val
                for k = 1:length(rbvars{rb})
                    jj = rbvars{rb}(k);
                    if get(cblist{jj},'Value')
                        plot(tt(iplot),data(iplot,jj),linestyle{jj},...
                            'color',colors(k,:));
                        ylabel(units(jj));
                        hold on                  
                    end                
                end   
            end
        end
        if verLessThan('Matlab','8.4')
            datetick('x','dd.mmm');
        end
        grid on
    end
end

function ix = findchange(t,period)
% Returns the indices of the end of each calendar period
% Period is any period that returns a number string from datestr.  E.g.;
%  'DD': day
%  'mm': month
periodno = str2num(datestr(t,period));
ix = [0;find(diff(periodno)~=0);length(t)];
end
