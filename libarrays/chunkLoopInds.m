function [iChunkStart,iChunkEnd] = chunkLoopInds(iCurrent,iBegin,iStride)
% chunkLoopInds return start and end index for indice chunks
% 
% example:    
% for i = iBegin:iEnd % where iBegin != 1    
%  iChunkStart  = (iCurrent-iBegin)*iStride + 1;
%  iChunkEnd    = (iCurrent-iBegin+1)*iStride; 
% if i=iEnd, then iChunkEnd=iStride*numChunks

iChunkStart  = (iCurrent-iBegin)*iStride + 1;
iChunkEnd    = (iCurrent-iBegin+1)*iStride; 