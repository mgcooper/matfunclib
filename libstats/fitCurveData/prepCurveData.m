function [varargout] = prepCurveData( varargin )
%PREPCURVEDATA Prepare data for curve fitting.
% 
%  Transform data, if necessary, for the fitCurveData function as follows:
%
%       * Return data as columns regardless of the input shapes. Error if
%       the number of elements do not match. Warn if the number of elements
%       match, but the sizes are different.
%
%       * Convert complex to real (remove imaginary parts) and warn.
%
%       * Remove NaN/Inf from data and warn.
%
%       * Convert nondouble to double and warn.
%
%       * If input X is empty then output X will be a vector of indices into
%       output Y. The fitCurveData function can then use output vector X as
%       x-data when there is only y-data.
% 
% 
%  X = PREPCURVEDATA(X) prepare X for fitCurveData
% 
%  [X,Y] = PREPCURVEDATA(X,Y) prepare X and Y for fitCurveData
% 
%  [X,Y,W] = PREPCURVEDATA(X,Y,W) prepare X, Y, and weights W for fitCurveData
% 
%  Data = PREPCURVEDATA('default') return default curve data for linear model
% 
%  Data = PREPCURVEDATA(modeltype) return default curve data for model type
%  specified by char/string-scalar `modeltype`. Valid options are
%  'linear','exponential','power','semilogx','semilogy'. 'semilogy' is the same
%  as 'exponential'. 
% 
% 
% Example
% 
% 
% Matt Cooper, 17-Jan-2023, https://github.com/mgcooper
% Inspired by prepareCurveData, Copyright 2011 The MathWorks, Inc.
% 
% See also: genCurveData, fitCurveData, plotCurveData

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'prepCurveData';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

validstrings = {'default','linear','exponential','power','semilogx','semilogy'};
validoption = @(x)any(validatestring(x,validstrings));

p.addOptional(    'x',                       @(x)isnumeric(x)     );
p.addOptional(    'y',                       @(x)isnumeric(x)     );
p.addOptional(    'w',        ones(size(x)), @(x)isnumeric(x)     );
p.addOptional(    'modeltype','default',     validoption          );

p.parseMagically('caller');
%------------------------------------------------------------------------------

% I didn't finish this ... inputparser might be too much to deal with
% defaultCurveData

% if input X is empty, it needs to replaced by a index vector for YIN
[x,y,w] = prepInputs(x,y,w);

% The inputs must all have the same number of elements
assertInputsHaveSameNumElements( varargin{:} );

% Prepare the data for fitting
[varargout{1:nargin}] = prepareFittingData( varargin{:} );



function assertInputsHaveSameNumElements( x, y, w )
% assertInputsHaveSameNumElements Ensure that all inputs have the same number
% of elements
if numel(x) ~= numel(y) || (nargin == 3 && numel(x) ~= numel(w) )
    error(message('libstats:prepCurveData:unequalNumel'));
end

function [x, y, w] = prepInputs( x, y, w )
% prepInputs If x is empty then replace it by an index vector the same size and
% shape as y. If weights (w) is empty then return a vector of ones the same size
% and shape as y. 
if isempty(x)
    x = reshape(1:numel(y),size(y));
end

if isempty(w)
   w = ones(size(y));
end




