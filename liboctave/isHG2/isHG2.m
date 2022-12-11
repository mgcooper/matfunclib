function tf=isHG2
%Find out if the Matlab/Octave version running this code is HG1 or HG2.
% The main difference between the two is that HG1 uses get(object,field),
% while HG2 supports both HG1 syntax and object.field calls. A lot of
% objects had their fields change or syntax changed. (e.g. to separate tick
% labels you will have to use new line character instead of the | symbol in
% HG2)
%
% Compatibility:
% Matlab: should work on all releases (tested on R2017a and R2012b)
% Octave: tested on 4.2.1
% OS:     written on Windows 10 (x64), the code should work cross-platform.
%
% Version: 1.0
% Date:    2017-09-18
% Author:  H.J. Wisselink
% Email=  'h_j_wisselink*alumnus_utwente_nl';
% Real_email = regexprep(Email,{'*','_'},{'@','.'})

%The idea of using a persistant variable is borrowed from the IsOctave
%function by Kurt von Laven.
%https://www.mathworks.com/matlabcentral/profile/authors/2405642-kurt-von-laven
%https://www.mathworks.com/matlabcentral/fileexchange/28847-is-octave
persistent HandleGraphics2_since_R2014b_unique_name_to_prevent_error
% (From the persistent doc:)
% "It is an error to declare a variable persistent if a variable with the
% same name exists in the current workspace. MATLAB also errors if you
% declare any of a function's input or output arguments as persistent
% within that same function."
if isempty(HandleGraphics2_since_R2014b_unique_name_to_prevent_error)
    if exist('OCTAVE_VERSION', 'builtin')
        %Octave is currently (v4.2) fully compatible with HG1-style calls,
        %but might in a future version also switch to object calls with the
        %dot notation. If that happens, this can be expanded with a similar
        %test as the one for Matlab below.
        HandleGraphics2_since_R2014b_unique_name_to_prevent_error=false;
        tf=HandleGraphics2_since_R2014b_unique_name_to_prevent_error;
        return
    end
    %(R2014b is version 8.4)
    Matlab_version=version;Matlab_version=str2double(Matlab_version(1:3));
    HandleGraphics2_since_R2014b_unique_name_to_prevent_error=...
        Matlab_version>=8.4;
end
tf=HandleGraphics2_since_R2014b_unique_name_to_prevent_error;
end