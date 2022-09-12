function Fit = myfit(x,y,varargin)
   
   % inspired by: https://pundit.pratt.duke.edu/wiki/MATLAB:Fitting
   
   p                 = inputParser;
   p.FunctionName    = 'myfit';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   validx            =  @(x)validateattributes(x,{'numeric'},           ...
                        {'real','vector'},'myfit','x',1);
   validy            =  @(x)validateattributes(x,{'numeric'},           ...
                        {'real','vector'},'myfit','y',2);                     
   
   addRequired(   p,'x',                           validx            );
   addRequired(   p,'y',                           validy            );
   addParameter(  p,'modeltype', 'linear',         validmodeltype    );
   addParameter(  p,'fitmethod', 'ols',            validfitmethod    );
   addParameter(  p,'pickmethod','auto',           validpickmethod   );
   addParameter(  p,'weights',   ones(size(q)),    validweights      );
   addParameter(  p,'useax',     'none',           validax           );
   addParameter(  p,'refpoints',  nan,             validrefpoints    );

   parse(x,y,varargin{:});

   modeltype   = p.Results.modeltype;
   fitmethod   = p.Results.fitmethod;
   pickmethod  = p.Results.pickmethod;
   weights     = p.Results.weights;
   refpoints   = p.Results.refpoints;
   useax       = p.Results.useax;
   unmatched      = p.Unmatched;
   
   % convert unmatched to varargin
   fields   = fieldnames(unmatched);
   for n = 1:numel(fields)
      myvarargin{2*n-1}  = fields{n};
      myvarargin{2*n}    = unmatched.(fields{n});
   end
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% % for general testing/examples:

%    % Load and manipulate the data
%    load Cantilever.dat
% 
%    Force = Cantilever(:,1) * 9.81;
%    Displ = Cantilever(:,2) * 2.54 / 100;
% 
%    %% Rename and create model data
%    x = Force;
%    y = Displ;
%    xmodel = linspace(min(x), max(x), 100);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


   linearLibrary     = {   'linear','quadratic','abline','originline',  ...
                           'trig','trigoffset','plane','general2nd',    ...
                           'right'};
                      
   nonLinearLibrary  = {   'exponential','power','satgrowth'};
   
   
   % get the function F, __ A, and initial coefficients b0
   [F,A,b0]    = setupModel(x,y,modeltype,fitmethod);
   
   % need function for models that can be solved via: 
   % coefs = A\y (works for A\Y, where Y is multidimensional)
   % coefs = 
   
   if ismember(linearLibrary,modeltype)
      
      % call the linear model fitter
      Fit   = linearSolver(x,y,modeltype,fitmethod);
      
   elseif ismember(linearizedLibrary,modeltype)
      
      Fit   = linearizedSolver(x,y,modeltype,fitmethod);
      
   elseif ismember(nonLinearLibrary,modeltype)
      
      Fit   = nonLinearSolver(x,y,modeltype,fitmethod);
      
   end
   
   
   Stats = fitEvaluator(A,Y,b,xmodel)
   
end

function Stats = fitEvaluator(A,Y,b,xmodel)

% below here doesn't change for anything   

% this is the one-dimensional setup for linear and linearized
   yhat   = F(coefs, x);
   ymodel = F(coefs, xmodel);

% this is the multi-dimensional setup:
   yhat   = F(coefs, x1v, x2v);
   ymodel = F(coefs, x1model, x2model);

% Calculate statistics (works for one- and multi-dimensional Y)

% Compute sum of the squares of the data residuals
   St = sum(( Y - mean(Y) ).^2)

% Compute sum of the squares of the estimate residuals
   Sr = sum(( Y - yhat ).^2)

% Compute the coefficient of determination
   r2 = (St - Sr) / St

% Generate estimates and model

if makeFigure == true

   if size(Y,2) == 1

      plot( x,      y,      'ko',...
            x,      yhat,   'ks',...
            xmodel, ymodel, 'k-');
            xlabel('Independent Value')
            ylabel('Dependent Value')
            title('Dependent vs. Independent and Model')
            legend('Data', 'Estimates', 'Model', 'location', 'best')

   elseif size(Y,2) > 1

      % Original data
      figure(1)
      meshc(   x1m, x2m, ym);
               xlabel('x1'); ylabel('x2'); zlabel('y Data')

      % Model data
      figure(2)
      meshc(   x1model, x2model, ymodel)
               xlabel('x1'); ylabel('x2'); zlabel('y Model')

      % Residuals
      figure(3)
      meshc(   x1m, x2m, (ym-F(coefs, x1m, x2m)))
               xlabel('x1'); ylabel('x2'); zlabel('Residuals')

   end
