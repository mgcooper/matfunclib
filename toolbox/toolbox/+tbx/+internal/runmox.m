function runmox()
   %
   % run tests with code coverage
   %
   % USAGE::
   %
   %   run_tests()
   %
   % (C) Copyright 2022 Remi Gau

   % Not sure if I want runtests in the top level or not, see other runtests
   % versions in tests/

   tic;

   cd(fileparts(mfilename('fullpath')));

   fprintf('\nHome is %s\n', getenv('HOME'));

   folder_to_cover = fullfile(pwd, 'src');

   test_folder = fullfile(pwd, 'tests');

   success = moxunit_runtests(test_folder, ...
      '-verbose', '-recursive', '-with_coverage', ...
      '-cover', folder_to_cover, ...
      '-cover_xml_file', 'coverage.xml', ...
      '-cover_html_dir', fullfile(pwd, 'coverage_html'));

   if success
      system('echo 0 > test_report.log');
   else
      system('echo 1 > test_report.log');
   end

   toc;
end
