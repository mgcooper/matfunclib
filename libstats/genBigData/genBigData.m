function genBigData(numBlocks, numFiles)
%GENBIGDATA general description of function
%
%  ds = GENBIGDATA(numBlocks, numFiles) generates tabular text datastore ds to
%  test big data tools
% 
% Example
%
%
% Matt Cooper, 21-Jan-2023, https://github.com/mgcooper
%
% See also

arguments
   numBlocks (:,1) double
   numFiles (:,1) double
end

% GENERATE DATA
rng("default")
ds = datastore("airlinesmall.csv", TreatAsMissing="NA", Delimiter=",");
ds.TextscanFormats([11, 23]) = {'%s'};
data = readall(ds);
newData = data;
delete("airlinebig*.csv")
h = waitbar(0, "0 of " + numBlocks + " blocks written.");
c = onCleanup(@() close(h));
for k = 1:numBlocks
   newData.ArrDelay = data.ArrDelay + round(5*randn(size(data.ArrDelay)));
   writetable(newData, "airlinebig"+k+".csv", "WriteMode","append")
   waitbar(k/numFiles, h, k + " of " + numBlocks + " blocks written.");
end
h = waitbar(0, "0 of " + numFiles + " copies created.");
c = onCleanup(@() close(h));
for k = 2:numFiles
   copyfile("airlinebig1.csv", "airlinebig"+k+".csv");
   waitbar(k/numFiles, h, k + " of " + numFiles + " copies created.");
end


