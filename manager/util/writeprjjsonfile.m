function writeprjjsonfile(jspath,wholefile)
   fid = fopen(fullfile(jspath,'functionSignatures.json'), 'wt');
   fprintf(fid,'%c',wholefile);
   fclose(fid);
end

% how its done in projects:
% Get JSON
%     fid = fopen(fname, 'r');
%     OC1 = onCleanup(@() any(fopen('all')==fid) && fclose(fid));
%         json = textscan(fid, '%s', 'Delimiter','', 'Whitespace','');
%     fclose(fid);
%     json = json{1};
%
%     % Convert to MATLAB struct
%     data = jsondecode([json{:}]);
%
%     % Insert all current projects
%     joinup = @(cstr) [sprintf('''%s'' ', cstr{1:end-1}) '''' cstr{end} ''''];
%     data.(mfilename).inputs(1).type = ['choices={' joinup(fixed) ' ' joinup(projectlist) '}'];
%     data.(mfilename).inputs(2).type = ['choices={' joinup(projectlist) '}'];
%
%     % Convert back the struct to JSON
%     json = cellstr(jsonencode(data));
%
%     % Write the updated JSON to file
%     fid  = fopen(fname, 'w');
%     OC2  = onCleanup(@() any(fopen('all')==fid) && fclose(fid));
%         cellfun(@(x) fprintf(fid, '%s\n', x), json);
%     fclose(fid);