function varargout = testdata(varargin)

% Might not use this, and use tbx.util.generateTestData instead

   datamenu = {'', ''}; % different types of data used for testing
   whichdata = validatestring(varargin{1}, datamenu);
   
   
   switch whichdata
      case 'example'
         
         [X, Y, T] = load_example_data;
         [varargout{1:nargout}] = deal(X, Y, T);
         
      case 'tests'
         
         % some other data
   end

end

function varargout = load_example_data

   datapath = tbx.internal.projectpath('data');
   
   % Just an example of custom data loading to deal with matlab-octave
   % incompatibilities (datetime/datenum in this case)
   if tbx.internal.isoctave
      
      load(fullfile(datapath,'example_data_octave.mat'),'X','Y','T'); 
      T = datenum(T); %#ok<*DATNM> 
   
   else
      load(fullfile(datapath,'example_data_matlab.mat'),'X','Y','T');
   end
   
   [varargout{1:nargout}] = deal(X, Y, T);

end