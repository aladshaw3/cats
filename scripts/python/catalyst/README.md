Python Pyomo Tools for CATS
=====

This directory contains a set of python tools for performing data analyses associated with surface chemistry in monoliths and packed-beds. User's can import data into these objects to simulate and parameterize reaction kinetics assuming the monoliths/packed-beds can be idealized as a 1D-0D reactor.

Isothermal_Monolith_Simulator Equations
-----

&epsilon;<sub>b</sub> &part;C<sub>b,i</sub>/&part;t + &epsilon;<sub>b</sub> v &part;C<sub>b,i</sub>/&part;z = -(1-&epsilon;<sub>b</sub>) G<sub>a</sub> k<sub>m,i</sub> (C<sub>b,i</sub> - C<sub>i</sub>)

&epsilon;<sub>w</sub> (1-&epsilon;<sub>b</sub>) dC<sub>i</sub>/dt = (1-&epsilon;<sub>b</sub>) G<sub>a</sub> k<sub>m,i</sub> (C<sub>b,i</sub> - C<sub>i</sub>) + (1-&epsilon;<sub>b</sub>) &‌sum;

dq/dt = SUM(all i, u_qi * ri)

Smax = S + SUM(all qi, u_si*qi)


Nonisothermal_Monolith_Simulator Equations
-----

(Includes the above in addition to the following...)

eb*rho*cpg*dT/dt + eb*rho*cpg*v*dT/dz = -(1-eb)*Ga*hc*(T - Tc) - eb*a*hwg*(T - Tw)

(1-eb)*rhoc*cpc*dTc/dt = (1-eb)*Kc*d^2T/dz^2 + (1-eb)*Ga*hc*(T - Tc) - (1-eb)*a*hwc*(Tc - Tw) + (1-eb)/1000*SUM(all rj, (-dHrxnj)*d_rxnj**rj)

rhow*cpw*dTw/dt = Kw*d^2Tw/dz^2 - eb*a*hwg*(Tw - T) - (1-eb)*a*hwc*(Tw - Tc) - aw*hwg*(Tw - Ta)


NOTE: These tools are a work in progress.

Requirements/Recommendations
-----
- (Recommended): Create a conda environment for (pyomo) or (idaes) to run
- (Min Dependent Libraries): [pyomo, numpy, ipopt, pyyaml, matplotlib, scipy, pint, pytest, unittest]
- (Rec Libraries): [idaes-pse]
- NOTE: If you install pyomo and ipopt through idaes-pse and use 'idaes get-extensions' to get access to additional HSL optimized libraries
- NOTE: If manually installing ipopt on Windows, you will need to specify ipopt=3.11.1
