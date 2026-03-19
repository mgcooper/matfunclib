function sqft = sqmi2sqft(sqmi)
   % sqmi2sqft Convert square miles to square feet
   %
   %  SQFT = SQMI2SQFT(SQMI) converts area values from square miles to square
   %  feet.
   %
   % Inputs
   %  sqmi - Area in square miles.
   %
   % Outputs
   %  sqft - Area in square feet.

   arguments
      sqmi {mustBeNumeric, mustBeReal}
   end

   sqft = sqmi .* 27878400; % 1 square mile = 27,878,400 square feet
end
