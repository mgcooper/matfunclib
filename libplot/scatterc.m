function varargout = scatterc(x,y,sz,c,opts)
   %SCATTERC scatter plot with filled face colors
   %
   %  H = SCATTERC(X,Y) makes a scatter plot of x,y with filled face colors
   %  H = SCATTERC(X,Y,SZ) sets the circle size to sz
   %  H = SCATTERC(X,Y,SZ,C) maps the face colors to data in C
   %  H = SCATTERC(_,'flag') description
   %  H = SCATTERC(_,'opts.name1',opts.value1,'opts.name2',opts.value2) applies
   %  any option available to built-in SCATTER function.
   %
   % Example
   %
   %
   % See also: scatter

   % Did not finish, idea was to formalize the stuff in demo_colorbar to ensure
   % scatter face colors are linked across subplots

   % PARSE ARGUMENTS
   arguments
      x (:,1) double
      y (:,1) double
      sz (:,1) double
      c (:,1) double
      opts.?matlab.graphics.chart.primitive.Scatter
   end

   % MAIN CODE


   % PARSE OUTPUTS
   % [varargout{1:nargout}] = dealout(argout1, argout2);

end

%% LOCAL FUNCTIONS


%% TESTS

%!test

% ## add octave tests here

%% LICENSE
%
% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
