function surfaceForcing = seasonalSurfaceEnergyFlux(annualAverageFlux   ,...
                            annualAmplitudeFlux,timeInSeconds)

                        
  surfaceForcing = annualAverageFlux - annualAmplitudeFlux .*           ...
                    cos(2*pi.*timeInSeconds./timeInSeconds(end));
  
% Qbar    = -0.5;
% t       = 1:t0;
% Qt      = Qbar - Q0.*cos(2*pi.*t./t0);

% figure; plot(t,Qt)