clearvars
clc

iBegin = 1;
iStride = 365;

Nyears = 4; % number of data "chunks"
chunkStart = 2; %
chunkEnd = Nyears;

iEnd = 365*Nyears;

for i = chunkStart:chunkEnd

   [iChunkStart, iChunkEnd] = chunkLoopInds(i, chunkStart, iStride);

   % is equivalent to:
   iChunkStart = (i-chunkStart)*iStride + 1;
   iChunkEnd = (i-chunkStart+1)*iStride;

   % where chunkStart effectively 'resets' the start index to account for
   % skipping the first year (in this example)

   % note: if i=iEnd, then iChunkEnd == iEnd == iStride*(iEnd/numChunks
end
