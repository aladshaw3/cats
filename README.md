CATS
=====

Catalytic After Treatment System (CATS)  <Version 0.0a>

This MOOSE module is primarily used to simulate catalysis reactions in the exhaust systems for vehicles. It combines SUPG methods for exhaust gas flow around the catalyst material and uses DG methods to simulate the mass balances of all gaseous species in the gas stream, as well as perform energy balances for thermal distribution in the catalyst. This module can also be applied for fixed-bed adsorption systems or other gas-solid catalyst reaction problems.


Installation and Usage
-----
To use CATS, a user must first download and install the MOOSE framework (https://mooseframework.inl.gov/). Follow the installation instructions contained therein first. 

After MOOSE is installed, you can download this source code repository to a sub-directory at the same level as the 'moose/' directory. (e.g., if MOOSE is installed in '(HOME)/projects/moose', then perform the 'git clone ...' commands in the '(HOME)/projects/' directory.)

For example (assuming MOOSE is located in '(HOME)/projects/moose'), do the following in the '(HOME)/projects' folder...

git clone https://github.com/aladshaw3/cats.git 

Then, you can build CATS using the 'make' commands in the '(HOME)/projects/cats' folder created. 


Running the Program
-----
To run CATS, use the command line to run a simulation case by giving the path and name of the input file to run.

For example...

./cats-opt -i path/to/file.i

Or, to run on multiple CPU cores...

mpiexec --n 4 ./cats-opt -i path/to/file.i


Citation
-----
Ladshaw, A.P., "CATS: Catalytic After Treatment System -- MOOSE based catalysis and fixed-bed model simulation tool," <Version (#)>, https://github.com/aladshaw3/cats, Accessed (Month) (Day), (Year).


Other Information
-----

WARNING: Module is currently under development! Use with caution!

For questions, contact Austin Ladshaw (ladshawap@ornl.gov  --or--  aladshaw3@outlook.com)


"Fork cats" to create a new MOOSE-based application.

For more information see: [http://mooseframework.org/create-an-app/](http://mooseframework.org/create-an-app/)
