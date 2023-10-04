

readtableheaders("huc8_dhsvm.csv")

% 
readtableheaders("huc8_dhsvm.csv", ...
   "SheetNames", ["option1", "option2"], "PreserveVariableNames", false)

headers = readtableheaders("simulations.xlsx", ...
   "SheetNames", ["option1", "option2"], "PreserveVariableNames", false)