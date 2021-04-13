'''
    This file creates an object to simulate non-isothermal monolith catalysis
    systems in pyomo. The primary objective of this simulator is to be
    used in conjunction with dynamic/kinetic monolith data and simulate
    that system while optimizing for the reactions in the system. User must
    provide some reasonable initial guesses to the kinetic parameters for
    the model to work effectively.

    The object inherits from 'isothermal_monolith_catalysis.py' and builds
    upon that object to add an energy balance in the gas and solid phases,
    as well as change a few things about how the user interfaces with the
    original methods.

    Author:     Austin Ladshaw
    Date:       04/13/2021
    Copyright:  This kernel was designed and built at Oak Ridge National
                Laboratory by Austin Ladshaw for research in the area
                of adsorption, catalysis, and surface science.
'''

# Import the pyomo environments
from pyomo.environ import *
from pyomo.dae import *

# Import some scipy tools (for black box evaluations)
from scipy.optimize import least_squares

# Import array and plotting tools
import numpy as np
import matplotlib.pyplot as plt

# Other import statements
import yaml
import os.path
from os import path
from enum import Enum
import time as TIME
import datetime
import json
from ast import literal_eval

# IDAES is not installed, then the script will search for any other available 'ipopt' library
if "idaes" in os.environ['CONDA_DEFAULT_ENV']:
    from idaes.core import *

from catalyst.isothermal_monolith_catalysis import *

# Helper function to evaluate specific heat of gas
def spec_heat_of_air(T):
    return 0.0001883*T + 0.9435061

