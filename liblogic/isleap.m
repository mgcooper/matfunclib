function out = isleap(year)

% Script to assess if a given year (in the Gregorian Calendar system) is a leap year or not.
% It returns 0 if it is not a leap year, 
% it returns 1 if it is a leap year.
% 
% Isaac M. M., Trieste(Italy). June 8, 2011 @16h05:37
% Istituto Nazionale di Oceanografia e di Geofisica Sperimentale
% Trieste, ITALY.
%
% Developed under Matlab(TM) 7.1.0.183 (R14) Service Pack 3
% Last modified on June 8, 2011 @16h05:37

out = ( (mod(year,4 ) == 0 ) | (mod(year,400) == 0) ) & ~( (mod(year,100) == 0) & ~(mod(year,400) == 0) );

% This is the pseudo-code applied:
%
%year = year(:);
%
%if mod(year,400) == 0
%   out = 1;
%else
%   if mod(year,100) == 0
%      out = 0;
%   else
%      if mod(year,4) == 0
%         out = 1;
%      else
%         out = 0;
%      end;
%   end;
%end;

% Copyright (c) 2011, Isaac Mancero Mosquera
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
%       the documentation and/or other materials provided with the distribution
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

