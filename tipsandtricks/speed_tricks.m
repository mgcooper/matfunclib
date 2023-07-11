function varargout = speed_tricks(varargin)
%SPEED_TRICKS speed tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%% JIT 

% From the OCTAVE faq:
% Matlab includes a "Just-In-Time" compiler. This compiler allows the
% acceleration of for-loops in Matlab to almost native performance with certain
% restrictions. The JIT must know the return type of all functions called in the
% loops and so you can't include user functions in the loop of JIT optimized
% loop

% If true - I did not know about the restriction on user functions

% Octave links to this which I think I found on my own a while back:
% https://web.archive.org/web/20140217072457/http://www.stat.cmu.edu/~nmv/2013/07/09/for-faster-r-use-openblas-instead-better-than-atlas-trivial-to-switch-to-on-ubuntu/

%% tips and tricks for speed and performance
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

% DONT USE ISBETWEEN and avoid year(datetime)
% https://www.mathworks.com/matlabcentral/answers/402023-why-are-datetime-operations-so-slow

% See signal processing section of tips book


%% library of fast functions

% lightspeed toolbox
% https://github.com/MarcinKonowalczyk/poly-fast-matlab.git (test shows little
% to no improvement relative to polyfit in r2022b)

%% tips and tricks

% For some reason this helped it finally click how in place operations work. I
% can go back to of trisolve notation:
% https://stackoverflow.com/questions/72207854/matlab-cant-modify-data-in-place
% The key thing is that the function arguments dont have to share the same name
% in the calling and function workspace, but the input / output arg names have
% to be the same wihtin each space

% make everything a function

% preallocate the random number arrays then index into them instead of generating each time

% always put column index as outer loop i.e.:
% for j = 
% 	for i = 
% 		A(i,j) = ...
% 	end
% end
% 
% parfor should be ok since each photon is independent. i can initialize phi_s
% as 2_pi.*rand(N,1) and then index into it with ps = phi_s(n), then I should
% also be able to create initialized vl, uz, uy, and ux since those are also not
% random and do not depend on prior values    
% 
% BUT since wt changes does that matter? I think not because it is within the
% while loop but should test to confirm 
% 
% see this:
% https://www.mathworks.com/help/parallel-computing/reduction-variable.html


% Use 'length' not @length for cellfun see link below for why and other similar
% https://undocumentedmatlab.com/articles/cellfun-undocumented-performance-boost

