function mustBeVectorValued(P)

   % Or name it:
   % elementsMustBeVectors
   % mustContainOnlyVectors
   % mustNotContainMatrix

   assert(all(cellfun(@isvector, P)));
end
