function [XOUT, I] = rmnan(XIN, DIM)
   %RMNAN Remove NaN values from data array
   %
   %  [OUT, I] = rmnan(IN, DIM) removes nan values from IN and returns OUT.
   %
   % See also: setnan, setval

   % this needs to be merged with setnan which allows to pass in logical indices

   if iscell(XIN)
      if nargin == 1, DIM = 1; end

      I = false(size(XIN));
      for n = 1:size(XIN, DIM)
         if isdatetime(XIN)
            if all(isnat(XIN{n})); I(n) = true; end
         elseif isstring(XIN)
            if all(ismissing(XIN{n})); I(n) = true; end
         else
            if all(isnan(XIN{n})); I(n) = true; end
         end
      end
      XIN(I) = [];
      XOUT = XIN;
   else

      if isdatetime(XIN)
         fnc = @(x) isnat(x);
      elseif isstring(XIN)
         fnc = @(x) ismissing(x);
      elseif istabular(XIN)

      else
         fnc = @(x) isnan(x);
      end

      if nargin == 1
         I = fnc(XIN);
         XIN(I) = [];
         XOUT = XIN;
      elseif nargin == 2
         if DIM == 1
            I = fnc(XIN(:,1));
            XIN(I,:) = [];
            XOUT = XIN;
         elseif DIM == 2
            I = fnc(XIN(1,:));
            XIN(:,I) = [];
            XOUT = XIN;
         end
      end
   end
end
