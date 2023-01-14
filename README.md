## Last Updated

Jac 13, 2023

## Build Status

[![Checks](https://github.com/aladshaw3/cats/actions/workflows/conda-build.yml/badge.svg)](https://github.com/aladshaw3/cats/actions/workflows/conda-build.yml)
[![Checks2](https://github.com/aladshaw3/cats/actions/workflows/personal-conda-build.yml/badge.svg)](https://github.com/aladshaw3/cats/actions/workflows/personal-conda-build.yml)

[![Checks3](https://github.com/aladshaw3/cats/actions/workflows/mac-conda-build.yml/badge.svg)](https://github.com/aladshaw3/cats/actions/workflows/mac-conda-build.yml)
[![Checks4](https://github.com/aladshaw3/cats/actions/workflows/mac-personal-conda-build.yml/badge.svg)](https://github.com/aladshaw3/cats/actions/workflows/mac-personal-conda-build.yml)

CATS
=====

Catalysis And Treatment Simulations (CATS)

This MOOSE module is can be used to simulate catalysis reactions in the exhaust systems for vehicles or in electrochemical catalysis for flow batteries and chemical conversion. Combines the standard MOOSE SUPG methods for fluid flow around through the domain and uses DG methods to simulate the mass/energy balances in the fluid streams, as well as electric potential and electric current balances. This module also includes an experimental DG implementation of Navier-Stokes equations for fluid flow.

Methods to resolve microscale intralayer diffusion include: (i) Dividing your full mesh into subdomains and using
interface kernels to transfer mass between macro- and micro-scale subdomains or (ii) Using a hybrid FD/FE method
to resolve the micro-scale for simple geometries, such as spherical/cylindrical particles or monolith walls/washcoat
of roughly uniform thickness.

Properties such as diffusivities, velocities, and mass transfer rates can be calculated using the (i) 'GasProperties' auxiliary system, (ii) the 'SimpleGasProperties' auxilary system, or (iii) the 'SimpleFluidProperties' auxilary system. The 'GasProperties' are
calculated from the full list of gases and associated parameters for each gas species using kinetic theory of
gases. The 'SimpleGasProperties' are easier to use, but make the assumption of an ideal gas that is primarily
made up of non-reactive standard air. Similarly, the 'SimpleFluidProperties' assumes an electrolyte liquid solution made primarily of water.

For more information, please read through the 'CATS-UserGuide-*.pdf' in the home directory of the source code.


Installation and Usage
-----
To use CATS, a user must first download and install the MOOSE framework (https://mooseframework.inl.gov/). Follow the installation instructions contained therein first.

After MOOSE is installed, you can download this source code repository to a sub-directory at the same level as the 'moose/' directory. (e.g., if MOOSE is installed in '(HOME)/projects/moose', then perform the 'git clone ...' commands in the '(HOME)/projects/' directory.)

For example (assuming MOOSE is located in '(HOME)/projects/moose'), do the following in the '(HOME)/projects' folder...

<code> git clone https://github.com/aladshaw3/cats.git </code>

Then, you can build CATS using the 'make' commands in the '(HOME)/projects/cats' folder created. You can
pass the '-j4' argument to run make with multiple processors (in this case, using 4 processors).

NOTE: MOOSE now builds using 'conda' environments. Your 'moose' conda environment MUST be active before
attempting to build the source code. See https://mooseframework.inl.gov/getting_started/installation/conda.html.

<code> make -j4 </code>

NOTE: If this is the first time running the 'make' command, it may take several minutes to an
hour to run, because it will also need to compile all of the MOOSE dependencies as well.

After the source code is built, you can test the code using the 'run_tests' command.

<code> ./run_tests -j4 </code>

This project may update frequently. If you are using this repository, please keep your copy up-to-date. You can
stay up-to-date by using...

<code> git fetch origin </code>

<code> git rebase origin/master </code>


Running the Program
-----
To run CATS, use the command line to run a simulation case by giving the path and name of the input file to run.

For example...

<code> ./cats-opt -i path/to/file.i </code>

Or, to run on multiple CPU cores...

<code> mpiexec --n 4 ./cats-opt -i path/to/file.i </code>


WARNING
-----
There may be a current bug in MOOSE that is caused by applying an integrated boundary
condition on a node set internal to a domain. MOOSE will report an error stating that
the variable does not exist on that node set, however, if you run the code with...

<code> mpiexec --n # ./cats-opt -i path/to/file.i </code>

where # > 1, then the code should run fine. See issue #13 for more information.


Citation
-----
Ladshaw, A.P., "CATS: Catalysis And Treatment Systems -- MOOSE based catalysis simulation tool," https://github.com/aladshaw3/cats, Accessed (Month) (Day), (Year).


Contact Information
-----

For questions, contact Austin Ladshaw (aladshaw3@outlook.com)
