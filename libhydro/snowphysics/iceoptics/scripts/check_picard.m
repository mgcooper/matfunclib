% I need to somehow tie together all the concepts. we have:
% ackermann's equation for 

% I know from Ackermann that the 'propagation coefficient' equals:
cp  = sqrt(3.*a.*be);

% I know from 


% Picard's Eq. 3 and 4 are correct, but his Eq. 6 is incorrect, I think

% Picard's Eq. 6 is inconsistent with Libois Eq. 10 only in the sense that
% Picard uses g not gG. 

% so ... the question then is whether Picard Eq. 6 is inconsistent with the
% other direction in which I derived it ... and if the 1-gG is the issue
% ... the answer is YES. If g is replaced with gG in Picard Eq. 6, then the
% equation is consistent with Libois, after substituting Picard Eq. 3/4
% and Libois' (1-g) = (1-gG)/2 into the standard equation I get the same
% expression as Libois. 

% so ... could the g error explain why Picard has higher values of kice? We
% can use one more piece of information ... Picard says he used g=0.86 and
% cites Libois 2014b (Experimental determination ...) and in that paper,
% g=0.86 is g, not gG (gG is 0.72). So, this means Picard used the
% incorrect value of g

% the difference would be:
g = 0.86;
gG = 0.72;
keP = 1;
ke = keP*sqrt((1-gG)/(1-g))
ke = keP*sqrt((1-g)/(1-gG))
ke = keP/sqrt(2)

load('Picard_Kabs_Data.mat');
wavlP   = kabs.interp.Picard_BAY_clean(:,1);
wavlW   = kabs.interp.Warren_layer_C(:,1);
kW      = kabs.interp.Warren_layer_C(:,2);
kP      = kabs.interp.Picard_BAY_clean(:,2);
figure; 
semilogy(wavlP,kP); hold on;
semilogy(wavlW,kW);
semilogy(wavlP,sqrt(2).*kP,':');


% since g = (gG+gD) = (gG+1) and Picard say's g=0.86, that implies gG=0.72
% Libois says gG varies from 0.5 to 0.8, for spheres gG=0.79, B=1.25
% Libois Table 1 has values of gG and B for different shapes

1-1.25/5.8


% my eff. scat length
% figure; plot(wavlP,


