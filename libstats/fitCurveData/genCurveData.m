function data = genCurveData(varargin)
%GENCURVEDATA generate default data for curve fitting testing
% 
%  data = genCurveData(opts)
% 
% See also: defaultCurveData, genBigData

% no inputs, return default linear curve data
if nargin == 0
   data = defaultCurveData('linear');
   return
elseif nargin == 1
   
   if isstruct(varargin{1})
      % one input, if struct, assume opts
      opts = varargin{1};
      modeltype = opts.modeltype;
   else
      % one input, if not struct, return default modeltype curve data
      validateattributes(varargin{1},{'char'},{'nonempty'},mfilename,'modeltype',1);
      data = defaultCurveData(varargin{1});
      return
   end
else
   opts = varargin{1};
   modeltype = varargin{2};
   if isfield(opts,'modeltype')
      warning('opts contains field modeltype, using input argument 2, modeltype')

   end
end

xmu     = opts.x.mu_data;
xmuerr  = opts.x.mu_err;
ymuerr  = opts.y.mu_err;
xsigerr = opts.x.sig_err;
ysigerr = opts.y.sig_err;
N       = opts.N;
Nboot   = opts.Nboot;

% create an ensemble of data with random errors
x = xmu .* sort(rand(N,1));

% NOTE: these aren't fully implemented ... x will need to be geenrated
% differently depending on the function i think at aleast for logistic

% modeltypes assume functions of the form:
% y      = a      + b*x          ->    y     = a+b*x        'linear'
% log(y) = log(a) + b*log(x)     ->    y     = a*x^b        'power'
% log(y) = log(a) + b*x          ->    y     = a*e^(b*x)    'semilogy'
% y      = a      + b*log(x)     ->    e^y   = a*x^b        'semilogx'

switch modeltype
   case 'linear'
      y = opts.a + opts.b*x;
   case {'exponential','semilogy'} % assume exponential is semilogy
      y = opts.a.*exp(opts.b.*x);
   case {'semilogx'}
      y = opts.a + opts.b.*log(x);
   case 'power'
      y = opts.a.*x.^opts.b;
end

xerr = normrnd(xmuerr,xsigerr,N,Nboot);
yerr = normrnd(ymuerr,ysigerr,N,Nboot);
rxy  = arrayfun(@(k) corr(xerr(:,k),yerr(:,k)),1:Nboot,'Uni',1);

data.x      = x;
data.y      = y;
data.xerr   = xerr;
data.yerr   = yerr;
data.xobs   = x+xerr;
data.yobs   = y+yerr;
data.rxy    = rxy;
data.X      = [ones(size(x)),x];
data.Xobs   = [ones(size(x)),data.xobs];


