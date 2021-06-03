Python Pyomo Tools for CATS
=====

This directory contains a set of python tools for performing data analyses associated with surface chemistry in monoliths and packed-beds. User's can import data into these objects to simulate and parameterize reaction kinetics assuming the monoliths/packed-beds can be idealized as a 1D-0D reactor.

Isothermal_Monolith_Simulator Equations
-----

&epsilon;<sub>b</sub> &part;C<sub>b,i</sub>/&part;t + &epsilon;<sub>b</sub> v &part;C<sub>b,i</sub>/&part;z = -(1-&epsilon;<sub>b</sub>) G<sub>a</sub> k<sub>m,i</sub> (C<sub>b,i</sub> - C<sub>i</sub>)

&epsilon;<sub>w</sub> (1-&epsilon;<sub>b</sub>) dC<sub>i</sub>/dt = (1-&epsilon;<sub>b</sub>) G<sub>a</sub> k<sub>m,i</sub> (C<sub>b,i</sub> - C<sub>i</sub>) + (1-&epsilon;<sub>b</sub>) <span>&sum;</span><sub>&forall;j</sub> (u<sub>C<sub>j</sub></sub> r<sub>j</sub>)

dq<sub>i</sub>/dt = <span>&sum;</span><sub>&forall;j</sub> (u<sub>q<sub>j</sub></sub> r<sub>j</sub>)

S<sub>max,i</sub> = S<sub>i</sub> + <span>&sum;</span><sub>&forall;q<sub>j</sub></sub> (u<sub>s<sub>j</sub></sub> q<sub>j</sub>)

Parameters
.....
test


Nonisothermal_Monolith_Simulator Equations
-----

(Includes the above in addition to the following...)

&epsilon;<sub>b</sub> &rho; c<sub>pg</sub> &part;T/&part;t + &epsilon;<sub>b</sub> &rho; c<sub>pg</sub> v &part;T/&part;z = -(1-&epsilon;<sub>b</sub>) G<sub>a</sub> h<sub>c</sub> (T - T<sub>c</sub>) - &epsilon;<sub>b</sub> &alpha; h<sub>wg</sub> (T - T<sub>w</sub>)

(1-&epsilon;<sub>b</sub>) &rho;<sub>c</sub> c<sub>pc</sub> &part;T<sub>c</sub>/&part;t = (1-&epsilon;<sub>b</sub>) K<sub>c</sub> &part;<sup>2</sup>T<sub>c</sub>/&part;z<sup>2</sup> + (1-&epsilon;<sub>b</sub>) G<sub>a</sub> h<sub>c</sub> (T - T<sub>c</sub>) - (1-&epsilon;<sub>b</sub>) &alpha; h<sub>wc</sub> (T<sub>c</sub> - T<sub>w</sub>) + [(1-&epsilon;<sub>b</sub>)/1000]  <span>&sum;</span><sub>&forall;j</sub> ((-&Delta;H<sub>rxn<sub>j</sub></sub>) d<sub>j</sub> r<sub>j</sub>)

&rho;<sub>w</sub> c<sub>pw</sub> &part;T<sub>w</sub>/&part;t = K<sub>w</sub> &part;<sup>2</sup>T<sub>w</sub>/&part;z<sup>2</sup> - &epsilon;<sub>b</sub> &alpha; h<sub>wg</sub> (T<sub>w</sub> - T) - (1-&epsilon;<sub>b</sub>) &alpha; h<sub>wc</sub> (T<sub>w</sub> - T<sub>c</sub>) - &alpha;<sub>w</sub> h<sub>wg</sub> (T<sub>w</sub> - T<sub>a</sub>)


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
