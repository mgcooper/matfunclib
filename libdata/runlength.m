function [RL,istart,istop] = runlength(M)
   %RUNLENGTH calculate run lengths along columns of matrix M
   %
   %  [RL,istart,istop] = runlength(M) returns the run lengths RL, and start and
   %  stop indices ISTART and ISTOP
   %
   %  RL is an array the size of M. Each element of RL holds the length of the
   %  run of consecutive equal values that contains it, computed down each
   %  column of M. M must be a column vector or a matrix of column series;
   %  pass a row vector as M(:).
   %
   %  ISTART and ISTOP are linear indices into a padded array with
   %  size(M,1)+1 rows, so ISTOP - ISTART is the length of each run. For a
   %  column vector M, ISTART is the first row of each run and ISTOP - 1 is
   %  its last row.
   %
   %  NaN never equals NaN, so each NaN is a run of length 1. ISTART and
   %  ISTOP hold one entry per NaN. For example, for M = [1;1;NaN;NaN;NaN;2;2],
   %  runlength(M) returns RL = [2;2;1;1;1;2;2], ISTART = [1;3;4;5;6], and
   %  ISTOP = [3;4;5;6;8]. Callers use NaN to break runs: isminlength calls
   %  runlength, and the baseflow toolbox functions eventfinder and
   %  setconstantnan call isminlength with NaN at the values they exclude.
   %  Do not merge consecutive NaNs into one run. A long NaN gap would then
   %  pass a minimum length test and join the runs on each side.
   %
   % See also: isminlength

   % work along columns, so that you can use linear indexing

   % find locations where items change along column
   jumps = diff(M) ~= 0;

   % pad implicit jumps at start and end
   ncol = size(jumps, 2);
   % mgc modified this to make it more intuitive
   jumps = [   ones(1, ncol);
      jumps;
      ones(1, ncol)   ];
   % the original way:
   % jumps = [true(1, ncol); jumps; true(1, ncol)];


   % find linear indices of starts and stops of runs
   ijump   = find(jumps);
   nrow    = size(jumps, 1);
   istart  = ijump(rem(ijump, nrow) ~= 0); % remove fake starts in last row
   istop   = ijump(rem(ijump, nrow) ~= 1); % remove fake stops in first row
   rl      = istop - istart;
   assert(sum(rl) == numel(M));


   % make matrix of 'derivative' of runlength
   % don't need last row, but needs same size as jumps for indices to be valid
   dRL = zeros(size(jumps));
   dRL(istart) = rl;
   dRL(istop) = dRL(istop) - rl;

   % remove last row and 'integrate' to get runlength
   RL = cumsum(dRL(1:end-1,:));
end
