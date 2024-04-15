function [result, exception] = try_(statement, default_result)
   %TRY_ Try to evaluate a statement and optionally return the caught exception
   %
   %  [RESULT, EXCEPTION] = TRY_(STATEMENT) Evaluates the anonymous function
   %  STATEMENT inside a try-catch block. If the statement fails, RESULT will be
   %  an empty array and EXCEPTION will hold the exception object.
   %
   %  [RESULT, EXCEPTION] = TRY_(STATEMENT, DEFAULT_RESULT) Takes an additional
   %  argument DEFAULT_RESULT, which will be returned if the statement fails.
   %  EXCEPTION will be empty if the statement succeeds.
   %
   %  Use this function when you don't need to handle an exception, for
   %  example, when you can let a Matlab built-in function catch the error in a
   %  later step, when the built-in function fails because the statement you
   %  tried to evaluate failed.
   %
   %  This is particularly useful in workflows where you have branching
   %  conditions that might produce optional variables or types. You can use
   %  try_ to silently attempt operations (like variable type conversions,
   %  mathematical operations, etc.) at the beginning of a function. This way,
   %  you can defer error-handling to later parts of the code or built-in
   %  functions that are specifically designed to handle such errors.
   %
   % Example:
   %  str = "yes"; % Initialize some data
   %  str = try_(@() categorical(str)); % Attempt conversion to categorical
   %
   % Later in your function, you'll use a built-in MATLAB function that
   % expects str to be a categorical variable. If the conversion failed,
   % the built-in function will handle the error.
   %
   % This becomes more useful if you have several type conversions. Instead of:
   % try
   %    str1 = categorical(str1)
   % catch
   % end
   % try
   %    str2 = categorical(str2)
   % catch
   % end
   % try
   %    str3 = categorical(str3)
   % catch
   % end
   %
   % Just use:
   % str1 = try_(@() categorical(str1));
   % str2 = try_(@() categorical(str2));
   % str3 = try_(@() categorical(str3));
   %
   % See also: try, catch

   assert(isa(statement, 'function_handle'))
   exception = [];

   if nargin < 2
      default_result = [];
   end

   try
      result = statement();
   catch exception
      result = default_result;
   end

   % TODO: add an additional argument to enable simpler calling syntax for
   % nested try-catch, e.g.:
   % [result, exception] = try_(@() statement, default_result);
   % result = try_(@() statement, 'rethrow', exception);

   % if ~isempty(opts.rethrow)
   %    rethrow(opts.rethrow)
   % end

   % Might be useful to do this and return the success flag:
   % success = true;
   % try
   %    result = statement();
   % catch ME
   %    success = false;
   % end

end

% function varargout = try_(statement)
%    assert(isa(statement, 'function_handle'))
%    exception = [];
%
%    if nargin < 2
%       % varargout = [];
%    end
%
%    try
%       varargout = statement();
%    catch exception
%    end
% end

% function varargout = try_(statement)
%    arguments (Repeating)
%       statement
%    end
%
%    assert(all(cellfun(@(s) isa(s, 'function_handle'))))
%    exception = cell(numel(statement), 1);
%    result = cell(numel(statement), 1);
%
%    for n = 1:numel(statement)
%       try
%          result{n} = statement();
%       catch ME
%          exception{n} = ME;
%       end
%    end
%    varargout = cell(2*numel(statement), 1);
%    varargout{1:2:2*numel(statement)-1} = deal(result);
%    varargout{2:2:2*numel(statement)} = deal(exception);
% end
