function repro_mar_regular_axis_irregular
   %REPRO_MAR_REGULAR_AXIS_IRREGULAR Regular RCM grid mis-flagged "irregular".
   %
   % Reported by the icemodel.forcing builder (2026-06-17). A real RCM grid axis
   % (MAR v3.11 native 15 km polar-stereo, variable X10_105 / Y21_199) is
   % classified "irregular" by the grid auto-detection even though the axis is
   % uniform. The file-derived axis (xkm/ykm) carries float32 STORAGE jitter --
   % its spacing varies ~2e-6 of a cell -- which the OLD absolute-tolerance
   % uniformity check rejected.
   %
   % Two defects were fixed (bug matfunclib-hfe), both in libraster/util:
   %   1. prepareMapGrid rounded the input to 10 absolute decimals before the
   %      uniformity test, injecting ~1e-10 noise into large-magnitude axes.
   %   2. customIsUniform used an ABSOLUTE tolerance; it now uses a RELATIVE
   %      tolerance (~1e-3 of the cell size) so float32 jitter is accepted while
   %      genuinely irregular axes (reprojected ~8e-2, curvilinear ~2e0) are
   %      rejected.
   %
   % Because exactremap's parseGridData delegates to libraster prepareMapGrid,
   % this also fixes the companion bead exactremap-ynp. Run from anywhere; loads
   % the saved axis in this folder.

   here = fileparts(mfilename('fullpath'));
   S = load(fullfile(here, 'mar_regular_axis_repro.mat'));

   % Use the RAW file-derived axes (xkm/ykm); these carry the float32 jitter that
   % the absolute-tolerance check used to reject. (S.xr/S.yr are a double-precision
   % reconstruction with far less jitter.)
   xr = double(S.xkm(:));
   yr = double(S.ykm(:));
   [Xm, Ym] = meshgrid(xr, yr);

   reldev = @(v) max(abs(diff(unique(v)) - mode(diff(unique(v))))) ...
      / abs(mode(diff(unique(v))));
   fprintf('relative spacing deviation:   x=%.2g  y=%.2g  (float32 jitter)\n', ...
      reldev(xr), reldev(yr));
   fprintf('per-axis builtin isuniform:   x=%d  y=%d\n', ...
      isuniform(unique(xr)), isuniform(unique(yr)));
   fprintf('per-axis customIsUniform:     x=%d  y=%d  (relative tol)\n', ...
      customIsUniform(unique(xr)), customIsUniform(unique(yr)));
   fprintf('mapGridFormat:                %s\n', mapGridFormat(Xm, Ym));
   fprintf('mapGridInfo (auto-detect):    %s\n', mapGridInfo(Xm, Ym));
   fprintf('mapGridInfo(_,''fullgrid''):    %s\n', mapGridInfo(Xm, Ym, 'fullgrid'));

   P = polyshape(xr(3) + [0 30 30 0], yr(3) + [0 0 30 30]);
   try
      exactremap(Xm + Ym, Xm, Ym, P, 'areaavg', 'UseGeoCoords', false);
      fprintf('exactremap auto-detect:       OK\n');
   catch ME
      fprintf('exactremap auto-detect:       FAIL (%s)\n', ...
         regexprep(ME.message, '\s+', ' '));
   end
end
