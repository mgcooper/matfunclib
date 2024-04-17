function test_AssertFalseCases
   for iT = 1:6
      try
         AssertFalseCase(iT); % All these calls have the condition as false and will throw an assert
      catch ME
         fprintf(1,sprintf('AssertFalseCase(%.0f) error caught with error ID:%s & Message:%s\n',iT,ME.identifier,ME.message));
      end
   end

   %%
function AssertFalseCase(iTest)

   assertF(true,true); % Sets assertFlag to true

   switch (iTest)
      case 1
         assertF(@() false, false); % Sets assertFlag to false. The condition false will not be evalated since it has a function handle
         assertF(0 > iTest); % Operates like the MATLAB assert function and condition is evaluated (independent of assertFlag)
      case 2
         assertF(0 > 2, false); % Sets assertFlag to false and then the condition is evaluated anyway as there is no function handle and assert is thrown
      case 3
         iValue1 = 0;
         iValue2 = iTest;
         assertF(@() iValue1 > iValue2,'%d is not greater than %d',iValue1,iValue2);
      case 4
         iValue1 = 0;
         iValue2 = iTest;
         assertF(iValue1 > iValue2,false,'%d is not greater than %d',iValue1,iValue2); % Set flag to false but condition is evaluated anyway as no function handle and assert is thrown
      case 5
         iValue1 = 0;
         iValue2 = iTest;
         assertF(true, false); % Sets assertFlag to false. The true condition will be evalated but since true no error is thrown
         assertF(iValue1 > iValue2, '%d is not greater than %d', iValue1, iValue2); % While flag is false, condition is evaluated anyway as no function handle and assert is thrown
      case 6
         iValue1 = 0;
         iValue2 = iTest;
         assertF(@() iValue1 > iValue2,'CustomError:NumberError','%d is not greater than %d',iValue1,iValue2);
   end
