function test_AssertCallTimes(iCount)
   if (nargin == 0)
      % Large number so we can see how using condition with and without handle
      % and false flag saves time
      iCount = 10000000; 
   end
   
   % mgc I started to modify these based on the new behavior but stopped
   
   % None of the following tests cause failures either because the condition is
   % true (so does not matter if flag is true or false) OR the condition is
   % false and uses a function handle and the assertFlag is false We cannot test
   % conditions where the condition is false and does not use a function handle
   % - since the condition is evaluated anyways (like MATLAB's assert)
   fprintf(1,'\n');
   
   % Normal MATLAB assert
   
   % Normal assert function call (always evaluated since no function handle)
   assert(sum(ones(1,iCount)) < iCount + 1); 
   
   % Place in handle so timing can be evaluated
   hf1 = @() assert(sum(ones(1,iCount)) < iCount + 1);
   f1_time = timeit(hf1);
   fprintf(1,'%.6f: MATLAB assert call time\n',f1_time);
   
   % assertF with no function handle
   assertF on
   
   % Normal assert function call (always evaluated since no function handle)
   assertF(sum(ones(1,iCount)) < iCount + 1);
   
   % Place in handle so timing can be evaluated
   hf2 = @() assertF(sum(ones(1,iCount)) < iCount + 1);
   f2_time = timeit(hf2);
   fprintf(1,'%.6f: assertF toggled on, called with no function handle and true condition (same as assert)\n',f2_time);
   
   % assertF with no function handle and true condition (same as assert) with
   % true flag always present
   
   % Normal assert function call (always evaluated since no function handle)
   assertF(sum(ones(1,iCount)) < iCount + 1,true);
   
   % Place in handle so timing can be evaluated
   hf3 = @() assertF(sum(ones(1,iCount)) < iCount + 1); 
   f3_time = timeit(hf3);
   fprintf(1,'%.6f: assertF with no function handle to true condition (same as assert) with true flag present\n',f3_time);
   
   % Our assertF with function handle to true condition with true flag always
   % present
   assertF(@() sum(ones(1,iCount)) < iCount + 1,true); % assert function call (evaluated based on assertFlag since it has a function handle)
   hf4 = @() assertF(@() sum(ones(1,iCount)) < iCount + 1,true); % Place in handle so timing can be evaluated
   f4_time = timeit(hf4);
   fprintf(1,'%.6f: assertF with function handle to true condition with true flag present\n',f4_time);
   % Our assertF with function handle to true condition with true flag not
   % present (but true)
   assertF(true,true); % Sets assertFlag to true
   assertF(@() sum(ones(1,iCount)) < iCount + 1); % assert function call (evaluated based on assertFlag since it has a function handle)
   hf5 = @() assertF(@() sum(ones(1,iCount)) < iCount + 1); % Place in handle so timing can be evaluated
   f5_time = timeit(hf5);
   fprintf(1,'%.6f: assertF with function handle to true condition with true flag not present (but true)\n',f5_time);
   % Our assertF with function handle to false condition with false flag present
   assertF(@() sum(ones(1,iCount)) < iCount + 0,false); % assert function call (evaluated based on assertFlag since it has a function handle)
   hf6 = @() assertF(@() sum(ones(1,iCount)) < iCount + 0,false); % Place in handle so timing can be evaluated
   f6_time = timeit(hf6);
   fprintf(1,'%.6f: assertF with function handle to false condition with false flag present\n',f6_time);
   % Our assertF with function handle to false condition with false flag not
   % present (but false)
   assertF(true,false); % Sets flag to false
   assertF(@() sum(ones(1,iCount)) < iCount + 0); % Does not check the false condition
   hf7 = @() assertF(@() sum(ones(1,iCount)) < iCount + 0); % Place in handle so timing can be evaluated
   f7_time = timeit(hf7);
   fprintf(1,'%.6f: assertF with function handle to false condition with false flag not present (but false)\n',f7_time);
end