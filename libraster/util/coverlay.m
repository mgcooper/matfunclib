function ax = coverlay(cm, varargin)
   %COVERLAY Overlay contours on axes.
   %
   % coverlay(cm,figh,Name,Value,...) Overlay any figure with contour lines as
   % defined by the ContourMatrix.
   %
   % Syntax:
   %   coverlay(cm) - overlay current figure with contours defined by cm.
   %   coverlay(cm,figh) - overlay figure pointed by figh with contours.
   %   coverlay(...,LineSpec) - draws contours with line type and color
   %       specified by LineSpec.
   %   coverlay(...,Name,Value) - specify contour properties using one or more
   %       property name, property value pairs.
   %   cm - contourmatrix containing data defining the contours.
   %   figh - optional figure handle, otherwise current figure is used.
   %   ...Name,Value - other arguments for contour generation.
   %       See Contour Properties.
   %
   % Typical usages is as follows:
   %   cm = contourc(x,y,Z,n);
   %   figh = imagesc(x,y,ZZ) or any other command that generates an image
   %       ZZ may be a different matrix but with the same domain, x,y.
   %   coverlay(cm,figh) - overlay the figure with contours.
   %   clabel(cm,figh) - label the contours
   %
   % Note:
   %   It is important for the image domain to match the contours domain.
   %   For example use the same X & Y vectors to specify both domains.
   %
   %  created 01/09/2020 by Mirko Hrovat
   %  updated 07/10/2023 by Matt Cooper:
   %     - Added tab-completion of Line properties
   %     - Fixed error when Image figure is passed as input (parsegraphics)
   %     - Added support for held state
   %     - Added axes return argument
   %
   % See also: contourc, clabel

   % Parse possible axes input.
   [ax, varargin, ~, isfigure] = parsegraphics(varargin{:});

   if isempty(ax)
      ax = gca;
   elseif isfigure
      ax = gca(ax);
   end
   washeld = get(ax, 'NextPlot');
   hold(ax, 'on')

   n = 1;
   nmax = size(cm,2);
   done = false;
   % Now parse contourmatrix and draw contours on figure
   % level information in contourmatrix is not used
   while ~done
      nv = cm(2,n);   % number of vertices in the contour
      x = cm(1,n+1:n+nv);
      y = cm(2,n+1:n+nv);
      % draw contour
      line(ax,x,y,varargin{:})
      n = nv + n + 1;
      if n > nmax
         done = true;
      end
   end

   % Restore hold state
   set(ax, 'NextPlot', washeld);

   if nargout == 1
      varargout{1} = ax;
   end
end

%% LICENSE
%
% Copyright (c) 2020, Mirko Hrovat
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
%
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% * Neither the name of Mirtech, Inc. nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

