function labels = degreeLabels2Latex(labels)
   %DEGREELABELS2LATEX Convert degree symbols in text labels to latex format.
   %
   %  labels = degreeLabels2Latex(labels)
   %
   % See also:

   if get(groot,'defaultTextInterpreter') == "latex"
      labels = strrep(labels,char(176),'$\circ$');
   end
end
