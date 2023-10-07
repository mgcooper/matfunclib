function tf = ishg2()
   %ISHG2 Return logical true if Matlab/Octave is running with HG1 or HG2 engine
   %
   %  tf = ishg2()
   %
   % The main difference between HG1 and HG2 is that HG1 uses get(object,field),
   % while HG2 supports both HG1 syntax and object.field calls.
   %
   % Compatibility:
   %
   % Matlab: should work on all releases (tested on R2017a and R2012b)
   % Octave: tested on 4.2.1
   % OS:     written on Windows 10 (x64), the code should work cross-platform.
   %
   % Version: 1.0
   % Date:    2017-09-18
   % Author:  H.J. Wisselink
   % Email=  'h_j_wisselink*alumnus_utwente_nl';
   % Real_email = regexprep(Email,{'*','_'},{'@','.'})
   %
   % See also: isoctave

   persistent HandleGraphics2_since_R2014b_unique_name_to_prevent_error
   if isempty(HandleGraphics2_since_R2014b_unique_name_to_prevent_error)
      if exist('OCTAVE_VERSION', 'builtin')
         % Octave is currently (v4.2) fully compatible with HG1-style calls,
         % but might in a future version also switch to object calls with the
         % dot notation. If that happens, this can be expanded with a similar
         % test as the one for Matlab below.
         HandleGraphics2_since_R2014b_unique_name_to_prevent_error=false;
         tf=HandleGraphics2_since_R2014b_unique_name_to_prevent_error;
         return
      end
      %(R2014b is version 8.4)
      Matlab_version = version;
      Matlab_version = str2double(Matlab_version(1:3));
      HandleGraphics2_since_R2014b_unique_name_to_prevent_error = ...
         Matlab_version>=8.4;
   end
   tf=HandleGraphics2_since_R2014b_unique_name_to_prevent_error;
end

%% LICENSE
%
% Copyright (c) 2017, Rik Wisselink
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
