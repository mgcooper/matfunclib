function mergedProps = mergeCustomProps(tbls, opts)
   %MERGECUSTOMPROPS Merge custom properties of tables.
   %
   %  mergedProps = mergeCustomProps(T1,T2, ..., TN)
   %
   % Example
   %
   % T1 = table;
   % T2 = table;
   % T1 = settableprops(T1,{'shared','unique1'},'table',{'sharedval1','1'})
   % T2 = settableprops(T2,{'shared','unique2','other3'},'table',{'sharedval2','2','3'})
   % mergedProps = mergeCustomProps(T1,T2)
   % only 'shared' and 'unique1' will be returned,
   %
   %
   % Matt Cooper, 20-May-2023, https://github.com/mgcooper
   %
   % See also: stacktables

   arguments (Repeating)
      tbls table
   end

   arguments
      opts.KeepUniqueProps (1,1) logical = false
   end

   % Extract custom properties from all tables
   customProps = cellfun(@(tbl) tbl.Properties.CustomProperties, tbls, 'un', 0);

   % Initialize merged properties as the properties of the first table
   mergedProps = customProps{1};

   % Check if all properties are empty and return if so
   if all(cellfun(@(props) isempty(fieldnames(props)), customProps))
      return
   end

   % Loop over remaining tables
   for n = 2:numel(tbls)
      % Get properties of next table
      props = customProps{n};

      % Find shared and unique property names
      %sharedProps = intersect(fieldnames(mergedProps), fieldnames(props));
      %uniqueProps = setdiff(fieldnames(props), fieldnames(mergedProps));

      % Loop over each property in the table
      for propNames = fieldnames(props)'
         propName = propNames{1};

         % Check if property already exists in merged properties
         if ismember(propName, fieldnames(mergedProps))
            % Get existing and new properties
            prop1 = mergedProps.(propName);
            prop2 = props.(propName);

            % For now, the try should catch these type errors, but to use this, it
            % has to go after the char to string conversion
            % Check if property types match
            % if ~strcmp(class(prop1), class(prop2))
            %    error('Property "%s" has different types in different tables.', propName);
            % end

            % Check if properties are tables and merge appropriately
            if istable(prop1) && istable(prop2)
               % Merge tables using stacktables function
               mergedProps.(propName) = stacktables(prop1, prop2);
            else
               % Merge properties

               % Convert char and cellstr to string arrays
               [prop1,prop2] = convertCharsToStrings(prop1,prop2);

               try
                  % Attempt to concatenate properties
                  mergedProps.(propName) = [prop1; prop2];
               catch
                  % If concatenation fails, try pad with appropriate missing value
                  missingVal = getMissingValue(class(prop1));
                  try
                     mergedProps.(propName) = [prop1; repmat(missingVal, numel(prop2), 1)];
                  catch ME
                     rethrow(ME)
                  end
               end
            end
         else
            %          % This may work, but I think it assumes the first tbl has no unique props
            %          % If property does not exist in merged properties, add it
            %          T = addprop(T, propName, "table");
            %          T.Properties.CustomProperties.(propname) = prop2;
            %          mergedProps.(propName) = T.Properties.CustomProperties.(propname);
         end
      end
   end

   if opts.KeepUniqueProps
      % For unique properties, need to add them to a new table
      T = table;
      [sharedProps, uniqueProps] = allCustomProps(tbls{:});
      for n = 1:numel(sharedProps)
         T = addprop(T,sharedProps{n},'table');
         T.Properties.CustomProperties.(sharedProps{n}) = ...
            mergedProps.(sharedProps{n});
      end

      for n = 1:numel(uniqueProps)
         uProps = uniqueProps{n};
         for m = 1:numel(uProps)
            T = addprop(T,uProps{m},'table');
            T.Properties.CustomProperties.(uProps{m}) = ...
               tbls{n}.Properties.CustomProperties.(uProps{m});
         end
      end
      mergedProps = T.Properties.CustomProperties;
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