# Class object to hold the non-isothermal simulator and all
#       model components. The mass balance is the same as before,
#       this object just adds in energy balance equations and changes
#       the reaction constraints to refer to the catalyst temperature
#       rather than the gas temperature.
#
#       NOTE: variable 'model.T' from the base class will represent
#           the gas temperature (for convenience). We will introduce a
#           new 'model.Tc' variable for catalyst temperature. Because of
#           this, we also have to change the reaction constraints to
#           refer to this new temperature variable instead of 'model.T'
#
#       Generalized Model Form:
#       ----------------------
#
#           Energy balance in channel space
#
#                   eb*rho*cpg*dT/dt + eb*rho*cpg*v*dT/dz
#                           = -(1-eb)*Ga*hc*(T - Tc) - eb*a*hwg*(T - Tw)
#
#           Energy balance in the washcoat
#
#                   (1-eb)*rhoc*cpc*dTc/dt = (1-eb)*Ga*hc*(T - Tc)
#                           - (1-eb)*a*hwc*(Tc - Tw) + (1-eb)*SUM(all rj, (-dHrj)*rj)
#
class Nonisothermal_Monolith_Simulator(Isothermal_Monolith_Simulator):
    # Override of base class initialization to add new params and tracking info
    def __init__(self):
        Isothermal_Monolith_Simulator.__init__(self)
        self.model.a = Param(within=NonNegativeReals, initialize=2,
                            mutable=True, units=units.cm**-1)

        # # TODO: May be able to calculate these from thermal conductivity and thickness
        self.model.hc = Param(within=NonNegativeReals, initialize=0.15,
                            mutable=True, units=units.J/units.K/units.min/units.cm**2)
        self.model.hwg = Param(within=NonNegativeReals, initialize=0.15,
                            mutable=True, units=units.J/units.K/units.min/units.cm**2)
        self.model.hwc = Param(within=NonNegativeReals, initialize=0.15,
                            mutable=True, units=units.J/units.K/units.min/units.cm**2)

        self.model.rhoc = Param(within=NonNegativeReals, initialize=0.9,
                            mutable=True, units=units.g/units.cm**3)
        self.model.cpc = Param(within=NonNegativeReals, initialize=0.935,
                            mutable=True, units=units.J/units.g/units.K)

    # Override of base class temperature set function to add new variable info
    def add_temperature_set(self, temps):
        Isothermal_Monolith_Simulator.add_temperature_set(self, temps)
        # # TODO: Add derivatives for T and Tc
        self.model.Tc = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                            domain=NonNegativeReals, initialize=298, units=units.K)
        self.model.cpg = Var(self.model.age_set, self.model.T_set, self.model.t,
                                    domain=NonNegativeReals, initialize=1.005, units=units.J/units.g/units.K)

    # # TODO: Add a temperature data set for fitting exotherms

    # Override of base class set radius function to add calculation of model.a
    def set_reactor_radius(self,rad):
        Isothermal_Monolith_Simulator.set_reactor_radius(self,rad)
        self.model.a.set_value(2.0/self.model.r.value)

    # # TODO: Add a norm form that includes the temperature data
    # # TODO: Customize the weight factors in the norm such that temperature
    #           fits will have same weight (on average) as concentration fits

    # # TODO: Override the reaction rate functions to use Tc instead of T
    #           arrhenius_rate_func and equilibrium_arrhenius_rate_func
    #
    #   NOTE: May need to also override all constraint functions for good measure

    # # TODO: Override 'build_constraints'

    # Override 'discretize_model'
    def discretize_model(self, method=DiscretizationMethod.FiniteDifference,
                        elems=20, tstep=100, colpoints=1):
        Isothermal_Monolith_Simulator.discretize_model(self, method=method,
                        elems=elems, tstep=tstep, colpoints=colpoints)
        # Unfix temperatures by default
        self.model.T[:,:,:,:].unfix()
        self.model.Tc[:,:,:,:].unfix()

        self.model.cpg[:,:,:].fix()
        #       Initialize Tc and cpg
        for age in self.model.age_set:
            for temp in self.model.T_set:
                T = value(self.model.T[age,temp,self.model.z.first(),self.model.t.first()])
                self.model.Tc[age,temp,:,:].set_value(T)
                self.model.cpg[age,temp,:].set_value(spec_heat_of_air(T))

        #       Fix ICs for temperatures
        self.model.T[:,:, :, self.model.t.first()].fix()
        self.model.Tc[:,:, :, self.model.t.first()].fix()
        #self.model.dT_dt[:,:,self.model.z.first(),self.model.t.first()].set_value(0)
        #self.model.dT_dt[:,:,self.model.z.first(),self.model.t.first()].fix()

        #       Fix BCs for temperatures
        self.model.T[:,:,self.model.z.first(), :].fix()
        self.model.Tc[:,:,self.model.z.first(), :].fix()

    #  Override 'set_temperature_ramp' (Fix Tc to T via a ramp function)
    def set_temperature_ramp(self, age, temp, start_time, end_time, end_temp):
        if self.isDiscrete == False:
            print("Error! User should call the discretizer before setting isothermal temperatures")
            exit()
        Isothermal_Monolith_Simulator.set_temperature_ramp(self, age, temp, start_time, end_time, end_temp)
        self.model.Tc[age,temp,:,:].fix()
        self.model.T[age,temp,:,:].fix()
        for time in self.model.t:
            T = value(self.model.T[age,temp,self.model.z.first(),time])
            self.model.Tc[age,temp,:,time].set_value(T)

    # # TODO: Create a 'set_temperature_ramp_BC' function

    # Override 'set_isothermal_temp' (Fix Tc to T)
    def set_isothermal_temp(self,age,temp,value):
        if self.isDiscrete == False:
            print("Error! User should call the discretizer before setting isothermal temperatures")
            exit()
        Isothermal_Monolith_Simulator.set_isothermal_temp(self,age,temp,value)
        self.model.Tc[age,temp,:,:].fix()
        self.model.T[age,temp,:,:].fix()
        self.model.Tc[age,temp,:,:].set_value(value)

    # # TODO: Create a 'set_const_temperature_BC' function

    # # TODO: Create a 'set_time_dependent_temperature_BC' function
