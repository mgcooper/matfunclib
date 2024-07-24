function tbl = settablecats(tbl, category)
   %SETTABLECATS Set table variables to categorical.
   %
   %  TBL = SETTABLECATS(TBL, CATEGORY)
   %
   % Matt Cooper, 04-May-2023, https://github.com/mgcooper
   %
   % NOTE: This is barely functional - it's more of an example, specific to
   % setting default time-based categories. It needs to be renamed or completely
   % refactored to a settimecats function and inherit the 'yearType','dayType',
   % etc options from 'day','year' functions.
   %
   % See also

   arguments
      tbl (:,:) table
      category (1,1) string {mustBeMember(category,{'month','season'})} ...
         = 'season'
   end

   if istimetable(tbl)

      tbl = settimetabletimevar(tbl);

      switch category
         case 'month'
            tbl.month = categorical(month(tbl.Time));
         case 'year'
            tbl.year = categorical(year(tbl.Time));
         case 'doy'
            tbl.doy = categorical(day(tbl.Time,'dayofyear'));
         case 'dayofyear'
            tbl.dayofyear = categorical(day(tbl.Time,'dayofyear'));
         case 'dayofmonth'
            tbl.dayofmonth = categorical(day(tbl.Time,'dayofmonth'));
         case 'dayofweek'
            tbl.dayofweek = categorical(day(tbl.Time,'dayofweek'));

         case 'season'
            tbl = setseasoncats(tbl);
      end

      % For reference, this almost works, but when the dateType is need (e.g.
      % category = 'monthofyear', then the function is 'month', not
      % 'monthofyear' so would need complicated if-else to strip out the
      % 'ofyear' .. prob not worth it
      %
      % % might be able to do this:
      %
      %    f = str2func(category);
      %    try
      %       tbl.(category) = categorical(f(tbl.Time));
      %    catch
      %       tbl.(category) = categorical(f(tbl.Time),category);
      %    end

   end
end

function tbl = setseasoncats(tbl)

   iwinter = tbl.month == 1 | tbl.month == 2 | tbl.month == 3;
   ispring = tbl.month == 4 | tbl.month == 5 | tbl.month == 6;
   isummer = tbl.month == 7 | tbl.month == 8 | tbl.month == 9;
   iautumn = tbl.month == 10 | tbl.month == 11 | tbl.month == 12;

   tbl.season(iwinter) = categorical("winter");
   tbl.season(ispring) = categorical("spring");
   tbl.season(isummer) = categorical("summer");
   tbl.season(iautumn) = categorical("autumn");
end

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
