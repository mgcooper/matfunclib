function inca(varargin)
%INCA   Includes axes objects from other axes.
%    INCA allows to cut & paste plots and other axes
%    contents from one axes object into another. It 
%    moves all children of the axes object (lines
%    text, title, axes-labels etc.). This may be
%    useful for collecting plots from single figures
%    into subplots of one figure. 
%
%    There are two ways to cut & paste a plot with inca:
%    1. Call the command INCA at the commandline, or
%    2. if an INCA menubar entry exist (see below), use
%       this menupoint.
%
%    After calling INCA the cursor will become an open
%    hand (with number one), ready for taking the plot. 
%    Click at the plot to copy, the cursor becomes a closed 
%    hand (or a hand with number two), ready for paste.
%    Now click at the destination plot, the plot will be 
%    pasted therein.
%
%    Remarks:
%    If the axes property 'NextPlot' is set to 'replace', any
%    existing axes contents will be removed before the new
%    contents will be added. To retain existing axes contents
%    use the command 'HOLD ON'.
%
%    INCA ON creates an INCA entry in the figure's menubar.
%    If this entry should be occur by default, add the 
%    following line into the Matlab STARTUP.M file:
%
%       set(0,'DefaultFigureCreateFcn','inca on')
%
%    INCA OFF removes the INCA entry from the menubar.
%
%    See also SUBPLOT, AXES, HOLD, NEWPLOT.

% Copyright (c) 2008-2009
% Norbert Marwan, Potsdam Institute for Climate Impact Research, Germany
% http://www.pik-potsdam.de
%
% Copyright (c) 2002-2008
% Norbert Marwan, Potsdam University, Germany
% http://www.agnld.uni-potsdam.de
%
% Last Revision: 2006-03-16
% Version: 1.5
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
% 
%     * Redistributions of source code must retain the above
%       copyright notice, this list of conditions and the following
%       disclaimer.
%     * Redistributions in binary form must reproduce the above
%       copyright notice, this list of conditions and the following
%       disclaimer in the documentation and/or other materials provided
%       with the distribution.
%     * All advertising materials mentioning features or use of this 
%       software must display the following acknowledgement:
%       This product includes software developed by the University of
%       Potsdam, Germany, the Potsdam Institute for Climate Impact
%       Research (PIK), and its contributors.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
% CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
% BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
% TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
% DATA, OR PROFITS; OR BUSINESS


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% splash the BSD license

try
    filename='inca';
    txt = {'';'BSD LICENSE';
    '';'Copyright (c) 2008-2009';
    'Norbert Marwan, Potsdam Institute for Climate Impact Research, Germany';
    'http://www.pik-potsdam.de';
    '';
    'Copyright (c) 2002-2008';
    'Norbert Marwan, Potsdam University, Germany';
    'http://www.agnld.uni-potsdam.de';
    '';
    'All rights reserved.';
    '';
    'Redistribution and use in source and binary forms, with or without';
    'modification, are permitted provided that the following conditions';
    'are met:';
    '';
    '    * Redistributions of source code must retain the above';
    '      copyright notice, this list of conditions and the following';
    '      disclaimer.';
    '    * Redistributions in binary form must reproduce the above';
    '      copyright notice, this list of conditions and the following';
    '      disclaimer in the documentation and/or other materials provided';
    '      with the distribution.';
    '    * All advertising materials mentioning features or use of this ';
    '      software must display the following acknowledgement:';
    '      This product includes software developed by the University of';
    '      Potsdam, Germany, the Potsdam Institute for Climate Impact';
    '      Research (PIK), and its contributors.';
    '';
    'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND';
    'CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,';
    'INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF';
    'MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE';
    'DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS';
    'BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,';
    'EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED';
    'TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,';
    'DATA, OR PROFITS; OR BUSINESS'
    };
    which_res=which([filename,'.m']);
    bsdrc_path=strrep(which_res,[filename,'.m'],'');
    bsdrc_file=[bsdrc_path, filesep, '.bsd.',filename];
    if ~exist(bsdrc_path,'dir')
        mkdir(strrep(which_res,[filename,'.m'],''),'private')
    end
    if ~exist(bsdrc_file,'file') || strcmpi(varargin,'bsd')
        if ~exist(bsdrc_file,'file')
            disp('First click on the license to accept them.')
        else
            disp('Click on the license to close them.')
        end
        fid=fopen(bsdrc_file,'w');
        fprintf(fid,'%s\n','If you delete this file, the BSD License will');
        fprintf(fid,'%s','splash up at the next time the programme starts.');
        fclose(fid);

        h=figure('NumberTitle','off',...,
            'ButtonDownFcn','close',...
            'Name','BSD License');
        ha=get(h,'Position');
        h=uicontrol('Style','Listbox',...
            'ButtonDownFcn','close',...
            'CallBack','close',...
            'Position',[0 0 ha(3) ha(4)],...
            'Value',1,...
            'FontName','Courier',...
            'BackgroundColor',[.8 .8 .8],...
            'String',txt);
        waitfor(h)
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check the input

    error(nargchk(0,1,nargin));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% make menu entry
    if nargin~=0
        h=guihandles;
        check=strcmpi(fieldnames(h),'figMenuEdit');
        if ~isempty(check)
            flag=sum(check)~=0;
        else
            flag=0;
        end

        if strcmpi(varargin{1},'off') && ~isempty(findobj('Tag','figMenuInca','Parent',gcf))
            delete(findobj('Tag','figMenuInca','Parent',gcf))
        elseif ~strcmpi(varargin{1},'off') && isempty(findobj('Tag','figMenuInca','Parent',gcf)) && flag
            uimenu('Label','In&ca',...
            'Callback','inca','Tag','figMenuInca',...
            'DeleteFcn','setptr(get(0,''Children''),''arrow'')')
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% copy & paste axes objects
    else
        try
            % make pointer to hand1 in all figures
            h_figs=get(0,'Children');
            setptr(h_figs,'hand1')
            disp('Click on axes to get.');
            waitforbuttonpress

            % axes object which is to copy
            h_oldax=gca;

            % make pointer to hand2 in all figures and to closehand in source figure
            setptr(h_figs,'hand2')
            setptr(gcf,'closedhand')
            disp('Click on new axes to put.');
            waitforbuttonpress

            % get position of the new axes object
            set(gca,'Units','Norm');
            np=get(gca,'NextPlot');
            pos=get(gca,'Position'); 
            if strcmpi(np,'replace')
                % replace the old axes with new
                if gca~=h_oldax
                    delete(gca)
                    h_newax=copyobj(h_oldax,gcf);
                    set(h_newax,'Units','Norm','Position',pos,'Tag','')
                end
            else
                % add the axes' childs into the new axes
                h_oldobj=allchild(h_oldax);
                h_oldobj(h_oldobj==get(h_oldax,'Title'))=[];
                h_oldobj(h_oldobj==get(h_oldax,'XLabel'))=[];
                h_oldobj(h_oldobj==get(h_oldax,'YLabel'))=[];
                copyobj(h_oldobj,gca)
            end

            % make pointer back to arrow in all figures
            setptr(h_figs,'arrow')

            catch
            disp('Aborted by user.');
            setptr(get(0,'Children'),'arrow')
        end
    end
catch
end
