function matlabinfo
   %MATLABINFO  MATLAB configuraton characteristics
   %   MATLABINFO prints important performance characteristics of MATLAB, the
   %   the operating system and hardware.  The information describes the
   %   circumstances under which a performance test was run to allow
   %   someone else to duplicate the results.
   %
   %   The information field may include any of, but usually not all of
   %
   %      title date version assertions root accelerator desktop jvm
   %      figures rendering cpu cpuspeed numbercpus ram swapspace os
   %
   %   To capture the output in a MATLAB string, use
   %      res = evalc('MATLABINFO');
   %
   % Copyright (c) 2016, The MathWorks, Inc.
   %
   % Renamed from 'configinfo' to 'matlabinfo' by Matt Cooper, 2023

   % tested on GLNX86 PCWIN MAC SOL2 HPUX GLNXA64
   disp('MATLAB configuration information');
   disp(['This data was gathered on: ' datestr(now)]);
   disp(['MATLAB version: ' version]);
   disp(['MATLAB root: ' matlabroot]);
   if feature('accel')
      if feature('jit')
         disp('MATLAB accelerator enabled');
         disp('MATLAB JIT: enabled');
      else
         disp('MATLAB accelerator: enabled');
         disp('MATLAB JIT: disabled');
      end
   else
      disp('MATLAB accelerator: disabled');
      disp('MATLAB JIT: disabled');
   end

   if feature('isdebug')
      disp('MATLAB assertions: enabled');
   else
      disp('MATLAB assertions: disabled');
   end
   if usejava('desktop')
      disp('MATLAB Desktop: enabled');
   else
      disp('MATLAB Desktop: disabled');
   end
   if usejava('jvm')
      disp('Java JVM: enabled');
      disp(['Java version: ' version('-java')])
   else
      disp('Java JVM: disabled');
   end

   disp(['CPU: ' feature('getcpu')]);
   try %#ok
      if strcmp(computer, 'GLNX86') || strcmp(computer, 'PCWIN')
         mhz = num2str(ceil(feature('timing', 'cpuspeed')/1000000));
         disp(['The measured CPU speed is: ' mhz ' MHz']);
      end
   end

   if strcmp(computer, 'GLNX86') || strcmp(computer, 'GLNXA64')
      [a,b] = unix('cat /proc/cpuinfo | grep processor | wc -l');
      if a == 0    % normal return from exec
         np = regexp(b, '[0-9]+', 'once', 'match');
         disp(['Number of processors: ' np])
      end

      [a,b] = unix('cat /proc/cpuinfo');
      if a == 0    % normal return from exec
         p  = strfind(b, 'cpu MHz');
         np = regexp(b(p:end), '[0-9]+', 'once', 'match');
         disp(['CPU speed is: ' np ' MHz']);
      end

      [a,b] = unix('cat /proc/meminfo');
      if a == 0    % normal return from exec
         p     = strfind(b, 'MemTotal');
         mem   = regexp(b(p:end), '[0-9]+', 'once', 'match');
         disp(['RAM: ' mem ' kB']);
         p     = strfind(b, 'SwapTotal');
         mem   = regexp(b(p:end), '[0-9]+', 'once', 'match');
         disp(['Swap space: ' mem ' kB']);
      end
   elseif strcmp(computer, 'PCWIN')
      np = getenv('NUMBER_OF_PROCESSORS');
      disp(['Number of processors: ' np]);
   end

   if strcmp(computer, 'SOL2')
      [a,b] = unix('prtconf');
      if a == 0    % normal return from exec
         p     = strfind(b, 'Memory size');
         mem   = regexp(b(p:end), '[0-9]+', 'once', 'match');
         disp(['RAM: ' mem ' MB']);
      end
   end

   if strcmp(computer, 'PCWIN')
      cmp    = evalc('feature(''memstats'')');
      pts    = strfind(cmp, 'Total:');
      mem    = regexp(cmp(pts(1):end), '[0-9]+', 'once', 'match');
      disp(['RAM: ' mem ' MB']);
      mem    = regexp(cmp(pts(2):end), '[0-9]+', 'once', 'match');
      disp(['Swap space: ' mem ' MB']);
   end
   disp(feature('getos'));
   disp(['Number of cores: ' num2str(feature('numcores'))])
   disp(['Number of threads: ' num2str(feature('numthreads'))]);
end

%% LICENSE
%
% Copyright (c) 2016, The MathWorks, Inc.
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution.
%     * In all cases, the software is, and all modifications and derivatives
%       of the software shall be, licensed to you solely for use in conjunction
%       with MathWorks products and service offerings.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

