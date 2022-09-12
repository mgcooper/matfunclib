function [tableTransposed] = transposeTable(tableIn)
%this function transposes a table. 
varNames = tableIn.Properties.VariableNames;
rowNames = tableIn.Properties.RowNames;

tableTransposed = table();

tableData = table2array(tableIn);
dataTransposed = tableData';
tableTransposed = table(dataTransposed,'RowNames',varNames);

tableSz = size(tableIn);

for n = 1:tableSz(1)
    
    tableTransposed.Properties.VariableNames{n} = rowNames{n};

                    


