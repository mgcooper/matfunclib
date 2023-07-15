function opts = setopts(funcname,varargin)
%SETOPTS set toolbox options.
%
%  Required inputs
%
%     funcname    : 'getevents', 'fitevents', or 'globalfit'
%
%     indicates whether to send back the default options for the event detection
%     algorithm 'getevents', the event fitting algorithm 'fitdqdt', or the
%     global fitting algorithm 'globalfit'
%
%  Optional name-value inputs for type 'getevents'
%
%     opts        :  structure containing any of the following fields
%
%     qmin        :  minimum flow value, below which values are set nan (m3/d)
%     nmin        :  minimum event length
%     fmax        :  maximum # of missing values gap-filled
%     rmax        :  maximum runlength of sequential constant values
%     rmin        :  maximum allowable rainfall in mm/d 
%     cmax        :  maximum run of sequential convex dQ/dt values
%     rmconvex    :  remove convex derivatives
%     rmnochange  :  remove consecutive constant derivates
%     rmrain      :  remove data on days with rainfall>rmin
%     pickevents  :  option to manually pick events
%     plotevents  :  option to plot picked events
%     asannual    :  option to detect events on an annual basis
%
%  Optional name-value inputs for type 'fitevents'
% 
%     derivmethod    : derivative (dQ/dt) method
%     fitmethod      : -dQ/dt = aQb fitting method
%     fitorder       : fitting order (value of exponent b)
%     fitnmin        : minimum number of values required to fit -dQ/dt = aQb 
%     pickfits       : pick fits manually?
%     pickmethod     : method to fit picks manually
%     plotfits       : plot the fits?
%     savefitplots   : save plots of fits?
%     etsparam       : min flow length parameter for ETS algorithm
%     vtsparam       : min flow length parameter for VTS algorithm
%     drainagearea   : drainage area in m2
%     gageID         : station name or ID
% 
%  Optional name-value inputs for type 'globalfit'
% 
%     drainagearea   : drainage area [m2]
%     drainagedens   : drainage density [km-1] = streamlength/drainagearea
%     aquiferdepth   : reference aquifer thickness [m]
%     streamlength   : effective channel length [m]
%     aquiferslope   : effective aquifer slope
%     aquiferbreadth : distance from channel to divide
%     drainableporos : drainable porosity
%     isflat         : logical indicating true or false
%     plotfits       : plot the various global fits?e
%     bootfit        : logical indicating whether to bootstrap the uncertainites
%     nreps          : number of reps for bootstrapping 
%     phimethod      : method used to fit drainable porosity
%     refqtls        : quantiles of Q and -dQ/dt for early/late reference lines
%     earlyqtls      : quantiles of Q and -dQ/dt for early reference lines
%     lateqtls       : quantiles of Q and -dQ/dt for late reference lines
%
%  Matt Cooper, 22-Oct-2022, https://github.com/mgcooper
%
%  See also getfits, fitdqdt

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

%% set default bfra settings

p = inputParser;
p.FunctionName = mfilename;

p.addRequired('funcname',@ischar);
parse(p,funcname);

switch funcname

   % event detection - input options for getevents
   case 'getevents'

      addParameter(p,   'qmin',        1,          @(x) bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'nmin',        4,          @(x) bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'fmax',        1,          @(x) bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'rmax',        2,          @(x) bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'rmin',        1,          @(x) bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'cmax',        2,          @(x) bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'rmconvex',    false,      @(x) bfra.validation.islogicalscalar(x)  );
      addParameter(p,   'rmnochange',  true,       @(x) bfra.validation.islogicalscalar(x)  );
      addParameter(p,   'rmrain',      true,       @(x) bfra.validation.islogicalscalar(x)  );
      addParameter(p,   'pickevents',  false,      @(x) bfra.validation.islogicalscalar(x)  );
      addParameter(p,   'plotevents',  false,      @(x) bfra.validation.islogicalscalar(x)  );
      addParameter(p,   'asannual',    false,      @(x) bfra.validation.islogicalscalar(x)  );

   % event fits - input options for fitevents
   case 'fitevents'

      addParameter(p,   'derivmethod', 'ETS',      @(x) ischar(x)             );
      addParameter(p,   'fitmethod',   'nls',      @(x) ischar(x)             );
      addParameter(p,   'fitorder',    'free',     @(x) ischar(x)|isnumeric(x));
      addParameter(p,   'pickfits',    false,      @(x) bfra.validation.islogicalscalar(x)    );
      addParameter(p,   'pickmethod',  'none',     @(x) ischar(x)             );
      addParameter(p,   'plotfits',    false,      @(x) bfra.validation.islogicalscalar(x)    );
      addParameter(p,   'saveplots',   false,      @(x) bfra.validation.islogicalscalar(x)    );
      addParameter(p,   'etsparam',    0.2,        @(x) bfra.validation.isnumericscalar(x)    );
      addParameter(p,   'vtsparam',    1.0,        @(x) bfra.validation.isnumericscalar(x)    );
      
   % global fit - input to bfra.globalfit
   case 'globalfit'

      addParameter(p,   'drainagearea',   nan,           @(x)bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'drainagedens',   0.8,           @(x)bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'aquiferdepth',   nan,           @(x)bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'streamlength',   nan,           @(x)bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'aquiferslope',   0.0,           @(x)bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'aquiferbreadth', nan,           @(x)bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'drainableporos', 0.1,           @(x)bfra.validation.isnumericscalar(x)  );
      addParameter(p,   'isflat',         true,          @(x)bfra.validation.islogicalscalar(x)  );
      addParameter(p,   'plotfits',       false,         @(x)bfra.validation.islogicalscalar(x)  );
      addParameter(p,   'bootfit',        false,         @(x)bfra.validation.islogicalscalar(x)  );
      addParameter(p,   'nreps',          1000,          @(x)bfra.validation.isdoublescalar(x)   );
      addParameter(p,   'phimethod',      'pointcloud',  @(x)ischar(x)           );
      addParameter(p,   'refqtls',        [0.50 0.50],   @(x)bfra.validation.isnumericvector(x)  );
      addParameter(p,   'earlyqtls',      [0.95 0.95],   @(x)bfra.validation.isnumericvector(x)  );
      addParameter(p,   'lateqtls',       [0.50 0.50],   @(x)bfra.validation.isnumericvector(x)  );

end

parse(p,funcname,varargin{:});

opts = p.Results;
opts = rmfield(opts,'funcname');