end

end

function [F,A,b0] = setupModel(x,y,modeltype,fitmethod)
   
% Polynomial fits are those where the dependent data is related to some set
% of integer powers of the independent variable 

switch modeltype
   
   % LINEAR
   case 'linear'
      F  = @(b, x) b(1)*x.^1 + b(2)*x.^0;
      A  =             [x.^1        x.^0];
      b0 = [0 0]; % prob replace with linearized coefs
   case 'quadratic'
      F  = @(b, x) b(1)*x.^2 + b(2)*x.^1 + b(3)*x.^0;
      A  =             [x.^2        x.^1        x.^0];
   case 'originline'
      F  = @(b, x) b(1)*x.^1;
      A  =              x.^1;
      
   case 'poly' % need to know the desired order
      
      
   % LINEAR - multidimensional
   case 'trig'
      F  = @(b, x) b(1)*cos(x) + b(2)*sin(x);
      A  =             [cos(x)        sin(x)];
   case 'trigoffset'
      F  = @(b, x) b(1)*cos(x) + b(2)*sin(x) + b(3)*x.^0;
      A  =             [cos(x)        sin(x)        x.^0];
   case 'plane'
      F  = @(b, x1e, x2e) b(1)*x1e.^1 + b(2)*x2e.^1 + b(3)*x2e.^0;
      A  =                    [x1v.^1        x2v.^1        x2v.^0];
   case 'general2nd'
      F  = @(c, x1e, x2e) c(1)*x1e.^2 + c(2)*x1e.*x2e + c(3)*x2e.^2 + c(4)*x1e + c(5)*x2e + c(6)*x1e.^0;
      A  =                    [x1v.^2        x1v.*x2v        x2v.^2        x1v        x2v        x1v.^0];
   case 'right'
      F  = @(c, x1e, x2e) c(1)*x1e.^2 + c(2)*x1e.*x2e + c(3)*x2e.^2 + c(4)*x1e + c(5)*x2e + c(6)*x1e.^0 + c(7)*cos(2*pi*x1e);
      A  =                    [x1v.^2        x1v.*x2v        x2v.^2        x1v        x2v        x1v.^0        cos(2*pi*x1v)];
   
	% NON-LINEAR - linearized
   case 'exponential'
      F  = @(b, x) b(1).*exp(b(2).*x);
   
   case 'power'
      F  = @(b, x) b(1).*x.^b(2);
     
   case 'satgrowth'
      F = @(b, x) b(1).*x./(b(2)+x);
        
   otherwise
      error('unrecognized model type')
      
end

end

function linearFitter(x,y,modeltype,fitmethod)

   % works for one- and multi-dimensional Y, linear
   b    = A\Y;
   
   % for linearized, he uses different solvers for each model:
   % see % NON-LINEAR - linearized section below
      
end

function linearizedFitter(x,y,F,modeltype)

switch modeltype
   
   % NON-LINEAR - linearized
   case 'exponential'

      xi    = x;
      eta   = log(y);
      P     = polyfit(xi, eta, 1);
      b(1)  = exp(P(2));
      b(2)  = P(1);
      
    case 'power'
      xi    = log10(x);
      eta   = log10(y);
      P     = polyfit(xi, eta, 1);
      b(1)  = 10^(P(2));
      b(2)  = P(1);
      
    case 'satgrowth'
       
      xi    = 1./x;
      eta   = 1./y;
      P     = polyfit(xi, eta, 1);
      b(1)  = 1/P(2);
      b(2)  = P(1)/P(2);

   otherwise
      error('unrecognized model type')
end

end


function nonLinearFitter(x,y,F,modeltype,fitmethod)
   
switch modeltype
      
   
   otherwise
      error('unrecognized model type')
end

% for nonlinear:
   fSSR        = @(b, x, y) sum(( y - F(b, x) ).^2);
   [coefs, Sr] = fminsearch(@(dum) fSSR(dum, x, y), b0);
   
end
   

