function s = optionsToNamedArguments(options)
%OPTIONS2NAMEDARGUMENTS
names = string(fieldnames(options));
s = strings(length(names),1);
for k = 1:length(names)
   name = names(k);
   value = options.(name);
   if isstring(value)
      s(k) = name + "=" + """" + value + """";
   elseif isnumeric(value) || islogical(value)
      s(k) = name + "=" + value;
   end
end
s = join(s,",");