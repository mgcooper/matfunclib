function Y = plotCurveData(X,flag1,flag2,options)
%PLOTCURVEDATA general description of function
% 
% Syntax
% 
%  Y = PLOTCURVEDATA(X) description
%  Y = PLOTCURVEDATA(X,'flag1') description
%  Y = PLOTCURVEDATA(X,'flag2') description
%  Y = PLOTCURVEDATA(___,'options.name1',options.value1,'options.name2',options.value2) description
%        The default flag is 'plot'. 
% 
% Example
% 
% 
% Matt Cooper, 17-Jan-2023, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------

arguments
   X (:,1) double
   flag1 (1,1) string {mustBeMember(flag1,{'add','multiply'})} = 'add'
   flag2 (1,1) string {mustBeMember(flag2,{'plot','figure','none'})} = 'none'
   options.LineStyle (1,1) string = "-"
   options.LineWidth (1,1) {mustBeNumeric} = 1
end

% inputArg (dim1,dim2) ClassName {valfnc1,valfunc2} = defaultValue
% doc argument-validation-functions
% see argumentsTest folder for ppowerful examples of accessing built-in
% name-value options w/tab completion
%------------------------------------------------------------------------------




