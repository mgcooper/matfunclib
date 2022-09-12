function albedo = broadbandAlbedo(wavelength,spectralDownwelling,spectralAlbedo)
   
   totalsolar  = trapz(wavelength,spectralDownwelling);
   albedo      = trapz(wavelength,spectralAlbedo.*spectralDownwelling)/totalsolar;
end