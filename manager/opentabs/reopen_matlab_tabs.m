
pathin  = [getenv('MATLABUSERPATH') 'opentabs/matlab_editor/'];
fname    = input('copy and paste the filename','s');
fname   = [pathin fname '.mat'];

load(fname)

for n = 1:numel(filelist)
    try
        open(filelist(n))
    catch
    end
end