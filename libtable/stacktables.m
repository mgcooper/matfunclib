function tblstack = stacktables(tbls, opts)
   %STACKTABLES vertically concatenate tables.
   %
   % Author: Matt Cooper
   %
   %
   % Based on tblvertcat by Sterling Baird (2020-09-05)
   %
   % Description: vertically concatenate tables with different
   % variables, filling in dummy values where necessary.
   %
   % Inputs:
   %  tbls - table, where each table can have a different number of rows and
   %  same and/or different variables*
   %
   % Outputs:
   %  tblout - vertically catenated table
   %
   % Usage:
   %  tblout = stacktables(tbl1,tbl2);
   %  tblout = stacktables(tbl1,tbl2,tbl3);
   %
   % Example:
   %
   % % define table columns
   % nrows = 3;
   % doubles = rand(nrows,1);
   % chars = repelem('a',nrows,1);
   % cells = repelem({rand(10)},nrows,1);
   % structs = repelem(struct('myvar',1),nrows,1);
   %
   % % make two tables
   % tbl1 = table(doubles,chars,structs);
   % tbl2 = table(chars,cells);
   %
   % % catenate them
   % tblout = stacktables(tbl1,tbl2)
   %
   % % Add rownames
   % tbl1.Properties.RowNames = {'a', 'b', 'c'};
   % tbl2.Properties.RowNames = {'a', 'b', 'c'};
   %
   % tblout = stacktables(tbl1,tbl2,"KeepRowNames",true);
   %
   % Notes:
   %  See https://www.mathworks.com/matlabcentral/answers/179290-merge-tables-with-different-dimensions
   %  and https://www.mathworks.com/matlabcentral/answers/410053-outerjoin-tables-with-identical-variable-names-and-unique-non-unique-keys
   %
   %  *variables of the same name must also be of the same datatype.

   arguments(Input, Repeating)
      tbls tabular
   end
   arguments(Input)
      opts.MergeCustomProps (1,1) logical = true
      opts.KeepRowNames (1,1) logical = true
   end

   %% table properties

   % Get the number of tables and number of rows in each table
   N = length(tbls);
   nrows = cellfun(@height,tbls);

   % Convert columns of chars to string if the char widths are not identical,
   % otherwise the join will fail.
   tbls = cellfun(@tblchars2string, tbls, 'un', 0);

   % % More explicit
   % for n = 1:N
   %    thistbl = tbls{n};
   %    idxchar = cellfun(@ischar,table2cell(thistbl(1,:)));
   %    varchar = thistbl.Properties.VariableNames{idxchar};
   %    thistbl.(varchar) = string(thistbl{:,idxchar});
   %    tbls{n} = thistbl;
   % end

   % Assign temporary keys going from 1 to total # rows among all tables
   rowKey = 'tpbedd3216830044debb7fc4c22fe01b92'; % purposefully obscure keyname
   tmpKey = [0 cumsum(nrows)];
   for n = 1:N
      % Assign range to rowKey column for outerjoin
      tbls{n}.(rowKey) = transpose(tmpKey(n)+1:tmpKey(n+1));
   end

   % Concatenate tables
   t1 = tbls{1};
   for n = 2:N

      % Unpack next table
      t2 = tbls{n};

      % Find shared variable names
      t1names = t1.Properties.VariableNames;
      t2names = t2.Properties.VariableNames;
      sharednames = intersect(t1names,t2names);

      % Catenation
      t1 = outerjoin(t1,tbls{n},'Key',[rowKey,sharednames],'MergeKeys',true);
   end

   % Remove temporary ids
   tblstack = removevars(t1,rowKey);

   % Collect rownames, which may or may not exist
   if all(cellfun(@istable, tbls))
      rownames = cellfun(@(tbl) tbl.Properties.RowNames, tbls, 'Uniform', 0);
   elseif all(cellfun(@istimetable, tbls))
      % Timetables do not hvae rownames
      rownames = "";
   end

   % Merge row names if they exist
   if opts.KeepRowNames && any(cellfun(@notempty, rownames))

      rownames = vertcat(rownames{:});

      % This will succeed if each table has rownames. If there are duplicates,
      % they are added as a new variable, otherwise as the RowNames property.
      try
         tblstack.Properties.RowNames = rownames;
      catch e
         if strcmp(e.identifier, 'MATLAB:table:DuplicateRowNames')
            % There are duplicate rownames, add them as a new column
            tblstack.rowNames = string(rownames);
         end

         if strcmp(e.identifier, 'MATLAB:table:IncorrectNumberOfRowNames')

            % This does not work b/c we need to know which table has them.
            % Return to this later if needed.
            rethrow(e)

            % % One or more tables does not have rownames
            % tblstack.rowNames = ...
            %    [string(rownames);
            %    repelem(missing, height(tblstack)-numel(rownames))'];
         end
      end

      % This is true if there are no duplicate rownames
      % areunique = isempty(setdiff(unique(rownames), rownames));

      % This checks if they're all equal, but not sure it is correct
      % all(cellfun(@isequal, rownames, rownames))
   end

   % Merge custom properties
   if opts.MergeCustomProps
      customProps = cellfun(@(tbl) ...
         tbl.Properties.CustomProperties, tbls, 'UniformOutput', false);

      if any(~cellfun(@(props) isempty(fieldnames(props)), customProps))
         tblstack.Properties.CustomProperties = mergeCustomProps(tbls{:});
      end
   end
end

function tbl = tblchars2string(tbl)
   try
      idxchar = cellfun(@ischar, table2cell(tbl(1, :)));
      tbl.(tbl.Properties.VariableNames{idxchar}) = string(tbl{:, idxchar});

      % Using vartype, in case it is more robust
      % varchar = string(tbl(1, vartype("char")).Properties.VariableNames);
      % tbl.(varchar) = string(tbl{:, vartype('char')});
   catch
   end
end

%% testing
% % check table props to see if the "table" or "variable" propertyType is there
% mprops = metaproperties(t1);
% for n = 1:numel(mprops)
%    [num2str(n) ' ' mprops(n).Name]
% end
%
% %mclass = metaclass(p1);
% %mprops = mclass.PropertyList;
%
% mprops = metaproperties(p1);
% mnames = {mprops.Name};
% mtypes = mclass.PropertyList
%
% % testing

%% CODE GRAVEYARD
%{
            %get variable types for each
            vartypes1=varfun(@class,t1,'OutputFormat','cell');
            vartypes2=varfun(@class,t2,'OutputFormat','cell');
            
            %% find variable IDs of different types
            %struct
            structIDtmp1 = find(strcmp('struct',vartypes1));
            structIDtmp2 = find(strcmp('struct',vartypes2));
            
            %cell
            cellIDtmp1 = find(strcmp('cell',vartypes1));
            cellIDtmp2 = find(strcmp('cell',vartypes2));
            
            %% find missing variable IDs of different types
            %struct
            structID1 = union(ia1,structIDtmp1);
            structID2 = union(ia2,structIDtmp2);
            
            %cell
            cellID1 = union(ia1,cellIDtmp1);
            cellID2 = union(ia2,cellIDtmp2);


% for i = 1:n
%     strcmp('struct',varfun(@class,tbl{i},'OutputFormat','cell')
% end

%             ia1([structID1,cellID1]) = [];
%             ia2([structID2,cellID2]) = [];

if isstruct(replaceval)
    for i = ID
        varname = varnames{ID};
        sfields = fields(t(varname));
        for j = 1:length(sfields)
            sfield = sfields{j};
            sfieldtype =
            replaceval.(sfield) =

%     if any(strcmp('tableID',fieldnames(tbl{n})))
%         error(['tbl{' int2str(n) '} contains a variable name, tableID'])
%     end


%     for p = n:ntbls     
        %             %% find missing variables
        %             nrows1 = height(t1);
        %             nrows2 = height(t2);


        %             % cell tables (cell with 0x0 double inside)
        %             [celltbl1,creplaceNames1] = replacevartbl(t2,nrows1,ia1,cell(1));
        %             [celltbl2,creplaceNames2] = replacevartbl(t1,nrows2,ia2,cell(1));
        %
        %             % remove values that are represented in cell and struct tables
        %             missing1 = setdiff(missingtmp1,creplaceNames1,'stable');
        %             missing2 = setdiff(missingtmp2,creplaceNames2,'stable');
        
        %             %% splice the missing variable tables into original tables
        %             % matrices of missing elements to splice into original
        %             missingmat1 = repelem(missing,nrows1,numel(missing1));
        %             missingmat2 = repelem(missing,nrows2,numel(missing2));
        %
        %             %tables to splice into original tables
        %             missingtbl1 = array2table(missingmat1,'VariableNames',missing1);
        %             missingtbl2 = array2table(missingmat2,'VariableNames',missing2);
        %
        %             %perform the splice
        %             tbl{n} = [t1, missingtbl1, celltbl1];
        %             tbl{p} = [t2 missingtbl2, celltbl2];
%     end

%catenate all tables
% tblout = vertcat(tbl{:});


        
        %             %get variable names from t2 that are not in t1
        %             [missingtmp1,ia1] = setdiff(t2names,t1names);
        %             %get variable names from t1 that are not in t2
        %             [missingtmp2,ia2] = setdiff(t1names,t2names);


% %% Replace Variable Table
% function [replacetbl,replaceNames] = replacevartbl(t,nrows,ia,replaceval)
% %replace type
% replacetype = class(replaceval);
% 
% %% missing variable IDs and names
% %variable names
% varnames = t.Properties.VariableNames;
% 
% %variable types
% vartypes=varfun(@class,t,'OutputFormat','cell');
% 
% %variable IDs of some type
% IDtmp = find(strcmp(replacetype,vartypes));
% 
% %missing variable IDs of different types
% ID = intersect(ia,IDtmp);
% 
% %missing variable names of different types
% replaceNames = varnames(ID);
% 
% %% construct table with replacement values and names
% %table dimensions
% nvars = length(ID);
% 
% if isstruct(replaceval) && isempty(replaceval)
%     error('if type struct, cannot be empty. Instead supply struct with no fields via struct()')
% end
% 
% replacemat = repelem(replaceval,nrows,nvars);
% replacetbl = array2table(replacemat);
% replacetbl.Properties.VariableNames = replaceNames;
% 
% end


 
%  types 'cell' and 'struct' are not supported by missing. Here, cell is
%  impelemented manually, but struct is not supported. A workaround for
%  using structs in tables is to wrap them in a cell. To implement struct()
%  would require at minimum making empty structs that mimic each field so
%  that they can be vertically catenated. Starting points would be:
%  https://www.mathworks.com/matlabcentral/answers/96973-how-can-i-concatenate-or-merge-two-structures
%  https://www.mathworks.com/matlabcentral/answers/315858-how-to-combine-two-or-multiple-structs-with-different-fields
%  https://www.mathworks.com/matlabcentral/fileexchange/7842-catstruct
%}
