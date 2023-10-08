function sqm = sqmi2sqm(sqmi)
   %sqmi2sqm convert square miles to square metres
   sqkm = 2.58999.*sqmi;
   sqm = sqkm.*1e6;
end