% do a find on these:
% cellfun(@isempty
% cellfun(@islogical
% cellfun(@isreal
% cellfun(@length
% cellfun(@ndims
% cellfun(@numel % equivalent is 'prodofsize'
% cellfun(@size
% cellfun(@isclass % equivalent 

% also avoid cellfun(@(x) isempty(x), ...) if instead cellfun(@isempty,...) can
% be used (for any function, not just isempty, which i just used as an example)

% Never put curly braces on rhs if they can go on lhs :
% https://www.mathworks.com/matlabcentral/answers/873328-speeding-up-using-cellfunction-and-arrayfun-versus-for-loop
% 

% Every function should operate on it's inputs and return them as outputs. If
% variables passed in are not modified then Matlab can use pass by reference 

% Use accel off to see if jit matters, didn't look into it much but try this:
% https://www.mathworks.com/help/simulink/ug/how-the-acceleration-modes-work.html

% this post discusses accel off:
% https://www.mathworks.com/matlabcentral/answers/99537-which-type-of-function-call-provides-better-performance-in-matlab

% Use try catch instead of if else when if else would just catch an error

% Using int for indexing variables might be faster because of the ceil calc,
% somewhere i found ceil is much slower with double

% Type checking function inputs, I assumed slows down code, but so expert says
% no: Recall, however, that Matlab compiles the code before running so even if
% you need to test many conditions it will be quite fast. Run the profiler to
% see.   

% check vvar: https://www.mathworks.com/matlabcentral/fileexchange/34276-vvar-class-a-fast-virtual-variable-class-for-matlab?s_tid=answers_rc2-1_p4_Topic
% also adcarray (and memmapfile in general) https://www.mathworks.com/matlabcentral/fileexchange/11097-adcarray?s_tid=srchtitle


% revisit this for caching and/or memoization
% https://undocumentedmatlab.com/articles/datestr-performance

%% on oop speed

% https://www.mathworks.com/matlabcentral/answers/15533-object-oriented-programming-performance-comparison-handle-class-vs-value-class-vs-no-oop?s_tid=answers_rc1-1_p1_Topic
% https://www.mathworks.com/matlabcentral/answers/579270-nested-functions-vs-object-oriented-programming-k-d-tree-example-and-relative-performance?s_tid=answers_rc1-3_p3_Topic

%% resources

%%% boilerplate
% https://www.mathworks.com/matlabcentral/answers/96817-what-things-can-i-do-to-increase-the-speed-and-memory-performance-of-my-matlab-code?s_tid=srchtitle
% https://www.mathworks.com/company/newsletters/articles/programming-patterns-maximizing-code-performance-by-optimizing-memory-access.html

%%% hardware
% https://www.mathworks.com/matlabcentral/answers/92044-is-it-possible-to-choose-computer-hardware-which-best-optimizes-the-performance-of-matlab

%%% functions 
% https://www.mathworks.com/matlabcentral/answers/99537-which-type-of-function-call-provides-better-performance-in-matlab?s_tid=srchtitle
% https://www.mathworks.com/matlabcentral/answers/80001-speed-functions-and-overheads?s_tid=answers_rc1-3_p3_Topic

%%% indexing
% https://www.mathworks.com/matlabcentral/answers/54522-why-is-indexing-vectors-matrices-in-matlab-very-inefficient?s_tid=srchtitle

%%% linear interpolation
% https://www.mathworks.com/matlabcentral/fileexchange/8627-fast-linear-interpolation?s_tid=answers_rc2-1_p4_Topic

%%% plotting
% next one might be irrelevant with newer matlab
% https://www.mathworks.com/matlabcentral/fileexchange/47205-fastscatter-m

%%% speeding up builtins
% https://www.mathworks.com/matlabcentral/answers/106903-which-matlab-operations-functions-need-speeding-up?s_tid=srchtitle
% https://www.mathworks.com/matlabcentral/answers/77843-what-functions-can-benefit-from-simple-patching#answer_87648

%%% pre-allocation
% https://www.mathworks.com/matlabcentral/answers/381431-performance-of-cell-arrays-multi-dimensional-arrays-structure-arrays-and-multiple-variables?s_tid=srchtitle
% https://www.mathworks.com/matlabcentral/fileexchange/31362-uninit-create-an-uninitialized-variable-like-zeros-but-faster

%%% oop
% https://www.mathworks.com/matlabcentral/answers/15533-object-oriented-programming-performance-comparison-handle-class-vs-value-class-vs-no-oop?s_tid=srchtitle

%%% file i/o
% https://blogs.mathworks.com/loren/2006/04/19/high-performance-file-io/

%%% math libraries
% https://www.mathworks.com/matlabcentral/answers/396296-what-if-anything-can-be-done-to-optimize-performance-for-modern-amd-cpu-s?s_tid=srchtitle
% next only relevant to AMD CPUs
% https://www.mathworks.com/matlabcentral/answers/1672304-how-can-i-use-the-blas-and-lapack-implementations-included-in-amd-optimizing-cpu-libraries-aocl-wi



% https://blogs.mathworks.com/loren/2007/03/22/in-place-operations-on-data
% 
% https://blogs.mathworks.com/loren/2020/07/31/the-value-of-value-semantics/
% 
% Mcrt surprising experience with no function calls
% 
% Canonical matlab help page see speed_fun notes I copied from it
% 
% Yair's blog
% 
% Matlabs point about Set get methods in classes and private methods not clear
% on it but basically if a resource intensive method is private I think then
% there is less overhead, see:
% https://blogs.mathworks.com/loren/2012/03/26/considering-performance-in-object-oriented-matlab-code/
% 
% fnc(obj, data) is faster than obj.fnc(data)
% 
% 
% 
% addpath, path operations, dbstack, evalin, etc are not good for performance.
% Work on, setup type stuff probably doesn't matter since they're called once,
% but magic parser uses evalin, does input parser? Since function signatures
% don't require input parser afaik, I could stop using it or use it less often,
% or use optionParser           

% Summary of:
% https://towardsdatascience.com/5-simple-hacks-to-speed-up-your-matlab-code-f160103b13bf
% - use jsystem if making system calls
% - The golden rule for MATLAB is to always assign the index of the faster loop
% to the most left part of the matrix dimensions and the slowest to the most
% right part. This rule also applies to tensors.
% For example: (NOTE: I don't find any difference, but mine is ~0.05 sec, wonder
% why so much slower?)
% 
% n = 1000;
% A = zeros(n, n);
% 
% % Column major assignment
% tic;
% for i = 1:n % slow loop
%     for j = 1:n % fast loop
%         A(i, j) = i + j;
%     end
% end
% toc % In my computer 0.005984sec
% 
% % Column major assignment
% tic;
% for j = 1:n % fast loop
%     for i = 1:n % slow loop
%         A(i, j) = i + j;
%     end
% end
% toc % In my computer 0.001053sec
% 
% - faster 1-d interpolation: interp1qr
% https://www.mathworks.com/matlabcentral/fileexchange/43325-quicker-1d-linear-interpolation-interp1qr?s_tid=prof_contriblnk
% NOTE: on fex, test says griddedInterpolant now faster
% 
% - dont do large logical temporary arrays:
% dont do this:
% a = round(rand(1e4));
% tic, b = any(a(:)~=0); toc
% instead do this:
% tic, c = any(a(:)); toc
% >> Elapsed time is 0.000188 seconds. (x337 speed up)



%% random notes

% - the point about recompiling every time a code changes, maybe also
% functionSignatures? Either way - the importance of compiling everything before
% running a mission critical workflow   
% - undocumented matlab posts about optimizing built-ins
% - datastores
% - stripped down figures
% - should parfor alwasy be used?
% - does functionSignatures increase speed? does it depend on inputparser? 
% - arcane stuff like clear classes, rebuilding hash, 
% - 

%% blas / lapack

% for changing the math libraries:
% - see my function machineinfo.m
% - https://www.mathworks.com/matlabcentral/answers/396296-what-if-anything-can-be-done-to-optimize-performance-for-modern-amd-cpu-s?s_tid=srchtitle

% mathworks docs on lapack:
% https://www.mathworks.com/help/matlab/math/lapack-in-matlab.html
% https://www.mathworks.com/help/matlab/matlab_external/calling-lapack-and-blas-functions-from-mex-files.html
% https://www.mathworks.com/help/coder/ug/generate-code-that-calls-lapack-functions.html


% table of matlab release features:
% https://www.mathworks.com/matlabcentral/answers/492752-table-of-matlab-release-features

%% mex

% % from a random answer, note this is for windows
% % MATLAB ships with BLAS and LAPACK libraries. E.g., on Windows for 64-bit
% % Microsoft compilation, you can typically find them here: 
% lib_blas   = [matlabroot '\extern\lib\win64\microsoft\libmwblas.lib']
% lib_lapack = [matlabroot '\extern\lib\win64\microsoft\libmwlapack.lib']
% % To link your code with these, you can just do this:
% cfilename = 'my_mex_name.c';
% mex(cfilename,lib_blas,lib_lapack);

