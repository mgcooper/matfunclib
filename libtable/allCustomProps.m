function [sharedProps, uniqueProps] = allCustomProps(tbls, opts)
   %ALLCUSTOMPROPS Get shared and unique custom properties in a set of tables.
   %
   % [sharedProps, uniqueProps] = allCustomProps(T1,T2)
   %
   % [sharedProps, uniqueProps] = allCustomProps(T1,T2,"asstring",true)
   %
   % Example
   %
   % T1 = table;
   % T2 = table;
   % T1 = settableprops(T1,{'shared','unique1'},'table',{'sharedval1','1'})
   % T2 = settableprops(T2,{'shared','unique2','other3'},'table',{'sharedval2','2','3'})
   %
   % [sharedProps,uniqueProps] = allCustomProps(T1,T2)
   % [sharedProps,uniqueProps] = allCustomProps(T1,T2,"asstrings",true)
   %
   %
   % Matt Cooper, 20-May-2023, https://github.com/mgcooper
   %
   % See also: stacktables

   arguments(Repeating)
      tbls table
   end

   arguments(Input)
      opts.asstrings (1,1) logical = false
   end

   nTables = numel(tbls);

   % Initialize
   propNames = cell(1, nTables);
   uniqueProps = cell(1, nTables);

   % Loop through all tables to compile all properties
   for n = 1:nTables
      propNames{n} = fieldnames(tbls{n}.Properties.CustomProperties);
   end

   % Identify the shared properties
   sharedProps = propNames{1};
   for n = 2:nTables
      sharedProps = intersect(sharedProps,propNames{n}, 'stable');
   end

   % Loop through all tables again to identify the unique properties
   for n = 1:nTables
      % Update the unique properties for the current table
      uniqueProps{n} = setdiff(propNames{n}, ...
         [sharedProps; vertcat(propNames{[1:n-1, n+1:end]})], 'stable');
   end

   if opts.asstrings
      sharedProps = string(sharedProps);
      uniqueProps = cellfun(@string, uniqueProps, 'UniformOutput', false);
   end
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
