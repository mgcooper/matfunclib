function out = iif(logicalstatement, outiftrue, outiffalse)
   %IIF emulates javas ? operator
   %
   % Syntax:
   %
   %  out = iif(logicalstatement, outifTrue, outifFalse)
   %
   %
   % DESCRIPTION
   % simplifies following statement:
   %   if foo == bar
   %      var = something;
   %   else
   %      var = something else;
   %   end
   % to:
   %   var = iif(foo == bar, something, something else);
   %
   % VERSIONING
   %             Author: Andreas Justin
   %      Creation date: 2018-11-19
   %             Matlab: 9.5, (R2018b)
   %  Required Products: -
   %
   % REVISONS
   % V0.1 | 2018-11-19 | Andreas Justin      | first implementation
   %
   % See also
   %
   % EXAMPLES
   %{
    iif(true, "TRUE", "FALSE")
        ans = 
            "TRUE"
   %}
   %
   % Borrowed by: Matt Cooper, 27-Oct-2022, https://github.com/mgcooper

   if logicalstatement
      out = outiftrue;
   else
      out = outiffalse;
   end
end
