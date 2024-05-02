function [colors] = defaultcolors(N, opts)
   %GETDEFAULTCOLORS Returns the default color triplets
   %
   %  [colors] = defaultcolors() returns the default color order triplets
   %
   % See also: distinguishable_colors

   arguments
      N = 21
      opts.palette string { ...
         mustBeMember(opts.palette, ["default", "distinguishable"])} = "default"
   end

   switch char(opts.palette)
      case 'default'
         colors = get(groot,'defaultaxescolororder');
      case 'distinguishable'
         colors = makedistinguishablecolors(N);
         return
   end

   % add some additional colors
   newcolors = [
      0.25 0.80 0.54      % turquoise
      0.76 0.00 0.47      % magenta
      0.83 0.14 0.14
      1.00 0.54 0.00
      0.47 0.25 0.80];

   colors = [colors; newcolors]; % N = 12

   % add the first nine colors from distinguishable colors
   colors = [colors;
      0	0	1
      1	0	0
      0	1	0
      0	0	0.172413793103448
      1	0.103448275862069	0.724137931034483
      1	0.827586206896552	0
      0	0.344827586206897	0
      0.517241379310345	0.517241379310345	1
      0.620689655172414	0.310344827586207	0.275862068965517]; % N = 21

   if ~isempty(N)
      colors = colors(1:N, :);
   end
end

function colors = makedistinguishablecolors(N)
   try
      colors = distinguishable_colors(N);
   catch e
      % Use custom cform
      func = @(x) colorspace('RGB->Lab', x);

      % The colors are distinguishable relative to the background color which is
      % the second argument 'w'.
      colors = distinguishable_colors(N, 'w', func);
   end
end

