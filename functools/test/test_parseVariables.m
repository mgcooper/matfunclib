% test_parseVariables

%%%%% Shared variables section

x = (1:10)';
y = (2:11)';
z = (3:12)';
V0 = table(x, y, z, 'VariableNames', {'x', 'y', 'z'});

originalNames = string(V0.Properties.VariableNames);

%% test with one input
[V, returnedNames, InputClass, missingNames, extraNames] = parseVariables(V0);

assert(istable(V))
assertEqual(InputClass, 'table')
assertEqual(returnedNames, originalNames)
assertEqual(missingNames, string.empty(1, 0))
assertEqual(extraNames, string.empty(1, 0))

%% test with expected VariableNames input and dropExtraNames false

expectedNames = 'x';

[V, returnedNames, InputClass, missingNames, extraNames] = parseVariables( ...
   V0, expectedNames, dropExtraNames=false);

assert(istable(V))
assertEqual(InputClass, 'table')
assertEqual(returnedNames, originalNames)
assertEqual(missingNames, string.empty(1, 0))
assertEqual(extraNames, setdiff(originalNames, expectedNames));

%% test with expected VariableNames input and dropExtraNames true

expectedNames = 'x';

[V, returnedNames, InputClass, missingNames, extraNames] = parseVariables( ...
   V0, expectedNames, dropExtraNames=true);

assert(istable(V))
assertEqual(InputClass, 'table')
assertEqual(returnedNames, expectedNames)
assertEqual(missingNames, string.empty(1, 0))
assertEqual(extraNames, setdiff(originalNames, expectedNames));
assert(isempty(intersect(returnedNames, extraNames)))

%% test with missing variable and dropExtraNames false

expectedNames = {'x', 'a'};

[V, returnedNames, InputClass, missingNames, extraNames] = parseVariables( ...
   V0, expectedNames, dropExtraNames=false);

assert(istable(V))
assertEqual(InputClass, 'table')
assertEqual(returnedNames, originalNames)
assertEqual(missingNames, "a")
assertEqual(extraNames, setdiff(originalNames, expectedNames));


%% test with missing variable and dropExtraNames true

expectedNames = {'x', 'a'};

[V, returnedNames, InputClass, missingNames, extraNames] = parseVariables( ...
   V0, expectedNames, dropExtraNames=true);

assert(istable(V))
assertEqual(InputClass, 'table')
assertEqual(returnedNames, "x")
assertEqual(missingNames, "a")
assertEqual(extraNames, setdiff(originalNames, expectedNames));
assert(isempty(intersect(returnedNames, extraNames)))


