function mustBeImplicitlyExpandable(A, A_reference)
   %MUSTBEIMPLICITLYEXPANDABLE Validate that A can be broadcast to size of A2.
   %
   % MUSTBEIMPLICITLYEXPANDABLE(A, A_REFERENCE) Validates that A is implicitly
   % expandable with respect to A_reference. This means A must either be a
   % scalar or have at least one dimension size that matches the corresponding
   % dimension size of A_reference. This function is useful for ensuring
   % compatibility for element-wise operations that rely on MATLAB's implicit
   % expansion feature.
   %
   % Parameters:
   %   A: The input array to validate.
   %   A_reference: The reference array A is compared against.
   %
   % Throws:
   %   MException if A is not a scalar and does not have at least one matching
   %   dimension size with A_reference.

   if ~isscalar(A) && ~hasMatchingDimension(A, A_reference)
      eid = 'MUSTBEIMPLICITLYEXPANDABLE:notScalarOrMatchingDimension';
      msg = ['Input must be a scalar or have at least one dimension size ' ...
         'in common with the reference array.'];

      % Generally preferable to throw from here, I think, otherwise the error
      % message traces to the calling function and doesn't say
      % mustBeImplicitlyExpandable
      throw(MException(eid, msg));

      %throwAsCaller(MException(eid, msg));
   end
end

function match = hasMatchingDimension(value, reference)
   % Helper function to check if value has at least one dimension size
   % in common with reference. It compensates for differences in array
   % dimensions by considering trailing singleton dimensions as matching.
   %
   % Parameters:
   %   value: The input array to check for matching dimensions.
   %   reference: The reference array to compare dimensions against.
   %
   % Returns:
   %   match: A logical value indicating if there is at least one matching
   %   dimension size between value and reference.

   % Ensure both input and reference have the same number of dimensions by padding
   % with ones to match the greater number of dimensions between them.
   maxDims = max(ndims(value), ndims(reference));
   valueSize = size(value, 1:maxDims);
   referenceSize = size(reference, 1:maxDims);

   % Check for at least one common dimension size, excluding any dimension
   % where either size is 1 (to account for MATLAB's implicit expansion rules)
   match = any((valueSize == referenceSize) & (valueSize ~= 1 | referenceSize ~= 1));
end

