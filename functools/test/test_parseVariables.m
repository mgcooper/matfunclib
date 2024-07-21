% test_parseVariables

%%%%% Shared variables section

x = (1:10)';
y = (2:11)';
z = (3:12)';
V0 = table(x, y, z, 'VariableNames', {'x', 'y', 'z'});

originalVariableNames = string(V0.Properties.VariableNames);

%% test with one input
[V, returnedVariableNames, InputClass, missingVariables] = parseVariables(V0);

assert(istable(V))
assertEqual(InputClass, 'table')
assertEqual(returnedVariableNames, originalVariableNames)
assertEqual(missingVariables, string.empty(1, 0))

%% test with VariableNames input

keepVariableNames = 'x';

[V, returnedVariableNames, InputClass, missingVariables] = parseVariables( ...
   V0, keepVariableNames);

assert(istable(V))
assertEqual(InputClass, 'table')
assertEqual(returnedVariableNames, keepVariableNames)
assertEqual(missingVariables, string.empty(1, 0))

%% test with missing variable

keepVariableNames = {'x', 'a'};

[V, returnedVariableNames, InputClass, missingVariables] = parseVariables( ...
   V0, keepVariableNames);

assert(istable(V))
assertEqual(InputClass, 'table')
assertEqual(returnedVariableNames, "x")
assertEqual(missingVariables, "a")



