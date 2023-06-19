function T = mergetablesbyvar(T1,T2,commonvar)
%MERGETABLESBYVAR merge two tables based on a common variable key
%
%  T = mergetablesbyvar(T1,T2,commonvar) merges columns of tables T1 and T2 with
%  variable name COMMONVAR into new table T using matlab's SYNCHRONIZE function
% 
% See also

% ivar1 = string(T1.Properties.VariableNames) == string(commonvar);
% ivar2 = string(T2.Properties.VariableNames) == string(commonvar);

ivar1 = contains(T1.Properties.VariableNames,commonvar);
ivar2 = string(T2.Properties.VariableNames) == string(commonvar);

T1 = T1(:,ivar1);
T2 = T2(:,ivar2);

% find the longer of the two records
% Time1 = T1(:,1);
% Time2 = T2(:,1);

T = synchronize(T1,T2);

% i think these might be 'timeseries' methods of synchronize, when i do
% 'doc synchronize' i get the timeseries version:
%    T     = synchronize(T1,T2,'union');
%    T     = synchronize(T1,T2,'commonrange');

%
%    t1     = synchronize(T1,T2,'commonrange');
%    t2     = synchronize(T1,T2,'union');



%    if isstruct(data)
%       T        = data.(fields{1});
%       irain    = find(string(T.Properties.VariableNames) == "Rainfall (mm)");
%       Train    = T(:,irain);
%
%       for n = 2:numtables
%          T        = data.(fields{n});
%          irain    = find(string(T.Properties.VariableNames) == "Rainfall (mm)");
%
%          Ttmp     = T(:,irain);
%          Train    = synchronize(Train,Ttmp);
%       end
%
%    end