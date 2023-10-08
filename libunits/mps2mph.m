function mph = mps2mph(mps)
   %Converts meters per second to miles per hour
   m_in_mi = ft2m(5280);
   s_in_hr = 3600;
   mph = (mps/m_in_mi)*s_in_hr;
end
