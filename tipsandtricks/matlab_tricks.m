function varargout = matlab_tricks(varargin)
%MATLAB_TRICKS matlab tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%% documentation

% rickynite/m2html
% PymatFlow/m2html
% firdavsmd9/M2HTMLProject
% tmxkn1/m2htmlext

%% people worth following

% https://www.mathworks.com/matlabcentral/fileexchange/?q=profileid:1010505
% https://www.mathworks.com/matlabcentral/fileexchange/?q=profileid:781437
% https://www.mathworks.com/matlabcentral/fileexchange/?q=profileid:3073010
% https://www.mathworks.com/matlabcentral/fileexchange/?q=profileid:46856
% https://www.mathworks.com/matlabcentral/fileexchange/?q=profileid:8668631
% https://www.mathworks.com/matlabcentral/fileexchange/?q=profileid:591043
% https://www.mathworks.com/matlabcentral/profile/authors/870065?detail=fileexchange
% https://www.mathworks.com/matlabcentral/profile/authors/390839?detail=fileexchange
% https://github.com/auralius?tab=repositories

%% WOW iterators work differently than I thought ...

% https://stackoverflow.com/questions/408080/is-there-a-foreach-in-matlab-if-so-how-does-it-behave-if-the-underlying-data-c
% https://blogs.mathworks.com/loren/2006/07/19/how-for-works/

% for description of how built-in behavior differs from foreach:
% https://blogs.mathworks.com/pick/2015/02/27/for-each/

% KEY THING is the for loop can iterate over columns of any primitive-type, so
% you have to think in terms of columns. See example using fieldnames at bottom.

% NOTE, it would be jhelpufl to add an eachstruct to the for-each toolbox that
% would iterate over each element (field) of a scalar struct


% 1) Define start, increment and end index
for test = 1:3:9
   test
end

% 2) Loop over vector
for test = [1, 3, 4]
   test
end

% 3) Loop over string
for test = 'hello'
   test
end

% 4) Loop over a one-dimensional cell array
for test = {'hello', 42, datestr(now) ,1:3}
   test
end

% 5) Loop over a two-dimensional cell array
for test = {'hello',42,datestr(now) ; 'world',43,datestr(now+1)}
   test(1)   
   test(2)
   disp('---')
end

% 6) Use fieldnames of structure arrays
s.a = 1:3 ; s.b = 10  ; 
for test = fieldnames(s)'
   s.(cell2mat(test))
end

% mgc: instead of cell2mat, convert to string array:
s.a = 1:3 ; s.b = 10  ; 
for test = string(fieldnames(s)')
   s.(test)
end

% these were my initial tests 
% test = 1:10;
% for i = test
%    disp(i)
% end
% 
% test = magic(3);
% test2 = test;
% for i = test
% %    disp(i')
%    test2 = test*i
% end



%% Best/least known matlab tricks:

% choices=fieldnames
% choices=function that reads directory
% varargin default Matlab arguments
% arguments block version of above
% mlx to html documentation?
% userdata property of plots
% On cleanup
% setenv/getenv
% validatestring
% Using java
% ?sugar (also see doc metaclass)
% mixin

% Can this be Used to run as shell script?
%{
gdal
%}

% IDEA: 

% If mfilename~='namespace'
% runcode(mfilename)
% return

% Where runcode reads the text of the file up to the line 'If
% mfilename~='namespace' , pastes that into a temp file, passes that to feval,
% then cleans up      

% To properly import, the import keyword would have to generate an object which
% when called does the same thing described above so when pkg.func is called
% its actually feval'ing the temp script, and from pkg import func creates a
% link from func to the temp file

%% best practices

% Search for instances of these and change:
% DONE clear all
% DONE exist(,'var') but search for ,'var') and ,'var')==
