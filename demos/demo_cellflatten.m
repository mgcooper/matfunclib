%% Demo: Different ways to extract a variable from a struct of tables

% Create a struct of tables
S0 = struct();
S0.tbl1 = table([1; 2; 3], ['a'; 'b'; 'c'], 'VariableNames', {'key', 'val'});
S0.tbl2 = table([4; 5; 6], ['d'; 'e'; 'f'], 'VariableNames', {'key', 'val'});
S0.tbl3 = table([7; 8; 9], ['g'; 'h'; 'i'], 'VariableNames', {'key', 'val'});

varname = 'key'; % The variable we want to extract from each table

%% Using cellflatten to obtain an array in one step:
A = cellflatten(struct2cell(...
   structfun(@(tbl) tbl.(varname), S0, 'UniformOutput', false)));
disp('Cellflatten:')
disp(A)

%% Methods comparison

% Below here goes step by step even when possible to chain into one step.

% Method 1: Using cell2mat
S = structfun(@(tbl) tbl.(varname), S0, 'UniformOutput', false);
C = struct2cell(S);
A = transpose(cell2mat(cellfun(@transpose, C, 'UniformOutput', false)));
disp('cell2mat:')
disp(A)

% Method 2: Using cell concatenation
A = structfun(@(tbl) tbl.(varname), S0, 'UniformOutput', false);
A = struct2cell(A);
A = [A{:}];
disp('cell concatenation:')
disp(A)

% Method 2 variant: Using struct2array (undocumented function). This does the
% same thing Method 2 does but can be chained into one step (see the performance
% comparison below).
A = structfun(@(tbl) tbl.(varname), S0, 'UniformOutput', false);
A = struct2array(A);
disp('struct2array:')
disp(A)


% Method 3: Using cellflatten (with dimension specification)
A = structfun(@(tbl) tbl.(varname), S0, 'UniformOutput', false);
A = struct2cell(A);
A = cellflatten(A, 2);
disp('cellflatten with dim=2:')
disp(A)


%% Performance comparison

% Use struct2array to mimic the horizontal concatenation method.
methods = {
   ...
   @() transpose(cell2mat(cellfun(@transpose, ...
   struct2cell(structfun(@(tbl) tbl.(varname), S0, 'Uniform', false)), ...
   'Uniform', false))), ...
   ...
   @() struct2array( ...
   structfun(@(tbl) tbl.(varname), S0, 'Uniform', false)) ...
   ...
   @() cellflatten( ...
   struct2cell(structfun(@(tbl) tbl.(varname), S0, 'Uniform', false)))
   };

num_runs = 1000;
times = zeros(length(methods), num_runs);

for i = 1:length(methods)
   for j = 1:num_runs
      tic;
      methods{i}();
      times(i,j) = toc;
   end
end

avg_times = mean(times, 2);
disp('Average execution times (in seconds):')
disp(array2table(avg_times, ...
   'RowNames', ...
   {'Method 1: cell2mat', 'Method 2: struct2array', 'Method 3: cellflatten'}))

[best_time, best_method] = min(avg_times);
disp(['The fastest method is Method ' num2str(best_method) ...
   ' with an average time of ' num2str(best_time) ' seconds.'])
