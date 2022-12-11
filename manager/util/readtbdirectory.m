function toolboxes = readtbdirectory(dbpath)

toolboxes = readtable(dbpath,'Delimiter',',','ReadVariableNames',true);