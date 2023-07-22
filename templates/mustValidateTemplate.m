function mustValidateTemplate(arg)
%mustValidateTemplate template for validator function
%   
% argument is <describe supported argument types>
% 
% Intended for use within arguments block to validate an input
%
% Example use in argument block validation:
% 
% arguments 
%     thisarg    { must<insert this function name>(thisarg) };
% end
% 
% See also: validators

if ~conditionalStatement(arg)

   % eid is one or more component fields and a mnemonic e.g.
   % eid = 'matfunclib:libraster:XandYDoNotMatch'
   eid = 'component:mnemonic';
   msg = 'Value must be ...';
   throwAsCaller(MException(eid, msg));
   
   % matlab uses 'message' to construct the message from the message library
   % eid = "MATLAB:validators:mustBeNonzeroLengthText";
   % msg = message("MATLAB:validators:nonzeroLengthText");
   % throwAsCaller(MException(eid, msg));
end