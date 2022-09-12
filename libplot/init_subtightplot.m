function [ set ] = init_subtightplot( gap_pct_vert,gap_pct_horz, ...
                                    marh_pct_low,marh_pct_high , ...
                                    marw_pct_left,marw_pct_right)
%INIT_SUBTIGHTPLOT A good starting point for gap marh marw
gap_pct_vert = gap_pct_vert/100;
gap_pct_horz = gap_pct_horz/100;
marh_pct_low = marh_pct_low/100;
marh_pct_high = marh_pct_high/100;
marw_pct_left = marw_pct_left/100;
marw_pct_right = marw_pct_right/100;

set.gap     =   [gap_pct_vert gap_pct_horz];
set.marh    =   [marh_pct_low marh_pct_high];
set.marw    =   [marw_pct_left marw_pct_right];

% set.gap     =   [gap_pct_vert*0.08 gap_pct_horz*0.08];
% set.marh    =   [marh_pct_low*0.08 marh_pct_high*0.08];
% set.marw    =   [marw_pct_left*0.08 marw_pct_right*0.08];
end

