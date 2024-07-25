function varargout = getfeature(fullname)
   %GETFEATURE translate toolbox name from 'ver' to feature name and vice versa
   %
   % Syntax:
   %   tbx.internal.getfeature(fullname) returns the feature name and checks
   %   license availability
   %
   % Inputs:
   %   fullname:       character vector of toolbox name as listed in ver
   %                   output (optional, if none given all features are
   %                   listed)
   %
   % Outputs:
   %   tf:             logical flag indicating if the feature is available
   %   shortname:      character vector of the "clear" (or "short") feature
   %                   name, e.g., 'MATLAB_Report_Gen' instead of 'MATLAB
   %                   Report Generator'.
   %   featurename:    The full feature name e.g. 'MATLAB Report Generator'.
   %
   %-------------------------------------------------------------------------
   % Version 1.1
   % 2018.09.04        Julian Hapke
   % 2020.05.05        checks all features known to current release
   %-------------------------------------------------------------------------
   %
   % 2024.04.18: Output parsing refactored by Matt Cooper.
   %
   % See also:

   assert(nargin < 2, 'Too many input arguments')

   if isstring(fullname)
      fullname = char(fullname);
   end

   % defaults
   checkAll = true;
   installedOnly = false;

   if nargin
      checkAll = false;
      installedOnly = strcmp(fullname, '-installed');
   end

   if checkAll || installedOnly
      allToolboxes = com.mathworks.product.util.ProductIdentifier.values;
      nToolboxes = numel(allToolboxes);
      out = cell(nToolboxes, 3);
      for iToolbox = 1:nToolboxes
         marketingName = char(allToolboxes(iToolbox).getName());
         flexName = char(allToolboxes(iToolbox).getFlexName());
         out{iToolbox, 1} = marketingName;
         out{iToolbox, 2} = flexName;
         out{iToolbox, 3} = license('test', flexName);
      end
      if installedOnly
         installedToolboxes = ver;
         installedToolboxes = {installedToolboxes.Name}';
         out = out(ismember(out(:,1), installedToolboxes),:);
      end

      % mgc refactored this then commented it out so this function returns
      % true/false if no outputs are requested.
      % if ~nargout
      %    out = [{'Name', 'FlexLM Name', 'License Available'}; out];
      %    disp(out)
      % end
   else
      productidentifier = com.mathworks.product.util.ProductIdentifier.get(fullname);
      if (isempty(productidentifier))
         warning('"%s" not found.', fullname)
         out = cell(1,3);
         return
      end
      feature = char(productidentifier.getFlexName());
      out = [{char(productidentifier.getName())} {feature} {license('test', feature)}];
   end

   % mgc: I changed the output to true/false first followed by the optional
   % "clear" feature name and formal feature name
   switch nargout
      case 0
         varargout{1} = out{3};
      case 1
         varargout{1} = out{3};
      case 2
         varargout{1} = out{3};
         varargout{2} = out{2};
      case 3
         varargout{1} = out{3};
         varargout{2} = out{2};
         varargout{3} = out{1};
      otherwise
   end
end
