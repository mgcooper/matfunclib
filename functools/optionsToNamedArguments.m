function s = optionsToNamedArguments(options)
   %OPTIONS2NAMEDARGUMENTS convert options struct to "name=value" argument list
   %
   % s.name1 = 'val1';
   % s.name2 = 'val2';
   % args = optionsToNamedArguments(s)
   %
   % See also: struct2nameval, unmatched2varargin, namedargs2cell

   names = string(fieldnames(options));
   s = strings(length(names),1);
   for k = 1:length(names)
      name = names(k);
      value = convertCharsToStrings(options.(name));
      if isstring(value)
         s(k) = name + "=" + """" + value + """";
      elseif isnumeric(value) || islogical(value)
         s(k) = name + "=" + value;
      end
   end
   s = join(s,",");
end
