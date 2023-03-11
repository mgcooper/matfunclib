function tf = checkfieldnames(varargin)
% this checks if all structs in varargin have equal fieldnames

% this doesn't work and i'm moving on

N=numel(varargin);
tf=false(N,1);
for n=1:N
   for m=n+1:N
      tf(n) = tf(n) || isequal(fieldnames(varargin{n}),fieldnames(varargin{m}));
      %tf(m) = tf(n);
   end
end

% % this checks if all structs in varargin are equal (fieldnames and values)
% N=numel(varargin);
% Z=false;
% for n=1:N
%    for m=n+1:N
%       Z = Z || isequal(varargin{n},varargin{m}); 
%    end
% end