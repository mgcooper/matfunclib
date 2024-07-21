function info = polyinfo(P)

   [numvertices, numregions, numholes, numsides, numboundaries] = ...
      deal(zeros(numel(P), 1));

   for n = 1:numel(P)
      p = P(n);
      numvertices(n) = numel(p.Vertices) / 2;
      numregions(n) = p.NumRegions;
      numholes(n) = p.NumHoles;
      numsides(n) = p.numsides;
      numboundaries(n) = p.numboundaries;
   end
   info = table(numvertices, numregions, numholes, numsides, numboundaries);
end
