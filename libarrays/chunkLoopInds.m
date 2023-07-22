function varargout = chunkLoopInds(iCurrent,iBegin,iStride)
% chunkLoopInds return start and end index to access chunks of array
%  
% [iChunkStart,iChunkEnd] = chunkLoopInds(iCurrent,iBegin,iStride) returns start
% and end indices to access elements of matrix A in chunks of size
% numel(iStride). If A has size NxM, then N = numel(A)/M, and M = iStride. N is
% also equal to max(iCurrent), assuming this function is called for all chunks
% of size iStride over array M. The iBegin parameter is nominally 1 if looping
% over all elements of A, but can be set to some other value to allow accessing
% a portion of array A.
% 
% idx = chunkLoopInds(iCurrent,iBegin,iStride) returns iChunkStart:iChunkEnd as
% an array (vector) of indices to use as linear indices.
% 
% Example
% 
% iBegin = 365;
% iEnd = 365*4;
% iStride = 365;
% for i = iBegin:iStride:iEnd % where iEnd-iStride+1 >= iBegin >= 1
%    
%    % [iChunkStart,iChunkEnd] = chunkLoopInds(i, iBegin, 4)
%    % % is equivalent to:
%    % iChunkStart = (i-1)*4 + 1;
%    % iChunkEnd = (i-1+1)*iStride;
%    % note: if i=iEnd, then iChunkEnd == iEnd == iStride*(iEnd/numChunks
% end
% 
% 
% See also: 

iChunkStart = (iCurrent-iBegin)*iStride + 1;
iChunkEnd = (iCurrent-iBegin+1)*iStride;

switch nargout
   case 1
      varargout{1} = iChunkStart:iChunkEnd;
   case 2
      varargout{1} = iChunkStart;
      varargout{2} = iChunkEnd;
end