function reopen_open_tabs

pathin   = [getenv('HOME') '/Desktop/opentabs/'];
pathout  = [pathin 'output/'];

% go to the folder
go_to_open_tabs(pathin)

% reopen the files
reopen_the_tabs(pathin)

end

% go to the folder and find the file you want
function go_to_open_tabs(pathin)
    cd(pathin)
end

function reopen_the_tabs(pathin)

fname   = input('copy and paste the filename','s');
fname   = [pathin fname '.txt'];

% set read options
opts                            = detectImportOptions(fname);
opts.Delimiter                  = ' ';
opts.ConsecutiveDelimitersRule  = 'join';
opts.VariableNamesLine          = 1;

fileNames    = readlines(fname);

for n = 1:numel(fileNames)
    
    thisFile   = fileNames(n);
    
    if contains(thisFile,'private')
        continue
    else
        thisFile       = strrep(thisFile,' ','\ ');
        [status,cmdout] = system(['open ' char(thisFile)]);
    end
end


% % FOR THE OLD VERSION, PRE APPLESCRIPT
% % read the file
% tabs    = readtable(fname,opts,'ReadVariableNames',false);

% % join filenames with spaces that got delimeted into extra columns
% icol    = find(ismember(tabs.Properties.VariableNames,'NAME'));
% 
% for n = 1:height(tabs)
%    
%     all_strings     = table2array(tabs(n,icol:end));
%     one_string      = string(all_strings{1});
%     
%     for m = 2:numel(all_strings) % start at 2, 1 is the intialized
%         
%         this_string = string(all_strings{m});
%         
%         if this_string==""
%             continue
%         else
%             one_string  = strcat(one_string," ",this_string);
%         end
%     end
%     tabs.NAME{n}  = one_string;
% end
% 
% tabs    = tabs(:,1:icol);
% 
% tabs.NAME = string(tabs.NAME);
% 
% % find open tabs that are pdfs:
% ipdf        = find(contains(tabs.NAME,'.pdf'));
% pdf_files   = tabs.NAME(ipdf);
% 
% for n = 1:numel(pdf_files)
%     
%     this_file   = pdf_files(n);
%     
%     if contains(this_file,'private')
%         continue
%     else
%         this_file       = strrep(this_file,' ','\ ');
%         [status,cmdout] = system(['open ' char(this_file)]);
%     end
% end

end
% % test open one file:
% one_file    = char(tabs.NAME(ipdf(1)));
% system(['open ' one_file])