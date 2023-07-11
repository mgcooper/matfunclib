function [RL,istart,istop] = runlength(M)
%RUNLENGTH calculate run lengths along columns of matrix M
% 
%  [RL,istart,istop] = runlength(M) returns the run lengths RL, and start and
%  stop indices ISTART and ISTOP
% 
% See also

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
