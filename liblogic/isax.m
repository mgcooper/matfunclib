function [ax,tf,varargout] = isax(varargin)
%ISAX deprecated: use axescheck or isaxis

% UPDATE: see axescheck - undocumented function i copied here designed to do
% what this does so I commented this out.

% NOTE: this function seems problmeatic, its a 'is' funciton, meaning the
% first output should be tf, but it's ax, and I now have 'isaxis' so need
% to do a search for where this is called and consider changing

% % this is an exmaple of how i used it in bfra_mapbasins before adding
% input parsing there:
%    % check if user provided axis
%    %[ax,varargout] = isax(varargin);

tf = cellfun(@(x) isscalar(x) && ishandle(x) &&                   ...
   strcmp('axes', get(x,'type')), varargin);

% detecting when varargout doesn't exist is tricky, it occurs when the
% only value in varargin is the ax, and also, it's needed because we
% want to remove the ax from the varargin cell array, so the remaining
% values can be passed into the plotting function. I think it will work
% to initialize varargout here as empty, but this patch was added after
% I thought this function already worked
varargout = {[]};

tf = any(tf);

if tf
   ax = varargin{tf};
   varargout = varargin(~tf);
else % try this syntax
   try
      tf = cellfun(@(x) isscalar(x{:}) && ishandle(x{:}) &&       ...
         strcmp('axes', get(x{:},'type')), varargin);
   end

   tf = any(tf);

   if tf
      ax=varargin{tf}{:};
      varargout = varargin(~tf);
   else
      % see if figure exists
      g = groot;
      if ~isempty(g.Children)
         ax = gca;
      else
         ax = []; % no open figure, calling program can make one
      end
   end

   if isempty(varargout) %|| ~exist(varargout,'var')
      varargout{1} = {[]};
   end
end

end