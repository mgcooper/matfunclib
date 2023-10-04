function [keys,vals] = getenvall(method)
   %GETENVALL Get all environment variables.
   %
   %  [KEYS, VALS] = getenvall() returns cell arrays KEYS, VALS containing all
   %  system environment variables.
   %
   %  [KEYS, VALS] = getenvall(METHOD) uses METHOD to retrieve the environment
   %  variables. When METHOD is 'system', a call to system('set') is used if
   %  ispc() returns TRUE, otherwise a call to system('env') is used (e.g., on
   %  macos). When METHOD is 'java', a call to java.lang.System.getenv() is
   %  used. Default METHOD is 'system'.
   %
   % % Example
   % % Retrieve all environment variables and print them
   %
   % [keys,vals] = getenvall();
   % cellfun(@(k,v) fprintf('%s=%s\n',k,v), keys, vals);
   %
   % % Build a MATLAB map or a table
   % m = containers.Map(keys, vals);
   % t = table(keys, vals);
   %
   % % access some variable by name
   % disp(m('OS'))   % similar to getenv('OS')
   %
   % See also: getuserpath, cdenv

   if nargin < 1
      method = 'system';
   else
      method = validatestring(method, {'java', 'system'});
   end

   persistent onpc; if isempty(onpc); onpc = ispc(); end

   switch method
      case 'java'
         map = java.lang.System.getenv();  % returns a Java map
         keys = cell(map.keySet.toArray());
         vals = cell(map.values.toArray());

      case 'system'
         cmd = ifelse(onpc, 'set', 'env');
         [~,out] = system(cmd);
         vars = regexp(strtrim(out), '^(.*)=(.*)$', ...
            'tokens', 'lineanchors', 'dotexceptnewline');
         keys = arrayfun(@(k) vars{k}(1), 1:numel(vars)).';
         vals = arrayfun(@(v) vars{v}(2), 1:numel(vars)).';
   end

   % Convert environment variables to UPPERCASE on PC and sort alphabetically
   ifelse(onpc, upper(keys), keys); [keys,ord] = sort(keys); vals = vals(ord);

   % not implemented: hack for hidden variables on pc
   % if onpc && hidden
   %    [~,out] = system('set "');
   % end
end
