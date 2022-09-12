This directory contains matlab scripts, synthetic data,
and examples for the non-linear regression techniques
described in the Sohn and Menke G-cubed article,
"Application of Maximum Likelihood and Bootstrap
Methods to non-linear curve-fit problems in geochemistry"

The sample data, Gauss_line.dat and Exp_line.dat, are
the synthetic datasets described in the text and plotted
in Figure 3 in the paper. Regression results obtained
using the NonLinReg_G3.m (Gaussian model) and Robust_Reg_G3.m
(Exponential model) codes are desribed in the files;

Exp_line.EML_results.txt --> Exponential data, Exponential fit
Exp_line.GML_results.txt --> Exponential data, Gaussian fit
Gauss_line.EML_results.txt --> Gaussian data, Exponential fit
Gauss_line.GML_results.txt --> Gaussian data, Gaussian fit

These results are summarized in Table 1 of the G-cubed paper.

Note that the regression codes call a number of subroutines
that must also be located in the same directory so they
can be accessed by the scripts. The subroutines, or functions,
used by each code are described in the header of the code.

PartCoeff.m, a code for the non-linear regression of elastic parameters
from crystal-melt partition coefficient data, is also
included, though it is provided in more of a "raw"
state - with less comments and less testing for bugs, etc.

Any questions or problems associated with these scripts
should be directed to Rob Sohn via email; rsohn@whoi.edu
