% tips and tricks for speed and performance
% 
% Consider the following tips on specific MATLAB functions when writing
% performance critical code. 
% 
% Avoid clearing more code than necessary. Do not use clear all
% programmatically. For more information, see clear. 
% 
% Avoid functions that query the state of MATLAB such as inputname, which, whos,
% exist(var), and dbstack. Run-time introspection is computationally expensive. 
% 
% Avoid functions such as eval, evalc, evalin, and feval(fname). Use the
% function handle input to feval whenever possible. Indirectly evaluating a
% MATLAB expression from text is computationally expensive.  
% 
% Avoid programmatic use of cd, addpath, and rmpath, when possible. Changing the
% MATLAB path during run time results in code recompilation. 

