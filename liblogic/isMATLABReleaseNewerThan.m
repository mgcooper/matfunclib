function tf = isMATLABReleaseNewerThan(release, stage, update)
   arguments
      % Intentionally omit data type to avoid type casting
      release {mustBeTextScalar, mustBeValidRelease}
      stage   {mustBeTextScalar} = "prerelease";
      update  (1,1) {mustBeInteger, mustBeNonnegative} = 0
   end
   tf = ~isMATLABReleaseOlderThan(release, stage, update);
end

% Custom validation function validates the release name.
function mustBeValidRelease(releaseString)
   % Valid releases include R10 (version 5.2) 1998 and later.
   % Look for patterns like R10, R14SP1, R2006a, R2020a, r2020A, or R2100g
   % Disallow leading and trailing white spaces.
   
   % Copyright 2019-2020 The MathWorks, Inc.
   
   if ~isempty(regexp(releaseString,'^[Rr][0-9]{4}[A-Za-z]([Ss][Pp]\d)?$', 'once')) ...
         || ~isempty(regexp(releaseString,'^[Rr]1[0-4](\.\d|[Ss][Pp]\d)?$', 'once'))
      return;
   end
   error(message('MATLAB:isMATLABReleaseOlderThan:invalidReleaseInput'))
end
