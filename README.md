# matfunclib

Library of matlab functions.

## MATLAB Project

The repository root is a MATLAB Project, `MatFuncLib.prj`. It references 20
sub-library Projects, one per library folder, so opening the root Project puts
every library on the MATLAB path:

    matlab -nodisplay -nosplash -batch "openProject('.')"

`resources/project` holds the Project definition and is tracked, so a fresh
clone opens without any generation step.

`projectfile.m` at the repository root generates that state from its
`SUBLIBRARIES` roster. Run it after you add, rename, or remove a library
folder. It converges: a re-run adds no file and no reference. Membership
follows git-tracked content. A folder with no tracked files stays out of
the Project, and a re-run removes such a member. A fresh clone gains no
empty folders.

    matlab -nodisplay -nosplash -batch \
      "addpath(genpath('manager')); projectfile('create')"

The `toolbox/` folder is the toolbox template, and it is not a Project.
`copytoolboxtemplate` refuses to stamp a template that carries a root `.prj`
or a `resources/` folder, because that state would merge into the new project.
