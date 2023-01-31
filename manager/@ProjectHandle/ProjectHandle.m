classdef ProjectHandle < matlab.mixin.SetGetExactNames
   %PROJECTHANDLE a set/get handle for ProjectManager
   %   Detailed explanation goes here

   properties
      ProjectName = {''};
      ProjectFolder = {''};
      DateCreated = {''};
      DateModified = {''};
      ActiveState = false;
      ActiveFiles = {''};
      ActiveFolder = {''};
      LinkedProject = {''};
%       ProjectName = "";
%       ProjectFolder = "";
%       DateCreated = "";
%       DateModified = "";
%       ActiveFiles = "";
%       ActiveState = "";
%       ActiveFolder = "";
%       LinkedProject = "";
   end

   % to make SetAcess protected
   properties (SetAccess = protected)
   end

   methods
      
      % if this is used, then we just say: Project = ProjectHandle;
      % then we use set/get to set props
      function obj = ProjectHandle()
         %ProjectHandle Construct an instance of this class
%          obj.ProjectName = projname;
      end

%       % require projname to instantiate
%       function obj = ProjectHandle(projname)
%          %ProjectHandle Construct an instance of this class
%          obj.ProjectName = projname;
%       end
      
%       % this would require all args, but maybe if we set 
%       function obj = ProjectHandle(projname,projfolder,datecreated, ...
%          datemodified,activefiles,activestate,activefolder,linkedproject)
%          %ProjectHandle Construct an instance of this class
%          obj.ProjectName = projname;
%          obj.ProjectFolder = projfolder;
%          obj.DateCreated = datecreated;
%          obj.DateModified = datemodified;
%          obj.ActiveFiles = activefiles;
%          obj.ActiveState = activestate;
%          obj.ActiveFolder = activefolder;
%          obj.LinkedProject = linkedproject;
%       end

      function set.ProjectName(obj,val)
         if nargin > 0
            obj.ProjectName = char(val); % or string? 
         end
      end

      function set.ProjectFolder(obj,val)
         if nargin > 0
            obj.ProjectFolder = cellstr(val);
         end
      end

      function set.DateCreated(obj,val)
         if nargin > 0
            try
               obj.DateCreated = datetime(val);
            catch
               obj.DateCreated = datetime(val,'ConvertFrom','datenum');
            end
         end
      end

      function set.DateModified(obj,val)
         if nargin > 0
            try
               obj.DateModified = datetime(val);
            catch
               obj.DateModified = datetime(val,'ConvertFrom','datenum');
            end
         end
      end

      function set.ActiveState(obj,val)
         if nargin > 0
            obj.ActiveState = logical(val);
         end
      end

      function set.ActiveFiles(obj,val)
         if nargin > 0
            obj.ActiveFiles = cellstr(val);
         end
      end

      function set.ActiveFolder(obj,val)
         if nargin > 0
            obj.ActiveFolder = cellstr(val);
         end
      end

      function set.LinkedProject(obj,val)
         if nargin > 0
            obj.LinkedProject = char(val);
         end
      end


      function outputArg = method1(obj,input1)
      %METHOD1 Summary of this method goes here
      %   Detailed explanation goes here
      outputArg = obj.ProjectName + input1;
      end
   end
end