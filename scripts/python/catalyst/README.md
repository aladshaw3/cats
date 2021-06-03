Python Pyomo Tools for CATS
=====

This directory contains a set of python tools for performing data analyses associated with surface chemistry in monoliths and packed-beds. User's can import data into these objects to simulate and parameterize reaction kinetics assuming the monoliths/packed-beds can be idealized as a 1D-0D reactor.

Isothermal_Monolith_Simulator Equations
-----

&epsilon;<sub>b</sub> &part;C<sub>b,i</sub>/&part;t + &epsilon;<sub>b</sub> v &part;C<sub>b,i</sub>/&part;z = -(1-&epsilon;<sub>b</sub>) G<sub>a</sub> k<sub>m,i</sub> (C<sub>b,i</sub> - C<sub>i</sub>)

&epsilon;<sub>w</sub> (1-&epsilon;<sub>b</sub>) dC<sub>i</sub>/dt = (1-&epsilon;<sub>b</sub>) G<sub>a</sub> k<sub>m,i</sub> (C<sub>b,i</sub> - C<sub>i</sub>) + (1-&epsilon;<sub>b</sub>) <span>&sum;</span><sub>&forall;j</sub> (u<sub>C<sub>i,j</sub></sub> r<sub>j</sub>)

&ast; dq<sub>i</sub>/dt = <span>&sum;</span><sub>&forall;j</sub> (u<sub>q<sub>i,j</sub></sub> r<sub>j</sub>)

** S<sub>max,i</sub> = S<sub>i</sub> + <span>&sum;</span><sub>&forall;q<sub>j</sub></sub> (u<sub>s<sub>i,j</sub></sub> q<sub>j</sub>)

&ast; NOTE: This is optional when building a model. User may opt to not explicitly include surface species

** NOTE: This is also optional when building a model and only available if the user is using the surface species. Alternatively, user may specify the sites themselves to be surface species.

Parameter | Meaning | Units
------------ | ------------- | -------------
&epsilon;<sub>b</sub> | bulk voids to total volume ratio | (unitless) L-gas/L-total
C<sub>b,i</sub> | bulk concentration of i<sup>th</sup> gas species | mol/L-gas
t | time dimension | min
z | axial dimension | cm
v | average linear gas velocity | cm/min
(1-&epsilon;<sub>b</sub>) | bulk solids to total volume ratio | (unitless) L-solids/L-total
G<sub>a</sub> | solids surface area to solids volume ratio | cm<sup>-1</sup>
k<sub>m,i</sub> | mass transfer rate of i<sup>th</sup> gas species | cm/min
C<sub>i</sub> | pore-space concentration of i<sup>th</sup> gas species | mol/L-gas
&epsilon;<sub>w</sub> | washcoat/solid pore volume to bulk solids volume | (unitless) L-gas/L-solids
u<sub>C<sub>i,j</sub></sub> | molar contribution of reaction j to change in pore-space concentration of species i | (unitless)
u<sub>q<sub>i,j</sub></sub> | molar contribution of reaction j to change in surface concentration of species i | (unitless)
u<sub>s<sub>i,j</sub></sub> | molar contribution of surface species j to mass balance of site i | (unitless)
r<sub>j</sub> | rate of reaction j | mol/L-solids/min
q<sub>i</sub> | surface concentration of species i | mol/L-solids
S<sub>i</sub> | open-site concentration of site i | mol/L-solids
S<sub>max,i</sub> | maximum number of available sites for site i | mol/L-solids

Nonisothermal_Monolith_Simulator Equations
-----

(<i>NOTE: Includes the above in addition to the following...</i>)

&epsilon;<sub>b</sub> &rho; c<sub>pg</sub> &part;T/&part;t + &epsilon;<sub>b</sub> &rho; c<sub>pg</sub> v &part;T/&part;z = -(1-&epsilon;<sub>b</sub>) G<sub>a</sub> h<sub>c</sub> (T - T<sub>c</sub>) - &epsilon;<sub>b</sub> &alpha; h<sub>wg</sub> (T - T<sub>w</sub>)

