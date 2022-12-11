# PlotDefaults
## Motivation and Purpose
When producing publications, or simply writing a dissertation or thesis, multiple plots are often desired, and a good house design can greatly increase the professionalism of your work. PlotDefaults is a handle class which encapsulates common plot operations such as: Default axis labelling (x,y,z), setting label interpreters and font sizes, setting legend interpreters and font sizes.
House colours are defined in the handle class PlotColours and can be added to as desired. Sizes are defined in children of the parent class PlotSizes, and three sizes are defined: std, med, big.
This class is designed to be modified to your own house style: I recommend using https://coolors.co/generate to generate your own colour scheme.

## Usage
Unzip PlotDefaults to a location of your choosing, and make sure that location is on your Matlab path. PlotDefaults acts on the current figure and axes and the following methodology is supported:
  applyDefaultLabels  - apply x,y,z labels with a latex interpreter
  applySizes          - apply one of three pre-set size definitions to
                        the tick, label and legend. Options are, 'std',
                        'med', 'big'.
  applyEqualAxes      - apply equal x,y,z data aspect ratios, or any combination of x,y,z.
  colours             - set of arrays containing RGB data for different
                        colours
### Examples:
  PlotDefaults.applyDefaultLabels
      Apply default labels to current plot    
  PlotDefaults.applySizes('std')
      Apply the standard set of sizes to the current plot.
  PlotDefaults.colours.blue(:, 1)
      Fetch the 1st shade of blue from the colour palette.
      
#### Copyright (C) Matthew Sparkes 2022 - 2023

