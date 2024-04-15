function varargout = chunkLoopInds(icurrent, ibegin, istride)
   %CHUNKLOOPINDS Return start and end index to access chunks of array
   %
   %  [ISTART, IEND] = CHUNKLOOPINDS(ICURRENT, IBEGIN, ISTRIDE) Returns start
   %  and end indices to access elements of matrix A in chunks of size ISTRIDE.
   %  Here, ICURRENT is the current loop iteration index and IBEGIN is the first
   %  loop iteration index.
   %
   %  For vector V with P elements, if ISTRIDE is an even divisor of P, then V
   %  can be reshaped into an array A of size NxM, with N = ISTRIDE and M = P/N.
   %  Thus ISTRIDE samples each "column" of the reshaped vector.
   %
   %  IDX = CHUNKLOOPINDS(ICURRENT, IBEGIN, ISTRIDE) Returns the list of linear
   %  indices ISTART:IEND.
   %
   % Example
   %  ibegin = 1;
   %  istride = 10;
   %  icurrent = 1;
   %  [istart, iend] = chunkLoopInds(icurrent, ibegin, istride)
   %  >>
   %     istart = 1, iend = 10
   %
   %  icurrent = 2;
   %  [istart, iend] = chunkLoopInds(icurrent, ibegin, istride)
   %  >>
   %     istart = 11, iend = 20
   %
   % See also:

   % TODO: Add option to check if ISTRIDE is an even divisor of numel(A)

   istart = (icurrent - ibegin) * istride + 1;
   iend = (icurrent - ibegin + 1) * istride;

   switch nargout
      case 1
         varargout{1} = istart:iend;
      case 2
         varargout{1} = istart;
         varargout{2} = iend;
   end
end
