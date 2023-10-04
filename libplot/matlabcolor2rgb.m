function rgbcolor = matlabcolor2rgb(matlabcolor)
   %MATLABCOLOR2RGB Convert matlab char color representation to rgb triplet.
   %
   %  rgbcolor = matlabcolor2rgb('r')
   %
   % See also: defaultcolors

   switch matlabcolor
      case 'r'
         rgbcolor = rgb('red');
      case 'g'
         rgbcolor = rgb('green');
      case 'b'
         rgbcolor = rgb('blue');
      case 'k'
         rgbcolor = rgb('black');
      case 'y'
         rgbcolor = rgb('yellow');
      case 'm'
         rgbcolor = rgb('magenta');
      case 'c'
         rgbcolor = rgb('cyan');
      case 'w'
         rgbcolor = rgb('white');
   end
end
