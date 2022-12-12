function [iChunkStart,iChunkEnd] = chunkLoopInds(iCurrent,iBegin,iStride)

% example:    
% for i = iBegin:iEnd % where iBegin != 1            
iChunkStart  =   (iCurrent-iBegin)*iStride + 1;
iChunkEnd    =   (iCurrent-iBegin+1)*iStride; 
% if i=iEnd, then iChunkEnd=iStride*numChunks