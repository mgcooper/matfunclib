function twoLineXlabels(ax, xlabels, jitter, varargin)

% arguments
%    
% end

[rows, cols] = size(xlabels);

set(ax,'XTickLabel','');
for n = 1:max([rows; cols])
   text(ax.XTick(n), ax.YLim(1)+jitter, sprintf('%s\n%s\n', xlabels(:,n)), ...
      'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
      varargin{:})
   % VerticalAlignment was 'cap'
end

% for n = 1:max([rows; cols])
%    text(ax.XTick(n), ax.YLim(1)+jitter, strtrim(sprintf('%s\n%s\n', xlabels(:,n))), ...
%       'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
%       varargin{:})
%    % VerticalAlignment was 'cap'
% end

% strtrim(sprintf('%s\\newline%s\\newline%s\n', labelArray{:}))