
% Commented out to suppress codeissues

% function [lat,lon] = prepareGeoCoords(lat, lon, func_name, ...
%       lat_var_name, lon_var_name, lat_pos, lon_pos)
%    %PREPAREGEOCOORDS prepare latitude-longitude arrays for geo processing
%    %
%    %   PREPAREGEOCOORDS(LAT, LON, FUNC_NAME, LAT_VAR_NAME, LON_VAR_NAME,
%    %   LAT_POS, LON_POS) ensures that LAT and LON are real vectors or
%    %   arrays of matching size, having class 'double' or 'single', and that
%    %   for every NaN-valued element of LAT there is identically-positioned
%    %   NaN-valued element in LON, and vice versa.
%    %
%    % See also:
%
%    % Real-valued double?
%    validateattributes( ...
%       lat, {'double','single'} ,{'real'}, func_name, lat_var_name, lat_pos)
%    validateattributes( ...
%       lon, {'double','single'} ,{'real'}, func_name, lon_var_name, lon_pos)
%
%    % Sizes match?
%    assert(isequal(size(lat),size(lon)), ...
%       "map:" + func_name + ":latlonSizeMismatch", ...
%       ['Function %s expected its %s and %s input arguments,\n', ...
%       '%s and %s, to match in size.'], ...
%       upper(func_name), num2ordinal(lat_pos), num2ordinal(lon_pos), ...
%       lat_var_name, lon_var_name)
%
%    % NaN positions correspond?
%    assert(isequal(isnan(lat),isnan(lon)), ...
%       "map:" + func_name + ":latlonNaNMismatch", ...
%       ['Function %s expected its %s and %s input arguments,\n', ...
%       '%s and %s, to have NaN-separators in corresponding positions.'], ...
%       upper(func_name), num2ordinal(lat_pos), num2ordinal(lon_pos), ...
%       lat_var_name, lon_var_name)
%
%    %% below here is og 'cleancoords' function which was just a copy of a script
%
%    % didn't finish this but see save_CALM_ALT and make_kuparuk_met_shapefle
%
%    % some combination of the method in kuparuk_met_coords which used char
%    % conversion to double and compared witht hese ascii codes and the
%    % method in calm_alt which used the actual characters
%    degchars = [176,111];
%    minchars = [8217,39];
%    secchars = [8221,34];   % also need to check for [39 39] which is ''
%
%    findchars = [8217,8221];
%    repchars = [39,34];
%
%
%    % this part from str2angle function
%    %------------------------------------------------------------
%    if nargin > 0
%       dmsstrs = convertStringsToChars(dmsstrs);
%    end
%
%    % convert cell array to a cell array vector
%    if iscell(dmsstrs)
%       dmsstrs = dmsstrs(:);
%    end
%
%    % If the string came from the ANGL2STR, it could include this LaTeX markup:
%    % ^{\circ}. If this substring is encountered, we need to replace it with a
%    % single character. The specific replacement doesn't matter because, as
%    % noted in its comments, the degreeCharacterAndQuotes function will skip
%    % over it. The space character, ' ', is a reasonable choice.
%    if ischar(dmsstrs)
%       dmsstrs = num2cell(dmsstrs,2);
%    end
%    dmsstrs = strrep(dmsstrs,'^{\circ}',' ');
%
%    % Convert to character array, justify, validate
%    dmsstrs = char(dmsstrs{:});
%    dmsstrs = rightjustify(dmsstrs);
%    %------------------------------------------------------------
%
%
%
%
%    % this part from str2angle function
%    %------------------------------------------------------------
%
%    for n = 1:numel(latstrs)
%
%       latn = latstrs(n)
%       lonn = latstrs(n);
%
%       % this calls the block above that i moved out of subfucntion for testing
%       dmsstrs = preprocessdmsstrs([latn;lonn]);
%
%       latdouble = double(latn);
%       londouble = double(lonn);
%
%       % use deblank just in case strrep doesn't get rid of all blanks
%       latn = deblank(strrep(char(text.Var3(n)),' ',''));
%       idd = strfind(latn,'°');
%       imm = strfind(latn,'''');
%       iss = strfind(latn,'”');
%
%       % check if dd or mm is missing
%       if isempty(idd) || isempty(imm)
%          disp('no dd or mm found')
%          break
%       end
%
%       % check if seconds unit is " rather than ”
%       if isempty(iss)
%          iss = strfind(latn,'"');
%       end
%
%       % if not, pull out dd mm ss (ss will be nan if iss is empty)
%       dd = str2double(latn(1:idd-1));
%       mm = str2double(latn(idd+1:imm-1));
%       ss = str2double(latn(imm+1:iss-1));
%
%       % check if the mm field is in decimal minutes
%       if mod(mm,1)>0
%          ss = mod(mm,1)*60;
%          mm = mm-mod(mm,1);
%
%          % if iss is still missing, set it to zero, otherwise pull it out
%       elseif isempty(iss)
%          ss = 00;
%       end
%
%       % now we have dd, mm, and ss
%       if contains(latn,'N')
%          latn = [num2str(dd) 'd' num2str(mm) 'm' num2str(ss) 'sN'];
%       elseif contains(latn,'S')
%          latn = [num2str(dd) 'd' num2str(mm) 'm' num2str(ss) 'sS'];
%       end
%
%       %latcheck(n) = dd + mm/60 + ss/3600;
%
%    end
% end
%
% function dmsstrs = preprocessdmsstrs(dmsstrs)
%
%
% end
%
%
% % this is exactly how it's done in kuparuk_met-coords
%
% function latorlon = cleanllstr1(llstr, coords)
%    degchars = [176,111];
%    minchars = [8217,39];
%    secchars = [8221,34];   % also need to check for [39 39] which is ''
%
%    findchars = [8217,8221];
%    repchars = [39,34];
%
%    for n = 1:height(coords)
%
%       %    latn = string(coords.Latitude{n});
%       %    lonn = string(coords.Longitude{n});
%
%       latn = coords.Latitude{n};
%       lonn = coords.Longitude{n};
%
%       latn = strrep(strrep(deblank(latn),' ',''),'  ','');
%       lonn = strrep(strrep(deblank(lonn),' ',''),'  ','');
%
%       for m = 1:numel(findchars)
%
%          % first strip the letters so conversion to double works
%          latn = strrep(upper(latn),'N','');
%          latn = strrep(upper(latn),'S','');
%          lonn = strrep(upper(lonn),'E','');
%          lonn = strrep(upper(lonn),'W','');
%          latn = double(char(latn));
%          lonn = double(char(lonn));
%
%          % find and replace the disallowed ascii characters, then back to char
%          irep = find(ismember(latn,findchars(m)));
%          latn(irep) = repchars(m);
%          latn = [char(latn) 'N'];
%
%          % repeat for lon
%          irep = find(ismember(lonn,findchars(m)));
%          lonn(irep) = repchars(m);
%          lonn = [char(lonn) 'W'];
%
%       end
%
%       % now convert to decdeg
%       latlon = str2angle([string(latn);string(lonn)]);
%
%       lat(n) = latlon(1);
%       lon(n) = latlon(2);
%    end
%
% end
%
%
% % this is exactly how it's done in save_calm_alt
% function latorlon = cleanllstr2(llstr)
%
%
%    idd = strfind(llstr,'°');
%    imm = strfind(llstr,{'''','’'});
%    iss = strfind(llstr,{'"','”'});
%
%
%    imm = contains(llstr,{'''','’'});
%    iss = ismember(llstr,{'"','”'});
%
%    % check if dd or mm is missing
%    if isempty(idd) || isempty(imm)
%       disp('no dd or mm found')
%    end
%
%    % check if seconds unit is " rather than ”
%    if isempty(iss)
%       iss = strfind(llstr,'"');
%    end
%
%    % if not, pull out dd mm ss (ss will be nan if iss is empty)
%    dd = str2double(llstr(1:idd-1));
%    mm = str2double(llstr(idd+1:imm-1));
%    ss = str2double(llstr(imm+1:iss-1));
%
%    % check if the mm field is in decimal minutes
%    if mod(mm,1)>0
%       ss = mod(mm,1)*60;
%       mm = mm-mod(mm,1);
%
%       % if iss is still missing, set it to zero, otherwise pull it out
%    elseif isempty(iss)
%       ss = 00;
%    end
%
%    % now we have dd, mm, and ss
%    if contains(llstr,'N')
%       llstr = [num2str(dd) 'd' num2str(mm) 'm' num2str(ss) 'sN'];
%    elseif contains(llstr,'S')
%       llstr = [num2str(dd) 'd' num2str(mm) 'm' num2str(ss) 'sS'];
%    end
% end
