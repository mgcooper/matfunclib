function [width, depth, xarea, discharge] = hydraulicGeometry(option, DA, ...
      slope, ecoregion)
   %HYDRAULICGEOMETRY Estimate bankfull hydraulic geometry parameters.
   %
   % This function calculates the bankfull channel width, depth,
   % cross-sectional area, and discharge for a given drainage area and slope
   % using empirical relationships derived from regression analysis. The
   % equations were developed by the USGS from 33 streams in Massachusetts, and
   % thus may have limited applicability elsewhere.
   %
   % Usage:
   %   [width, depth, xarea, discharge] = hydraulicGeometry(darea)
   %   [width, depth, xarea, discharge] = hydraulicGeometry(darea, slope)
   %
   % Inputs:
   %   darea - Drainage area in square kilometers (km2)
   %   slope - (Optional) Channel slope in percent (%)
   %
   % Outputs:
   %   width - Bankfull channel width in meters (m)
   %   depth - Bankfull channel mean depth in meters (m)
   %   xarea - Bankfull cross-sectional area in square meters (m2)
   %   discharge - Bankfull discharge in cubic meters per second (m3/s)
   %
   % Note:
   %   If slope is not provided, single linear regression formulas are used.
   %   If slope is provided, multiple linear regression formulas are applied.
   %
   % Example:
   %   [w, d, xa, q] = hydraulicGeometry(50)
   %   [w, d, xa, q] = hydraulicGeometry(50, 2.5)
   %
   % References:
   %   https://pubs.usgs.gov/sir/2013/5155/pdf/sir2013-5155.pdf
   %
   % See also:


   %    % Sag hydraulic geometry relations:
   %    % https://pubs.usgs.gov/of/1986/0267/report.pdf
   %
   %    % Need to retrive a, c, k from report
   %    sites = ["sagwon", "atigun", "conus", "yukon"
   %    b = [0.06, 0.13, 0.12, 0.19]; % w = a * Q ^ b
   %    f = [0.46, 0.17, 0.45, 0.43]; % d = c * Q ^ f
   %    m = [0.47, 0.63, 0.43, 0.42]; % v = k * Q ^ m
   %
   % The CONUS is from Dunne and Leopold, 1972
   % THe Yukon is from Emmett, 1972
   % The sagwon is for Q>800 cfs, below which ice affected
   % The atigun is for Q>10 cfs, below which ice affected
   %
   % All units in ft and ft3/s
   %
   % Check usgs 9-207 forms


   % DA = drainage area
   % CS = channel slope

   % (for alaska):
   % ER = ecoregion
   % BFW = bankfull width [ft]
   % BFA = bankfull cross sectional area [ft2]
   % BFAD = bankfull average channel depth [ft]
   % BFMD = bankfull maximum channel depth [ft]
   % OHWw = ordinary high water width [ft]
   % SFW = summer flow width [ft]
   %


   % Validate input arguments
   narginchk(2, 3);
   validatestring( ...
      option, {'alaska', 'massachusetts', 'ak', 'mass'}, mfilename, 'OPTION', 1);
   validateattributes( ...
      DA, {'numeric'}, {'positive', 'scalar'}, mfilename, 'DAREA', 2);
   if nargin > 2
      validateattributes( ...
         slope, {'numeric'}, {'positive', 'scalar'}, mfilename, 'SLOPE', 3);
   end
   
   % Alaska equations do not provide discharge
   if strcmp(option, {'alaska', 'ak'}) 
      nargoutchk(1, 3)
   end

   % Convert darea from km2 to mi2
   DA = sqkm2sqmi(DA);

   % Apply the formulas for the requested region
   switch option

      case {'alaska', 'ak'}

         if nargin < 3

            % "Summer flow width"
            % a = 1.714;   % width = a * DA ^ b
            % b = 0.660;

            % Bankfull flow width
            a = 3.436;     % width = a * DA ^ b
            b = 0.730;
            
            % Bankfull maximum channel depth
            c = 2.070;     % depth = c * DA ^ d
            d = 0.277;
            
            % Bankfull cross-sectional area
            e = 5.875;     % xarea = e * DA ^ f
            f = 0.936;
            
            % Discharge - not available for alaska
            g = 0;
            h = 0;

         elseif nargin == 5


            CS = slope;
            ER = ecoregion;


            % Bankfull flow width (same as nargin == 3)
            a = 3.436;     % width = a * DA ^ b
            b = 0.730;
            
            % Bankfull average channel depth
            c = 0.611;     % depth = c * DA ^ d * cc * CS ^ dd * ccc * ER ^ ddd
            d = 0.238;
            cc = 1.0;
            dd = -0.0946;
            ccc = 1.0;
            ddd = 0.441;
            
            % Bankfull cross-sectional area (same as nargin == 3)
            e = 5.875;     % xarea = e * DA ^ f
            f = 0.936;
            
            % % "Summer flow width" - the "normal" summer flow width
            % a0 = 10.30; % width = a0 + a * DA ^ b + aa * CS ^ bb + aaa * ER ^ bbb
            % a = 0.115;
            % b = 1.0;
            % aa = -12769;
            % bb = 1.0;
            % aaa = 26.28;
            % bbb = 1.0;

            % Decided to stop here and just use the DA-based regressions

            % % "Summer flow width" from bankfull width
            % % width = a * BFW ^ b * CS ^ d * ER ^ e;
            %
            % c = ;    % depth = c * DA ^ d
            % d = ;
            % e = ;   % cross_sectional_area = e * DA ^ f
            % f = ;
            % g = ;   % discharge = g * DA ^ h
            % h = ;

         else

         end

      case {'massachusetts', 'mass'}

         if nargin < 3
            % Slope is not provided

            a = 15.0418;   % width = a * DA ^ b
            b = 0.4038;
            c = 0.9502;    % depth = c * DA ^ d
            d = 0.2960;
            e = 14.1156;   % xarea = e * DA ^ f
            f = 0.7026;
            g = 37.1364;   % discharge = g * DA ^ h
            h = 0.7996;

         elseif nargin == 3
            % Slope provided

            a = 10.6640;   % width = a * DA ^ b * slope ^ bb
            b = 0.3935;
            c = 0.7295;    % depth = c * DA ^ d * slope ^ dd
            d = 0.2880;
            e = 7.6711;    % xarea = e * DA ^ f * slope ^ ff
            f = 0.6842;
            g = 8.2490;    % discharge = g * DA ^ h * slope ^ hh
            h = 0.7545;

            % slope parameters
            bb = 0.1751;
            dd = 0.1346;
            ff = 0.3105;
            hh = 0.7659;

         else

            error('unrecognized number of inputs')
         end
         
         
   end

   % Compute hydraulic geometry parameters
   if nargin < 3
      % Slope is not provided
      width = a * DA ^ b;
      depth = c * DA ^ d;
      xarea = e * DA ^ f;
      discharge = g * DA ^ h;
   else
      % Slope provided
      width = a * DA ^ b * slope ^ bb;
      depth = c * DA ^ d * slope ^ dd;
      xarea = e * DA ^ f * slope ^ ff;
      discharge = g * DA ^ h * slope ^ hh;
   end

   % Convert outputs to the metric system
   width = ft2m(width); % [m]
   depth = ft2m(depth); % [m]
   xarea = sqft2sqm(xarea); % [m2]
   discharge = cfs2cms(discharge); % [m3 s-1]
end
