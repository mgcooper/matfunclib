function legobj = getlegobj(varargin)

% minimal example to build out later
if nargin == 0
   fig = gcf;
else
   fig = varargin{1};
end

legobj = findobj(fig, 'Type', 'Legend');
%childs = get(fig,'Children');

   
