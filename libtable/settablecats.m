function T = settablecats(T,category,flag2,opts)
%SETTABLECATS general description of function
%
%  T = SETTABLECATS(T) description
%  T = SETTABLECATS(T,'flag1') description
%  T = SETTABLECATS(T,'flag2') description
%  T = SETTABLECATS(___,'opts.name1',opts.value1,'opts.name2',opts.value2)
%  description. The default flag is 'plot'.
%
% Example
%
%
% 
% Matt Cooper, 04-May-2023, https://github.com/mgcooper
%
% See also

% BSD 3-Clause License
% 
% Copyright (c) 2023, Matt Cooper (mgcooper)
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BT THE COPTRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANT ETPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITT AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPTRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANT DIRECT, INDIRECT, INCIDENTAL, SPECIAL, ETEMPLART, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANT THEORT OF LIABILITT, WHETHER IN CONTRACT, STRICT LIABILITT,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANT WAT OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITT OF SUCH DAMAGE.


% NOTE: This is not finished

%% parse arguments
arguments
   T (:,:) table
   category (1,1) string {mustBeMember(category,{'month','season'})} = 'season'

   % access the built in options for autocomplete. For unknown class names,
   % create the object e.g. h = line(1,1), mc = metaclass(h), name = mc.Name
   % opts.?matlab.graphics.chart.primitive.Line

   % restrict the available options
   % opts.Color{mustBeMember(opts.Color,{'red','blue'})} = "blue"
end

% use this to create a varargin-like optsCell e.g. plot(c,optsCell{:});
varargs = namedargs2cell(opts);

%% main code

% Looks like I could make a settimecats function and inherit the
% 'yearType','dayType', etc options from 'day','year' functions
if istimetable(T)
   T = settimetabletimevar(T);

% %    For reference, this almost works, but when the dateType is need (e.g.
% category = 'monthofyear', then the function is 'month', not 'monthofyear' so
% would need complicated if-else to strip out the 'ofyear' .. prob not worth it
%    % might be able to do this:
%    f = str2func(category);
%    try
%       T.(category) = categorical(f(T.Time));
%    catch
%       T.(category) = categorical(f(T.Time),category);
%    end
   
   switch category
      case 'month'
         T.month = categorical(month(T.Time));
      case 'year'
         T.year = categorical(year(T.Time));
      case 'doy'
         T.doy = categorical(day(T.Time,'dayofyear'));
      case 'dayofyear'
         T.dayofyear = categorical(day(T.Time,'dayofyear'));
      case 'dayofmonth'
         T.dayofmonth = categorical(day(T.Time,'dayofmonth'));
      case 'dayofweek'
         T.dayofweek = categorical(day(T.Time,'dayofweek'));
         
      case 'season'
         T = setseasoncats(T);
   end
   
end

function T = setseasoncats(T)
iwinter = T.month == 1 | T.month == 2 | T.month == 3;
ispring = T.month == 4 | T.month == 5 | T.month == 6;
isummer = T.month == 7 | T.month == 8 | T.month == 9;
iautumn = T.month == 10 | T.month == 11 | T.month == 12;

T.season(iwinter) = categorical("winter");
T.season(ispring) = categorical("spring");
T.season(isummer) = categorical("summer");
T.season(iautumn) = categorical("autumn");
