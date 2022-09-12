% to find indices of common elements of two cell arrays
% use ismember

pets        = {'cat';'dog';'dog';'dog';'giraffe';'hamster'}
species     = {'cat' 'dog'}
[tf, loc]   = ismember(pets, species)