(1-&epsilon;<sub>b</sub>) &rho;<sub>c</sub> c<sub>pc</sub> &part;T<sub>c</sub>/&part;t = (1-&epsilon;<sub>b</sub>) K<sub>c</sub> &part;<sup>2</sup>T<sub>c</sub>/&part;z<sup>2</sup> + (1-&epsilon;<sub>b</sub>) G<sub>a</sub> h<sub>c</sub> (T - T<sub>c</sub>) - (1-&epsilon;<sub>b</sub>) &alpha; h<sub>wc</sub> (T<sub>c</sub> - T<sub>w</sub>) + [(1-&epsilon;<sub>b</sub>)/1000]  <span>&sum;</span><sub>&forall;j</sub> ((-&Delta;H<sub>rxn<sub>j</sub></sub>) d<sub>j</sub> r<sub>j</sub>)

&rho;<sub>w</sub> c<sub>pw</sub> &part;T<sub>w</sub>/&part;t = K<sub>w</sub> &part;<sup>2</sup>T<sub>w</sub>/&part;z<sup>2</sup> - &epsilon;<sub>b</sub> &alpha; h<sub>wg</sub> (T<sub>w</sub> - T) - (1-&epsilon;<sub>b</sub>) &alpha; h<sub>wc</sub> (T<sub>w</sub> - T<sub>c</sub>) - &alpha;<sub>w</sub> h<sub>wg</sub> (T<sub>w</sub> - T<sub>a</sub>)

Parameter | Meaning | Units
------------ | ------------- | -------------
&rho; | gas density | g/cm<sup>3</sup>
&rho;<sub>c</sub> | solids density | g/cm<sup>3</sup>
&rho;<sub>w</sub> | wall density | g/cm<sup>3</sup>
c<sub>pg</sub> | specific heat capacity of gas | J/g/K
c<sub>pc</sub> | specific heat capacity of solids | J/g/K
c<sub>pw</sub> | specific heat capacity of wall | J/g/K
T | temperature of gas | K
T<sub>c</sub> | temperature of solids | K
T<sub>w</sub> | temperature of wall | K
T<sub>a</sub> | temperature of ambient air | K
&alpha; | surface to volume ratio for cylindrical reactor inner wall | cm<sup>-1</sup>
&alpha;<sub>w</sub> | surface to volume ratio for cylindrical reactor outer wall | cm<sup>-1</sup>
h<sub>c</sub> | heat transfer rate from gas to solids | J/K/min/cm<sup>2</sup>
h<sub>wg</sub> | heat transfer rate from gas to wall | J/K/min/cm<sup>2</sup>
h<sub>wc</sub> | heat transfer rate from solids to wall | J/K/min/cm<sup>2</sup>
K<sub>c</sub> | solids thermal conductivity | J/K/min/cm
K<sub>w</sub> | wall thermal conductivity | J/K/min/cm
&Delta;H<sub>rxn<sub>j</sub></sub> | heat of the j<sup>th</sup> reaction | J/K/mol
d<sub>j</sub> | &ast;multiplier for heat of reaction | (unitless)

&ast; NOTE: This multiplier is set to 1 by default.

Notes
-----

These tools are a work in progress.

Requirements/Recommendations
-----
- (Recommended): Create a conda environment for (pyomo) or (idaes) to run
- (Minimum Dependent Libraries): [pyomo, numpy, ipopt, pyyaml, matplotlib, scipy, pint, pytest, unittest]
- (Recommended Libraries): [idaes-pse]
- NOTE: If you install pyomo and ipopt through idaes-pse and use 'idaes get-extensions' to get access to additional HSL optimized libraries
- NOTE: If manually installing ipopt on Windows, you will need to specify ipopt=3.11.1
