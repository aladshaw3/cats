CATS
=====

Catalytic After Treatment System (CATS)  <Version 1.0>

This MOOSE module is primarily used to simulate catalysis reactions in the exhaust systems for vehicles. Users may combine SUPG methods for exhaust gas flow around the catalyst material and uses DG methods to simulate the mass balances of all gaseous species in the gas stream, as well as perform energy balances for thermal distribution in the catalyst. This module can also be applied for fixed-bed adsorption systems or other gas-solid catalyst reaction problems.

Methods to resolve microscale intralayer diffusion include: (i) Dividing your full mesh into subdomains and using
interface kernels to transfer mass between macro- and micro-scale subdomains or (ii) Using a hybrid FD/FE method
to resolve the micro-scale for simple geometries, such as spherical/cylindrical particles or monolith walls/washcoat
of roughly uniform thickness.

Properties such as diffusivities, velocities, and mass transfer rates can be calculated using either the (i) 'GasProperties' auxiliary system or (ii) the 'SimpleGasProperties' auxilary system. The 'GasProperties' are
calculated from the full list of gases and associated parameters for each gas species using kinetic theory of
gases. The 'SimpleGasProperties' are easier to use, but make the assumption of an ideal gas that is primarily
made up of non-reactive standard air.

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


Citation
-----
Ladshaw, A.P., "CATS: Catalytic After Treatment System -- MOOSE based catalysis and fixed-bed model simulation tool," <Version (#)>, https://github.com/aladshaw3/cats, Accessed (Month) (Day), (Year).


Other Information
-----

For questions, contact Austin Ladshaw (ladshawap@ornl.gov  --or--  aladshaw3@outlook.com)


"Fork cats" to create a new MOOSE-based application.

For more information see: [http://mooseframework.org/create-an-app/](http://mooseframework.org/create-an-app/)
