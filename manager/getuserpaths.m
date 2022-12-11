function [keys,vals] = getuserpaths

[keys,vals] = getenvall('system');     % get all env vars
keep = contains(keys,'PATH');          % keep ones with PATH
keys = keys(keep); 
vals = vals(keep);