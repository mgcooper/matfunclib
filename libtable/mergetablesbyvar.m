function T = mergetablesbyvar(T1,T2,commonvar)
   %MERGETABLESBYVAR Merge two tables based on a common variable key.
   %
   %  T = mergetablesbyvar(T1,T2,commonvar) merges columns of tables T1 and T2 with
   %  variable name COMMONVAR into new table T using matlab's SYNCHRONIZE function
   %
   % See also: stacktables, mergeCustomProps

   % ivar1 = string(T1.Properties.VariableNames) == string(commonvar);
   % ivar2 = string(T2.Properties.VariableNames) == string(commonvar);

   ivar1 = contains(T1.Properties.VariableNames,commonvar);
   ivar2 = string(T2.Properties.VariableNames) == string(commonvar);

   T1 = T1(:,ivar1);
   T2 = T2(:,ivar2);

   % find the longer of the two records
   % Time1 = T1(:,1);
   % Time2 = T2(:,1);

   T = synchronize(T1,T2);

   % i think these might be 'timeseries' methods of synchronize, when i do
   % 'doc synchronize' i get the timeseries version:
   %    T     = synchronize(T1,T2,'union');
   %    T     = synchronize(T1,T2,'commonrange');

   %
   %    t1     = synchronize(T1,T2,'commonrange');
   %    t2     = synchronize(T1,T2,'union');



   %    if isstruct(data)
   %       T        = data.(fields{1});
   %       irain    = find(string(T.Properties.VariableNames) == "Rainfall (mm)");
   %       Train    = T(:,irain);
   %
   %       for n = 2:numtables
   %          T        = data.(fields{n});
   %          irain    = find(string(T.Properties.VariableNames) == "Rainfall (mm)");
   %
   %          Ttmp     = T(:,irain);
   %          Train    = synchronize(Train,Ttmp);
   %       end
   %
   %    end
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
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.