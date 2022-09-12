function NewData = timetablereduce(Data,varargin)
   
   p=MipInputParser;
   p.FunctionName='timetablereduce';
   p.addRequired('Data',@(x)istimetable(x));
   p.addParameter('alpha',0.32,@(x)isnumeric(x));
   p.parseMagically('caller');
   alpha = p.Results.alpha; 
   
   % 
   Data  = renametimetabletimevar(Data);
   Time  = Data.Time;
   
   % check 

   % compute mean, stderr, ci, etc
   [SE,CI,PM,mu,sigma] = stderr(table2array(Data),'alpha',alpha); 
   CIL = CI(:,1); CIH = CI(:,2);

   NewData = timetable(Time,mu,sigma,SE,CIL,CIH,PM);
   
   % copy over properties (might not work, if fails, fix brace indexing)
   if ~isempty(Data.Properties.VariableUnits)
      NewData.Properties.VariableUnits = Data.Properties.VariableUnits{1};
   elseif ~isempty(Data.Properties.VariableContinuity)
      NewData.Properties.VariableContinuity = Data.Properties.VariableContinuity{1};
   end
   

