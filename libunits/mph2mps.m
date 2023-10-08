function mps = mph2mps(mph)
   % Converts miles per hour to meters per second
   m_in_mi = ft2m(5280);
   s_in_hr = 3600;
   mps = mph*m_in_mi/s_in_hr;
end
