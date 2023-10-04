function elsevalue = ifelse(condition, thenvalue, elsevalue)

arguments
   condition (1,1) logical
   thenvalue
   elsevalue
end

if condition
   elsevalue = thenvalue;
end


% function result = ifelse(condition, thenvalue, elsevalue)
%
% if condition
%    result = thenvalue;
% else
%    result = elsevalue;
% end

% function result = ifelse(condition,truevalue,falsevalue)
% if condition
%     result = truevalue;
% else
%     result = falsevalue;
% end
