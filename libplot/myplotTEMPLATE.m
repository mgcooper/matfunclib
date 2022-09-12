function varargout = myplot(obj, varargin)

% I copied this from a stackoverlfow answer:
% https://stackoverflow.com/questions/39365970/matlab-optional-handle-argument-first-for-plot-like-functions

% the basic structure follows the one in abline, and uses the undocumented
% function axescheck, which it seems should be a stable function, and could
% replace the isax thing I came up with from kearney's suggestion
    
    % Check the number of output arguments.
    nargoutchk(0,1);

    % Parse possible axes input.
    [ax, args, ~] = axescheck(varargin{:}); %#ok<ASGLU>

    % Get handle to either the requested or a new axis.
    if isempty(ax)
        hax = gca;
    else
        hax = ax;
    end

    % At this point, hax refers either to a specified axis, or
    % to a fresh one if none was specified. args refers to the
    % remainder of any arguments passed in varargin.

    % Parse the rest of args

    % Make the plot in hax

    % Output a handle to the axes if requested.
    if nargout == 1
        varargout{1} = hax;
    end  

end
