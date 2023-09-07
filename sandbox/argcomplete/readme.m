% NOTE: I think once I add the function signature i lose all subsequent auto
% cmplete for example this was all to get the table property variable names to
% autocomplete in barchartcats, which works with the json file, but then the
% subsetquent metaclass inheritance for barchartopts seeems to go away so it wa
% alll a wast of time

% this is to see if i can combine functionSignatures.json with arguments block
% to get autocomplete for property values like fieldnames(S) or
% T.Properties.VariableNames

% try varyign the functionSignatures.json defnitions, I tried using char,
% string, rquired first followed by positional, all required, all positonal, all
% ordered, etc. 

% f_argcomplete1 is the simplest case, it shows it can be done ie. you
% can have an arguments block and a json file and get property completion from
% the json 

% but whn you add multiple args in a row, it goes away after the first auto
% complete unless yo use strings