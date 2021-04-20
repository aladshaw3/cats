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
#                           - (1-eb)*a*hwc*(Tc - Tw) + (1-eb)/1000*SUM(all rj, (-dHrxnj)*d_rxnj**rj)
#
#               NOTE: d_rxnj = Kronecker Delta based on reaction/catalyst zoning
#
class Nonisothermal_Monolith_Simulator(Isothermal_Monolith_Simulator):
    # Override of base class initialization to add new params and tracking info
    def __init__(self):
        Isothermal_Monolith_Simulator.__init__(self)
        self.model.a = Param(within=NonNegativeReals, initialize=2,
                            mutable=True, units=units.cm**-1)

        # # TODO: May be able to calculate these from thermal conductivity and thickness
        self.model.hc = Var(domain=NonNegativeReals, initialize=0.15,
                            units=units.J/units.K/units.min/units.cm**2)
        self.model.hwg = Var(domain=NonNegativeReals, initialize=0.15,
                            units=units.J/units.K/units.min/units.cm**2)
        self.model.hwc = Var(domain=NonNegativeReals, initialize=0.15,
                            units=units.J/units.K/units.min/units.cm**2)

        self.model.rhoc = Param(within=NonNegativeReals, initialize=0.9,
                            mutable=True, units=units.g/units.cm**3)
        self.model.cpc = Param(within=NonNegativeReals, initialize=0.935,
                            mutable=True, units=units.J/units.g/units.K)

        self.heats_list = {}
        self.heats_list["hc"] = False
        self.heats_list["hwg"] = False
        self.heats_list["hwc"] = False
        self.heats_list["dHrxn"] = {}
        self.isInitialTempSet = {}
        self.isWallTempSet = {}
        self.isBoundaryTempSet = {}
        self.isIsothermal = {}
        self.isAllIsothermal = True

    # Override of base class temperature set function to add new variable info
    def add_temperature_set(self, temps):
        Isothermal_Monolith_Simulator.add_temperature_set(self, temps)
        self.model.Tc = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                            domain=NonNegativeReals, initialize=298, units=units.K)
        self.model.Tw = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                            domain=NonNegativeReals, initialize=298, units=units.K)
        self.model.dT_dz = DerivativeVar(self.model.T, wrt=self.model.z, initialize=0, units=units.K/units.cm)
        self.model.dT_dt = DerivativeVar(self.model.T, wrt=self.model.t, initialize=0, units=units.K/units.min)
        self.model.dTc_dt = DerivativeVar(self.model.Tc, wrt=self.model.t, initialize=0, units=units.K/units.min)
        self.model.cpg = Var(self.model.age_set, self.model.T_set, self.model.t,
                                    domain=NonNegativeReals, initialize=1.005, units=units.J/units.g/units.K)

        for age in self.model.age_set:
            self.isInitialTempSet[age] = {}
            self.isBoundaryTempSet[age] = {}
            self.isIsothermal[age] = {}
            self.isWallTempSet[age] = {}
            for temp in self.model.T_set:
                self.isInitialTempSet[age][temp] = False
                self.isBoundaryTempSet[age][temp] = False
                self.isIsothermal[age][temp] = False
                self.isWallTempSet[age][temp] = False

    # Override for adding reactions which adds in new var/params for heat of reactions
    def add_reactions(self, rxns):
        Isothermal_Monolith_Simulator.add_reactions(self, rxns)
        self.model.dHrxn = Var(self.model.all_rxns, domain=Reals, initialize=0)
        self.model.d_rxn = Var(self.model.all_rxns, self.model.z, domain=Reals, initialize=1)

        for rxn in self.model.all_rxns:
            self.heats_list["dHrxn"][rxn] = False

    # # TODO: Add a temperature data set for fitting exotherms

    # Override of base class set radius function to add calculation of model.a
    def set_reactor_radius(self,rad):
        Isothermal_Monolith_Simulator.set_reactor_radius(self,rad)
        self.model.a.set_value(2.0/self.model.r.value)

    # # TODO: Add a norm form that includes the temperature data
    # # TODO: Customize the weight factors in the norm such that temperature
    #           fits will have same weight (on average) as concentration fits

    # Define a single arrhenius rate function to be used in the model
    #       This function assumes the reaction index (rxn) is valid
    def arrhenius_rate_func(self, rxn, model, age, temp, loc, time):
        r = 0
        k = arrhenius_rate_const(model.A[rxn], model.B[rxn], model.E[rxn], model.Tc[age,temp,loc,time])
        r=k
        for spec in model.component(rxn+"_reactants"):
            if spec in model.gas_set:
                r=r*model.C[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
            if self.isSurfSpecSet == True:
                if spec in model.surf_set:
                    r=r*model.q[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
                if self.isSitesSet == True:
                    if spec in model.site_set:
                        r=r*model.S[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
        return r

    # Define a single equilibrium arrhenius rate function to be used in the model
    #       This function assumes the reaction index (rxn) is valid
    def equilibrium_arrhenius_rate_func(self, rxn, model, age, temp, loc, time):
        r = 0
        (Ar, Er) = equilibrium_arrhenius_consts(model.Af[rxn], model.Ef[rxn], model.dH[rxn], model.dS[rxn])
        kf = arrhenius_rate_const(model.Af[rxn], 0, model.Ef[rxn], model.Tc[age,temp,loc,time])
        kr = arrhenius_rate_const(Ar, 0, Er, model.Tc[age,temp,loc,time])
        rf=kf
        rr=kr
        for spec in model.component(rxn+"_reactants"):
            if spec in model.gas_set:
                rf=rf*model.C[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
            if self.isSurfSpecSet == True:
                if spec in model.surf_set:
                    rf=rf*model.q[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
                if self.isSitesSet == True:
                    if spec in model.site_set:
                        rf=rf*model.S[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
        for spec in model.component(rxn+"_products"):
             if spec in model.gas_set:
                 rr=rr*model.C[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
             if self.isSurfSpecSet == True:
                 if spec in model.surf_set:
                     rr=rr*model.q[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
                 if self.isSitesSet == True:
                     if spec in model.site_set:
                         rr=rr*model.S[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
        r = rf-rr
        return r

    # Define a function for the reaction sum for gas species
    def reaction_sum_gas(self, gas_spec, model, age, temp, loc, time):
        r_sum=0
        for r in model.arrhenius_rxns:
            r_sum += model.u_C[gas_spec,r,loc]*self.arrhenius_rate_func(r, model, age, temp, loc, time)
        for re in model.equ_arrhenius_rxns:
            r_sum += model.u_C[gas_spec,re,loc]*self.equilibrium_arrhenius_rate_func(re, model, age, temp, loc, time)
        return r_sum

    # Define a function for the reaction sum for surface species
    def reaction_sum_surf(self, surf_spec, model, age, temp, loc, time):
        r_sum=0
        for r in model.arrhenius_rxns:
            r_sum += model.u_q[surf_spec,r,loc]*self.arrhenius_rate_func(r, model, age, temp, loc, time)
        for re in model.equ_arrhenius_rxns:
            r_sum += model.u_q[surf_spec,re,loc]*self.equilibrium_arrhenius_rate_func(re, model, age, temp, loc, time)
        return r_sum

    # Define a function for the reaction sum for energy balance
    def reaction_sum_heats(self, model, age, temp, loc, time):
        r_sum=0
        for r in model.arrhenius_rxns:
            r_sum += -model.dHrxn[r]*model.d_rxn[r,loc]*self.arrhenius_rate_func(r, model, age, temp, loc, time)
        for re in model.equ_arrhenius_rxns:
            r_sum += -model.dHrxn[re]*model.d_rxn[re,loc]*self.equilibrium_arrhenius_rate_func(re, model, age, temp, loc, time)
        return r_sum

    # Define a function for the site sum
    def site_sum(self, site_spec, model, age, temp, loc, time):
        sum = 0
        for surf_spec in model.surf_set:
            sum+=model.u_S[site_spec,surf_spec]*model.q[surf_spec,age,temp,loc,time]
        return sum

    # Bulk mass balance constraint
    def bulk_mb_constraint(self, m, gas, age, temp, z, t):
        return m.eb*m.dCb_dt[gas, age, temp, z, t] + m.eb*m.v[age,temp,t]*m.dCb_dz[gas, age, temp, z, t] == -(1-m.eb)*m.Ga*m.km[gas, age, temp, z, t]*(m.Cb[gas, age, temp, z, t] - m.C[gas, age, temp, z, t])

    # Washcoat mass balance constraint
    def pore_mb_constraint(self, m, gas, age, temp, z, t):
        rxn_sum=self.reaction_sum_gas(gas, m, age, temp, z, t)
        return m.ew*(1-m.eb)*m.dC_dt[gas, age, temp, z, t] == (1-m.eb)*m.Ga*m.km[gas, age, temp, z, t]*(m.Cb[gas, age, temp, z, t] - m.C[gas, age, temp, z, t]) + (1-m.eb)*rxn_sum

    # Adsorption/surface mass balance constraint
    def surf_mb_constraint(self, m, surf, age, temp, z, t):
        rxn_sum=self.reaction_sum_surf(surf, m, age, temp, z, t)
        return m.dq_dt[surf, age, temp, z, t] == rxn_sum

    # Site density balance constraint
    def site_bal_constraint(self, m, site, age, temp, z, t):
        sum=self.site_sum(site, m, age, temp, z, t)
        return m.Smax[site,age,z,t] - m.S[site, age, temp, z, t] - sum == 0

    # Energy balance in gas phase
    def gas_eb_constraint(self, m, age, temp, z, t):
        return m.eb*m.rho[age,temp,t]*m.cpg[age,temp,t]*m.dT_dt[age,temp,z,t] + m.eb*m.rho[age,temp,t]*m.cpg[age,temp,t]*m.v[age,temp,t]*m.dT_dz[age,temp,z,t] \
                == -(1-m.eb)*m.Ga*m.hc*(m.T[age,temp,z,t]-m.Tc[age,temp,z,t]) - m.eb*m.a*m.hwg*(m.T[age,temp,z,t]-m.Tw[age,temp,z,t])

    # Energy balance in solid phase
    #                   (1-eb)*rhoc*cpc*dTc/dt = (1-eb)*Ga*hc*(T - Tc)
    #                           - (1-eb)*a*hwc*(Tc - Tw) + (1-eb)/1000*SUM(all rj, (-dHrxnj)*d_rxnj**rj)
    def solid_eb_constraint(self, m, age, temp, z, t):
        rxn_sum=self.reaction_sum_heats(m, age, temp, z, t)
        return (1-m.eb)*m.rhoc*m.cpc*m.dTc_dt[age,temp,z,t] == (1-m.eb)*m.Ga*m.hc*(m.T[age,temp,z,t]-m.Tc[age,temp,z,t]) \
                -(1-m.eb)*m.a*m.hwc*(m.Tc[age,temp,z,t]-m.Tw[age,temp,z,t]) + ((1-m.eb)/1000)*rxn_sum

    # Edge constraint for central differencing
    def temp_edge_constraint(self, m, age, temp, t):
        return m.dT_dz[age, temp, m.z[-1], t] == (m.T[age, temp, m.z[-1], t] - m.T[age, temp, m.z[-2], t])/(m.z[-1]-m.z[-2])

    # Build Constraints
    def build_constraints(self):
        for rxn in self.model.all_rxns:
            if self.isRxnBuilt[rxn] == False:
                print("Error! Cannot build constraints until reaction info is set")
                exit()
        self.model.bulk_cons = Constraint(self.model.gas_set, self.model.age_set,
                                self.model.T_set, self.model.z,
                                self.model.t, rule=self.bulk_mb_constraint)
        self.model.pore_cons = Constraint(self.model.gas_set, self.model.age_set,
                                self.model.T_set, self.model.z,
                                self.model.t, rule=self.pore_mb_constraint)
        if self.isSurfSpecSet == True:
            self.model.surf_cons = Constraint(self.model.surf_set, self.model.age_set,
                                    self.model.T_set, self.model.z,
                                    self.model.t, rule=self.surf_mb_constraint)

            if self.isSitesSet == True:
                self.model.site_cons = Constraint(self.model.site_set, self.model.age_set,
                                        self.model.T_set, self.model.z,
                                        self.model.t, rule=self.site_bal_constraint)

        self.model.gas_energy = Constraint(self.model.age_set,
                                self.model.T_set, self.model.z,
                                self.model.t, rule=self.gas_eb_constraint)

        self.model.solid_energy = Constraint(self.model.age_set,
                                self.model.T_set, self.model.z,
                                self.model.t, rule=self.solid_eb_constraint)

        self.isConBuilt = True

    # Override 'discretize_model'
    def discretize_model(self, method=DiscretizationMethod.FiniteDifference,
                        elems=20, tstep=100, colpoints=1):
        Isothermal_Monolith_Simulator.discretize_model(self, method=method,
                        elems=elems, tstep=tstep, colpoints=colpoints)

        if self.DiscType == "DiscretizationMethod.FiniteDifference":
            self.model.dTdz_edge = Constraint(self.model.age_set, self.model.T_set, self.model.t, rule=self.temp_edge_constraint)
        # Unfix temperatures by default
        self.model.T[:,:,:,:].unfix()
        self.model.Tc[:,:,:,:].unfix()

        self.model.Tw[:,:,:,:].fix()
        self.model.cpg[:,:,:].fix()
        #       Initialize Tc and cpg
        for age in self.model.age_set:
            for temp in self.model.T_set:
                T = value(self.model.T[age,temp,self.model.z.first(),self.model.t.first()])
                self.model.Tc[age,temp,:,:].set_value(T)
                self.model.Tw[age,temp,:,:].set_value(T)
                self.model.cpg[age,temp,:].set_value(spec_heat_of_air(T))

        #       Initialize Kronecker delta
        self.model.d_rxn.fix()
        for rxn in self.model.all_rxns:
            val = value(self.model.d_rxn[rxn,self.model.z.first()])
            self.model.d_rxn[rxn,:].set_value(val)

        #       Fix ICs for temperatures
        self.model.T[:,:, :, self.model.t.first()].fix()
        self.model.Tc[:,:, :, self.model.t.first()].fix()
        self.model.dT_dt[:,:,self.model.z.first(),self.model.t.first()].set_value(0)
        self.model.dT_dt[:,:,self.model.z.first(),self.model.t.first()].fix()

        #       Fix BCs for temperatures
        self.model.T[:,:,self.model.z.first(), :].fix()
        self.model.Tc[:,:,self.model.z.first(), :].fix()

        # # TODO: Deactivate any objective function (if any), then activate a new
        #           objective function for inclusion of temperature data

    # # TODO: Override 'set_reaction_zone'

    # # TODO: Override 'set_reaction_info' (and add bounds on parameters)

    # # TODO: Create a set of 'set_heats' function (and add bounds on parameters)

    #  Override 'set_temperature_ramp' (Fix Tc to T via a ramp function)
    def set_temperature_ramp(self, age, temp, start_time, end_time, end_temp):
        if self.isDiscrete == False:
            print("Error! User should call the discretizer before setting isothermal temperatures")
            exit()
        Isothermal_Monolith_Simulator.set_temperature_ramp(self, age, temp, start_time, end_time, end_temp)
        self.model.Tc[age,temp,:,:].fix()
        self.model.T[age,temp,:,:].fix()

        # Fix the derivative vars
        self.model.dTc_dt[age,temp,:,:].fix()
        self.model.dT_dt[age,temp,:,:].fix()
        self.model.dT_dz[age,temp,:,:].fix()
        self.model.dTc_dt_disc_eq[age,temp,:,:].deactivate()
        self.model.dT_dt_disc_eq[age,temp,:,:].deactivate()
        self.model.dT_dz_disc_eq[age,temp,:,:].deactivate()
        self.model.gas_energy[age,temp,:,:].deactivate()
        self.model.solid_energy[age,temp,:,:].deactivate()
        self.isInitialTempSet[age][temp] = True
        self.isBoundaryTempSet[age][temp] = True
        self.isWallTempSet[age][temp] = True
        self.isIsothermal[age][temp] = True
        for time in self.model.t:
            T = value(self.model.T[age,temp,self.model.z.first(),time])
            self.model.Tc[age,temp,:,time].set_value(T)
            self.model.Tw[age,temp,:,time].set_value(T)

    # Override 'set_isothermal_temp' (Fix Tc to T)
    def set_isothermal_temp(self,age,temp,value):
        if self.isDiscrete == False:
            print("Error! User should call the discretizer before setting isothermal temperatures")
            exit()
        Isothermal_Monolith_Simulator.set_isothermal_temp(self,age,temp,value)
        self.model.Tc[age,temp,:,:].fix()
        self.model.T[age,temp,:,:].fix()
        self.model.Tc[age,temp,:,:].set_value(value)
        self.model.Tw[age,temp,:,:].set_value(value)

        # Fix the derivative vars
        self.model.dTc_dt[age,temp,:,:].fix()
        self.model.dT_dt[age,temp,:,:].fix()
        self.model.dT_dz[age,temp,:,:].fix()
        self.model.dTc_dt_disc_eq[age,temp,:,:].deactivate()
        self.model.dT_dt_disc_eq[age,temp,:,:].deactivate()
        self.model.dT_dz_disc_eq[age,temp,:,:].deactivate()
        self.model.gas_energy[age,temp,:,:].deactivate()
        self.model.solid_energy[age,temp,:,:].deactivate()

        self.isInitialTempSet[age][temp] = True
        self.isBoundaryTempSet[age][temp] = True
        self.isIsothermal[age][temp] = True
        self.isWallTempSet[age][temp] = True

    # Create a 'set_const_wall_temperature' function
    def set_const_wall_temperature(self,age,temp,value):
        self.model.Tw[age,temp,:,:].set_value(value)
        self.isWallTempSet[age][temp] = True

    # Create a 'set_const_temperature_IC' function
    def set_const_temperature_IC(self,age,temp,value):
        if self.isDiscrete == False:
            print("Error! User should call the discretizer before setting initial conditions")
            exit()
        self.model.T[age,temp, :, self.model.t.first()].set_value(value)
        self.model.T[age,temp, :, self.model.t.first()].fix()
        self.model.Tc[age,temp, :, self.model.t.first()].set_value(value)
        self.model.Tc[age,temp, :, self.model.t.first()].fix()
        self.isInitialTempSet[age][temp] = True
        self.isVelocityRecalculated = False

    # Create a 'set_const_temperature_BC' function
    def set_const_temperature_BC(self,age,temp,value):
        if self.isInitialTempSet[age][temp] == False:
            print("Error! User must specify initial conditions before boundary conditions")
            exit()

        self.model.T[age,temp,self.model.z.first(), :].set_value(value)
        self.model.T[age,temp,self.model.z.first(), :].fix()
        self.isBoundaryTempSet[age][temp] = True
        self.isVelocityRecalculated = False

    # # TODO: Create a 'set_time_dependent_temperature_BC' function

    # # TODO: Create a 'set_temperature_ramp_BC' function

    # Override 'recalculate_linear_velocities'
    def recalculate_linear_velocities(self, interally_called=False, isMonolith=True):
        Isothermal_Monolith_Simulator.recalculate_linear_velocities(self, interally_called=interally_called, isMonolith=isMonolith)
        for age in self.model.age_set:
            for temp in self.model.T_set:
                for time in self.model.t:
                    T = value(self.model.T[age,temp,self.model.z.first(),time])
                    self.model.cpg[age,temp,time].set_value(spec_heat_of_air(T))

        # # TODO: Add in calculation for heats (hc, hwc, hwg)?

    # Function to fix a heat term
    def fix_heat(self,name):
        if name == "hc":
            self.model.hc.fix()
            self.heats_list["hc"] = True
        elif name == "hwg":
            self.model.hwg.fix()
            self.heats_list["hwg"] = True
        elif name == "hwc":
            self.model.hwc.fix()
            self.heats_list["hwc"] = True
        else:
            if name in self.model.all_rxns:
                self.model.dHrxn[name].fix()
                self.heats_list["dHrxn"][name] = True

    # Function to fix all heat terms
    def fix_all_heats(self):
        self.model.hc.fix()
        self.model.hwg.fix()
        self.model.hwc.fix()
        self.heats_list["hc"] = True
        self.heats_list["hwg"] = True
        self.heats_list["hwc"] = True
        for r in self.model.all_rxns:
            self.model.dHrxn[r].fix()
            self.heats_list["dHrxn"][r] = True

    # Function to fix all reaction heats
    def fix_all_reaction_heats(self):
        for r in self.model.all_rxns:
            self.model.dHrxn[r].fix()
            self.heats_list["dHrxn"][r] = True


    # Function to unfix a heat term
    def unfix_heat(self,name):
        if name == "hc":
            self.model.hc.unfix()
            self.heats_list["hc"] = False
        elif name == "hwg":
            self.model.hwg.unfix()
            self.heats_list["hwg"] = False
        elif name == "hwc":
            self.model.hwc.unfix()
            self.heats_list["hwc"] = False
        else:
            if name in self.model.all_rxns:
                self.model.dHrxn[name].unfix()
                self.heats_list["dHrxn"][name] = False

    # Function to unfix all heat terms
    def unfix_all_heats(self):
        self.model.hc.unfix()
        self.model.hwg.unfix()
        self.model.hwc.unfix()
        self.heats_list["hc"] = False
        self.heats_list["hwg"] = False
        self.heats_list["hwc"] = False
        for r in self.model.all_rxns:
            self.model.dHrxn[r].unfix()
            self.heats_list["dHrxn"][r] = False

    # Function to unfix all reaction heats
    def unfix_all_reaction_heats(self):
        for r in self.model.all_rxns:
            self.model.dHrxn[r].unfix()
            self.heats_list["dHrxn"][r] = False

    # Override 'initialize_auto_scaling'
    def initialize_auto_scaling(self):
        Isothermal_Monolith_Simulator.initialize_auto_scaling(self)
        if self.isBoundaryTempSet == False:
            print("Error! Must specify boundary conditions for temperature before attempting scaling")
            exit()

        # set initial scaling factor to inverse of max values
        maxkey = max(self.model.T.get_values(), key=self.model.T.get_values().get)
        maxval = self.model.T[maxkey].value
        self.model.scaling_factor.set_value(self.model.T, 1/maxval)
        self.model.scaling_factor.set_value(self.model.Tc, 1/maxval)

        # set initial scaling factors for heats
        self.model.scaling_factor.set_value(self.model.hc, 1/self.model.hc.value)
        self.model.scaling_factor.set_value(self.model.hwc, 1/self.model.hwc.value)
        self.model.scaling_factor.set_value(self.model.hwg, 1/self.model.hwg.value)
        for rxn in self.model.all_rxns:
            dHval = abs(self.model.dHrxn[rxn].value)
            if dHval < 1e-2:
                dHval = 1
            self.model.scaling_factor.set_value(self.model.dHrxn[rxn], 1/dHval)

        # set scaling for gas energy constraints
        maxval = 0
        for key in self.model.gas_energy:
            newval = abs(value(self.model.gas_energy[key]))
            if newval > maxval:
                maxval = newval
        if maxval < 1e-1:
            maxval = 1e-1
        self.model.scaling_factor.set_value(self.model.gas_energy, 1/maxval)

        # set scaling for solid energy constraints
        maxval = 0
        for key in self.model.solid_energy:
            newval = abs(value(self.model.solid_energy[key]))
            if newval > maxval:
                maxval = newval
        if maxval < 1e-1:
            maxval = 1e-1
        self.model.scaling_factor.set_value(self.model.solid_energy, 1/maxval)

        # set scaling for derivative variables and constraints
        maxval = 0
        for key in self.model.dT_dz_disc_eq:
            newval = abs(value(self.model.dT_dz_disc_eq[key]))
            if newval > maxval:
                maxval = newval
        if maxval < 1e-1:
            maxval = 1e-1
        self.model.scaling_factor.set_value(self.model.dT_dz_disc_eq, 1/maxval)
        self.model.scaling_factor.set_value(self.model.dT_dz, 1/maxval)

        maxval = 0
        for key in self.model.dT_dt_disc_eq:
            newval = abs(value(self.model.dT_dt_disc_eq[key]))
            if newval > maxval:
                maxval = newval
        if maxval < 1e-1:
            maxval = 1e-1
        self.model.scaling_factor.set_value(self.model.dT_dt_disc_eq, 1/maxval)
        self.model.scaling_factor.set_value(self.model.dT_dt, 1/maxval)
        self.model.scaling_factor.set_value(self.model.dTc_dt_disc_eq, 1/maxval)
        self.model.scaling_factor.set_value(self.model.dTc_dt, 1/maxval)

    # Override 'finalize_auto_scaling'
    def finalize_auto_scaling(self):
        Isothermal_Monolith_Simulator.finalize_auto_scaling(self)

        # Reset constraints for variables and derivative variables
        #       NOT for the constraints though (these should not be rescaled)
        maxkey = max(self.model.T.get_values(), key=self.model.T.get_values().get)
        maxval = self.model.T[maxkey].value
        self.model.scaling_factor.set_value(self.model.T, 1/maxval)
        self.model.scaling_factor.set_value(self.model.Tc, 1/maxval)

        # set scaling for derivative vars
        maxkey = max(self.model.dT_dz.get_values(), key=self.model.dT_dz.get_values().get)
        minkey = min(self.model.dT_dz.get_values(), key=self.model.dT_dz.get_values().get)

        if abs(self.model.dT_dz[maxkey].value) >= abs(self.model.dT_dz[minkey].value):
            maxval = abs(self.model.dT_dz[maxkey].value)
        else:
            maxval = abs(self.model.dT_dz[minkey].value)
        if maxval < 1e-1:
            maxval = 1e-1
        self.model.scaling_factor.set_value(self.model.dT_dz, 1/maxval)
        self.model.scaling_factor.set_value(self.model.dT_dz_disc_eq, 1/maxval)

        maxkey = max(self.model.dT_dt.get_values(), key=self.model.dT_dt.get_values().get)
        minkey = min(self.model.dT_dt.get_values(), key=self.model.dT_dt.get_values().get)

        if abs(self.model.dT_dt[maxkey].value) >= abs(self.model.dT_dt[minkey].value):
            maxval = abs(self.model.dT_dt[maxkey].value)
        else:
            maxval = abs(self.model.dT_dt[minkey].value)
        if maxval < 1e-1:
            maxval = 1e-1
        self.model.scaling_factor.set_value(self.model.dT_dt, 1/maxval)
        self.model.scaling_factor.set_value(self.model.dT_dt_disc_eq, 1/maxval)

        maxkey = max(self.model.dTc_dt.get_values(), key=self.model.dTc_dt.get_values().get)
        minkey = min(self.model.dTc_dt.get_values(), key=self.model.dTc_dt.get_values().get)

        if abs(self.model.dTc_dt[maxkey].value) >= abs(self.model.dTc_dt[minkey].value):
            maxval = abs(self.model.dTc_dt[maxkey].value)
        else:
            maxval = abs(self.model.dTc_dt[minkey].value)
        if maxval < 1e-1:
            maxval = 1e-1
        self.model.scaling_factor.set_value(self.model.dTc_dt, 1/maxval)
        self.model.scaling_factor.set_value(self.model.dTc_dt_disc_eq, 1/maxval)

        # reset scaling factors for heats
        self.model.scaling_factor.set_value(self.model.hc, 1/self.model.hc.value)
        self.model.scaling_factor.set_value(self.model.hwc, 1/self.model.hwc.value)
        self.model.scaling_factor.set_value(self.model.hwg, 1/self.model.hwg.value)
        for rxn in self.model.all_rxns:
            dHval = abs(self.model.dHrxn[rxn].value)
            if dHval < 1e-2:
                dHval = 1
            self.model.scaling_factor.set_value(self.model.dHrxn[rxn], 1/dHval)

        # Only rescale constraints if they were not scaled before
        if self.rescaleConstraint == True:
            # set scaling for gas energy constraints
            maxval = 0
            for key in self.model.gas_energy:
                newval = abs(value(self.model.gas_energy[key]))
                if newval > maxval:
                    maxval = newval
            if maxval < 1e-1:
                maxval = 1e-1
            self.model.scaling_factor.set_value(self.model.gas_energy, 1/maxval)

            # set scaling for solid energy constraints
            maxval = 0
            for key in self.model.solid_energy:
                newval = abs(value(self.model.solid_energy[key]))
                if newval > maxval:
                    maxval = newval
            if maxval < 1e-1:
                maxval = 1e-1
            self.model.scaling_factor.set_value(self.model.solid_energy, 1/maxval)


    # # TODO: Override 'initialize_simulator'
    def initialize_simulator(self, console_out=False, options={'print_user_options': 'yes',
                                                    'linear_solver': LinearSolverMethod.MA97,
                                                    'tol': 1e-8,
                                                    'acceptable_tol': 1e-8,
                                                    'compl_inf_tol': 1e-8,
                                                    'constr_viol_tol': 1e-8,
                                                    'max_iter': 3000,
                                                    'obj_scaling_factor': 1,
                                                    'diverging_iterates_tol': 1e50}):

        for age in self.isIsothermal:
            for temp in self.isIsothermal[age]:
                if self.isIsothermal[age][temp] == False:
                    self.isAllIsothermal = False
                    break
            if self.isAllIsothermal == False:
                break
        if self.isAllIsothermal == True:
            return Isothermal_Monolith_Simulator.initialize_simulator(self,
                                                                console_out=console_out,
                                                                options=options)
        else:
            for spec in self.model.gas_set:
                for age in self.model.age_set:
                    for temp in self.model.T_set:
                        if self.isBoundarySet[spec][age][temp] == False:
                            print("Error! Must specify boundaries before attempting to solve")
                            exit()
            if self.isSurfSpecSet == True:
                for spec in self.model.surf_set:
                    for age in self.model.age_set:
                        for temp in self.model.T_set:
                            if self.isInitialSet[spec][age][temp] == False:
                                print("Error! Must specify initial conditions before attempting to solve")
                                exit()
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    if self.isBoundaryTempSet[age][temp] == False:
                        print("Error! Must specify boundaries before attempting to solve")
                        exit()
                    if self.isWallTempSet[age][temp] == False:
                        print("Error! Must specify wall temperatures before attempting to solve")
                        exit()

            if self.isVelocityRecalculated == False:
                self.recalculate_linear_velocities(interally_called=True,isMonolith=True)

            # Setup a dictionary to determine which reaction to unfix after solve
            self.initialize_time = TIME.time()
            fixed_dict = {}
            fixed_heat_dict = {}
            for rxn in self.rxn_list:
                fixed_dict[rxn]=self.rxn_list[rxn]["fixed"]
            for item in self.heats_list:
                if item == "hc":
                    fixed_heat_dict[item] = self.heats_list[item]
                elif item == "hwc":
                    fixed_heat_dict[item] = self.heats_list[item]
                elif item == "hwg":
                    fixed_heat_dict[item] = self.heats_list[item]
                else:
                    fixed_heat_dict[item] = {}
                    for rxn in self.heats_list[item]:
                        fixed_heat_dict[item][rxn] = self.heats_list[item][rxn]
            self.fix_all_reactions()
            self.fix_all_heats()

            # Run a solve of the model without objective function
            if self.isObjectiveSet == True:
                self.model.obj.deactivate()

            # Fix all times not associated with current time step
            self.model.Cb[:, :, :, :, :].fix()
            self.model.C[:, :, :, :, :].fix()
            self.model.dCb_dt[:, :, :, :, :].fix()
            self.model.dC_dt[:, :, :, :, :].fix()
            self.model.dCb_dz[:, :, :, :, :].fix()
            self.model.bulk_cons[:, :, :, :, :].deactivate()
            self.model.pore_cons[:, :, :, :, :].deactivate()
            self.model.dCb_dz_disc_eq[:, :, :, :, :].deactivate()
            self.model.dCb_dt_disc_eq[:, :, :, :, :].deactivate()
            self.model.dC_dt_disc_eq[:, :, :, :, :].deactivate()
            if self.DiscType == "DiscretizationMethod.FiniteDifference":
                self.model.dCbdz_edge[:, :, :, :].deactivate()
                self.model.dTdz_edge[:, :, :].deactivate()

            self.model.Tc[:,:,:,:].fix()
            self.model.T[:,:,:,:].fix()
            self.model.dTc_dt[:,:,:,:].fix()
            self.model.dT_dt[:,:,:,:].fix()
            self.model.dT_dz[:,:,:,:].fix()
            self.model.gas_energy[:,:,:,:].deactivate()
            self.model.solid_energy[:,:,:,:].deactivate()
            self.model.dTc_dt_disc_eq[:,:,:,:].deactivate()
            self.model.dT_dt_disc_eq[:,:,:,:].deactivate()
            self.model.dT_dz_disc_eq[:,:,:,:].deactivate()

            if self.isSurfSpecSet == True:
                self.model.q[:, :, :, :, :].fix()
                self.model.dq_dt[:, :, :, :, :].fix()
                self.model.surf_cons[:, :, :, :, :].deactivate()
                self.model.dq_dt_disc_eq[:, :, :, :, :].deactivate()

                if self.isSitesSet == True:
                    self.model.S[:, :, :, :, :].fix()
                    self.model.site_cons[:, :, :, :, :].deactivate()

            # Loops over specific sub-problems to solve
            for age_solve in self.model.age_set:
                for temp_solve in self.model.T_set:

                    # Inside age_solve && temp_solve
                    print("Initializing for " + str(age_solve) + " -> " + str(temp_solve))

                    i=0
                    for time_solve in self.model.t:
                        # Solve 1 time at a time starting with the i=1 time step (since IC is known)
                        if i > 0:
                            start = TIME.time()
                            print("\t... time_step " + str(time_solve))
                            self.model.Cb[:, age_solve, temp_solve, :, time_solve].unfix()
                            self.model.C[:, age_solve, temp_solve, :, time_solve].unfix()
                            self.model.dCb_dt[:, age_solve, temp_solve, :, time_solve].unfix()
                            self.model.dC_dt[:, age_solve, temp_solve, :, time_solve].unfix()
                            self.model.dCb_dz[:, age_solve, temp_solve, :, time_solve].unfix()
                            self.model.bulk_cons[:, age_solve, temp_solve, :, time_solve].activate()
                            self.model.pore_cons[:, age_solve, temp_solve, :, time_solve].activate()
                            self.model.dCb_dz_disc_eq[:, age_solve, temp_solve, :, time_solve].activate()
                            self.model.dCb_dt_disc_eq[:, age_solve, temp_solve, :, time_solve].activate()
                            self.model.dC_dt_disc_eq[:, age_solve, temp_solve, :, time_solve].activate()
                            if self.DiscType == "DiscretizationMethod.FiniteDifference":
                                self.model.dCbdz_edge[:, age_solve, temp_solve, time_solve].activate()
                                self.model.dTdz_edge[age_solve, temp_solve, time_solve].activate()

                            if self.isIsothermal[age_solve][temp_solve] == False:
                                self.model.T[age_solve, temp_solve, :, time_solve].unfix()
                                self.model.Tc[age_solve, temp_solve, :, time_solve].unfix()
                                self.model.dT_dt[age_solve, temp_solve, :, time_solve].unfix()
                                self.model.dTc_dt[age_solve, temp_solve, :, time_solve].unfix()
                                self.model.dT_dz[age_solve, temp_solve, :, time_solve].unfix()
                                self.model.gas_energy[age_solve, temp_solve, :, time_solve].activate()
                                self.model.solid_energy[age_solve, temp_solve, :, time_solve].activate()
                                self.model.dT_dz_disc_eq[age_solve, temp_solve, :, time_solve].activate()
                                self.model.dT_dt_disc_eq[age_solve, temp_solve, :, time_solve].activate()
                                self.model.dTc_dt_disc_eq[age_solve, temp_solve, :, time_solve].activate()


                            if self.isSurfSpecSet == True:
                                self.model.q[:, age_solve, temp_solve, :, time_solve].unfix()
                                self.model.dq_dt[:, age_solve, temp_solve, :, time_solve].unfix()
                                self.model.surf_cons[:, age_solve, temp_solve, :, time_solve].activate()
                                self.model.dq_dt_disc_eq[:, age_solve, temp_solve, :, time_solve].activate()

                                if self.isSitesSet == True:
                                    self.model.S[:, age_solve, temp_solve, :, time_solve].unfix()
                                    self.model.site_cons[:, age_solve, temp_solve, :, time_solve].activate()

                            # Make sure the vars that should be fixed, are fixed
                            #   Fix ICs, BCs, and dCb_dt @ z=0, t=0
                            self.model.dCb_dt[:,age_solve, temp_solve,self.model.z.first(),self.model.t.first()].fix()
                            self.model.Cb[:,age_solve, temp_solve, :, self.model.t.first()].fix()
                            self.model.C[:,age_solve, temp_solve, :, self.model.t.first()].fix()
                            if self.isSurfSpecSet == True:
                                self.model.q[:,age_solve, temp_solve, :, self.model.t.first()].fix()
                            self.model.Cb[:,age_solve, temp_solve,self.model.z.first(), :].fix()

                            self.model.dT_dt[age_solve, temp_solve,self.model.z.first(),self.model.t.first()].fix()
                            self.model.T[age_solve, temp_solve, :, self.model.t.first()].fix()
                            self.model.Tc[age_solve, temp_solve, :, self.model.t.first()].fix()
                            self.model.T[age_solve, temp_solve,self.model.z.first(), :].fix()

                            #Inside age_solve, temp_solve, and time_solve
                            solver = SolverFactory('ipopt')

                            # Check user options
                            if 'print_user_options' in options:
                                if options['print_user_options'] == "yes":
                                    solver.options['print_user_options'] = options['print_user_options']
                            #   linear_solver -> valid options:
                            #   -------------------------------
                            #       Depends on installed libraries
                            #           'mumps'  --> available on Windows AND 'idaes'
                            #                       (Only option if NOT using 'idaes')
                            #           'ma27' --> NOT available on Windows
                            #                       BUT is available with 'idaes'
                            #                       (Best for Small problems, Not parallel)
                            #           'ma57' --> NOT available on Windows
                            #                       BUT is available with 'idaes'
                            #                       (Best for Medium problems, threaded blas)
                            #           'ma77' --> NOT functional with Windows OR 'idaes'
                            #           'ma86' --> NOT functional with Windows OR 'idaes'
                            #           'ma97' --> NOT available on Windows
                            #                       BUT is available with 'idaes'
                            #                       (Best for Large problems, parallel)
                            #           'pardiso' --> NOT functional with Windows OR 'idaes'
                            #           'wsmp' --> NOT functional with Windows OR 'idaes'
                            #
                            #   NOTE: The solver libraries bundled with 'idaes' are MUCH more
                            #           computationally efficient than the standard Windows
                            #           solver libraries
                            if 'linear_solver' in options:
                                # Force the use of MUMPS if conda environment is not setup for 'idaes'
                                if "idaes" not in os.environ['CONDA_DEFAULT_ENV']:
                                    options['linear_solver'] = LinearSolverMethod.MUMPS
                                if options['linear_solver'] == LinearSolverMethod.MUMPS:
                                    # Only available option without 'idaes' enviroment or
                                    #   another precompiled HSL library: https://www.hsl.rl.ac.uk/ipopt/
                                    solver.options['linear_solver'] = 'mumps'
                                elif options['linear_solver'] == LinearSolverMethod.MA27:
                                    # Best for small problems (no parallelization)
                                    solver.options['linear_solver'] = 'ma27'
                                elif options['linear_solver'] == LinearSolverMethod.MA57:
                                    # Best for medium problems (threaded BLAS)
                                    solver.options['linear_solver'] = 'ma57'
                                elif options['linear_solver'] == LinearSolverMethod.MA97:
                                    # Best for large problems (maximizes parallelization)
                                    solver.options['linear_solver'] = 'ma97'
                                else:
                                    print("Error! Invalid solver option")
                                    print("\tValid Options: 'LinearSolverMethod.MUMPS'")
                                    print("\t               'LinearSolverMethod.MA27'")
                                    print("\t               'LinearSolverMethod.MA57'")
                                    print("\t               'LinearSolverMethod.MA97'")
                                    print("\nNOTE: 'MA' solvers only available if 'idaes' environment is used...")
                                    exit()
                            if 'tol' in options:
                                solver.options['tol'] = options['tol']
                            if 'acceptable_tol' in options:
                                solver.options['acceptable_tol'] = options['acceptable_tol']
                            if 'compl_inf_tol' in options:
                                solver.options['compl_inf_tol'] = options['compl_inf_tol']
                            if 'constr_viol_tol' in options:
                                solver.options['constr_viol_tol'] = options['constr_viol_tol']
                            if 'max_iter' in options:
                                solver.options['max_iter'] = options['max_iter']
                            if 'obj_scaling_factor' in options:
                                solver.options['obj_scaling_factor'] = options['obj_scaling_factor']
                            if 'diverging_iterates_tol' in options:
                                solver.options['diverging_iterates_tol'] = options['diverging_iterates_tol']
                            if 'warm_start_init_point' in options:
                                solver.options['warm_start_init_point'] = options['warm_start_init_point']

                            # Run solver (tighten the bounds to force good solutions)
                            solver.options['bound_push'] = 1e-2
                            solver.options['bound_frac'] = 1e-2
                            solver.options['slack_bound_push'] = 1e-2
                            solver.options['slack_bound_frac'] = 1e-2
                            solver.options['warm_start_init_point'] = 'yes'

                            if self.model.find_component('scaling_factor'):
                                solver.options['nlp_scaling_method'] = 'user-scaling'
                            else:
                                solver.options['nlp_scaling_method'] = 'gradient-based'

                            results = solver.solve(self.model, tee=console_out, load_solutions=False)
                            if results.solver.status == SolverStatus.ok:
                                self.model.solutions.load_from(results)
                            elif results.solver.status == SolverStatus.warning:
                                print("WARNING: Solver did not exit normally at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                print("\tResults are loaded, but need to be checked")
                                self.model.solutions.load_from(results)
                            else:
                                self.model.solutions.load_from(results)
                                print("An Error has occurred at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                print("\tStatus: " + str(results.solver.status))
                                print("\tTermination Condition: " + str(results.solver.termination_condition))

                            # Fix the steps that were just solved
                            self.model.Cb[:, age_solve, temp_solve, :, time_solve].fix()
                            self.model.C[:, age_solve, temp_solve, :, time_solve].fix()
                            self.model.dCb_dt[:, age_solve, temp_solve, :, time_solve].fix()
                            self.model.dC_dt[:, age_solve, temp_solve, :, time_solve].fix()
                            self.model.dCb_dz[:, age_solve, temp_solve, :, time_solve].fix()
                            self.model.bulk_cons[:, age_solve, temp_solve, :, time_solve].deactivate()
                            self.model.pore_cons[:, age_solve, temp_solve, :, time_solve].deactivate()
                            self.model.dCb_dz_disc_eq[:, age_solve, temp_solve, :, time_solve].deactivate()
                            self.model.dCb_dt_disc_eq[:, age_solve, temp_solve, :, time_solve].deactivate()
                            self.model.dC_dt_disc_eq[:, age_solve, temp_solve, :, time_solve].deactivate()
                            if self.DiscType == "DiscretizationMethod.FiniteDifference":
                                self.model.dCbdz_edge[:, age_solve, temp_solve, time_solve].deactivate()
                                self.model.dTdz_edge[age_solve, temp_solve, time_solve].deactivate()

                            if self.isIsothermal[age_solve][temp_solve] == False:
                                self.model.T[age_solve, temp_solve, :, time_solve].fix()
                                self.model.Tc[age_solve, temp_solve, :, time_solve].fix()
                                self.model.dT_dt[age_solve, temp_solve, :, time_solve].fix()
                                self.model.dTc_dt[age_solve, temp_solve, :, time_solve].fix()
                                self.model.dT_dz[age_solve, temp_solve, :, time_solve].fix()
                                self.model.gas_energy[age_solve, temp_solve, :, time_solve].deactivate()
                                self.model.solid_energy[age_solve, temp_solve, :, time_solve].deactivate()
                                self.model.dT_dz_disc_eq[age_solve, temp_solve, :, time_solve].deactivate()
                                self.model.dT_dt_disc_eq[age_solve, temp_solve, :, time_solve].deactivate()
                                self.model.dTc_dt_disc_eq[age_solve, temp_solve, :, time_solve].deactivate()

                            if self.isSurfSpecSet == True:
                                self.model.q[:, age_solve, temp_solve, :, time_solve].fix()
                                self.model.dq_dt[:, age_solve, temp_solve, :, time_solve].fix()
                                self.model.surf_cons[:, age_solve, temp_solve, :, time_solve].deactivate()
                                self.model.dq_dt_disc_eq[:, age_solve, temp_solve, :, time_solve].deactivate()

                                if self.isSitesSet == True:
                                    self.model.S[:, age_solve, temp_solve, :, time_solve].fix()
                                    self.model.site_cons[:, age_solve, temp_solve, :, time_solve].deactivate()

                        else:
                            # i = 0, don't do anything
                            pass
                        i+=1
                    # End time_solve loop
                # End temp_solve loop
            # End age_solve loop

            # Unfix all variables
            self.model.Cb[:, :, :, :, :].unfix()
            self.model.C[:, :, :, :, :].unfix()
            self.model.dCb_dt[:, :, :, :, :].unfix()
            self.model.dC_dt[:, :, :, :, :].unfix()
            self.model.dCb_dz[:, :, :, :, :].unfix()
            self.model.bulk_cons[:, :, :, :, :].activate()
            self.model.pore_cons[:, :, :, :, :].activate()
            self.model.dCb_dz_disc_eq[:, :, :, :, :].activate()
            self.model.dCb_dt_disc_eq[:, :, :, :, :].activate()
            self.model.dC_dt_disc_eq[:, :, :, :, :].activate()
            if self.DiscType == "DiscretizationMethod.FiniteDifference":
                self.model.dCbdz_edge[:, :, :, :].activate()
                self.model.dTdz_edge[:, :, :].activate()

            for age in self.model.age_set:
                for temp in self.model.T_set:
                    if self.isIsothermal[age][temp] == False:
                        self.model.T[age, temp, :, :].unfix()
                        self.model.Tc[age, temp, :, :].unfix()
                        self.model.dT_dt[age, temp, :, :].unfix()
                        self.model.dTc_dt[age, temp, :, :].unfix()
                        self.model.dT_dz[age, temp, :, :].unfix()
                        self.model.gas_energy[age, temp, :, :].activate()
                        self.model.solid_energy[age, temp, :, :].activate()
                        self.model.dT_dz_disc_eq[age, temp, :, :].activate()
                        self.model.dT_dt_disc_eq[age, temp, :, :].activate()
                        self.model.dTc_dt_disc_eq[age, temp, :, :].activate()

            if self.isSurfSpecSet == True:
                self.model.q[:, :, :, :, :].unfix()
                self.model.dq_dt[:, :, :, :, :].unfix()
                self.model.surf_cons[:, :, :, :, :].activate()
                self.model.dq_dt_disc_eq[:, :, :, :, :].activate()

                if self.isSitesSet == True:
                    self.model.S[:, :, :, :, :].unfix()
                    self.model.site_cons[:, :, :, :, :].activate()

            # Make sure boundaries and ICs are re-fixed
            self.model.dCb_dt[:,:,:,self.model.z.first(),self.model.t.first()].fix()
            self.model.Cb[:,:,:, :, self.model.t.first()].fix()
            self.model.C[:,:,:, :, self.model.t.first()].fix()
            if self.isSurfSpecSet == True:
                self.model.q[:,:,:, :, self.model.t.first()].fix()
            self.model.Cb[:,:,:,self.model.z.first(), :].fix()

            self.model.dT_dt[:,:,self.model.z.first(),self.model.t.first()].fix()
            self.model.T[:,:, :, self.model.t.first()].fix()
            self.model.Tc[:,:, :, self.model.t.first()].fix()
            self.model.T[:,:,self.model.z.first(), :].fix()

            # Add objective function back
            if self.isObjectiveSet == True:
                self.model.obj.activate()

            # After solve, unfix specified reactions
            for rxn in fixed_dict:
                if fixed_dict[rxn] == False:
                    self.unfix_reaction(rxn)
            for item in fixed_heat_dict:
                if item == "hc":
                    if fixed_heat_dict[item] == False:
                        self.unfix_heat(item)
                elif item == "hwc":
                    if fixed_heat_dict[item] == False:
                        self.unfix_heat(item)
                elif item == "hwg":
                    if fixed_heat_dict[item] == False:
                        self.unfix_heat(item)
                else:
                    for rxn in fixed_heat_dict[item]:
                        if fixed_heat_dict[item][rxn] == False:
                            self.unfix_heat(rxn)

            self.isInitialized = True
            self.initialize_time = (TIME.time() - self.initialize_time)
            return (results.solver.status, results.solver.termination_condition)
            # End Initializer


    # # TODO: Override 'run_solver' (?)

    # # TODO: Override saving and loading of models
