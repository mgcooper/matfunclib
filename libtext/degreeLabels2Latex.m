function labels = degreeLabels2Latex(labels)

if get(groot,'defaultTextInterpreter') == "latex"
   labels = strrep(labels,char(176),'$\circ$');
end