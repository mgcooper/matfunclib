function s = optionsToNamedArguments(options)
   %OPTIONS2NAMEDARGUMENTS convert options struct to "name=value" argument list
   %
   % s.name1 = 'val1';
   % s.name2 = 'val2';
   % args = optionsToNamedArguments(s)
   %
   % See also: struct2nameval, struct2varargin, namedargs2cell

   names = string(fieldnames(options));
   s = strings(length(names),1);
   for n = 1:length(names)
      name = names(n);
      value = convertCharsToStrings(options.(name));
      if isstring(value)
         s(n) = name + "=" + """" + value + """";
      elseif isnumeric(value) || islogical(value)
         s(n) = name + "=" + value;
      end
   end
   s = join(s,",");
end
