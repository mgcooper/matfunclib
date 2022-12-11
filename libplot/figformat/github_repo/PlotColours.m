% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%   PLOTCOLOURS
%
%   A constant data class providing a range of colours for plots. Colours
%   and shades are produced from https://coolors.co/generate. Each colour
%   is a 12-by-3 array, where the indicies 1 through 12 return a different
%   shade of that colour, and the 3 components correspond to the RGB values
%   of that colour. Available colours:
%   
%       blue
%       orange
%       yellow
%       green
%       purple
%
%   Recommended usage: PlotColours can be used directly by accessing any of
%   the colours through,
%       PlotColours.colours.colour(n_shade, :),
%   where colour is the colour of choice and n_shade is the index
%   corresponding to the colour of choice.
%   
%   However, PlotColours is also attached to the PlotDefaults class, and
%   can be accessed by PlotDefaults.colours.colour(n_shade, :), assuming
%   PlotDefaults is present on your system.
%
%   % Copyright (C) Matthew Sparkes 2022 - 2023
%
%
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %


classdef PlotColours < handle
    properties (Constant)
        colours = PlotColours;
    end

    properties (SetAccess = protected)
        blue
        orange
        yellow
        green
        purple
        red
    end

    methods (Access = private)
        function obj = PlotColours
            obj.blue =      [
                            239, 248, 251;
                            207, 235, 242;
                            175, 221, 233;
                            135, 205, 222;
                            111, 195, 216;
                            79, 181, 207;
                            53, 164, 192;
                            44, 137, 160;
                            35, 110, 128;
                            26, 82, 96;
                            18, 55, 64;
                            9, 27, 32
                            ]./255;
        
            obj.orange =    [
                            254, 240, 236;
                            252, 209, 197;
                            250, 178, 158;
                            248, 147, 119;
                            246, 116, 81;
                            244, 86, 42;
                            233, 60, 12;
                            194, 50, 10;
                            155, 40, 8;
                            116, 30, 6;
                            78, 20, 4;
                            39, 10, 2
                            ]./255;
        
            obj.yellow  =   [
                            255, 249, 235;
                            255, 237, 194;
                            255, 224, 153;
                            255, 212, 113;
                            255, 200, 71;
                            255, 188, 31;
                            245, 171, 0;
                            204, 143, 0;
                            163, 114, 0;
                            122, 86, 0;
                            82, 57, 0;
                            41, 29, 0
                            ]./255;
        
            obj.green =     [
                            228, 243, 206;
                            210, 235, 173;
                            192, 227, 140;
                            174, 219, 107;
                            156, 211, 74;
                            137, 197, 48;
                            114, 164, 40;
                            92, 131, 32;
                            69, 99, 24;
                            46, 66, 16;
                            23, 33, 8;
                            11, 16, 4
                            ]./255;
        
            obj.purple =    [
                            249, 238, 252;
                            237, 203, 246;
                            225, 168, 240;
                            220, 150, 237;
                            212, 133, 234;
                            200, 98, 228;
                            188, 63, 222;
                            172, 35, 209;
                            143, 30, 174;
                            114, 24, 140;
                            86, 18, 105;
                            57, 12, 70
                            ]./255;
        
            obj.red =       [
                            249, 220, 220;
                            243, 185, 185;
                            237, 150, 150;
                            234, 133, 133;
                            231, 115, 115;
                            225, 81, 81;
                            220, 46, 46;
                            192, 33, 33;
                            157, 27, 27;
                            122, 21, 21;
                            87, 15, 15;
                            52, 9, 9
                            ]./255;

        end
    end
end