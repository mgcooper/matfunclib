%    Example 1

fid = fopen('myfile.txt', 'w');  % Open file for writing
if fid ~= -1  % Check that file opened successfully
   fdisp(fid, [1 2 3]);  % Use fdisp to write numeric array
   fdisp(fid, 'Hello, World!');  % Use fdisp to write string
   fdisp(fid, {'Apple', 'Banana', 'Cherry'});  % Use fdisp to write cell array of strings
   fclose(fid);  % Always close your files!
else
   error('Failed to open file');
end

%    Example 2 - Use the sizelimit option

fid = fopen('mybigfile.txt', 'w');  % open file for writing
if fid ~= -1  % check if the file was opened successfully
   fdisp(fid, rand(2e6,1));  % try to write a big numeric array. The default sie limit is 1e6
   fclose(fid);  % close the file
else
   error('Failed to open file');
end

fid = fopen('mybigfile.txt', 'w');  % open file for writing
if fid ~= -1  % check if the file was opened successfully
   fdisp(fid, rand(2e6,1), true);  % write a big numeric array by overriding the size limit
   fclose(fid);  % close the file
else
   error('Failed to open file');
end