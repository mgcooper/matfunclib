function [t,data,headers,units,rbstrings,rbvars] = read_easyweather(file)
% READ_EASYWEATHER: Reads weather history data from Easyweather software
% Input:
%  file   History file saved from the Easyweather software
% Output:
%  t         time array in Matlab serial time format
%  data      data array with 16 columns
%  headers   Celle array of headers for the columns in data
%  units     Cell array of physical units
%  rbstrings, rbvars: Used by easyweather_display.
%
% Old versions of the software create plain ascii files without headers
% Newer versions (Sofware version 8, 2013) use unicode (UTF-16 LE) and has
% column headers in the first line.  The variables reported and the order
% of variables also differ somewhat.
%
% March 2018, Are Mjaavatten
% 
% Acknowledgement:
%  To read the unicode files, I use textscanu.m by Vlad Atanasiu
%  The file is available at The Matworks File Exchange:
% https://www.mathworks.com/matlabcentral/fileexchange/18956-read-unicode-files

    rbstrings = {'Temperatures','Humidity','Wind','Rain','Pressure',...
        'WindDirection'};
    linestyle = repmat({'-'},[16,1]);
    if check_uni(file) == true
        C = textscanu(file);
        headers = C(1,4:end)';        
        units = cell(size(headers));
        for i = 1:length(headers)
            h = headers{i};
            ix = regexp(h,'\(');
            if ~isempty(ix)
                units{i} = h(ix+1:end-1);
                headers{i} = h(1:ix-1);
            else
                units{i} = '-';
            end
        end
        C = C(2:end,:);
        N = length(C);   % Number of entries
        t = datenum(C(:,2),'yyyy-mm-dd HH:MM:SS');
        filecolumns = [4:11,13:19];
        datacolumns = filecolumns-3;
        ncols = length(datacolumns);
        data = zeros(N,length(datacolumns)); 
        for i = 1:ncols
            data(:,datacolumns(i)) = cell2mat(cellfun(@str2num,...
                C(:,filecolumns(i)),'UniformOutput',false));
        end
        data(:,9) = winddir(C(:,12)); % Convert from string to degrees
        rbvars = {[1,3],[2,4],[7,8],[13,15],5,9};  
    else
        fmt = ...
           '%d %s %s %d %d %f %d %f %f %f %f %s %f %f %f %f %f %f %f %f %d %d';
        fid = fopen(file);
        d = textscan(fid, fmt);  
        fclose(fid);
        t = datenum(strcat(d{2},d{3}),'dd-mm-yyyyhh:MM'); 
        filecolumns = [5:11,13:20];
        datacolumns = filecolumns-4;
        ncols = length(datacolumns);
        data = zeros(length(t),ncols);
        for i = 1:ncols
            data(:,datacolumns(i)) = double(d{filecolumns(i)});
        end
        data(:,8) = winddir(d{12}); % Convert from string to degrees
        headers = {
            'Indoor Humidity'
            'Indoor Temperature'
            'Outdoor Humidity'
            'Outdoor Temperature'
            'Absolute Pressure'
            'Wind'
            'Gust'
            'Direction'
            'Relative Pressure'
            'Dewpoint'
            'Windchill'
            'Hour Rainfall'
            '24 Hour Rainfall'
            'Week Rainfall'
            'Month Rainfall'
            'Total Rainfall'
            };

        units = {
            '%'
            'ºC'
            '%'
            'ºC'
            'Hpa'
            'm/s'
            'm/s'
            'degrees'
            'hPa'
            'ºC'
            'ºC'
            'mm'
            'mm'
            'mm'
            'mm'
            'mm'
            }; 
        rbvars = {[2,4],[1,3],[6,7],[13,15],9,8};  
    end
end

function unicode = check_uni(file)
% CHECK_UNI: True if text file is unicode (UTF-8 ot UTF-16)
    fid = fopen(file');
    firstchar = fscanf(fid,'%c',2);
    fclose(fid);

    % UTF text files normally start with a byte order mark (BOM)
    unicode = false;
    if double(firstchar(1))*256+double(firstchar(2)) > 61370
        unicode = true;
    end
end

function degrees = winddir(wind)
% WINDDIR: Translates Easyweather wind direction strings to degrees
    windstrings = {'N','NNE','NE','NEE','E','SEE','SE','SSE','S','SSW','SW','SWW',...
        'W','NWW','NW','NNW'};
    winddeg = 0:22.5:359;
    degrees = zeros(size(wind));
    for i = 1:16
        degrees(strcmp(windstrings{i},wind)) = winddeg(i);
    end
end