function [V, Vmat] = EditDistance(string1, string2)
   %EDITDISTANCE Find the "edit distance" between two strings or char arrays
   %
   %  [V, VMAT] = EDITDISTANCE(STRING1, STRING2)
   %
   % Syntax
   %  [V] = EDITDISTANCE(STRING1, STRING2) Returns the minimum number of
   %  operations required to convert STRING1 to STRING2 (the "edit distance").
   %  
   %  [V, VMAT] = EDITDISTANCE(STRING1, STRING2) Also returns the matrix
   %  solution to the problem.
   % 
   % Description
   %  Edit Distance is a standard Dynamic Programming problem. Given two strings
   %  s1 and s2, the edit distance between s1 and s2 is the minimum number of
   %  operations required to convert string s1 to s2. The following operations
   %  are typically used:
   %     - Replacing one character of string by another character.
   %     - Deleting a character from string
   %     - Adding a character to string
   %
   % Examples
   %  s1 = 'article'
   %  s2 = 'ardipo'
   %  EditDistance(s1, s2)
   %  > 4
   %
   % Four actions are required to convert s1 to s2:
   %  1. replace(t,d)
   %  2. replace(c,p)
   %  3. replace(l,o)
   %  4. delete(e)
   % 
   % The second output VMAT returns the matrix solution to this problem.
   %
   %
   % by: Reza Ahmadzadeh (seyedreza_ahmadzadeh@yahoo.com -
   % reza.ahmadzadeh@iit.it)
   % 14-11-2012
   %
   % Rewritten for Modern Matlab by Matt Cooper, Apr 2024.
   %
   % See also:

   arguments (Input)
      string1 (1, :) string {mustBeTextScalar} = []
      string2 (1, :) string {mustBeTextScalar} = []
   end
   arguments (Output)
      V (1, 1) double
      Vmat (:, :) double
   end
   
   % Early exit for empty inputs.
   if isempty(string1) || isempty(string2)
      V = [];
      Vmat = [];
      return
   end
   
   % Alternative to arguments:
   % [string1, string2] = convertStringsToChars(string1, string2);

   M = length(string1);
   N = length(string2);
   Vmat = zeros(M+1, N+1);
   for m = 1:M
      Vmat(m+1, 1) = m;
   end
   for n = 1:N
      Vmat(1, n+1) = n;
   end
   for m = 1:M
      for n = 1:N
         if (string1(m) == string2(n))
            Vmat(m+1, n+1) = Vmat(m, n);
         else
            Vmat(m+1, n+1) = 1 + min(min(Vmat(m+1,n), Vmat(m,n+1)), Vmat(m,n));
         end
      end
   end
   V = Vmat(M+1, N+1);
end

%% Ancient version

%{
m=length(string1);
n=length(string2);
v=zeros(m+1,n+1);
for i=1:1:m
    v(i+1,1)=i;
end
for j=1:1:n
    v(1,j+1)=j;
end
for i=1:m
    for j=1:n
        if (string1(i) == string2(j))
            v(i+1,j+1)=v(i,j);
        else
            v(i+1,j+1)=1+min(min(v(i+1,j),v(i,j+1)),v(i,j));
        end
    end
end
V=v(m+1,n+1);
end
%}
