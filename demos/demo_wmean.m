
% Example from Wikipedia

% Given two school classes — one with 20 students, one with 30 students — and
% test grades in each class as follows:

Morning = ...
   [62, 67, 71, 74, 76, 77, 78, 79, 79, 80, 80, 81, 81, 82, 83, ...
   84, 86, 89, 93, 98];

Afternoon = ...
   [81, 82, 83, 84, 85, 86, 87, 87, 88, 88, 89, 89, 89, 90, 90, ...
   90, 90, 91, 91, 91, 92, 92, 93, 93, 94, 95, 96, 97, 98, 99];

% The mean for the morning class is 80
mean(Morning)

% The mean of the afternoon class is 90
mean(Afternoon)

% The unweighted mean of the two means is 85
mean([mean(Morning) mean(Afternoon)])


% However, this does not account for the difference in number of students in
% each class (20 versus 30); hence the value of 85 does not reflect the average
% student grade (independent of class). 

% The average student grade can be obtained by averaging all the grades, without
% regard to classes (add all the grades up and divide by the total number of
% students): 
% x = 4300 50 = 86
% {\displaystyle {\bar {x}}={\frac {4300}{50}}=86.}

mean([Morning(:); Afternoon(:)])

% Or, this can be accomplished by weighting the class means by the number of
% students in each class. The larger class is given more "weight": 

% x = ( (20 × 80) + (30 × 90) ) / (20 + 30) = 86
% {\bar {x}}={\frac {(20\times 80)+(30\times 90)}{20+30}}=86.

weights = [length(Morning); length(Afternoon)] ./ length([Morning Afternoon]);
wmean([mean(Morning); mean(Afternoon)], weights);

% Thus, the weighted mean makes it possible to find the mean average student
% grade without knowing each student's score. Only the class means and the
% number of students in each class are needed.



