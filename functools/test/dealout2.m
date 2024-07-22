function varargout = dealout2(varargin)
   %DEALOUT deal out function outputs
   %
   % [argout1, argout2] = dealout(argin1, argin2, ..., arginN]
   % [cellArrayOutput{1:nargout}] = dealout(argin1, argin2, ..., arginN);
   % [cellArrayOutput{1:nargout}] = dealout(cellArrayInput{:});
   % [-] = dealout(structInput);
   % [-] = dealout(struct2cell(structInput));
   %
   % The number of output arguments does not have to match the number of inputs,
   % but they will be dealt out in the exact order they are dealt in i.e.
   % argout1 = argin1, argout2 = argin2, and so forth.
   %
   % Also the number of outputs must of course not exceed the number of inputs.
   %
   % Note: if the calling function tries to do something like this:
   % varargout = dealout(arg1) ... and no output is requested from the base
   % workspace, then the first element of arg1 will get sent back. For example:
   %
   % function celloutput = myfunction(varargin)
   %
   % ... function code
   %
   % varargout = dealout(cellarg1);
   %
   % % Then, in a script:
   % myfunction(...)
   %
   % % with no requested outputs, will return the first element of cellarg1. But
   % if this syntax is used, nothing will be returned:
   %
   % function celloutput = myfunction(varargin)
   %
   % ... function code
   %
   % [varargout{1:nargout}] = dealout(cellarg1);
   %
   % Matt Cooper, 22 Jun 2023
   %
   % See also

   args = varargin;

   % This first part is designed to eliminate the calling syntax:
   %
   % [val1, val2, ..., valN] = dealout(struct2cell(opts))
   %
   % Here, opts is a name-value struct with N pairs. If that calling syntax is
   % used, struct2cell produces a cell-array with one element per name-value
   % pair in opts, which is the desired result, but upon passing it to this
   % function, it gets nested inside varargin, and then ARGS is a scalar
   % cell-array, with the desired cell-array its only element.
   %
   % In contrast, if struct2cell is applied here, as it is below, it produces
   % the desired cell-array and is not nested inside the scalar varargin array.
   %
   % Note that, if args = varargin{:} is used instead of args = varargin, it
   % would produce the desired result, but it is unclear what the side effects
   % of this would be in other use cases.

   if numel(args) == 1 && isstruct(args{1})
      try
         args = struct2cell(args{:});
      catch
      end
   end

   % If the user forgets the support for struct expansion using the syntax
   % noted above, and uses struct2cell in the calling function, then
   % the input to this function ARGS will be a cell array with the same number
   % of elements as the number of fields in the name-value struct. If all
   % name-value pairs are requested, then nargout will equal the number of
   % elements in ARGS, but if not, it is ambiguous. One option is to return
   % 1:nargout. But this requires the caller to request values in exactly the
   % order they exist in the opts struct, which is error prone. Initially an
   % error was issued in this case, but instead, the second condition below,
   % nargout > numel(args{:}) was added to allow this, and the try-catch block
   % should handle cases where this fails.

   % Apr 2024 - added the second condition.
   if nargout > numel(args) && nargout > numel(args{:})
      error('One input required for each requested output')
   end

   % if iscell(args{1}) && numel(args{:}) == nargout
   % This is stricter and requires nargout to exactly equal the number of
   % fields, but that is inconsistent with the intention of this function
   % to specifically allow more inputs than outputs, and to "dealout" them
   % in the order requested. To use this, add negation and issue an error,
   % or only proceed to try-catch if this is true.
   % end

   % This was an attempt to fix the nargout = 1, nargin = 1 case but doesn't
   % work
   %    if nargin == 1 && nargout == 1 && iscell(varargin{1})
   %       varargout{1} = args{1}{1};
   %       % varargout = arrayfun(@(arg) arg, args{1};
   %       return
   %    end

   try
      % Syntax is [out1, out2, ..., outN] = dealout(in1, in2, ..., inN]
      [varargout{1:nargout}] = deal(args{1:nargout});

      % Note: this syntax is useful for forcing one output
      % [varargout{1:max(1,nargout)}] = deal(varargin{1:nargout});
   catch e

      % Syntax is [out1, out2, ..., outN] = dealout(CellArray)
      varargout = args{:};

      % Note that this would work but is unnecessary:
      % varargout = deal(args{:});

      % And here varargin would be a cell array with nargout elements but each
      % element is the entire args cell array, not the desired result.
      % [varargout{1:nargout}] = deal(args{:});

      % And here varargin is like above but each element as a 1x1 cell array
      % containing the individual respective element of args.
      % [varargout{1:nargout}] = deal(args);

      % I am surprised this does not work
      % varargout = cell(nargout, 1);
      % [varargout{:}] = deal(args{:});
   end

   % TODO:
   % Compare with this format:
   % if ~iscell(x), x = num2cell(x); end
   % varargout = cell(1,nargout);
   % [varargout{:}] = deal(x{:});

   % Compare with fex function deal2
end
