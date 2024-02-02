
https://www.mathworks.com/matlabcentral/answers/317695-what-is-the-penalty-for-using-a-try-catch

https://www.mathworks.com/matlabcentral/answers/151916-how-is-a-try-catch-block-evaluated?s_tid=prof_contriblnk

I have a different experience (running R2022b on macos). I run a numerical model, performance is critical. If I include a single try-catch block in a function called by the main program, with no exception handling, but an error occurs and is thus passed, I see a performance hit of up to 60%, meaning the model takes 1.6x longer to run. 

For example:
try
	% some code that may or may not error
catch
end

if the code errors, the model takes 1.6x as long to run as when the code does not error. Now, I also have codegen directives throughout my codebase and there are too many to turn them all off and see if it changes the behavior. 
