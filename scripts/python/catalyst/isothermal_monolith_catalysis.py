'''
    This file creates an object to simulate isothermal monolith catalysis
    systems in pyomo. The primary objective of this simulator is to be
    used in conjunction with dynamic/kinetic monolith data and simulate
    that system while optimizing for the reactions in the system. User must
    provide some reasonable initial guesses to the kinetic parameters for
    the model to work effectively.

    Author:     Austin Ladshaw
    Date:       03/02/2021
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

# Define an Enum class for reaction types
class ReactionType(Enum):
    Arrhenius = 1
    EquilibriumArrhenius = 2

# Define an Enum class for discretizer types
class DiscretizationMethod(Enum):
    OrthogonalCollocation = 1
    FiniteDifference = 2

# Define an Enum class for linear solver types
class LinearSolverMethod(Enum):
    MUMPS = 1
    MA27 = 2
    MA57 = 3
    MA97 = 4

# Helper function to grab reference state diffusivities in cm**2/s
def default_ref_diffusivity(spec):
    if "nh3" in spec.lower():
        return 0.826
    elif "ar" in spec.lower():
        return 0.437
    elif "ch4" in spec.lower():
        return 0.485
    elif "co2" in spec.lower():
        return 0.390
    elif "co" in spec.lower():
        return 0.475
    elif "h2o" in spec.lower():
        return 0.638
    elif "h2" in spec.lower():
        return 1.747
    elif "he" in spec.lower():
        return 0.437
    elif "so2" in spec.lower():
        return 0.384
    elif "no2" in spec.lower():
        return 0.485
    elif "no" in spec.lower():
        return 0.485
    elif "n2o" in spec.lower():
        return 0.485
    elif "o2" in spec.lower():
        return 0.561
    else:
        return 0.638

# Helper function to calculate Ergun Pressure Drop contribution
#   mu = gas viscosity in kg/m/s
#   rho = gas density in kg/m**3
#   v = average linear velocity in m/s
#   dh = hydraulic diameter in m
#   eps = bulk porosity (unitless)
#
#       Returns Pressure change in kPa / cm
def ergun_pressure_drop(mu, rho, v, dh, eps):
    dP_m = 150.0*mu*(1-eps)**2/(eps**3*dh**2)*eps*v
    dP_m += 1.75*(1-eps)/(eps**3*dh)*rho*eps**2*v**2
    return dP_m/1000.0/100.0

# Helper function for Arrhenius reaction rates
#   E = activation energy in J/mol
#   A = pre-exponential factor (units depend on reaction)
#   B = power of temperature (usually = 0)
#   T = temperature of system in K
#
#   Function returns the k value of the Arrhenius Expression
def arrhenius_rate_const(A, B, E, T):
    return A*T**B*exp(-E/8.3145/T)

# Helper function for Equilibrium Arrhenius reaction rates
#   Af = forward rate pre-exponential term (units depend on reaction)
#   Ef = forward rate activation energy in J/mol
#   dH = equilibrium reaction enthalpy in J/mol
#   dS = equilibrium reaction entropy in J/K/mol
#
#   Function returns a tuple of reverse pre-exponential and activation energy
#           (Ar, Er)
def equilibrium_arrhenius_consts(Af, Ef, dH, dS):
    Ar = Af*exp(-dS/8.3145)
    Er = Ef - dH
    return (Ar, Er)

# Class object to hold the simulator and all model components
#       This object will be how a user interfaces with the
#       pyomo simulator and dictates the form of the model
#
#       Generalized Model Form:
#       ----------------------
#
#           Mass balance in channel space (Mandatory)
#
#                   eb*dCb/dt + eb*v*dCb/dz = -(1-eb)*Ga*km*(Cb - C)
#
#           Mass balance in the washcoat (Mandatory)
#
#                   ew*(1-eb)*dC/dt = (1-eb)*Ga*km*(Cb - C) + (1-eb)*SUM(all i, u_ci * ri)
#
#           Surface species reaction terms (Optional, if surface species not needed)
#
#                   dq/dt = SUM(all i, u_qi * ri)
#
#           Specific Site Balances (Optional, but required if tracking surface species)
#
#                   Smax = S + SUM(all qi, u_si*qi) = 0
#

# # TODO: Units Handling: https://pyomo.readthedocs.io/en/stable/advanced_topics/units_container.html
class Isothermal_Monolith_Simulator(object):
    #Default constructor
    # Pass a list of species names (Specs) for the mass balances
    def __init__(self):
        # Create an empty concrete model
        self.model = ConcreteModel()

        # Add the mandatory components to the model
        self.model.eb = Param(within=NonNegativeReals, initialize=0.3309, mutable=True, units=None)
        self.model.ew = Param(within=NonNegativeReals, initialize=0.2, mutable=True, units=None)
        self.model.r = Param(within=NonNegativeReals, initialize=1, mutable=True, units=units.cm)
        self.model.Ga = Param(within=NonNegativeReals, initialize=57.57541, mutable=True, units=units.cm**-1)
        self.model.cell_density = Param(within=NonNegativeReals, initialize=62, mutable=True, units=units.cm**-2)
        self.model.dh = Param(within=NonNegativeReals, initialize=0.078, mutable=True, units=units.cm)
        self.model.diff_factor = Param(within=NonNegativeReals, initialize=1.4, mutable=True, units=None)

        # Add some tracking boolean statements
        self.isBoundsSet = False
        self.isTimesSet = False
        self.isTempSet = False
        self.isAgeSet = False
        self.age_list = {}
        self.isGasSpecSet = False
        self.gas_list = {}
        self.isSurfSpecSet = False
        self.isSitesSet = False
        self.site_list = {}
        self.isRxnSet = False
        self.isRxnBuilt = {}
        self.rxn_list = {}
        self.isConBuilt = False
        self.isDiscrete = False
        self.isInitialSet = {}
        self.isBoundarySet = {}
        self.isObjectiveSet = False
        self.isInitialized = False
        self.build_time = TIME.time()
        self.initialize_time = 0
        self.solve_time = 0
        self.isVelocityRecalculated = False
        self.load_time = 0
        self.rescaleConstraint = False

        self.isDataBoundsSet = False
        self.isDataTimesSet = False
        self.isDataAgeSet = False
        self.isDataTempSet = False
        self.isDataGasSpecSet = False
        self.isDataSurfSpecSet = False
        self.isDataValuesSet = {}
        self.isIsothermalTempSet = False
        self.isSpaceVelocityByTotalVolume = True
        self.isReactionSetByTotalVolume = True

        self.DiscType = "DiscretizationMethod.FiniteDifference"
        self.colpoints = 2
        self.isMonolith = True
        self.full_length = 1
        # # TODO: Require users to provide full catalyst length (auto calculated for now)


    # Add a continuous set for spatial dimension (current expected units = cm)
    def add_axial_dim(self, start_point=0, end_point=1, point_list=[]):
        if point_list == []:
            self.model.z = ContinuousSet(bounds=(start_point,end_point))
        else:
            self.model.z = ContinuousSet(initialize=point_list)
        self.isBoundsSet = True
        self.full_length = (self.model.z.last()-self.model.z.first())

    # Add axial points for data (if avaialbe)
    def add_axial_dataset(self, point_set):
        if type(point_set) is not list:
            self.model.z_data = Set(initialize=[point_set])
        else:
            self.model.z_data = Set(initialize=point_set)
        self.isDataBoundsSet = True


    # Add a continuous set for temporal dimension (current expected units = min)
    def add_temporal_dim(self, start_point=0, end_point=1, point_list=[]):
        if point_list == []:
            self.model.t = ContinuousSet(bounds=(start_point,end_point))
        else:
            self.model.t = ContinuousSet(initialize=point_list)
        self.isTimesSet = True

    # Add time set for data
    def add_temporal_dataset(self, point_set):
        if self.isTimesSet == False:
            raise Exception("Error! Cannot setup data times without first specifying model times")

        new_list = []
        for time in point_set:
            if time >= self.model.t.first() and time <= self.model.t.last():
                new_list.append(time)
        self.model.t_data = Set(initialize=new_list)
        self.model.t_data_full = Set(initialize=point_set)
        self.isDataTimesSet = True


    # Add a param set for aging times/conditions [Can be reals, ints, or strings]
    #
    #       Access to model.age param is as follows:
    #       ---------------------------------------
    #           model.age[age, time] =
    #                       catalyst age at simulation time
    def add_age_set(self, ages):
        if self.isTimesSet == False:
            raise Exception("Error! Time dimension must be set first!")

        if type(ages) is list:
            i=0
            for item in ages:
                key = "age_"+str(i)
                self.age_list[key] = item
                i+=1
            self.model.age_set = Set(initialize=ages)
        else:
            self.age_list["age_0"] = ages
            self.model.age_set = Set(initialize=[ages])

        self.isAgeSet = True

    # Add a data param set for aging times/conditions [Can be reals, ints, or strings]
    #
    #       Access to model.age param is as follows:
    #       ---------------------------------------
    #           model.age_data[age_data, time_data] =
    #                       catalyst age at run time
    def add_data_age_set(self, ages):
        if self.isDataTimesSet == False:
            raise Exception("Error! Time dimension must be set first!")
        if self.isAgeSet == False:
            raise Exception("Error! Must set ages for simulation first!")

        if type(ages) is list:
            i=0
            for item in ages:
                key = "age_"+str(i)
                self.age_list[key] = item
                i+=1
            self.model.data_age_set = Set(initialize=ages)
        else:
            self.age_list["age_0"] = ages
            self.model.data_age_set = Set(initialize=[ages])

        # Check to see if each age in the data set has a cooresponding simulation set
        for age in self.model.data_age_set:
            if age not in self.model.age_set:
                raise Exception("Error! Data ages must be a sub-set of simulation ages. "
                                +str(age)+ " given is not in model.age_set")
        self.isDataAgeSet = True

    # Add a variable set for isothermal temperatures [Must be reals]
    #       Currently expects temperatures in K
    #
    #       Access to model.T var is as follows:
    #       ---------------------------------------
    #           model.T[age, temperature, loc, time] =
    #                       isothermal temperature for aging condition at simulation location and time
    def add_temperature_set(self, temps):
        if self.isTimesSet == False or self.isBoundsSet == False:
            raise Exception("Error! Time and space dimensions must be set first!")

        if self.isAgeSet == False:
            raise Exception("Error! Catalyst ages must be set first!")

        if type(temps) is list:
            self.model.T_set = Set(initialize=temps)
            self.model.T = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                domain=NonNegativeReals, initialize=298, units=units.K)
        else:
            self.model.T_set = Set(initialize=[temps])
            self.model.T = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                domain=NonNegativeReals, initialize=298, units=units.K)
        # Create time dependent parameter for space velocity
        #       NOTE: Space velocity is volumetric flow rate of gas at STP per catalyst volume
        #               Different experimental runs may have different space velocities
        self.model.space_velocity = Var(self.model.age_set, self.model.T_set, self.model.t,
                                    domain=NonNegativeReals, initialize=1000, units=units.min**-1)
        self.model.v = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                    domain=NonNegativeReals, initialize=15110, units=units.cm/units.min)
        # Adding pressure variable (to track pressure drop) and reference temperature and pressure
        #       params to modify the flow rate / velocity as temperature and pressure change
        #       The reference temperature and pressure should be associated with a cooresponding
        #       space velocity. Default values: 150 C and 1 atm (choosen due to the nature of
        #       typical exhaust gas experiments, not at STP)
        self.model.P = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                    domain=NonNegativeReals, initialize=101.35, units=units.kPa)
        self.model.Tref = Param(self.model.age_set, self.model.T_set, within=NonNegativeReals,
                                initialize=273.15, mutable=True, units=units.K)
        self.model.Pref = Param(self.model.age_set, self.model.T_set, within=NonNegativeReals,
                                initialize=101.35, mutable=True, units=units.kPa)
        self.model.rho = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                    domain=NonNegativeReals, initialize=0.0012, units=units.g/units.cm**3)
        self.model.mu = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                    domain=NonNegativeReals, initialize=0.000185, units=units.g/units.cm/units.s)
        self.model.Re = Var(self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                    domain=NonNegativeReals, initialize=7500, units=None)
        self.isTempSet = True

    # Add a data set for temperatures [Must be reals]
    def add_data_temperature_set(self, temps):
        if self.isDataTimesSet == False or self.isDataBoundsSet == False:
            raise Exception("Error! Time and space dimensions for data must be set first!")

        if self.isDataAgeSet == False:
            raise Exception("Error! Catalyst ages for data sets must be set first!")

        if self.isTempSet == False:
            raise Exception("Error! Model must have temperature information set first!")

        if type(temps) is list:
            self.model.data_T_set = Set(initialize=temps)
        else:
            self.model.data_T_set = Set(initialize=[temps])
        # Check to see if each temp in the data set has a cooresponding simulation set
        for temp in self.model.data_T_set:
            if temp not in self.model.T_set:
                raise Exception("Error! Data temps must be a sub-set of simulation temps. "
                                +str(temp)+ " given is not in model.T_set")
        self.isDataTempSet = True

    # Add gas species (both bulk and washcoat) [Must be strings]
    #       Currently expects species concentrations in mol/L
    #
    #       Access to model.Cb and model.C Vars is as follows:
    #       ---------------------------------------
    #           model.Cb( or model.C )[species, age, temperature, location, time] =
    #                       bulk/pore concentration of given species, at given
    #                       aging condition, at given temperature, at given
    #                       axial location, at given simulation time
    def add_gas_species(self, gas_species):
        if self.isTimesSet == False or self.isBoundsSet == False:
            raise Exception("Error! Cannot specify gas species until the time and bounds are set")
        if self.isTempSet == False or self.isAgeSet == False:
            raise Exception("Error! Cannot specify gas species until the temperatures and ages are set")

        if type(gas_species) is list:
            for item in gas_species:
                if isinstance(item, str):
                    self.gas_list[item] = {"bulk": item+"_b",
                                            "washcoat": item+"_w",
                                            "inlet": item+"_in"}
                else:
                    raise Exception("Error! Gas species must be a string. "
                                    +str(item)+ " given is not a string object")
            self.model.gas_set = Set(initialize=gas_species)
            self.model.Cb = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                            self.model.z, self.model.t,
                            domain=NonNegativeReals, bounds=(1e-20,1),
                            initialize=1e-20, units=units.mol/units.L)
            self.model.C = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                            self.model.z, self.model.t,
                            domain=NonNegativeReals, bounds=(1e-20,1),
                            initialize=1e-20, units=units.mol/units.L)
        else:
            if isinstance(gas_species, str):
                self.gas_list[gas_species] = {"bulk": gas_species+"_b",
                                            "washcoat": gas_species+"_w",
                                            "inlet": gas_species+"_in"}
                self.model.gas_set = Set(initialize=[gas_species])
                self.model.Cb = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                                self.model.z, self.model.t,
                                domain=NonNegativeReals, bounds=(1e-20,1),
                                initialize=1e-20, units=units.mol/units.L)
                self.model.C = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                                self.model.z, self.model.t,
                                domain=NonNegativeReals, bounds=(1e-20,1),
                                initialize=1e-20, units=units.mol/units.L)
            else:
                raise Exception("Error! Gas species must be a string. "
                                +str(gas_species)+ " given is not a string object")
        self.isGasSpecSet = True
        for spec in self.model.gas_set:
            self.isBoundarySet[spec] = {}
            for age in self.model.age_set:
                self.isBoundarySet[spec][age] = {}
                for temp in self.model.T_set:
                    self.isBoundarySet[spec][age][temp] = False
        self.model.dCb_dz = DerivativeVar(self.model.Cb, wrt=self.model.z, initialize=0, units=units.mol/units.L/units.cm)
        self.model.dCb_dt = DerivativeVar(self.model.Cb, wrt=self.model.t, initialize=0, units=units.mol/units.L/units.min)
        self.model.dC_dt = DerivativeVar(self.model.C, wrt=self.model.t, initialize=0, units=units.mol/units.L/units.min)
        self.model.km = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                        self.model.z, self.model.t,
                        domain=NonNegativeReals, initialize=112, units=units.cm/units.min)
        self.model.Dm = Param(self.model.gas_set, within=NonNegativeReals, initialize=0.4, mutable=True, units=units.cm**2/units.s)
        self.model.Sc = Var(self.model.gas_set, self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                    domain=NonNegativeReals, initialize=0.0065, units=None)
        self.model.Sh = Var(self.model.gas_set, self.model.age_set, self.model.T_set, self.model.z, self.model.t,
                                    domain=NonNegativeReals, initialize=5.75, units=None)

        for spec in self.model.gas_set:
            self.model.Dm[spec].set_value( default_ref_diffusivity(spec) )

    # Add gas species for data observations and a weight factor 'w' to be used for
    #   changing the behavior of the objective function
    def add_data_gas_species(self, gas_species):
        if self.isDataTimesSet == False or self.isDataBoundsSet == False:
            raise Exception("Error! Cannot specify gas species until the data time and spatial observations are set")
        if self.isDataTempSet == False or self.isDataAgeSet == False:
            raise Exception("Error! Cannot specify gas species until the data temperatures and ages are set")

        if type(gas_species) is list:
            self.model.data_gas_set = Set(initialize=gas_species)
            self.model.Cb_data = Param(self.model.data_gas_set, self.model.data_age_set,
                            self.model.data_T_set, self.model.z_data, self.model.t_data,
                            within=Reals, mutable=True,
                            initialize=1e-20, units=units.mol/units.L)
            self.model.Cb_data_full = Param(self.model.data_gas_set, self.model.data_age_set,
                            self.model.data_T_set, self.model.z_data, self.model.t_data_full,
                            within=Reals, mutable=True,
                            initialize=1e-20, units=units.mol/units.L)
            self.model.w = Param(self.model.data_gas_set, self.model.data_age_set,
                            self.model.data_T_set, self.model.t_data_full,
                            within=NonNegativeReals, mutable=True,
                            initialize=1, units=None)
        else:
            if isinstance(gas_species, str):
                self.model.data_gas_set = Set(initialize=[gas_species])
                self.model.Cb_data = Param(self.model.data_gas_set, self.model.data_age_set,
                                self.model.data_T_set, self.model.z_data, self.model.t_data,
                                within=Reals, mutable=True,
                                initialize=1e-20, units=units.mol/units.L)
                self.model.Cb_data_full = Param(self.model.data_gas_set, self.model.data_age_set,
                                self.model.data_T_set, self.model.z_data, self.model.t_data_full,
                                within=Reals, mutable=True,
                                initialize=1e-20, units=units.mol/units.L)
                self.model.w = Param(self.model.data_gas_set, self.model.data_age_set,
                                self.model.data_T_set, self.model.t_data_full,
                                within=NonNegativeReals, mutable=True,
                                initialize=1, units=None)
            else:
                raise Exception("Error! Gas species must be a string. "
                                +str(gas_species)+" given is not a string object")
        # Check to see if each temp in the data set has a cooresponding simulation set
        for spec in self.model.data_gas_set:
            self.isDataValuesSet[spec] = {}
            if spec not in self.model.gas_set:
                raise Exception("Error! Data gas species must be a sub-set of simulation species. "
                                +str(spec)+ " given is not in model.gas_set")
            for loc in self.model.z_data:
                self.isDataValuesSet[spec][loc] = False

        self.isDataGasSpecSet = True

    # Add surface species (optional) [Must be strings]
    #       Currently expects surface concentrations in mol/L
    #
    #       Access to model.q Vars is as follows:
    #       ---------------------------------------
    #           model.q[species, age, temperature, location, time] =
    #                       surface concentration of given species, at given
    #                       aging condition, at given temperature, at given
    #                       axial location, at given simulation time
    def add_surface_species(self, surf_species):
        if self.isGasSpecSet == False:
            raise Exception("Error! Cannot specify surface species without having gas species")
        if type(surf_species) is list:
            self.model.surf_set = Set(initialize=surf_species)
            self.model.q = Var(self.model.surf_set, self.model.age_set, self.model.T_set,
                            self.model.z, self.model.t,
                            domain=NonNegativeReals, bounds=(1e-20,10),
                            initialize=1e-20, units=units.mol/units.L)
        else:
            if isinstance(surf_species, str):
                self.model.surf_set = Set(initialize=[surf_species])
                self.model.q = Var(self.model.surf_set, self.model.age_set, self.model.T_set,
                                self.model.z, self.model.t,
                                domain=NonNegativeReals, bounds=(1e-20,10),
                                initialize=1e-20, units=units.mol/units.L)
            else:
                raise Exception("Error! Surface species must be a string. "
                                +str(surf_species)+" given is not a string object")
        self.isSurfSpecSet = True
        self.model.dq_dt = DerivativeVar(self.model.q, wrt=self.model.t, initialize=0, units=units.mol/units.L/units.min)

    # Add surface species for data observations and a weight factor 'wq' to be used for
    #   changing the behavior of the objective function
    def add_data_surface_species(self, surface_species):
        if self.isDataTimesSet == False or self.isDataBoundsSet == False:
            raise Exception("Error! Cannot specify surface species until the data time and spatial observations are set")
        if self.isDataTempSet == False or self.isDataAgeSet == False:
            raise Exception("Error! Cannot specify surface species until the data temperatures and ages are set")
        if self.isSurfSpecSet == False:
            raise Exception("Error! Cannot specify data surface species until the simulation surface species are set")

        if type(surface_species) is list:
            self.model.data_surface_set = Set(initialize=surface_species)
            self.model.q_data = Param(self.model.data_surface_set, self.model.data_age_set,
                            self.model.data_T_set, self.model.z_data, self.model.t_data,
                            within=Reals, mutable=True,
                            initialize=1e-20, units=units.mol/units.L)
            self.model.q_data_full = Param(self.model.data_surface_set, self.model.data_age_set,
                            self.model.data_T_set, self.model.z_data, self.model.t_data_full,
                            within=Reals, mutable=True,
                            initialize=1e-20, units=units.mol/units.L)
            self.model.wq = Param(self.model.data_surface_set, self.model.data_age_set,
                            self.model.data_T_set, self.model.t_data_full,
                            within=NonNegativeReals, mutable=True,
                            initialize=1, units=None)
        else:
            if isinstance(surface_species, str):
                self.model.data_surface_set = Set(initialize=[surface_species])
                self.model.q_data = Param(self.model.data_surface_set, self.model.data_age_set,
                                self.model.data_T_set, self.model.z_data, self.model.t_data,
                                within=Reals, mutable=True,
                                initialize=1e-20, units=units.mol/units.L)
                self.model.q_data_full = Param(self.model.data_surface_set, self.model.data_age_set,
                                self.model.data_T_set, self.model.z_data, self.model.t_data_full,
                                within=Reals, mutable=True,
                                initialize=1e-20, units=units.mol/units.L)
                self.model.wq = Param(self.model.data_surface_set, self.model.data_age_set,
                                self.model.data_T_set, self.model.t_data_full,
                                within=NonNegativeReals, mutable=True,
                                initialize=1, units=None)
            else:
                raise Exception("Error! Surface species must be a string. "
                                +str(gas_species)+" given is not a string object")
        # Check to see if each temp in the data set has a cooresponding simulation set
        for spec in self.model.data_surface_set:
            self.isDataValuesSet[spec] = {}
            if spec not in self.model.surf_set:
                raise Exception("Error! Data surface species must be a sub-set of simulation species. "
                                +str(spec)+ " given is not in model.surface_set")
            for loc in self.model.z_data:
                self.isDataValuesSet[spec][loc] = False

        self.isDataSurfSpecSet = True

    # Add surface sites (optional, but necessary when using surface species) [Must be strings]
    #       Currently expects surface concentrations in mol/L
    #
    #       Access to model.S Vars is as follows:
    #       ---------------------------------------
    #           model.S[site, age, temperature, location, time] =
    #                       surface concentration of given site, at given
    #                       aging condition, at given temperature, at given
    #                       axial location, at given simulation time
    #
    #       Access to model.Smax Param is as follows:
    #       ---------------------------------------
    #           model.Smax[site, age, location, time] =
    #                       maximum concentration of given site, at given
    #                       aging condition, at given temperature, at given
    #                       axial location, at given simulation time
    def add_surface_sites(self, sites):
        if self.isSurfSpecSet == False:
            raise Exception("Error! Cannot specify surface sites without having surface species")
        if type(sites) is list:
            for item in sites:
                if isinstance(item, str):
                    self.site_list[item] = item
                else:
                    raise Exception("Error! Surface site must be a string. "
                                    +str(item)+" given is not a string object")
            self.model.site_set = Set(initialize=sites)
            self.model.S = Var(self.model.site_set, self.model.age_set, self.model.T_set,
                            self.model.z, self.model.t,
                            domain=NonNegativeReals, bounds=(1e-20,10),
                            initialize=1e-20, units=units.mol/units.L)
            self.model.Smax = Param(self.model.site_set, self.model.age_set,
                            self.model.z, self.model.t,
                            within=NonNegativeReals, initialize=1e-20,
                            mutable=True, units=units.mol/units.L)
        else:
            if isinstance(sites, str):
                self.site_list[sites] = sites
                self.model.site_set = Set(initialize=[sites])
                self.model.S = Var(self.model.site_set, self.model.age_set, self.model.T_set,
                                self.model.z, self.model.t,
                                domain=NonNegativeReals, bounds=(1e-20,10),
                                initialize=1e-20, units=units.mol/units.L)
                self.model.Smax = Param(self.model.site_set, self.model.age_set,
                                self.model.z, self.model.t,
                                within=NonNegativeReals, initialize=1e-20,
                                mutable=True, units=units.mol/units.L)
            else:
                raise Exception("Error! Surface sites must be a string. "
                                +str(sites)+" given is not a string object")

        self.model.u_S = Param(self.model.site_set, self.model.surf_set, domain=Reals,
                                        initialize=0, mutable=True)
        self.isSitesSet = True

    # Add reactions to the model (does not include molar contributions to mass balances yet)
    #       Currently expects Arrhenius rate terms as the following...
    #           A = pre-exponential term (units depend on reaction type)
    #           E = activation energy in J/mol
    #           B = temperature power (no units, optional)
    #           dH = reaction enthalpy (J/mol) - for equilibrium
    #           dS = reaction entropy (J/K/mol) - for equilibrium
    #
    #   NOTE: The 'rxns' argument must be a dictionary whose keys are the labels or names
    #           of the reactions to consider and that maps to a type of reaction we
    #           want to create for that label
    def add_reactions(self, rxns):
        if self.isGasSpecSet == False:
            raise Exception("Error! Cannot specify reactions before defining species")

        if type(rxns) is not dict:
            raise Exception("Error! Must specify reactions using a formatted dictionary. "
                            +str(rxns)+" given in not a dict object")

        # Iterate through the reaction list
        arr_rxn_list = []
        arr_equ_rxn_list = []
        full_rxn_list = []
        for r in rxns:
            full_rxn_list.append(r)
            self.isRxnBuilt[r] = False
            # Determine what to do with different reaction types
            if rxns[r] == ReactionType.Arrhenius:
                arr_rxn_list.append(r)
            elif rxns[r] == ReactionType.EquilibriumArrhenius:
                arr_equ_rxn_list.append(r)
            else:
                raise Exception("Error! Unsupported 'ReactionType' object. "
                                +str(rxns[r])+" given is not recognized")

        # Setup model with all reactions (store sets for each type)
        self.model.all_rxns = Set(initialize=full_rxn_list)
        self.model.arrhenius_rxns = Set(initialize=arr_rxn_list)
        self.model.equ_arrhenius_rxns = Set(initialize=arr_equ_rxn_list)

        # All reactions (regardless of type) have some impact on mass balances
        #           Access is [species, rxn, loc]
        #
        #       NOTE: u_C and u_q were made positional so that reactions could be
        #           turned off or on based on location in the domain. This can be
        #           utilized to simulate the effect of catalyst 'zoning'
        self.model.u_C = Param(self.model.gas_set, self.model.all_rxns, self.model.z, domain=Reals,
                                initialize=0, mutable=True)
        if self.isSurfSpecSet == True:
            self.model.u_q = Param(self.model.surf_set, self.model.all_rxns, self.model.z, domain=Reals,
                                    initialize=0, mutable=True)

        # # TODO: Specify units for these variables
        # Variables for the Arrhenius type
        self.model.A = Var(self.model.arrhenius_rxns, domain=NonNegativeReals, initialize=0)
        self.model.B = Var(self.model.arrhenius_rxns, domain=Reals, initialize=0)
        self.model.E = Var(self.model.arrhenius_rxns, domain=Reals, initialize=0)

        # Variables for the Equilibrium Arrhenius type
        self.model.Af = Var(self.model.equ_arrhenius_rxns, domain=NonNegativeReals, initialize=0)
        self.model.Ef = Var(self.model.equ_arrhenius_rxns, domain=Reals, initialize=0)
        self.model.dH = Var(self.model.equ_arrhenius_rxns, domain=Reals, initialize=0)
        self.model.dS = Var(self.model.equ_arrhenius_rxns, domain=Reals, initialize=0)

        full_species_list = []
        for gas in self.model.gas_set:
            full_species_list.append(gas)
        if self.isSurfSpecSet == True:
            for surf in self.model.surf_set:
                full_species_list.append(surf)
            if self.isSitesSet == True:
                for site in self.model.site_set:
                    full_species_list.append(site)

        self.model.all_species_set = Set(initialize=full_species_list)
        for spec in self.model.all_species_set:
            self.isInitialSet[spec] = {}
            for age in self.model.age_set:
                self.isInitialSet[spec][age] = {}
                for temp in self.model.T_set:
                    self.isInitialSet[spec][age][temp] = False
        #       Access is [rxn, species]
        self.model.rxn_orders = Param(self.model.all_rxns, self.model.all_species_set,
                                    domain=Reals, initialize=0, mutable=True)
        self.isRxnSet = True
        for rxn in rxns:
            self.rxn_list[rxn] = {}
            self.rxn_list[rxn]["type"]=rxns[rxn]
            self.rxn_list[rxn]["fixed"]=False


    #========= Setup functions for parameters ===============
    def set_bulk_porosity(self, eb):
        if eb > 1 or eb < 0:
            raise Exception("Error! Porosity must be a value between 0 and 1")
        self.model.eb.set_value(eb)
        self.svf = eb
        self.calculate_form_factors(self.isMonolith, self.model.dh.value)

    def set_washcoat_porosity(self, ew):
        if ew > 1 or ew < 0:
            raise Exception("Error! Porosity must be a value between 0 and 1")
        self.model.ew.set_value(ew)

    def set_reactor_radius(self,rad):
        self.model.r.set_value(rad)

    def set_effective_diffusivity_factor(self,f):
        if f < 1.0:
            f = 1.0
        if f > 2.0:
            f = 2.0
        self.model.diff_factor.set_value(f)

    def set_reactor_length(self,len):
        if len <= 0:
            raise Exception("Error! Length must be a non-negative and non-zero value")
        self.full_length = len

    def set_mass_transfer_coef(self, km):
        self.model.km[:,:,:,:,:].set_value(km)

    def set_surface_to_volume_ratio(self, Ga):
        self.model.Ga.set_value(Ga)

    # NOTE: Be default, the reactor is assumed a Monolith
    #       Changing to 'packed bed' will update how mass transfer
    #       coefficients are calculated.
    def set_reactor_to_packed_bed(self):
        self.isMonolith = False
        self.calculate_form_factors(self.isMonolith, self.model.dh.value)

    # NOTE: If using 'packed bed', then user MUST supply particle diameter as dh
    def set_packed_bed_particle_diameter(self, dia):
        self.model.dh.set_value(dia)
        self.set_reactor_to_packed_bed()

    def set_reactor_to_monolith(self):
        self.isMonolith = True
        self.calculate_form_factors(self.isMonolith, self.model.dh.value)

    # Site density is a function of aging, thus you provide the
    #       name of the site you want to set and the age that the
    #       given value would correspond to
    def set_site_density(self, site, age, value):
        if self.isSitesSet == False:
            raise Exception("Error! Did not specify the existance of surface sites")
        if value < 0:
            raise Exception("Error! Cannot have a negative concentration of sites")
        if value < 1e-20:
            value = 1e-20
        self.model.Smax[site, age, :, :].set_value(value)

    # Set the isothermal temperatures for a simulation
    #   Sets all to a constant, can be changed later
    def set_isothermal_temp(self,age,temp,value):
        self.model.T[age,temp,:,:].set_value(value)
        self.isVelocityRecalculated = False
        self.isIsothermalTempSet = True

    # Set the space velocity for a simulation to a given value
    #   Assumes same value for all times (can be reset later)
    #       User may also provide reference pressure and temperature
    #       associated with this space velocity
    def set_space_velocity(self,age,temp,value,Pref=101.15,Tref=273.15, byTotalVolume=True):
        self.model.space_velocity[age,temp,:].set_value(value)
        self.model.Pref[age,temp].set_value(Pref)
        self.model.Tref[age,temp].set_value(Tref)
        self.isSpaceVelocityByTotalVolume = byTotalVolume

    # Set a space velocity that is common to all runs
    #       User may also provide reference pressure and temperature
    #       associated with this space velocity
    def set_space_velocity_all_runs(self,value,Pref=101.15,Tref=273.15, byTotalVolume=True):
        self.model.space_velocity[:,:,:].set_value(value)
        self.model.Pref[:,:].set_value(Pref)
        self.model.Tref[:,:].set_value(Tref)
        self.isSpaceVelocityByTotalVolume = byTotalVolume

    # Set the monolith cell density
    #       User is responsible for ensuring the units work out. If
    #       user provided lengths in cm, then the cell density should
    #       be provided as (# cells per cm^2)
    def set_cell_density(self,value):
        self.model.cell_density.set_value(value)
        self.calculate_form_factors(self.isMonolith, self.model.dh.value)

    # Setup site balance information (in needed)
    #       To setup the information for a site balance, pass the name of the
    #       site (site) you want to specify, then pass a dictionary containing
    #       relevant site balance information
    def set_site_balance(self, site, info):
        if self.isSitesSet == False:
            raise Exception("Error! Cannot set site balance info before specifying that there are sites")
        if type(info) is not dict:
            raise Exception("Error! Must specify site balances using a formatted dictionary. "
                            +str(info)+ " given is not a dict object")
        if "mol_occupancy" not in info:
            raise Exception("Error! Must specify reaction 'mol_occupancy' in dictionary")
        for spec in self.model.surf_set:
            if spec in info["mol_occupancy"]:
                self.model.u_S[site, spec].set_value(info["mol_occupancy"][spec])


    # Setup reaction information
    #       To setup information for a reaction, pass the name of the
    #       reaction (rxn) you want to specify and then pass a dictionary
    #       containing relevant reaction information.
    #
    #
    def set_reaction_info(self, rxn, info):
        if self.isRxnSet == False:
            raise Exception("Error! Cannot set reaction parameters before declaring reaction types")
        if type(info) is not dict:
            raise Exception("Error! Must specify reactions using a formatted dictionary. "
                            +str(info)+ " given is not a dict object")
        if "parameters" not in info:
            raise Exception("Error! Must specify reaction 'parameters' in dictionary")
        if "mol_reactants" not in info:
            raise Exception("Error! Must specify reaction 'mol_reactants' in dictionary")
        if "mol_products" not in info:
            raise Exception("Error! Must specify reaction 'mol_products' in dictionary")
        if "rxn_orders" not in info:
            raise Exception("Error! Must specify reaction 'rxn_orders' in dictionary")
        if rxn in self.model.arrhenius_rxns:
            self.model.A[rxn].set_value(info["parameters"]["A"])
            try:
                self.model.A[rxn].setlb(info["parameters"]["A_lb"])
                self.model.A[rxn].setub(info["parameters"]["A_ub"])
            except:
                self.model.A[rxn].setlb(info["parameters"]["A"]*0.8)
                self.model.A[rxn].setub(info["parameters"]["A"]*1.2)

            self.model.E[rxn].set_value(info["parameters"]["E"])
            try:
                self.model.E[rxn].setlb(info["parameters"]["E_lb"])
                self.model.E[rxn].setub(info["parameters"]["E_ub"])
            except:
                if info["parameters"]["E"] >= 0.0:
                    self.model.E[rxn].setlb(info["parameters"]["E"]*0.8)
                    self.model.E[rxn].setub(info["parameters"]["E"]*1.2)
                else:
                    self.model.E[rxn].setlb(info["parameters"]["E"]*1.2)
                    self.model.E[rxn].setub(info["parameters"]["E"]*0.8)
            try:
                self.model.B[rxn].set_value(info["parameters"]["B"])
                try:
                    self.model.B[rxn].setlb(info["parameters"]["B_lb"])
                    self.model.B[rxn].setub(info["parameters"]["B_ub"])
                except:
                    if info["parameters"]["B"] >= 0.0:
                        self.model.B[rxn].setlb(info["parameters"]["B"]*0.8)
                        self.model.B[rxn].setub(info["parameters"]["B"]*1.2)
                    else:
                        self.model.B[rxn].setlb(info["parameters"]["B"]*1.2)
                        self.model.B[rxn].setub(info["parameters"]["B"]*0.8)
            except:
                self.model.B[rxn].set_value(0)
                self.model.B[rxn].setlb(0)
                self.model.B[rxn].setub(0)
                self.model.B[rxn].fix()
        elif rxn in self.model.equ_arrhenius_rxns:
            self.model.Af[rxn].set_value(info["parameters"]["A"])
            try:
                self.model.Af[rxn].setlb(info["parameters"]["A_lb"])
                self.model.Af[rxn].setub(info["parameters"]["A_ub"])
            except:
                self.model.Af[rxn].setlb(info["parameters"]["A"]*0.8)
                self.model.Af[rxn].setub(info["parameters"]["A"]*1.2)

            self.model.Ef[rxn].set_value(info["parameters"]["E"])
            try:
                self.model.Ef[rxn].setlb(info["parameters"]["E_lb"])
                self.model.Ef[rxn].setub(info["parameters"]["E_ub"])
            except:
                if info["parameters"]["E"] >= 0.0:
                    self.model.Ef[rxn].setlb(info["parameters"]["E"]*0.8)
                    self.model.Ef[rxn].setub(info["parameters"]["E"]*1.2)
                else:
                    self.model.Ef[rxn].setlb(info["parameters"]["E"]*1.2)
                    self.model.Ef[rxn].setub(info["parameters"]["E"]*0.8)

            self.model.dH[rxn].set_value(info["parameters"]["dH"])
            try:
                self.model.dH[rxn].setlb(info["parameters"]["dH_lb"])
                self.model.dH[rxn].setub(info["parameters"]["dH_ub"])
            except:
                if info["parameters"]["dH"] >= 0.0:
                    self.model.dH[rxn].setlb(info["parameters"]["dH"]*0.8)
                    self.model.dH[rxn].setub(info["parameters"]["dH"]*1.2)
                else:
                    self.model.dH[rxn].setlb(info["parameters"]["dH"]*1.2)
                    self.model.dH[rxn].setub(info["parameters"]["dH"]*0.8)

            self.model.dS[rxn].set_value(info["parameters"]["dS"])
            try:
                self.model.dS[rxn].setlb(info["parameters"]["dS_lb"])
                self.model.dS[rxn].setub(info["parameters"]["dS_ub"])
            except:
                if info["parameters"]["dS"] >= 0.0:
                    self.model.dS[rxn].setlb(info["parameters"]["dS"]*0.8)
                    self.model.dS[rxn].setub(info["parameters"]["dS"]*1.2)
                else:
                    self.model.dS[rxn].setlb(info["parameters"]["dS"]*1.2)
                    self.model.dS[rxn].setub(info["parameters"]["dS"]*0.8)
        else:
            raise Exception("Error! Given reaction name does not exist in model. "
                            +str(rxn)+ " given does not exist")

        #Create a model set for reactants and products
        react_list = []
        prod_list = []
        for spec in self.model.all_species_set:
            if spec in info["mol_reactants"]:
                react_list.append(spec)
            if spec in info["mol_products"]:
                prod_list.append(spec)

        # Add sets for reactants and products specific to each reaction
        self.model.add_component(rxn+"_reactants", Set(initialize=react_list))
        self.model.add_component(rxn+"_products", Set(initialize=prod_list))

        # Grab all stoichiometry information
        for spec in self.model.gas_set:
            u_C_sum = 0
            if spec in info["mol_reactants"]:
                u_C_sum -= info["mol_reactants"][spec]
            if spec in info["mol_products"]:
                u_C_sum += info["mol_products"][spec]
            self.model.u_C[spec,rxn,:].set_value(u_C_sum)

        if self.isSurfSpecSet == True:
            for spec in self.model.surf_set:
                u_q_sum = 0
                if spec in info["mol_reactants"]:
                    u_q_sum -= info["mol_reactants"][spec]
                if spec in info["mol_products"]:
                    u_q_sum += info["mol_products"][spec]
                self.model.u_q[spec,rxn,:].set_value(u_q_sum)

        # Set reaction order information
        for spec in self.model.all_species_set:
            if spec in info["rxn_orders"]:
                if spec in info["mol_reactants"] or spec in info["mol_products"]:
                    self.model.rxn_orders[rxn,spec].set_value(info["rxn_orders"][spec])

        # Check for and apply user defined overrides
        if "override_molar_contribution" in info:
            print("WARNING! Overriding the molar contributions can result in undefined model behavior.")
            for spec in info["override_molar_contribution"]:
                if spec in self.model.gas_set:
                    self.model.u_C[spec,rxn,:].set_value(info["override_molar_contribution"][spec])
                if self.isSurfSpecSet == True:
                    if spec in self.model.surf_set:
                        self.model.u_q[spec,rxn,:].set_value(info["override_molar_contribution"][spec])

        self.isRxnBuilt[rxn] = True

    # Function to manually override parameter bounds for reactions
    #   This is optional. Default values are setup in the 'set_reaction_info' function
    #       User MUST provide...
    #           rxn = name of the reaction to apply changes to
    #           param = name of param to apply changes to
    #                   ("A", "B", "E", "dH", or "dS")
    #                       if param is invalid, then nothing is done
    #
    #       THEN, User provides either...
    #           bounds = a tuple containing the lower and upper bounds (lower, upper)
    #           factor = a non-negative value used as a basis for setting bounds
    #                       (fractional percent down and up to allow adjustment)
    #
    #       If user provides nothing, then nothing happens.
    #       If user provides both args, then 'bounds' will be used only
    def set_reaction_param_bounds(self, rxn, param, bounds=None, factor=None):
        if rxn not in self.model.all_rxns:
            print("Error! Invalid reaction given. Continuing anyway.")
            return
        if self.isRxnBuilt[rxn] == False:
            print("Error! Cannot changes bounds of reaction without first calling 'set_reaction_info'")
            print("\tSkipping this action...")
            return
        if bounds != None:
            if type(bounds) is not tuple:
                print("Error! Bounds must be given as a tuple argument (lower, upper)")
                return
            if bounds[0] > bounds[1]:
                print("Error! Bounds must be given as an ORDERED tuple argument (lower, upper)")
                return
        if factor != None:
            if factor < 0:
                factor = 0
            factor_up = factor
            factor_low = factor
            if factor >= 1:
                factor_low = 0.99
        if rxn in self.model.arrhenius_rxns:
            if param == "A":
                if bounds != None:
                    self.model.A[rxn].setlb(bounds[0])
                    self.model.A[rxn].setub(bounds[1])
                    return
                if factor != None:
                    self.model.A[rxn].setlb(self.model.A[rxn].value*(1-factor_low))
                    self.model.A[rxn].setub(self.model.A[rxn].value*(1+factor_up))
                    return
            elif param == "B":
                if bounds != None:
                    self.model.B[rxn].setlb(bounds[0])
                    self.model.B[rxn].setub(bounds[1])
                    return
                if factor != None:
                    if self.model.B[rxn].value >=0:
                        self.model.B[rxn].setlb(self.model.B[rxn].value*(1-factor_low))
                        self.model.B[rxn].setub(self.model.B[rxn].value*(1+factor_up))
                    else:
                        self.model.B[rxn].setub(self.model.B[rxn].value*(1-factor_low))
                        self.model.B[rxn].setlb(self.model.B[rxn].value*(1+factor_up))
                    return
            elif param == "E":
                if bounds != None:
                    self.model.E[rxn].setlb(bounds[0])
                    self.model.E[rxn].setub(bounds[1])
                    return
                if factor != None:
                    if self.model.E[rxn].value >=0:
                        self.model.E[rxn].setlb(self.model.E[rxn].value*(1-factor_low))
                        self.model.E[rxn].setub(self.model.E[rxn].value*(1+factor_up))
                    else:
                        self.model.E[rxn].setub(self.model.E[rxn].value*(1-factor_low))
                        self.model.E[rxn].setlb(self.model.E[rxn].value*(1+factor_up))
                    return
            else:
                print("Error! Invalid parameter name")
                return
        if rxn in self.model.equ_arrhenius_rxns:
            if param == "A":
                if bounds != None:
                    self.model.Af[rxn].setlb(bounds[0])
                    self.model.Af[rxn].setub(bounds[1])
                    return
                if factor != None:
                    self.model.Af[rxn].setlb(self.model.Af[rxn].value*(1-factor_low))
                    self.model.Af[rxn].setub(self.model.Af[rxn].value*(1+factor_up))
                    return
            elif param == "E":
                if bounds != None:
                    self.model.Ef[rxn].setlb(bounds[0])
                    self.model.Ef[rxn].setub(bounds[1])
                    return
                if factor != None:
                    if self.model.Ef[rxn].value >=0:
                        self.model.Ef[rxn].setlb(self.model.Ef[rxn].value*(1-factor_low))
                        self.model.Ef[rxn].setub(self.model.Ef[rxn].value*(1+factor_up))
                    else:
                        self.model.Ef[rxn].setub(self.model.Ef[rxn].value*(1-factor_low))
                        self.model.Ef[rxn].setlb(self.model.Ef[rxn].value*(1+factor_up))
                    return
            elif param == "dH":
                if bounds != None:
                    self.model.dH[rxn].setlb(bounds[0])
                    self.model.dH[rxn].setub(bounds[1])
                    return
                if factor != None:
                    if self.model.dH[rxn].value >=0:
                        self.model.dH[rxn].setlb(self.model.dH[rxn].value*(1-factor_low))
                        self.model.dH[rxn].setub(self.model.dH[rxn].value*(1+factor_up))
                    else:
                        self.model.dH[rxn].setub(self.model.dH[rxn].value*(1-factor_low))
                        self.model.dH[rxn].setlb(self.model.dH[rxn].value*(1+factor_up))
                    return
            elif param == "dS":
                if bounds != None:
                    self.model.dS[rxn].setlb(bounds[0])
                    self.model.dS[rxn].setub(bounds[1])
                    return
                if factor != None:
                    if self.model.dS[rxn].value >=0:
                        self.model.dS[rxn].setlb(self.model.dS[rxn].value*(1-factor_low))
                        self.model.dS[rxn].setub(self.model.dS[rxn].value*(1+factor_up))
                    else:
                        self.model.dS[rxn].setub(self.model.dS[rxn].value*(1-factor_low))
                        self.model.dS[rxn].setlb(self.model.dS[rxn].value*(1+factor_up))
                    return
            else:
                print("Error! Invalid parameter name")
                return

    # Function to define weight factors to be used in the objective function
    def set_weight_factor(self, spec, age, temp, value):
        if self.isDataGasSpecSet == False and self.isDataSurfSpecSet == False:
            raise Exception("Error! Cannot specify weight factors prior to setting up the data")

        if self.isDataGasSpecSet == True:
            if spec in self.model.data_gas_set:
                self.model.w[spec,age,temp,:].set_value(value)
        if self.isDataSurfSpecSet == True:
            if spec in self.model.data_surface_set:
                self.model.wq[spec,age,temp,:].set_value(value)

    # Function to set provide a multiplier to a weight factor
    def set_weight_factor_multiplier(self, spec, age, temp, mult):
        if self.isDataGasSpecSet == False and self.isDataSurfSpecSet == False:
            raise Exception("Error! Cannot specify weight factors prior to setting up the data")

        if self.isDataGasSpecSet == True:
            if spec in self.model.data_gas_set:
                for time in self.model.t_data_full:
                    self.model.w[spec,age,temp,time].set_value(self.model.w[spec,age,temp,time].value*mult)
        if self.isDataSurfSpecSet == True:
            if spec in self.model.data_surface_set:
                for time in self.model.t_data_full:
                    self.model.wq[spec,age,temp,time].set_value(self.model.wq[spec,age,temp,time].value*mult)

    # Function to automatically select weight factors based on data
    def auto_select_weight_factor(self, spec, age, temp):
        maxval = 1e-20
        for z in self.model.z_data:
            for t in self.model.t_data:
                if self.isDataGasSpecSet == True:
                    if spec in self.model.data_gas_set:
                        if self.model.Cb_data[spec,age,temp,z,t].value > maxval:
                            maxval = self.model.Cb_data[spec,age,temp,z,t].value
                if self.isDataSurfSpecSet == True:
                    if spec in self.model.data_surface_set:
                        if self.model.q_data[spec,age,temp,z,t].value > maxval:
                            maxval = self.model.q_data[spec,age,temp,z,t].value
        self.set_weight_factor(spec, age, temp, 1/maxval)

    # Function to iterate through all spec, age, temp to get all weight factors
    def auto_select_all_weight_factors(self):
        if self.isDataGasSpecSet == True:
            for spec in self.model.data_gas_set:
                for age in self.model.data_age_set:
                    for temp in self.model.data_T_set:
                        self.auto_select_weight_factor(spec, age, temp)
        if self.isDataSurfSpecSet == True:
            for spec in self.model.data_surface_set:
                for age in self.model.data_age_set:
                    for temp in self.model.data_T_set:
                        self.auto_select_weight_factor(spec, age, temp)

    # Function to ignore weight factors between a specified time range
    #   time_window = tuple of (start_time, end_time) where the weight
    #               factors are to be set to zero
    def ignore_weight_factor(self, spec, age, temp, time_window):
        if self.isDataGasSpecSet == False and self.isDataSurfSpecSet == False:
            raise Exception("Error! Cannot specify weight factors prior to setting up the data")

        if type(time_window) is not tuple:
            raise Exception("Error! Argument 'time_window' must be tuple (start, end)")

        if time_window[0] > time_window[1]:
            raise Exception("Error! Tuple must be (lower_time, higher_time)")

        inside = False
        for time in self.model.t_data:
            if time >= time_window[0] and time <= time_window[1]:
                inside = True
            else:
                inside = False

            if inside == True:
                if self.isDataGasSpecSet == True:
                    if spec in self.model.data_gas_set:
                        self.model.w[spec,age,temp,time].set_value(0)
                if self.isDataSurfSpecSet == True:
                    if spec in self.model.data_surface_set:
                        self.model.wq[spec,age,temp,time].set_value(0)


    # Function to ignore all weight factors within a specified time range
    def ignore_all_weight_factors(self, time_window):
        if self.isDataGasSpecSet == True:
            for spec in self.model.data_gas_set:
                for age in self.model.data_age_set:
                    for temp in self.model.data_T_set:
                        self.ignore_weight_factor(spec, age, temp, time_window)
        if self.isDataSurfSpecSet == True:
            for spec in self.model.data_surface_set:
                for age in self.model.data_age_set:
                    for temp in self.model.data_T_set:
                        self.ignore_weight_factor(spec, age, temp, time_window)

    # Function to set a reference diffusivity for a species
    #       spec = name of species to set gas phase diffusivity for
    #       val = value of gas phase diffusivity in cm**2/s
    def set_ref_diffusivity(self, spec, val):
        if self.isGasSpecSet == False:
            raise Exception("Error! Cannot specify diffusivity without setting up gas species first")
        if spec not in self.model.gas_set:
            raise Exception("Error! Unrecognized gas species name was given when trying to set diffusivity. "
                            +str(spec)+ " given is not a valid name in model.gas_set")

        if val < 1e-6:
            val = 1e-6
        self.model.Dm[spec].set_value(val)

    # Helper function to calculate and store Ga and dh values
    #       This automatically gets called whenever a user updates
    #       the approximations to cell_density or bulk_porosity
    def calculate_form_factors(self, isMonolith=True, dh_true=0.1):
        Ac = self.model.eb.value / self.model.cell_density.value
        dc = 2*(Ac/3.14159)**0.5
        ds = Ac**0.5
        self.model.dh.set_value(0.5*(dc+ds))
        self.model.Ga.set_value(4*self.model.cell_density.value*self.model.dh.value/(1-self.model.eb.value))
        if isMonolith == False:
            self.model.dh.set_value(dh_true)
            self.model.Ga.set_value(6/self.model.dh.value)


    # Function to interpolate or extrapolate a model value to a given location and time
    #       var = variable object in the model
    #       spec = name of the species (required for scoping into variable)
    #       age = name of the age set (required for scoping into variable)
    #       temp = name of the temperature set (required for scoping into variable)
    #       loc = float for location in spatial domain
    #       loc = float for location in temporal domain
    #       eps = (optional) tolerance to prevent divide by zero error
    #
    def interpret_var(self, var, spec, age, temp, loc, time, eps=1e-6):
        if eps > 1e-6:
            eps = 1e-6
        if eps < 1e-16:
            eps = 1e-16
        nearest_loc_index = self.model.z.find_nearest_index(loc)
        nearest_time_index = self.model.t.find_nearest_index(time)

        if nearest_loc_index == 1:
            next_nearest_loc_index = 2
        elif nearest_loc_index == len(self.model.z):
            next_nearest_loc_index = len(self.model.z)-1
        else:
            #if self.model.z[nearest_loc_index] >= loc:
            if self.model.z.at(nearest_loc_index) >= loc:
                next_nearest_loc_index = nearest_loc_index - 1
            else:
                next_nearest_loc_index = nearest_loc_index + 1

        if nearest_time_index == 1:
            next_nearest_time_index = 2
        elif nearest_time_index == len(self.model.t):
            next_nearest_time_index = len(self.model.t)-1
        else:
            #if self.model.t[nearest_time_index] >= time:
            if self.model.t.at(nearest_time_index) >= time:
                next_nearest_time_index = nearest_time_index - 1
            else:
                next_nearest_time_index = nearest_time_index + 1

        #z_dist = (self.model.z[nearest_loc_index] - loc)
        z_dist = (self.model.z.at(nearest_loc_index) - loc)
        #t_dist = (self.model.t[nearest_time_index] - time)
        t_dist = (self.model.t.at(nearest_time_index) - time)
        #z_slope = -(var[spec,age,temp,self.model.z[nearest_loc_index],self.model.t[nearest_time_index]] - var[spec,age,temp,self.model.z[next_nearest_loc_index],self.model.t[nearest_time_index]])/(self.model.z[nearest_loc_index] - (self.model.z[next_nearest_loc_index] + eps) )
        z_slope = -(var[spec,age,temp,self.model.z.at(nearest_loc_index),self.model.t.at(nearest_time_index)] - var[spec,age,temp,self.model.z.at(next_nearest_loc_index),self.model.t.at(nearest_time_index)])/(self.model.z.at(nearest_loc_index) - (self.model.z.at(next_nearest_loc_index) + eps) )
        #t_slope = -(var[spec,age,temp,self.model.z[nearest_loc_index],self.model.t[nearest_time_index]] - var[spec,age,temp,self.model.z[nearest_loc_index],self.model.t[next_nearest_time_index]])/(self.model.t[nearest_time_index] - (self.model.t[next_nearest_time_index] + eps) )
        t_slope = -(var[spec,age,temp,self.model.z.at(nearest_loc_index),self.model.t.at(nearest_time_index)] - var[spec,age,temp,self.model.z.at(nearest_loc_index),self.model.t.at(next_nearest_time_index)])/(self.model.t.at(nearest_time_index) - (self.model.t.at(next_nearest_time_index) + eps) )

        loc_val = self.model.z.at(nearest_loc_index)
        time_val = self.model.t.at(nearest_time_index)

        return (var[spec,age,temp,loc_val,time_val] + z_slope*z_dist + t_slope*t_dist)

    # Define a single arrhenius rate function to be used in the model
    #       This function assumes the reaction index (rxn) is valid
    def arrhenius_rate_func(self, rxn, model, age, temp, loc, time):
        r = 0
        k = arrhenius_rate_const(model.A[rxn], model.B[rxn], model.E[rxn], model.T[age,temp,loc,time])
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
        kf = arrhenius_rate_const(model.Af[rxn], 0, model.Ef[rxn], model.T[age,temp,loc,time])
        kr = arrhenius_rate_const(Ar, 0, Er, model.T[age,temp,loc,time])
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

    # Define a function for the site sum
    def site_sum(self, site_spec, model, age, temp, loc, time):
        sum = 0
        for surf_spec in model.surf_set:
            sum+=model.u_S[site_spec,surf_spec]*model.q[surf_spec,age,temp,loc,time]
        return sum

    # Bulk mass balance constraint
    def bulk_mb_constraint(self, m, gas, age, temp, z, t):
        return m.eb*m.dCb_dt[gas, age, temp, z, t] + m.eb*m.v[age,temp,z,t]*m.dCb_dz[gas, age, temp, z, t] == -(1-m.eb)*m.Ga*m.km[gas, age, temp, z, t]*(m.Cb[gas, age, temp, z, t] - m.C[gas, age, temp, z, t])

    # Washcoat mass balance constraint
    def pore_mb_constraint(self, m, gas, age, temp, z, t):
        rxn_sum=self.reaction_sum_gas(gas, m, age, temp, z, t)
        if self.isReactionSetByTotalVolume == False:
            return m.ew*(1-m.eb)*m.dC_dt[gas, age, temp, z, t] == (1-m.eb)*m.Ga*m.km[gas, age, temp, z, t]*(m.Cb[gas, age, temp, z, t] - m.C[gas, age, temp, z, t]) + (1-m.eb)*rxn_sum
        else:
            return m.ew*(1-m.eb)*m.dC_dt[gas, age, temp, z, t] == (1-m.eb)*m.Ga*m.km[gas, age, temp, z, t]*(m.Cb[gas, age, temp, z, t] - m.C[gas, age, temp, z, t]) + rxn_sum

    # Adsorption/surface mass balance constraint
    def surf_mb_constraint(self, m, surf, age, temp, z, t):
        rxn_sum=self.reaction_sum_surf(surf, m, age, temp, z, t)
        return m.dq_dt[surf, age, temp, z, t] == rxn_sum

    # Site density balance constraint
    def site_bal_constraint(self, m, site, age, temp, z, t):
        sum=self.site_sum(site, m, age, temp, z, t)
        return m.Smax[site,age,z,t] - m.S[site, age, temp, z, t] - sum == 0

    # Edge constraint for central differencing
    def bulk_edge_constraint(self, m, gas, age, temp, t):
        #return m.dCb_dz[gas, age, temp, m.z[-1], t] == (m.Cb[gas, age, temp, m.z[-1], t] - m.Cb[gas, age, temp, m.z[-2], t])/(m.z[-1]-m.z[-2])
        return m.dCb_dz[gas, age, temp, m.z.at(-1), t] == (m.Cb[gas, age, temp, m.z.at(-1), t] - m.Cb[gas, age, temp, m.z.at(-2), t])/(m.z.at(-1)-m.z.at(-2))

    # Objective function
    def norm_objective(self, m):
        sum = 0
        try:
            for spec in m.data_gas_set:
                for age in m.data_age_set:
                    for temp in m.data_T_set:
                        for z in m.z_data:
                            for t in m.t_data:
                                sum+=m.w[spec,age,temp,t]*(m.Cb_data[spec,age,temp,z,t] - self.interpret_var(m.Cb,spec,age,temp,z,t))**2
        except:
            pass
        try:
            for spec in m.data_surface_set:
                for age in m.data_age_set:
                    for temp in m.data_T_set:
                        for z in m.z_data:
                            for t in m.t_data:
                                sum+=m.wq[spec,age,temp,t]*(m.q_data[spec,age,temp,z,t] - self.interpret_var(m.q,spec,age,temp,z,t))**2
        except:
            pass
        return sum


    # Build Constraints
    def build_constraints(self):
        for rxn in self.model.all_rxns:
            if self.isRxnBuilt[rxn] == False:
                raise Exception("Error! Cannot build constraints until reaction info is set. "
                                +str(rxn)+ " reaction is not yet constructed")
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

        self.isConBuilt = True

    # Apply a discretizer
    def discretize_model(self, method=DiscretizationMethod.FiniteDifference, elems=20, tstep=100, colpoints=2):
        if self.isConBuilt == False:
            raise Exception("Error! Must build the constraints before calling a discretizer")

        print("Starting discretizer. Please wait...")

        if colpoints < 2:
            colpoints = 2

        # Apply the discretizer method
        fd_discretizer = TransformationFactory('dae.finite_difference')
        # Secondary discretizer is for orthogonal collocation methods (if desired)
        oc_discretizer = TransformationFactory('dae.collocation')

        # discretization in time
        fd_discretizer.apply_to(self.model,nfe=tstep,wrt=self.model.t,scheme='BACKWARD')

        if method == DiscretizationMethod.FiniteDifference:
            fd_discretizer.apply_to(self.model,nfe=elems,wrt=self.model.z,scheme='CENTRAL')
            self.DiscType = "DiscretizationMethod.FiniteDifference"
            self.model.dCbdz_edge = Constraint(self.model.gas_set, self.model.age_set, self.model.T_set, self.model.t, rule=self.bulk_edge_constraint)
        elif method == DiscretizationMethod.OrthogonalCollocation:
            oc_discretizer.apply_to(self.model,nfe=elems,wrt=self.model.z,ncp=colpoints,scheme='LAGRANGE-RADAU')
            self.DiscType = "DiscretizationMethod.OrthogonalCollocation"
            self.colpoints = colpoints
        else:
            raise Exception("Error! Unrecognized discretization method. "
                            +str(method)+ " given is not recognized")

        # Before exiting, we should initialize some additional parameters that
        #   the discretizer doesn't already handle

        # Force temperature to be isothermal
        self.model.T[:,:,:,:].fix()
        for age in self.model.age_set:
            for temp in self.model.T_set:
                val = value(self.model.T[age,temp,self.model.z.first(),self.model.t.first()])
                self.model.T[age,temp,:,:].set_value(val)

        #       Initialize space_velocity, linear velocity, and pressure
        self.model.space_velocity[:,:,:].fix()
        self.model.v[:,:,:,:].fix()
        self.model.P[:,:,:,:].fix()
        volume = 0
        if self.isSpaceVelocityByTotalVolume == False:
            volume = self.full_length*3.14159*value(self.model.r)**2*(1-self.model.eb.value)
        else:
            volume = self.full_length*3.14159*value(self.model.r)**2
        for age in self.model.age_set:
            for temp in self.model.T_set:
                flow_rate_ref = volume*value(self.model.space_velocity[age,temp,self.model.t.first()])
                press = value(self.model.P[age,temp,self.model.z.last(),self.model.t.first()])
                temperature = value(self.model.T[age,temp,self.model.z.first(),self.model.t.first()])
                self.model.P[age,temp,:,:].set_value(press)
                val = value(self.model.space_velocity[age,temp,self.model.t.first()])
                self.model.space_velocity[age,temp, :].set_value(val)
                flow_rate_true = flow_rate_ref*(value(self.model.Pref[age,temp])/press)*(temperature/value(self.model.Tref[age,temp]))
                self.model.v[age,temp, :, :].set_value(flow_rate_true/volume/value(self.model.eb)*(self.model.z.last()-self.model.z.first()))

        #       Initialize gas density and viscosity
        self.model.rho[:,:,:,:].fix()
        self.model.mu[:,:,:,:].fix()
        for age in self.model.age_set:
            for temp in self.model.T_set:
                T = self.model.T[age,temp,self.model.z.first(),self.model.t.first()].value
                val = self.model.P[age,temp,self.model.z.first(),self.model.t.first()].value*1000/287.058/T*1000
                self.model.rho[age,temp,:,:].set_value(val/100**3)
                val = 0.1458*T**1.5/(110.4+T)
                self.model.mu[age,temp,:,:].set_value(val/10000)

        #       Initialize pressure drop across monolith
        self.calculate_pressure_drop()

        #       Initialize dimensionless numbers
        #           NOTE: Assume time is always in minutes (for any user inputs,
        #                   i.e., space-velocity and time coordinates)
        #                   Thus, we should calculate km in cm/min
        #                   (users won't input Diffusivities, so we will use cm**2/s
        #                   and just note when the units need converting)
        self.model.Re[:,:,:,:].fix()
        self.model.Sc[:,:,:,:,:].fix()
        self.model.Sh[:,:,:,:,:].fix()
        for age in self.model.age_set:
            for temp in self.model.T_set:
                Re = self.model.rho[age,temp,self.model.z.first(),self.model.t.first()].value* \
                    self.model.v[age,temp, self.model.z.first(), self.model.t.first()].value/60* \
                        self.model.dh.value/self.model.mu[age,temp,self.model.z.first(),self.model.t.first()].value
                self.model.Re[age,temp,:,:].set_value(Re)
                T = self.model.T[age,temp,self.model.z.first(),self.model.t.first()].value

                for spec in self.model.gas_set:
                    Sc = self.model.mu[age,temp,self.model.z.first(),self.model.t.first()].value/ \
                    self.model.rho[age,temp,self.model.z.first(),self.model.t.first()].value/ \
                    (self.model.Dm[spec].value*exp(-887.5*((1.0/T)-(1.0/473.15))))

                    self.model.Sc[spec,age,temp,:,:].set_value(Sc)

                    if self.isMonolith == True:
                        Sh = (0.3+(0.62*Re**0.5*Sc**0.33*(1+(0.4/Sc)**0.67)**-0.25)*(1+(Re/282000)**(5/8))**(4/5))
                    else:
                        Sh = (2+(0.4*Re**0.5+0.06*Re**0.67)*Sc**0.4)
                    self.model.Sh[spec,age,temp,:,:].set_value(Sh)

        #       Initialize mass transfer rates
        self.model.km[:,:,:,:,:].fix()
        for spec in self.model.gas_set:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    T = self.model.T[age,temp,self.model.z.first(),self.model.t.first()].value
                    val = self.model.Sh[spec,age,temp,self.model.z.first(),self.model.t.first()].value*self.model.ew.value**self.model.diff_factor.value* \
                            (self.model.Dm[spec].value*exp(-887.5*((1.0/T)-(1.0/473.15))))*60 / self.model.dh.value
                    self.model.km[spec,age,temp,:,:].set_value(val)

        #       Initialize Smax
        if self.isSitesSet == True:
            for site in self.model.site_set:
                for age in self.model.age_set:
                    val = value(self.model.Smax[site,age,self.model.z.first(),self.model.t.first()])
                    self.model.Smax[site,age,:,:].set_value(val)

        #        Initialize u_C
        for spec in self.model.gas_set:
            for rxn in self.model.all_rxns:
                val = value(self.model.u_C[spec,rxn,self.model.z.first()])
                self.model.u_C[spec,rxn,:].set_value(val)

        #        Initialize u_q
        if self.isSurfSpecSet == True:
            for spec in self.model.surf_set:
                for rxn in self.model.all_rxns:
                    val = value(self.model.u_q[spec,rxn,self.model.z.first()])
                    self.model.u_q[spec,rxn,:].set_value(val)

        # For PDE portions, fix the first time derivative at the first node
        for spec in self.model.gas_set:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    self.model.dCb_dt[spec,age,temp,self.model.z.first(),self.model.t.first()].set_value(0)
                    self.model.dCb_dt[spec,age,temp,self.model.z.first(),self.model.t.first()].fix()

        self.isDiscrete = True

        # Build the objective function (if possible)
        anyFalse = False
        if self.isDataGasSpecSet == True or self.isDataSurfSpecSet == True:
            if self.isDataGasSpecSet == True:
                for spec in self.model.data_gas_set:
                    for loc_dat in self.model.z_data:
                        if self.isDataValuesSet[spec][loc_dat] == False:
                            anyFalse = True
                            break
            if self.isDataSurfSpecSet == True:
                for spec in self.model.data_surface_set:
                    for loc_dat in self.model.z_data:
                        if self.isDataValuesSet[spec][loc_dat] == False:
                            anyFalse = True
                            break
            if anyFalse == True:
                raise Exception("Error! Some data for gases not set. Cannot create objective function. "
                                +str(self.isDataValuesSet)+ " check dict for missing pieces")
            self.model.obj = Objective(rule=self.norm_objective)
            self.isObjectiveSet = True

        self.build_time = (TIME.time() - self.build_time)
        print("\tComplete! Elapsed time (s) = "+str(self.build_time))

    # Set initial condition for surface species as fraction of surface sites
    def set_surf_IC_as_fraction_of_sites(self, surf_spec, site, age, temp, fraction):
        if self.isSurfSpecSet == False:
            raise Exception("Error! Cannot use this function is there is no surface species")
        if self.isSitesSet == False:
            raise Exception("Error! Cannot use this function is there is no sites defined")
        if surf_spec not in self.model.surf_set:
            raise Exception("Error! "+surf_spec+" is not a valid surface species in the model")
        if site not in self.model.site_set:
            raise Exception("Error! "+site+" is not a valid surface site in the model")

        if self.model.u_S[site, surf_spec].value <= 0:
            raise Exception("Error! "+site+","+surf_spec+" pair is not a valid combination according to model site balance")

        if fraction > 1:
            fraction = 1
        if fraction < 0:
            fraction = 0

        for loc in self.model.z:
            value = fraction*self.model.Smax[site, age, loc, self.model.t.first()].value
            if value < 1e-20:
                value = 1e-20
            self.model.q[surf_spec,age,temp, loc, self.model.t.first()].set_value(value)
            self.model.q[surf_spec,age,temp, loc, self.model.t.first()].fix()
        self.isInitialSet[surf_spec][age][temp] = True


    # Set constant initial conditions
    def set_const_IC(self,spec,age,temp,value):
        if self.isDiscrete == False:
            raise Exception("Error! User should call the discretizer before setting initial conditions")
        if value < 0:
            raise Exception("Error! Concentrations cannot be negative")
        if value < 1e-20:
            value = 1e-20
        if spec in self.model.gas_set:
            self.model.Cb[spec,age,temp, :, self.model.t.first()].set_value(value)
            self.model.Cb[spec,age,temp, :, self.model.t.first()].fix()
            self.model.C[spec,age,temp, :, self.model.t.first()].set_value(value)
            self.model.C[spec,age,temp, :, self.model.t.first()].fix()
            self.isInitialSet[spec][age][temp] = True
        if self.isSurfSpecSet == True:
            if spec in self.model.surf_set:
                self.model.q[spec,age,temp, :, self.model.t.first()].set_value(value)
                self.model.q[spec,age,temp, :, self.model.t.first()].fix()
                self.isInitialSet[spec][age][temp] = True
            if self.isSitesSet == True:
                if spec in self.model.site_set:
                    # Do not set this initial value (not a time dependent variable)
                    self.isInitialSet[spec][age][temp] = True

    # Set initial condition when given ppm as units
    def set_const_IC_in_ppm(self, spec, age, temp, ppm_val):
        if self.isDiscrete == False:
            raise Exception("Error! User should call the discretizer before setting initial conditions")
        if ppm_val < 0:
            raise Exception("Error! Concentrations cannot be negative")
        if self.isIsothermalTempSet == False:
            raise Exception("Error! Cannot use 'set_const_IC_in_ppm' if temperatures are not set first")
        if spec not in self.model.gas_set:
            raise Exception("Error! Given species name is not a valid gas species name. "
                            +str(spec)+ " given is not in model.gas_set")

        value = ppm_val/10**6*self.model.Pref[age,temp].value/8.3145/self.model.T[age,temp,self.model.z.first(),self.model.t.first()].value
        if value < 1e-20:
            value = 1e-20
        self.model.Cb[spec,age,temp, :, self.model.t.first()].set_value(value)
        self.model.Cb[spec,age,temp, :, self.model.t.first()].fix()
        self.model.C[spec,age,temp, :, self.model.t.first()].set_value(value)
        self.model.C[spec,age,temp, :, self.model.t.first()].fix()
        self.isInitialSet[spec][age][temp] = True


    # Set constant boundary conditions
    def set_const_BC(self,spec,age,temp,value, auto_init=True):
        if spec not in self.model.gas_set:
            raise Exception("Error! Cannot specify boundary value for non-gas species. "
                            +str(spec)+" given is not in model.gas_set")

        if self.isInitialSet[spec][age][temp] == False:
            raise Exception("Error! User must specify initial conditions before boundary conditions. "
                            +str(spec)+","+str(age)+","+str(temp)+ " given does not have IC")

        if value < 0:
            raise Exception("Error! Concentrations cannot be negative")
        if value < 1e-20:
            value = 1e-20

        self.model.Cb[spec,age,temp,self.model.z.first(), :].set_value(value)
        self.model.Cb[spec,age,temp,self.model.z.first(), :].fix()
        #This should improve convergence
        if auto_init == True:
            for time in self.model.t:
                if time != self.model.t.first():
                    self.model.Cb[spec,age,temp,:, time].set_value(value)
                    self.model.C[spec,age,temp,:, time].set_value(value)
        self.isBoundarySet[spec][age][temp] = True

    # Set boundary condition when given ppm as units
    def set_const_BC_in_ppm(self, spec, age, temp, ppm_val, auto_init=True):
        if spec not in self.model.gas_set:
            raise Exception("Error! Cannot specify boundary value for non-gas species. "
                            +str(spec)+" given is not in model.gas_set")

        if self.isInitialSet[spec][age][temp] == False:
            raise Exception("Error! User must specify initial conditions before boundary conditions. "
                            +str(spec)+","+str(age)+","+str(temp)+ " given does not have IC")

        if ppm_val < 0:
            raise Exception("Error! Concentrations cannot be negative")

        if self.isIsothermalTempSet == False:
            raise Exception("Error! Cannot use 'set_const_IC_in_ppm' if temperatures are not set first")

        for time in self.model.t:
            value = ppm_val/10**6*self.model.Pref[age,temp].value/8.3145/self.model.T[age,temp,self.model.z.first(),time].value
            if value < 1e-20:
                value = 1e-20
            self.model.Cb[spec,age,temp,self.model.z.first(), time].set_value(value)
            self.model.Cb[spec,age,temp,self.model.z.first(), time].fix()

            #This should improve convergence
            if auto_init == True:
                if time != self.model.t.first():
                    self.model.Cb[spec,age,temp,:, time].set_value(value)
                    self.model.C[spec,age,temp,:, time].set_value(value)
        self.isBoundarySet[spec][age][temp] = True

    # Set time dependent BCs using a 'time_value_pairs' list of tuples
    #       If user does not provide an initial value, it will be assumed 1e-20
    def set_time_dependent_BC(self,spec,age,temp,time_value_pairs,initial_value=1e-20, auto_init=True):
        if spec not in self.model.gas_set:
            raise Exception("Error! Cannot specify boundary value for non-gas species. "
                            +str(spec)+" given is not in model.gas_set")

        if self.isInitialSet[spec][age][temp] == False:
            raise Exception("Error! User must specify initial conditions before boundary conditions. "
                            +str(spec)+","+str(age)+","+str(temp)+ " given does not have IC")

        if type(time_value_pairs) is not list:
            raise Exception("Error! Must specify time dependent BCs using a list of tuples: [(t0,value), (t1,value) ...]. "
                            +str(spec)+","+str(age)+","+str(temp)+ " given does not have correct args")

        if type(time_value_pairs[0]) is not tuple:
            raise Exception("Error! Must specify time dependent BCs using a list of tuples: [(t0,value), (t1,value) ...]. "
                            +str(spec)+","+str(age)+","+str(temp)+ " given does not have correct args")

        # Set the first value as given initial_value
        if initial_value < 1e-20:
            initial_value = 1e-20
        i=0
        current_bc_time = time_value_pairs[i][0]
        current_bc_value = time_value_pairs[i][1]
        for time in self.model.t:
            if time == self.model.t.first():
                current_bc_value = initial_value
            if time >= current_bc_time:
                ###
                try:
                    j=i
                    while time >= time_value_pairs[j][0]:
                        j+=1
                    i=j-1
                except:
                    pass
                ###
                try:
                    current_bc_value = time_value_pairs[i][1]
                    if current_bc_value < 1e-20:
                        current_bc_value = 1e-20
                except:
                    pass
                self.model.Cb[spec,age,temp,self.model.z.first(), time].set_value(current_bc_value)
                self.model.Cb[spec,age,temp,self.model.z.first(), time].fix()
                #This should improve convergence
                if auto_init == True:
                    self.model.Cb[spec,age,temp,:, time].set_value(current_bc_value)
                    self.model.C[spec,age,temp,:, time].set_value(current_bc_value)
                i+=1
                try:
                    current_bc_time = time_value_pairs[i][0]
                except:
                    pass
            else:
                self.model.Cb[spec,age,temp,self.model.z.first(), time].set_value(current_bc_value)
                self.model.Cb[spec,age,temp,self.model.z.first(), time].fix()
                #This should improve convergence
                if auto_init == True:
                    self.model.Cb[spec,age,temp,:, time].set_value(current_bc_value)
                    self.model.C[spec,age,temp,:, time].set_value(current_bc_value)

        self.isBoundarySet[spec][age][temp] = True


    # Set time dependent boundary condition when given ppm as units
    def set_time_dependent_BC_in_ppm(self, spec, age, temp, time_value_pairs, initial_value=0, auto_init=True):
        if spec not in self.model.gas_set:
            raise Exception("Error! Cannot specify boundary value for non-gas species. "
                            +str(spec)+" given is not in model.gas_set")

        if self.isInitialSet[spec][age][temp] == False:
            raise Exception("Error! User must specify initial conditions before boundary conditions. "
                            +str(spec)+","+str(age)+","+str(temp)+ " given does not have IC")

        if type(time_value_pairs) is not list:
            raise Exception("Error! Must specify time dependent BCs using a list of tuples: [(t0,value), (t1,value) ...]. "
                            +str(spec)+","+str(age)+","+str(temp)+ " given does not have correct args")

        if type(time_value_pairs[0]) is not tuple:
            raise Exception("Error! Must specify time dependent BCs using a list of tuples: [(t0,value), (t1,value) ...]. "
                            +str(spec)+","+str(age)+","+str(temp)+ " given does not have correct args")

        if self.isIsothermalTempSet == False:
            raise Exception("Error! Cannot use 'set_const_IC_in_ppm' if temperatures are not set first")


        # Set the first value as given initial_value
        initial_value = initial_value/10**6*self.model.Pref[age,temp].value/8.3145/self.model.T[age,temp,self.model.z.first(),self.model.t.first()].value
        if initial_value < 1e-20:
            initial_value = 1e-20
        i=0
        current_bc_time = time_value_pairs[i][0]
        current_bc_value = time_value_pairs[i][1]
        for time in self.model.t:
            if time == self.model.t.first():
                current_bc_value = initial_value
            if time >= current_bc_time:
                ###
                try:
                    j=i
                    while time >= time_value_pairs[j][0]:
                        j+=1
                    i=j-1
                except:
                    pass
                ###
                try:
                    current_bc_value = time_value_pairs[i][1]
                    current_bc_value = current_bc_value/10**6*self.model.Pref[age,temp].value/8.3145/self.model.T[age,temp,self.model.z.first(),time].value
                    if current_bc_value < 1e-20:
                        current_bc_value = 1e-20
                except:
                    pass
                self.model.Cb[spec,age,temp,self.model.z.first(), time].set_value(current_bc_value)
                self.model.Cb[spec,age,temp,self.model.z.first(), time].fix()
                #This should improve convergence
                if auto_init == True:
                    self.model.Cb[spec,age,temp,:, time].set_value(current_bc_value)
                    self.model.C[spec,age,temp,:, time].set_value(current_bc_value)
                i+=1
                try:
                    current_bc_time = time_value_pairs[i][0]
                except:
                    pass
            else:
                self.model.Cb[spec,age,temp,self.model.z.first(), time].set_value(current_bc_value)
                self.model.Cb[spec,age,temp,self.model.z.first(), time].fix()
                #This should improve convergence
                if auto_init == True:
                    self.model.Cb[spec,age,temp,:, time].set_value(current_bc_value)
                    self.model.C[spec,age,temp,:, time].set_value(current_bc_value)

        self.isBoundarySet[spec][age][temp] = True

    # Function to add linear temperature ramp section
    #       Starting temperature will be whatever the temperature is
    #       at the start time. End temperature will be carried over to
    #       end time (if possible).
    def set_temperature_ramp(self, age, temp, start_time, end_time, end_temp):
        if self.isDiscrete == False:
            raise Exception("Error! User should call the discretizer before setting a temperature ramp")
        start_temp = value(self.model.T[age,temp,self.model.z.first(),self.model.t.first()])
        previous_time = self.model.t.first()
        for time in self.model.t:
            if time <= start_time:
                start_temp = value(self.model.T[age,temp,self.model.z.first(),self.model.t.first()])
            else:
                if time >= end_time:
                    self.model.T[age,temp,:,time].set_value(end_temp)
                else:
                    slope = (end_temp-start_temp)/(end_time-start_time)
                    self.model.T[age,temp,:,time].set_value(start_temp+slope*(time-start_time))
            previous_time = time
        self.isVelocityRecalculated = False
        self.isIsothermalTempSet = True

    # Function to set isothermal temperature via data
    #       This function will attempt to setup temperature information via
    #       a set of data in the given data_dict for a specific catalyst
    #       "age" and "temp" run. You can read in temperature data via the
    #       'naively_read_data_file' function and return data as lists.
    #       Then, the data dictionary will hold the time stamps and
    #       temperature data at specified locations. This dictionary can
    #       come directly from the read method, but then use must also
    #       provide a 'key_loc_pairs' dictionary to decode the names of
    #       temperatures from the files and know what location they
    #       belong to
    def set_temperature_from_data(self, age, temp, data_dict, key_loc_pairs):
        if type(data_dict) is not dict:
            raise Exception("Error! Must specify temperature information using a formatted dictionary. "
                            +str(data_dict)+" given in not a dict object")
        all_lower_keys = []
        for item in data_dict:
            all_lower_keys.append(str(item).lower())
        time_key = ""
        for key in all_lower_keys:
            if "time" == key:
                time_key = key
                break
        if time_key == "":
            raise Exception("Error! data_dict must contain a 'time' key to a list of time stamps")
        for item in key_loc_pairs:
            if item not in data_dict.keys():
                raise Exception("Error! 'key_loc_pairs' must be a subset of the same keys in 'data_dict'")

        key_loc_pairs = dict(sorted(key_loc_pairs.items(), key=lambda item: item[1]))

        # Embedded helper function for setting up temperatures
        def _set_temperature(model, age, temp, time, data_index, data_dict, key_loc_pairs):
            slope = {}
            i=0
            current_key = ""
            previous_key = ""
            key_list = []
            for key in key_loc_pairs:
                key_list.append(key)
                current_key = key
                if i==0:
                    slope[key] = 0
                    previous_key = key
                else:
                    slope[current_key] = (data_dict[current_key][data_index] - data_dict[previous_key][data_index])/(key_loc_pairs[current_key] - key_loc_pairs[previous_key])
                i+=1
                previous_key = current_key

            key_id=0
            key_id_old=0
            loc_id=0
            for loc in model.z:
                if loc <= key_loc_pairs[key_list[key_id]]:
                    pass
                else:
                    if key_id != -1:
                        key_id_old = key_id
                        key_id+=1
                    if key_id < len(key_list):
                        key_id=key_id
                    else:
                        key_id=-1
                loc_id+=1

                if loc <= key_loc_pairs[key_list[0]]:
                    model.T[age,temp,loc,time].set_value(data_dict[key_list[0]][data_index])
                elif loc >= key_loc_pairs[key_list[-1]]:
                    model.T[age,temp,loc,time].set_value(data_dict[key_list[-1]][data_index])
                else:
                    Tnew = slope[key_list[key_id]]*(loc - key_loc_pairs[key_list[key_id_old]]) + data_dict[key_list[key_id_old]][data_index]
                    model.T[age,temp,loc,time].set_value(Tnew)

            #End loc loop

        temp_dict = {}
        for key in key_loc_pairs:
            temp_dict[key] = [0]
        data_index = 0
        time_old = self.model.t.first()
        data_index_old = 0
        for time in self.model.t:

            while time > data_dict["time"][data_index]:
                if data_index != -1:
                    data_index_old = data_index
                    data_index+=1
                else:
                    break
                if data_index >= len(data_dict["time"]):
                    data_index=-1
                    data_index_old=-2
                    break

            if data_index == data_index_old:
                # Setup initial data
                _set_temperature(self.model, age, temp, time, data_index, data_dict, key_loc_pairs)
            elif time > data_dict["time"][-1]:
                # Setup final data
                _set_temperature(self.model, age, temp, time, -1, data_dict, key_loc_pairs)
            else:
                # Setup current data
                for key in temp_dict:
                    Tnew = (data_dict[key][data_index]-data_dict[key][data_index_old])/(data_dict["time"][data_index]-data_dict["time"][data_index_old])*(time - data_dict["time"][data_index_old]) + data_dict[key][data_index_old]
                    temp_dict[key][0] = Tnew
                _set_temperature(self.model, age, temp, time, 0, temp_dict, key_loc_pairs)
            time_old = time

        #End for loop over all model time
        self.isVelocityRecalculated = False
        self.isIsothermalTempSet = True

    # Function to define reaction 'zones'
    #       By default, all reactions occur in all zones. Users can
    #       utilize this function to specify if a particular reaction
    #       set is only active in a particular 'zone' of the catalyst.
    #       The 'zone' must be specified via a tuple argument where
    #       the first item in the tuple is the start of the zone and
    #       the second argument is the end of the zone. The given
    #       reaction will not occur at points outside the given zone.
    def set_reaction_zone(self, rxn, zone, isNotActive=False):
        if self.isDiscrete == False:
            raise Exception("Error! User should call the discretizer before setting a reaction zone")
        if rxn not in self.model.all_rxns:
            raise Exception("Error! Invalid reaction ID given. "
                            +str(rxn)+" given is not a valid name in model.all_rxns")
        if type(zone) is not tuple:
            raise Exception("Error! Zone must be given as tuple: zone=(start_loc, end_loc)")
        start_loc = zone[0]
        if start_loc > zone[1]:
            start_loc = zone[1]
            end_loc = zone[0]
        else:
            end_loc = zone[1]
        inside = False
        for loc in self.model.z:
            if loc >= start_loc and loc <= end_loc:
                inside = True
            else:
                inside = False

            if inside == isNotActive:
                for spec in self.model.gas_set:
                    self.model.u_C[spec,rxn,loc].set_value(0)
                if self.isSurfSpecSet == True:
                    for spec in self.model.surf_set:
                        self.model.u_q[spec,rxn,loc].set_value(0)

    # Function to set site density by zone
    #   By default, setting a site density parameter is done across entire
    #   domain. However, if the catalyst is zoned, then the site densities
    #   may vary by location. Thus, users can use this function to delineate
    #   different site densities by different catalyst zones.
    #
    #       site = name of the site to set values for
    #       age = name of the age of the catalyst
    #       zone = tuple containing the start and end points for this zone
    #            = (start_loc, end_loc) - inclusive
    #       value = value of the density of sites in this zone
    def set_site_density_by_zone(self, site, age, zone, value):
        if self.isDiscrete == False:
            raise Exception("Error! User should call the discretizer before setting a reaction zone")
        if self.isSitesSet == False:
            raise Exception("Error! Model object does not contain surface sites!")
        if type(zone) is not tuple:
            raise Exception("Error! Zone must be given as tuple: zone=(start_loc, end_loc)")
        if value < 0:
            raise Exception("Error! Cannot have a negative concentration of sites")
        if value < 1e-20:
            value = 1e-20

        start_loc = zone[0]
        if start_loc > zone[1]:
            start_loc = zone[1]
            end_loc = zone[0]
        else:
            end_loc = zone[1]
        inside = False
        for loc in self.model.z:
            if loc >= start_loc and loc <= end_loc:
                inside = True
            else:
                inside = False

            if inside == True:
                self.model.Smax[site, age, loc, :].set_value(value)

    # Function to setup data for a specific data species, specific data age,
    #   specific data temperature run, at a specific location, based on a
    #   list of time values and cooresponding data values at those times.
    #
    #   NOTE: The list of time values and cooresponding data points should be
    #           in their correct order (we don't check order for you)
    def set_data_values_for(self, spec, age, temp, loc, times, values):
        #if self.isDataGasSpecSet == False:
        #    raise Exception("Error! Data gas species must be set in model data before providing values")

        if type(times) is not list:
            raise Exception("Error! Given times must be a list of values")

        if type(values) is not list:
            raise Exception("Error! Values for setting data must be given as a list")

        if loc not in self.model.z_data:
            raise Exception("Error! Location given was not specified during the creation of the spatial data set. "
                            +str(loc)+ " given is not a valid location in model.z_data")

        if len(times) != len(values):
            raise Exception("Error! The 'times' list and 'values' list must be of same size")

        if len(times) > 500:
            print("Setting up large data space for "+spec+"->"+str(age)+"->"+str(temp)+" at loc = "+str(loc)+"...")

        found = False
        if self.isDataGasSpecSet == True:
            if spec in self.model.data_gas_set:
                i=0
                for t in times:
                    self.model.Cb_data_full[spec, age, temp, loc, t].set_value(values[i])
                    if t >= self.model.t.first() and t <= self.model.t.last():
                        self.model.Cb_data[spec, age, temp, loc, t].set_value(values[i])
                    i+=1
                found = True
        else:
            pass #possible error
        if self.isDataSurfSpecSet == True:
            if spec in self.model.data_surface_set:
                i=0
                for t in times:
                    self.model.q_data_full[spec, age, temp, loc, t].set_value(values[i])
                    if t >= self.model.t.first() and t <= self.model.t.last():
                        self.model.q_data[spec, age, temp, loc, t].set_value(values[i])
                    i+=1
                found = True
        else:
            pass #possible error

        if found == False:
            raise Exception("Error! Data species name given is invalid!")

        self.isDataValuesSet[spec][loc] = True


    # This function will recalculate all linear velocities
    #   based on the space-velocity and temperature and pressure information
    #       Optional arg: internally_called determines whether or not to consider
    #                       this function call as definitive. By default, it is
    #                       set to false. When the function is called internally,
    #                       then it notes that this doesn't need to be called again
    def recalculate_linear_velocities(self, interally_called=False, isMonolith=True):
        full_area = 3.14159*value(self.model.r)**2
        volume = 0
        if self.isSpaceVelocityByTotalVolume == False:
            volume = self.full_length*full_area*(1-self.model.eb.value)
        else:
            volume = self.full_length*full_area
        open_area = full_area*value(self.model.eb)
        for age in self.model.age_set:
            for temp in self.model.T_set:
                for time in self.model.t:
                    for loc in self.model.z:
                        Q_ref = volume*value(self.model.space_velocity[age,temp,time])
                        P = value(self.model.P[age,temp,self.model.z.last(),time])
                        T = value(self.model.T[age,temp,loc,time])
                        Q_real = Q_ref*(value(self.model.Pref[age,temp])/P)*(T/value(self.model.Tref[age,temp]))
                        self.model.v[age,temp,loc,time].set_value(Q_real/open_area)

        for age in self.model.age_set:
            for temp in self.model.T_set:
                for time in self.model.t:
                    for loc in self.model.z:
                        T = self.model.T[age,temp,loc,time].value
                        val = self.model.P[age,temp,self.model.z.last(),time].value*1000/287.058/T*1000
                        self.model.rho[age,temp,loc,time].set_value(val/100**3)
                        val = 0.1458*T**1.5/(110.4+T)
                        self.model.mu[age,temp,loc,time].set_value(val/10000)

        for age in self.model.age_set:
            for temp in self.model.T_set:
                for time in self.model.t:
                    for loc in self.model.z:
                        Re = self.model.rho[age,temp,loc,time].value* \
                            self.model.v[age,temp,loc,time].value/60* \
                                self.model.dh.value/self.model.mu[age,temp,loc,time].value
                        self.model.Re[age,temp,loc,time].set_value(Re)
                        T = self.model.T[age,temp,loc,time].value

                        for spec in self.model.gas_set:
                            Sc = self.model.mu[age,temp,loc,time].value/ \
                            self.model.rho[age,temp,loc,time].value/ \
                            (self.model.Dm[spec].value*exp(-887.5*((1.0/T)-(1.0/473.15))))

                            self.model.Sc[spec,age,temp,loc,time].set_value(Sc)
                            if isMonolith == True:
                                Sh = (0.3+(0.62*Re**0.5*Sc**0.33*(1+(0.4/Sc)**0.67)**-0.25)*(1+(Re/282000)**(5/8))**(4/5))
                            else:
                                Sh = (2+(0.4*Re**0.5+0.06*Re**0.67)*Sc**0.4)
                            self.model.Sh[spec,age,temp,loc,time].set_value(Sh)

        for spec in self.model.gas_set:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    for time in self.model.t:
                        for loc in self.model.z:
                            T = self.model.T[age,temp,loc,time].value
                            val = self.model.Sh[spec,age,temp,loc,time].value*self.model.ew.value**self.model.diff_factor.value* \
                                (self.model.Dm[spec].value*exp(-887.5*((1.0/T)-(1.0/473.15))))*60 / self.model.dh.value
                            ## TODO: Add unit conversions for time
                            ## TODO: Add unit conversions for space
                            #   val = cm/min
                            self.model.km[spec,age,temp,loc,time].set_value(val)

        self.calculate_pressure_drop()
        if interally_called == True:
            self.isVelocityRecalculated = True

    # Function to calculate pressure drop across monolith
    def calculate_pressure_drop(self):
        for age in self.model.age_set:
            for temp in self.model.T_set:
                for time in self.model.t:
                    # # TODO: Check units for conversions
                    mu = self.model.mu[age,temp,self.model.z.last(),time].value * 100.0 / 1000.0
                    rho = self.model.rho[age,temp,self.model.z.last(),time].value * 100.0**3 / 1000.0
                    v = self.model.v[age,temp,self.model.z.last(),time].value / 60.0 / 100.0
                    dh = self.model.dh.value / 100.0
                    eps = self.model.eb.value
                    dP_dz = ergun_pressure_drop(mu, rho, v, dh, eps)
                    z_old = self.model.z.last()
                    for z in reversed(self.model.z):
                        if z == self.model.z.last():
                            z_old = z
                        else:
                            self.model.P[age,temp,z,time].set_value(self.model.P[age,temp,z_old,time].value + dP_dz*(z_old-z))


    # Function to fix all kinetic vars
    def fix_all_reactions(self):
        for r in self.model.arrhenius_rxns:
            self.model.A[r].fix()
            self.model.B[r].fix()
            self.model.E[r].fix()
            self.rxn_list[r]["fixed"]=True
        for re in self.model.equ_arrhenius_rxns:
            self.model.Af[re].fix()
            self.model.Ef[re].fix()
            self.model.dH[re].fix()
            self.model.dS[re].fix()
            self.rxn_list[re]["fixed"]=True

    # Function to unfix all kinetic vars
    def unfix_all_reactions(self):
        for r in self.model.arrhenius_rxns:
            self.model.A[r].unfix()
            self.model.B[r].unfix()
            self.model.E[r].unfix()
            self.rxn_list[r]["fixed"]=False
        for re in self.model.equ_arrhenius_rxns:
            self.model.Af[re].unfix()
            self.model.Ef[re].unfix()
            self.model.dH[re].unfix()
            self.model.dS[re].unfix()
            self.rxn_list[re]["fixed"]=False

    # Function to fix only a given reaction
    def fix_reaction(self, rxn):
        if rxn in self.model.arrhenius_rxns:
            self.model.A[rxn].fix()
            self.model.B[rxn].fix()
            self.model.E[rxn].fix()
            self.rxn_list[rxn]["fixed"]=True
        if rxn in self.model.equ_arrhenius_rxns:
            self.model.Af[rxn].fix()
            self.model.Ef[rxn].fix()
            self.model.dH[rxn].fix()
            self.model.dS[rxn].fix()
            self.rxn_list[rxn]["fixed"]=True

    # Function to unfix a specified reaction
    def unfix_reaction(self, rxn):
        if rxn in self.model.arrhenius_rxns:
            self.model.A[rxn].unfix()
            self.model.B[rxn].unfix()
            self.model.E[rxn].unfix()
            self.rxn_list[rxn]["fixed"]=False
        if rxn in self.model.equ_arrhenius_rxns:
            self.model.Af[rxn].unfix()
            self.model.Ef[rxn].unfix()
            self.model.dH[rxn].unfix()
            self.model.dS[rxn].unfix()
            self.rxn_list[rxn]["fixed"]=False

    # Function to fix all equilibrium relations
    def fix_all_equilibrium_relations(self):
        for re in self.model.equ_arrhenius_rxns:
            self.model.dH[re].fix()
            self.model.dS[re].fix()
            self.rxn_list[re]["fixed"]=True

    # Function to fix a given equilibrium relation
    def fix_equilibrium_relation(self, rxn):
        if rxn in self.model.equ_arrhenius_rxns:
            self.model.dH[rxn].fix()
            self.model.dS[rxn].fix()
            self.rxn_list[rxn]["fixed"]=True

    # Function to initialize automatic scaling
    #       This function is not required, but in
    #       practice, should be called before running
    #       the 'initialize_simulator' function below
    def initialize_auto_scaling(self, scale_to=1):
        for spec in self.model.gas_set:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    if self.isBoundarySet[spec][age][temp] == False:
                        raise Exception("Error! Must specify boundaries before attempting to initialize scaling. "
                                        +str(spec)+","+str(age)+","+str(temp)+ " given does not have BCs set")

        self.model.scaling_factor = Suffix(direction=Suffix.EXPORT)

        # set initial scaling factor to inverse of max values
        maxkey = max(self.model.Cb.get_values(), key=self.model.Cb.get_values().get)
        maxval = self.model.Cb[maxkey].value
        self.model.scaling_factor.set_value(self.model.Cb, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.C, scale_to/maxval)

        # set scaling for surface species and sites
        if self.isSurfSpecSet == True:
            if self.isSitesSet == True:
                maxkey = max(self.model.Smax.extract_values(), key=self.model.Smax.extract_values().get)
                maxval = self.model.Smax[maxkey].value
                self.model.scaling_factor.set_value(self.model.q, scale_to/maxval)
                self.model.scaling_factor.set_value(self.model.S, scale_to/maxval)
            else:
                maxkey = max(self.model.q.get_values(), key=self.model.q.get_values().get)
                maxval = self.model.q[maxkey].value
                if maxval < 1e-10:
                    maxval = 1
                self.model.scaling_factor.set_value(self.model.q, scale_to/maxval)

        # set scaling for reaction variables
        for r in self.model.arrhenius_rxns:
            Aval = self.model.A[r].value
            if Aval < 1e-6:
                Aval = 1
            self.model.scaling_factor.set_value(self.model.A[r], 1/Aval)

            Bval = abs(self.model.B[r].value)
            if Bval < 1e-2:
                Bval = 1
            self.model.scaling_factor.set_value(self.model.B[r], 1/Bval)

            Eval = abs(self.model.E[r].value)
            if Eval < 1e-2:
                Eval = 1
            self.model.scaling_factor.set_value(self.model.E[r], 1/Eval)
        for re in self.model.equ_arrhenius_rxns:
            Aval = self.model.Af[re].value
            if Aval < 1e-6:
                Aval = 1
            self.model.scaling_factor.set_value(self.model.Af[re], 1/Aval)

            Eval = abs(self.model.Ef[re].value)
            if Eval < 1e-2:
                Eval = 1
            self.model.scaling_factor.set_value(self.model.Ef[re], 1/Eval)

            dHval = abs(self.model.dH[re].value)
            if dHval < 1e-2:
                dHval = 1
            self.model.scaling_factor.set_value(self.model.dH[re], 1/dHval)

            dSval = abs(self.model.dS[re].value)
            if dSval < 1e-2:
                dSval = 1
            self.model.scaling_factor.set_value(self.model.dS[re], 1/dSval)

        # set scaling for bulk constraints
        maxval = 0
        for key in self.model.bulk_cons:
            newval = abs(value(self.model.bulk_cons[key]))
            if newval > maxval:
                maxval = newval
        if maxval < 1e-5:
            maxval = 1e-5
        self.model.scaling_factor.set_value(self.model.bulk_cons, scale_to/maxval)

        # set scaling for pore constraints
        maxval = 0
        for key in self.model.pore_cons:
            newval = abs(value(self.model.pore_cons[key]))
            if newval > maxval:
                maxval = newval
        if maxval < 1e-5:
            maxval = 1e-5
        self.model.scaling_factor.set_value(self.model.pore_cons, scale_to/maxval)

        # set scaling for surf constraints
        if self.isSurfSpecSet == True:
            if self.isSitesSet == True:
                maxval = 0
                for key in self.model.site_cons:
                    newval = abs(value(self.model.site_cons[key]))
                    if newval > maxval:
                        maxval = newval
                if maxval < 1e-2:
                    maxval = 1e-2
                self.model.scaling_factor.set_value(self.model.site_cons, scale_to/maxval)
                self.model.scaling_factor.set_value(self.model.surf_cons, scale_to/maxval)
            else:
                maxval = 0
                for key in self.model.surf_cons:
                    newval = abs(value(self.model.surf_cons[key]))
                    if newval > maxval:
                        maxval = newval
                if maxval < 1e-2:
                    maxval = 1e-2
                self.model.scaling_factor.set_value(self.model.surf_cons, scale_to/maxval)

        # set scaling for derivative variables and constraints
        maxval = 0
        for key in self.model.dCb_dz_disc_eq:
            newval = abs(value(self.model.dCb_dz_disc_eq[key]))
            if newval > maxval:
                maxval = newval
        if maxval < 1e-5:
            maxval = 1e-5
        self.model.scaling_factor.set_value(self.model.dCb_dz_disc_eq, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.dCb_dz, scale_to/maxval)
        if self.DiscType == "DiscretizationMethod.FiniteDifference":
            self.model.scaling_factor.set_value(self.model.dCbdz_edge, scale_to/maxval)

        maxval = 0
        for key in self.model.dCb_dt_disc_eq:
            newval = abs(value(self.model.dCb_dt_disc_eq[key]))
            if newval > maxval:
                maxval = newval
        if maxval < 1e-5:
            maxval = 1e-5
        self.model.scaling_factor.set_value(self.model.dCb_dt_disc_eq, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.dCb_dt, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.dC_dt_disc_eq, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.dC_dt, scale_to/maxval)

        # surface and site constraints for derivatives
        if self.isSurfSpecSet == True:
            maxval = 0
            for key in self.model.dq_dt_disc_eq:
                newval = abs(value(self.model.dq_dt_disc_eq[key]))
                if newval > maxval:
                    maxval = newval
            if maxval < 1e-2:
                maxval = 1e-2
            self.model.scaling_factor.set_value(self.model.dq_dt_disc_eq, scale_to/maxval)
            self.model.scaling_factor.set_value(self.model.dq_dt, scale_to/maxval)


    # Function to finialize the scaling of system variables
    def finalize_auto_scaling(self, scale_to=1, obj_scale_to=1):
        if self.isInitialized == False:
            raise Exception("Error! Cannot automate final variable scaling if variables not initialized")

        self.rescaleConstraint = False
        # add the scaling_factor if it doesn't already exist
        if self.model.find_component('scaling_factor'):
            self.rescaleConstraint = False
        else:
            self.rescaleConstraint = True
            self.model.scaling_factor = Suffix(direction=Suffix.EXPORT)

        # set scaling for objective function
        if self.isObjectiveSet == True:
            maxobj = value(self.model.obj)
            if maxobj >= 100:
                self.model.scaling_factor.set_value(self.model.obj, obj_scale_to )
            else:
                self.model.scaling_factor.set_value(self.model.obj, obj_scale_to/(maxobj) )
        else:
            if self.rescaleConstraint == False:
                return

        # Reset constraints for variables and derivative variables
        #       NOT for the constraints though (these should not be rescaled)
        maxkey = max(self.model.Cb.get_values(), key=self.model.Cb.get_values().get)
        maxval = self.model.Cb[maxkey].value
        self.model.scaling_factor.set_value(self.model.Cb, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.C, scale_to/maxval)

        # set scaling for surface species and sites
        if self.isSurfSpecSet == True:
            maxkey = max(self.model.q.get_values(), key=self.model.q.get_values().get)
            maxval = self.model.q[maxkey].value
            if maxval < 1e-10:
                maxval = 1
            self.model.scaling_factor.set_value(self.model.q, scale_to/maxval)

            if self.isSitesSet == True:
                maxkey = max(self.model.S.get_values(), key=self.model.S.get_values().get)
                maxval = self.model.S[maxkey].value
                self.model.scaling_factor.set_value(self.model.S, scale_to/maxval)

        # set scaling for derivative vars
        maxkey = max(self.model.dCb_dz.get_values(), key=self.model.dCb_dz.get_values().get)
        minkey = min(self.model.dCb_dz.get_values(), key=self.model.dCb_dz.get_values().get)

        if abs(self.model.dCb_dz[maxkey].value) >= abs(self.model.dCb_dz[minkey].value):
            maxval = abs(self.model.dCb_dz[maxkey].value)
        else:
            maxval = abs(self.model.dCb_dz[minkey].value)
        self.model.scaling_factor.set_value(self.model.dCb_dz, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.dCb_dz_disc_eq, scale_to/maxval)
        if self.DiscType == "DiscretizationMethod.FiniteDifference":
            self.model.scaling_factor.set_value(self.model.dCbdz_edge, scale_to/maxval)

        maxkey = max(self.model.dCb_dt.get_values(), key=self.model.dCb_dt.get_values().get)
        minkey = min(self.model.dCb_dt.get_values(), key=self.model.dCb_dt.get_values().get)

        if abs(self.model.dCb_dt[maxkey].value) >= abs(self.model.dCb_dt[minkey].value):
            maxval = abs(self.model.dCb_dt[maxkey].value)
        else:
            maxval = abs(self.model.dCb_dt[minkey].value)
        self.model.scaling_factor.set_value(self.model.dCb_dt, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.dCb_dt_disc_eq, scale_to/maxval)

        maxkey = max(self.model.dC_dt.get_values(), key=self.model.dC_dt.get_values().get)
        minkey = min(self.model.dC_dt.get_values(), key=self.model.dC_dt.get_values().get)

        if abs(self.model.dC_dt[maxkey].value) >= abs(self.model.dC_dt[minkey].value):
            maxval = abs(self.model.dC_dt[maxkey].value)
        else:
            maxval = abs(self.model.dC_dt[minkey].value)
        self.model.scaling_factor.set_value(self.model.dC_dt, scale_to/maxval)
        self.model.scaling_factor.set_value(self.model.dC_dt_disc_eq, scale_to/maxval)

        if self.isSurfSpecSet == True:
            maxkey = max(self.model.dq_dt.get_values(), key=self.model.dq_dt.get_values().get)
            minkey = min(self.model.dq_dt.get_values(), key=self.model.dq_dt.get_values().get)

            if abs(self.model.dq_dt[maxkey].value) >= abs(self.model.dq_dt[minkey].value):
                maxval = abs(self.model.dq_dt[maxkey].value)
            else:
                maxval = abs(self.model.dq_dt[minkey].value)
            self.model.scaling_factor.set_value(self.model.dq_dt, scale_to/maxval)
            self.model.scaling_factor.set_value(self.model.dq_dt_disc_eq, scale_to/maxval)


        # Rescale the parameters just in case
        # set scaling for reaction variables
        for r in self.model.arrhenius_rxns:
            Aval = self.model.A[r].value
            if Aval < 1e-6:
                Aval = 1
            self.model.scaling_factor.set_value(self.model.A[r], 1/Aval)

            Bval = abs(self.model.B[r].value)
            if Bval < 1e-2:
                Bval = 1
            self.model.scaling_factor.set_value(self.model.B[r], 1/Bval)

            Eval = abs(self.model.E[r].value)
            if Eval < 1e-2:
                Eval = 1
            self.model.scaling_factor.set_value(self.model.E[r], 1/Eval)
        for re in self.model.equ_arrhenius_rxns:
            Aval = self.model.Af[re].value
            if Aval < 1e-6:
                Aval = 1
            self.model.scaling_factor.set_value(self.model.Af[re], 1/Aval)

            Eval = abs(self.model.Ef[re].value)
            if Eval < 1e-2:
                Eval = 1
            self.model.scaling_factor.set_value(self.model.Ef[re], 1/Eval)

            dHval = abs(self.model.dH[re].value)
            if dHval < 1e-2:
                dHval = 1
            self.model.scaling_factor.set_value(self.model.dH[re], 1/dHval)

            dSval = abs(self.model.dS[re].value)
            if dSval < 1e-2:
                dSval = 1
            self.model.scaling_factor.set_value(self.model.dS[re], 1/dSval)


        # Only rescale constraints if they were not scaled before
        if self.rescaleConstraint == True:
            # set scaling for bulk constraints
            maxval = 0
            for key in self.model.bulk_cons:
                newval = abs(value(self.model.bulk_cons[key]))
                if newval > maxval:
                    maxval = newval
            if maxval < 1e-5:
                maxval = 1e-5
            self.model.scaling_factor.set_value(self.model.bulk_cons, scale_to/maxval)

            # set scaling for pore constraints
            maxval = 0
            for key in self.model.pore_cons:
                newval = abs(value(self.model.pore_cons[key]))
                if newval > maxval:
                    maxval = newval
            if maxval < 1e-5:
                maxval = 1e-5
            self.model.scaling_factor.set_value(self.model.pore_cons, scale_to/maxval)

            # set scaling for surf constraints
            if self.isSurfSpecSet == True:
                if self.isSitesSet == True:
                    maxval = 0
                    for key in self.model.site_cons:
                        newval = abs(value(self.model.site_cons[key]))
                        if newval > maxval:
                            maxval = newval
                    if maxval < 1e-2:
                        maxval = 1e-2
                    self.model.scaling_factor.set_value(self.model.site_cons, scale_to/maxval)
                    self.model.scaling_factor.set_value(self.model.surf_cons, scale_to/maxval)
                else:
                    maxval = 0
                    for key in self.model.surf_cons:
                        newval = abs(value(self.model.surf_cons[key]))
                        if newval > maxval:
                            maxval = newval
                    if maxval < 1e-2:
                        maxval = 1e-2
                    self.model.scaling_factor.set_value(self.model.surf_cons, scale_to/maxval)


    # Helper function to establish a guess based on another time step
    #       This is a helper function that will use the information
    #       of the model at 'time_ref' (for the same age and temp)
    #       to guess the solution at 'time_solve' for all model
    #       variables.
    def _initial_guesser(self, age_solve, temp_solve, time_solve, time_ref):
        for spec in self.model.gas_set:
            for loc in self.model.z:
                if loc != self.model.z.first():
                    self.model.Cb[spec, age_solve, temp_solve, loc, time_solve].set_value(self.model.Cb[spec, age_solve, temp_solve, loc, time_ref].value)
                self.model.C[spec, age_solve, temp_solve, loc, time_solve].set_value(self.model.C[spec, age_solve, temp_solve, loc, time_ref].value)
        if self.isSurfSpecSet == True:
            for spec in self.model.surf_set:
                for loc in self.model.z:
                    self.model.q[spec, age_solve, temp_solve, loc, time_solve].set_value(self.model.q[spec, age_solve, temp_solve, loc, time_ref].value)
            if self.isSitesSet == True:
                for spec in self.model.site_set:
                    for loc in self.model.z:
                        self.model.S[spec, age_solve, temp_solve, loc, time_solve].set_value(self.model.S[spec, age_solve, temp_solve, loc, time_ref].value)

    # Function to initilize the simulator
    def initialize_simulator(self, console_out=False, options={'print_user_options': 'yes',
                                                    'linear_solver': LinearSolverMethod.MA27,
                                                    'tol': 1e-8,
                                                    'acceptable_tol': 1e-8,
                                                    'compl_inf_tol': 1e-8,
                                                    'constr_viol_tol': 1e-8,
                                                    'max_iter': 3000,
                                                    'obj_scaling_factor': 1,
                                                    'diverging_iterates_tol': 1e50},
                                                    restart_on_warning=False,
                                                    restart_on_error=False,
                                                    use_old_times=False):
        for spec in self.model.gas_set:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    if self.isBoundarySet[spec][age][temp] == False:
                        raise Exception("Error! Must specify boundaries before attempting to solve. "
                                        +str(spec)+","+str(age)+","+str(temp)+" given does not have BCs set")
        if self.isSurfSpecSet == True:
            for spec in self.model.surf_set:
                for age in self.model.age_set:
                    for temp in self.model.T_set:
                        if self.isInitialSet[spec][age][temp] == False:
                            raise Exception("Error! Must specify initial conditions before attempting to solve. "
                                            +str(spec)+","+str(age)+","+str(temp)+" given does not have ICs set")

        if self.isIsothermalTempSet == False:
            raise Exception("Error! Cannot initialize if temperatures are not set first")

        if self.isVelocityRecalculated == False:
            self.recalculate_linear_velocities(interally_called=True,isMonolith=self.isMonolith)

        # Setup a dictionary to determine which reaction to unfix after solve
        self.initialize_time = TIME.time()
        fixed_dict = {}
        for rxn in self.rxn_list:
            fixed_dict[rxn]=self.rxn_list[rxn]["fixed"]
        self.fix_all_reactions()

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

        if self.isSurfSpecSet == True:
            self.model.q[:, :, :, :, :].fix()
            self.model.dq_dt[:, :, :, :, :].fix()
            self.model.surf_cons[:, :, :, :, :].deactivate()
            self.model.dq_dt_disc_eq[:, :, :, :, :].deactivate()

            if self.isSitesSet == True:
                self.model.S[:, :, :, :, :].fix()
                self.model.site_cons[:, :, :, :, :].deactivate()

        # Loops over specific sub-problems to solve
        age_solve_old = self.model.age_set.first()
        temp_solve_old = self.model.T_set.first()
        time_solve_old = self.model.t.first()
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

                        #Inside age_solve, temp_solve, and time_solve
                        solver = SolverFactory('ipopt')
                        #solver = SolverFactory('multistart')
                        #solver = SolverFactory('trustregion')

                        # Check user options
                        for item in options:
                            solver.options[item] = options[item]
                        if 'print_user_options' in options:
                            if options['print_user_options'] == "yes":
                                solver.options['print_user_options'] = options['print_user_options']
                        else:
                            solver.options['print_user_options'] = 'yes'
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
                                raise Exception("\nNOTE: 'MA' solvers only available if 'idaes' environment is used...")
                        else:
                            if "idaes" not in os.environ['CONDA_DEFAULT_ENV']:
                                solver.options['linear_solver'] = 'mumps'
                            else:
                                solver.options['linear_solver'] = 'ma97'
                        if 'tol' in options:
                            solver.options['tol'] = options['tol']
                        else:
                            solver.options['tol'] = 1e-8
                        if 'acceptable_tol' in options:
                            solver.options['acceptable_tol'] = options['acceptable_tol']
                        else:
                            solver.options['acceptable_tol'] = 1e-8
                        if 'compl_inf_tol' in options:
                            solver.options['compl_inf_tol'] = options['compl_inf_tol']
                        else:
                            solver.options['compl_inf_tol'] = 1e-8
                        if 'constr_viol_tol' in options:
                            solver.options['constr_viol_tol'] = options['constr_viol_tol']
                        else:
                            solver.options['constr_viol_tol'] = 1e-8
                        if 'max_iter' in options:
                            solver.options['max_iter'] = options['max_iter']
                        else:
                            solver.options['max_iter'] = 3000
                        if 'obj_scaling_factor' in options:
                            solver.options['obj_scaling_factor'] = options['obj_scaling_factor']
                        else:
                            solver.options['obj_scaling_factor'] = 1
                        if 'diverging_iterates_tol' in options:
                            solver.options['diverging_iterates_tol'] = options['diverging_iterates_tol']
                        else:
                            solver.options['diverging_iterates_tol'] = 1e50
                        if 'warm_start_init_point' in options:
                            solver.options['warm_start_init_point'] = options['warm_start_init_point']
                        else:
                            solver.options['warm_start_init_point'] = 'yes'

                        # Run solver (tighten the bounds to force good solutions) (1e-4 was old)
                        solver.options['bound_push'] = 1e-6
                        solver.options['bound_frac'] = 1e-6
                        solver.options['mu_init'] = 1e-2
                        solver.options['slack_bound_push'] = 1e-6
                        solver.options['slack_bound_frac'] = 1e-6
                        solver.options['warm_start_init_point'] = 'yes'

                        if self.model.find_component('scaling_factor'):
                            solver.options['nlp_scaling_method'] = 'user-scaling'
                        else:
                            solver.options['nlp_scaling_method'] = 'gradient-based'

                        if use_old_times == True:
                            self._initial_guesser(age_solve, temp_solve, time_solve, time_solve_old)
                            solver.options['nlp_scaling_method'] = 'gradient-based'

                        results = solver.solve(self.model, tee=console_out, load_solutions=False)
                        if results.solver.status == SolverStatus.ok:
                            self.model.solutions.load_from(results)
                        elif results.solver.status == SolverStatus.warning:
                            if restart_on_warning == False:
                                print("WARNING: Solver did not exit normally at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                print("\tResults are loaded, but need to be checked")
                                self.model.solutions.load_from(results)
                            else:
                                print("WARNING: Solver did not exit normally at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                print("\tAttempting to correct with restart...")
                                #Establish initial guess
                                self._initial_guesser(age_solve, temp_solve, time_solve, time_solve_old)

                                #After initial guess, rerun solver
                                if solver.options['nlp_scaling_method'] == 'user-scaling':
                                    solver.options['nlp_scaling_method'] = 'gradient-based'
                                else:
                                    if self.model.find_component('scaling_factor'):
                                        solver.options['nlp_scaling_method'] = 'user-scaling'
                                results = solver.solve(self.model, tee=console_out, load_solutions=False)

                                if results.solver.status == SolverStatus.ok:
                                    self.model.solutions.load_from(results)
                                    print("\tCorrection success!")
                                elif results.solver.status == SolverStatus.warning:
                                    print("\tSame issue persists...")
                                    print("\tResults are loaded, but need to be checked")
                                    self.model.solutions.load_from(results)
                                else:
                                    #self.model.solutions.load_from(results)
                                    print("An Error has occurred at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                    print("\tStatus: " + str(results.solver.status))
                                    print("\tTermination Condition: " + str(results.solver.termination_condition))
                                    return (results.solver.status, results.solver.termination_condition)

                        else:
                            if restart_on_error == False:
                                #self.model.solutions.load_from(results)
                                print("An Error has occurred at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                print("\tStatus: " + str(results.solver.status))
                                print("\tTermination Condition: " + str(results.solver.termination_condition))
                                return (results.solver.status, results.solver.termination_condition)
                            else:
                                print("An Error has occurred at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                print("\tAttempting to recover with restart...")
                                #Establish initial guess
                                self._initial_guesser(age_solve, temp_solve, time_solve, time_solve_old)

                                #After initial guess, rerun solver
                                if solver.options['nlp_scaling_method'] == 'user-scaling':
                                    solver.options['nlp_scaling_method'] = 'gradient-based'
                                else:
                                    if self.model.find_component('scaling_factor'):
                                        solver.options['nlp_scaling_method'] = 'user-scaling'
                                results = solver.solve(self.model, tee=console_out, load_solutions=False)

                                if results.solver.status == SolverStatus.ok:
                                    self.model.solutions.load_from(results)
                                    print("\tRecovery success!")
                                elif results.solver.status == SolverStatus.warning:
                                    print("\tWARNING: Solver did not exit normally at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                    print("\tResults are loaded, but need to be checked")
                                    self.model.solutions.load_from(results)
                                else:
                                    #self.model.solutions.load_from(results)
                                    print("\tUnable to recover...")
                                    print("An Error has occurred at (" + str(age_solve) + ", " + str(temp_solve) + ", " + str(time_solve) + ")")
                                    print("\tStatus: " + str(results.solver.status))
                                    print("\tTermination Condition: " + str(results.solver.termination_condition))
                                    return (results.solver.status, results.solver.termination_condition)

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
                    time_solve_old = time_solve
                # End time_solve loop
                temp_solve_old = temp_solve
            # End temp_solve loop
            age_solve_old = age_solve
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

        # Add objective function back
        if self.isObjectiveSet == True:
            self.model.obj.activate()

        # After solve, unfix specified reactions
        for rxn in fixed_dict:
            if fixed_dict[rxn] == False:
                self.unfix_reaction(rxn)

        self.isInitialized = True
        self.initialize_time = (TIME.time() - self.initialize_time)
        return (results.solver.status, results.solver.termination_condition)
        # End Initializer

    # Function to run the solver
    def run_solver(self, console_out=True, options={'print_user_options': 'yes',
                                                    'linear_solver': LinearSolverMethod.MA97,
                                                    'tol': 1e-6,
                                                    'acceptable_tol': 1e-6,
                                                    'compl_inf_tol': 1e-6,
                                                    'constr_viol_tol': 1e-6,
                                                    'max_iter': 3000,
                                                    'obj_scaling_factor': 1,
                                                    'diverging_iterates_tol': 1e50}):
        for spec in self.model.gas_set:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    if self.isBoundarySet[spec][age][temp] == False:
                        raise Exception("Error! Must specify boundaries before attempting to solve. "
                                        +str(spec)+","+str(age)+","+str(temp)+" given does not have BCs set")
        if self.isSurfSpecSet == True:
            for spec in self.model.surf_set:
                for age in self.model.age_set:
                    for temp in self.model.T_set:
                        if self.isInitialSet[spec][age][temp] == False:
                            raise Exception("Error! Must specify initial conditions before attempting to solve. "
                                            +str(spec)+","+str(age)+","+str(temp)+" given does not have ICs set")

        if self.isIsothermalTempSet == False:
            raise Exception("Error! Cannot solve if temperatures are not set first")

        if self.isObjectiveSet == False:
            print("Warning! No objective function set. Forcing all kinetics to be fixed.")
            self.fix_all_reactions()
        if self.isVelocityRecalculated == False:
            self.recalculate_linear_velocities(interally_called=True,isMonolith=self.isMonolith)
        self.solve_time = TIME.time()

        solver = SolverFactory('ipopt')

        # Check user options
        for item in options:
            solver.options[item] = options[item]
        if 'print_user_options' in options:
            if options['print_user_options'] == "yes":
                solver.options['print_user_options'] = options['print_user_options']
        else:
            solver.options['print_user_options'] = 'yes'
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
                raise Exception("\nNOTE: 'MA' solvers only available if 'idaes' environment is used...")
        else:
            if "idaes" not in os.environ['CONDA_DEFAULT_ENV']:
                solver.options['linear_solver'] = 'mumps'
            else:
                solver.options['linear_solver'] = 'ma97'
        if 'tol' in options:
            solver.options['tol'] = options['tol']
        else:
            solver.options['tol'] = 1e-6
        if 'acceptable_tol' in options:
            solver.options['acceptable_tol'] = options['acceptable_tol']
        else:
            solver.options['acceptable_tol'] = 1e-6
        if 'compl_inf_tol' in options:
            solver.options['compl_inf_tol'] = options['compl_inf_tol']
        else:
            solver.options['compl_inf_tol'] = 1e-6
        if 'constr_viol_tol' in options:
            solver.options['constr_viol_tol'] = options['constr_viol_tol']
        else:
            solver.options['constr_viol_tol'] = 1e-6
        if 'max_iter' in options:
            solver.options['max_iter'] = options['max_iter']
        else:
            solver.options['max_iter'] = 3000
        if 'obj_scaling_factor' in options:
            solver.options['obj_scaling_factor'] = options['obj_scaling_factor']
        else:
            solver.options['obj_scaling_factor'] = 1
        if 'diverging_iterates_tol' in options:
            solver.options['diverging_iterates_tol'] = options['diverging_iterates_tol']
        else:
            solver.options['diverging_iterates_tol'] = 1e50
        if 'warm_start_init_point' in options:
            solver.options['warm_start_init_point'] = options['warm_start_init_point']
        else:
            solver.options['warm_start_init_point'] = 'yes'

        # Call the solver
        if self.isInitialized == True:
            # MORE INFO: https://coin-or.github.io/Ipopt/OPTIONS.html
            # -------------------------------------------------------
            #       Check out the 'Initializer' section for ipopt options
            #   If we have already initialized the solution, then we are already
            #   at (or very close to) the solution to the problem. However, ipopt
            #   does NOT like starting variables that are near the boundaries
            #   of the optimization problem. Thus, we need to tell ipopt to not
            #   change the initial values (at least not by much). To do that,
            #   we are forced to specify very small numbers for 'bound_frac' and
            #   'bound_push'. Otherwise, ipopt will essentially through out all
            #   the hard work that our custom initializer does. (1e-6 or 1e-8 was old)
            solver.options['bound_push'] = 1e-10
            solver.options['bound_frac'] = 1e-10
            solver.options['mu_init'] = 1e-4
            solver.options['slack_bound_push'] = 1e-10
            solver.options['slack_bound_frac'] = 1e-10
            solver.options['warm_start_init_point'] = 'yes'

            # Strictly enfore to ipopt that the variables are not to move
            #       from their given initial states. This is needed if the
            #       objective function is set because of how complex it is
            #       for the model to converge when changing kinetic parameters.
            if self.isObjectiveSet == True:
                solver.options['bound_push'] = 1e-16
                solver.options['bound_frac'] = 1e-16
                solver.options['mu_init'] = 1e-4
                solver.options['slack_bound_push'] = 1e-16
                solver.options['slack_bound_frac'] = 1e-16
                solver.options['warm_start_init_point'] = 'yes'

        # Check if model has scaling factors
        if self.model.find_component('scaling_factor'):
            solver.options['nlp_scaling_method'] = 'user-scaling'
        else:
            solver.options['nlp_scaling_method'] = 'gradient-based'

        results = solver.solve(self.model, tee=console_out, load_solutions=False)
        if results.solver.status == SolverStatus.ok:
            self.model.solutions.load_from(results)
        elif results.solver.status == SolverStatus.warning:
            print("WARNING: Solver did not exit normally...")
            print("\tResults are loaded, but need to be checked")
            self.model.solutions.load_from(results)
        else:
            try:
                self.model.solutions.load_from(results)
            except:
                pass
            print("An Error has occurred!")
            print("\tStatus: " + str(results.solver.status))
            print("\tTermination Condition: " + str(results.solver.termination_condition))

        self.solve_time = (TIME.time() - self.solve_time)

        print("\nModel Statistics")
        print("-----------------")
        print("\tBuild Time (s)      = " + str(self.build_time))
        print("\tInitialize Time (s) = " + str(self.initialize_time))
        print("\tSolve Time (s)      = " + str(self.solve_time))
        print()
        return (results.solver.status, results.solver.termination_condition)


    # Function to print out results of variables at all locations and times
    def print_results_all_locations(self, spec_list, age, temp, file_name="", include_temp=False):
        if type(spec_list) is not list:
            raise Exception("Error! Need to provide species as a list (even if it is just one species)")
        for spec in spec_list:
            if spec not in self.model.all_species_set:
                print("Error! Invalid species given!")
                raise Exception("\t"+str(spec)+ " is not a species in the model")
        if file_name == "":
            for spec in spec_list:
                file_name+=spec+"_"
            file_name+=str(age)+"_"+str(temp)+"_"
            file_name+="all_loc"
            file_name+=".txt"

        folder="output/"
        if not os.path.exists(folder):
            os.makedirs(folder)

        file = open(folder+file_name,"w")

        # Embeddd helper function
        def _print_all_results(model, var, spec, age, temp, file, isTemp=False):
            tstart = model.t.first()
            tend = model.t.last()

            #Print header first
            file.write('\t'+'Times (across)'+'\n')
            for time in model.t:
            	if time == tend:
            		file.write(str(time)+'\n')
            	elif time == tstart:
            		file.write('time ->\t'+str(time)+'\t')
            	else:
            		file.write(str(time)+'\t')

            for time in model.t:
            	if time == tend:
            		file.write(str(var)+'[@t='+str(time)+']\n')
            	elif time == tstart:
            		file.write('Z (down)\t'+str(var)+'[@t='+str(time)+']\t')
            	else:
            		file.write(str(var)+'[@t='+str(time)+']\t')

            #Print x results
            for loc in model.z:
                for time in model.t:
                    if time == tstart:
                        if isTemp == False:
                            file.write(str(loc)+'\t'+str(value(var[spec,age,temp,loc,time]))+'\t')
                        else:
                            file.write(str(loc)+'\t'+str(value(var[age,temp,loc,time]))+'\t')
                    elif time == tend:
                        if isTemp == False:
                            file.write(str(value(var[spec,age,temp,loc,time]))+'\n')
                        else:
                            file.write(str(value(var[age,temp,loc,time]))+'\n')
                    else:
                        if isTemp == False:
                            file.write(str(value(var[spec,age,temp,loc,time]))+'\t')
                        else:
                            file.write(str(value(var[age,temp,loc,time]))+'\t')
            file.write('\n')

        for spec in spec_list:
            if spec in self.model.gas_set:
                file.write('Results for bulk '+str(spec)+'_b in table below'+'\n')
                _print_all_results(self.model, self.model.Cb, spec, age, temp, file)
                file.write('Results for washcoat '+str(spec)+'_w in table below'+'\n')
                _print_all_results(self.model, self.model.C, spec, age, temp, file)
            elif spec in self.model.surf_set:
                file.write('Results for surface '+str(spec)+' in table below'+'\n')
                _print_all_results(self.model, self.model.q, spec, age, temp, file)
            else:
                file.write('Results for site '+str(spec)+' in table below'+'\n')
                _print_all_results(self.model, self.model.S, spec, age, temp, file)
        if include_temp == True:
            file.write('Results for temperature in the table below'+'\n')
            _print_all_results(self.model, self.model.T, None, age, temp, file, include_temp)

        file.write('\n')
        file.close()

    # Function to print a list of species at a given node for all times
    def print_results_of_location(self, spec_list, age, temp, loc, file_name="", include_temp=False):
        if type(spec_list) is not list:
            raise Exception("Error! Need to provide species as a list (even if it is just one species)")
        for spec in spec_list:
            if spec not in self.model.all_species_set:
                print("Error! Invalid species given!")
                raise Exception("\t"+str(spec)+ " is not a species in the model")
        if file_name == "":
            for spec in spec_list:
                file_name+=spec+"_"
            file_name+=str(age)+"_"+str(temp)+"_"
            file_name+="loc_z_at_"+str(loc)
            file_name+=".txt"

        folder="output/"
        if not os.path.exists(folder):
            os.makedirs(folder)

        file = open(folder+file_name,"w")

        file.write('Results for z='+str(loc)+' at in table below'+'\n')
        file.write('Time\t')
        for spec in spec_list:
            if spec in self.model.gas_set:
                file.write(str(spec)+'_b\t'+str(spec)+'_w\t')
            elif spec in self.model.surf_set:
                file.write(str(spec)+'\t')
            else:
                file.write(str(spec)+'\t')
        if include_temp == True:
            file.write("T[K]"+'\t')
        file.write('\n')
        for time in self.model.t:
            file.write(str(time) + '\t')
            for spec in spec_list:
                if spec in self.model.gas_set:
                    file.write(str(value(self.model.Cb[spec,age,temp,loc,time])) + '\t' + str(value(self.model.C[spec,age,temp,loc,time])) + '\t')
                elif spec in self.model.surf_set:
                    file.write(str(value(self.model.q[spec,age,temp,loc,time])) + '\t')
                else:
                    file.write(str(value(self.model.S[spec,age,temp,loc,time])) + '\t')
            if include_temp == True:
                file.write(str(value(self.model.T[age,temp,loc,time])) + '\t')
            file.write('\n')
        file.write('\n')
        file.close()


    # Function to print a list of species at the exit of the domain
    def print_results_of_breakthrough(self, spec_list, age, temp, file_name="", include_temp=False):
        self.print_results_of_location(spec_list, age, temp, self.model.z.last(), file_name, include_temp)

    # Print integrated average results over domain for a species
    def print_results_of_integral_average(self, spec_list, age, temp, file_name=""):
        if type(spec_list) is not list:
            raise Exception("Error! Need to provide species as a list (even if it is just one species)")
        for spec in spec_list:
            if spec not in self.model.all_species_set:
                print("Error! Invalid species given!")
                raise Exception("\t"+str(spec)+ " is not a species in the model")
        if file_name == "":
            for spec in spec_list:
                file_name+=spec+"_"
            file_name+=str(age)+"_"+str(temp)+"_"
            file_name+="integral_avg"
            file_name+=".txt"

        folder="output/"
        if not os.path.exists(folder):
            os.makedirs(folder)

        file = open(folder+file_name,"w")

        file.write('Integral average results in table below'+'\n')
        file.write('Time\t')
        for spec in spec_list:
            if spec in self.model.gas_set:
                file.write(str(spec)+'_b\t'+str(spec)+'_w\t')
            elif spec in self.model.surf_set:
                file.write(str(spec)+'\t')
            else:
                file.write(str(spec)+'\t')
        file.write('\n')
        for time in self.model.t:
            file.write(str(time) + '\t')
            for spec in spec_list:
                if spec in self.model.gas_set:
                    #bulk variable
                    total = 0
                    i = 0
                    for loc in self.model.z:
                        if i == 0:
                            loc_old = loc
                        else:
                            total += (loc - loc_old)*0.5*(value(self.model.Cb[spec,age,temp,loc,time])+value(self.model.Cb[spec,age,temp,loc_old,time]))
                        i += 1
                        loc_old = loc
                    avg = total/(self.model.z.last()-self.model.z.first())
                    file.write(str(avg) + '\t')

                    # Washcoat variable
                    total = 0
                    i = 0
                    for loc in self.model.z:
                        if i == 0:
                            loc_old = loc
                        else:
                            total += (loc - loc_old)*0.5*(value(self.model.C[spec,age,temp,loc,time])+value(self.model.C[spec,age,temp,loc_old,time]))
                        i += 1
                        loc_old = loc
                    avg = total/(self.model.z.last()-self.model.z.first())
                    file.write(str(avg) + '\t')
                elif spec in self.model.surf_set:
                    total = 0
                    i = 0
                    for loc in self.model.z:
                        if i == 0:
                            loc_old = loc
                        else:
                            total += (loc - loc_old)*0.5*(value(self.model.q[spec,age,temp,loc,time])+value(self.model.q[spec,age,temp,loc_old,time]))
                        i += 1
                        loc_old = loc
                    avg = total/(self.model.z.last()-self.model.z.first())
                    file.write(str(avg) + '\t')
                else:
                    total = 0
                    i = 0
                    for loc in self.model.z:
                        if i == 0:
                            loc_old = loc
                        else:
                            total += (loc - loc_old)*0.5*(value(self.model.S[spec,age,temp,loc,time])+value(self.model.S[spec,age,temp,loc_old,time]))
                        i += 1
                        loc_old = loc
                    avg = total/(self.model.z.last()-self.model.z.first())
                    file.write(str(avg) + '\t')
            file.write('\n')
        file.write('\n')
        file.close()

    # Define a function to print optimal parameter information to a file
    def print_kinetic_parameter_info(self, file_name=""):
        if file_name == "":
            file_name+="parameter_info"
            file_name+=".txt"

        folder="output/"
        if not os.path.exists(folder):
            os.makedirs(folder)

        file = open(folder+file_name,"w")

        for rxn in self.model.all_rxns:
            line = rxn+" (moles / volume catalyst / time) = "
            if rxn in self.model.arrhenius_rxns:
                line+= "k_"+rxn+" * "
                spec_i=0
                for spec in self.model.component(rxn+"_reactants"):
                    if spec_i == 0:
                        line+= spec+"^("+str(self.model.rxn_orders[rxn,spec].value)+") "
                    else:
                        line+= "* "+spec+"^("+str(self.model.rxn_orders[rxn,spec].value)+") "
                    spec_i+=1
            elif rxn in self.model.equ_arrhenius_rxns:
                line+= "kf_"+rxn+" * "
                spec_i=0
                for spec in self.model.component(rxn+"_reactants"):
                    if spec_i == 0:
                        line+= spec+"^("+str(self.model.rxn_orders[rxn,spec].value)+") "
                    else:
                        line+= "* "+spec+"^("+str(self.model.rxn_orders[rxn,spec].value)+") "
                    spec_i+=1
                line+= "- kr_"+rxn+" * "
                spec_i=0
                for spec in self.model.component(rxn+"_products"):
                    if spec_i == 0:
                        line+= spec+"^("+str(self.model.rxn_orders[rxn,spec].value)+") "
                    else:
                        line+= "* "+spec+"^("+str(self.model.rxn_orders[rxn,spec].value)+") "
                    spec_i+=1
            else:
                raise Exception("Error! It should be impossible for you to get here... Ut oh...")
            file.write(line)
            file.write('\n')
            if rxn in self.model.arrhenius_rxns:
                file.write("\tk_"+rxn+" = A * T^B * exp[-E/R/T]")
                file.write('\n')
                file.write("\t  A (varies) =\t" + str(self.model.A[rxn].value))
                file.write('\n')
                file.write("\t  E (J/mol)  =\t" + str(self.model.E[rxn].value))
                file.write('\n')
                file.write("\t  B (None)   =\t" + str(self.model.B[rxn].value))
            elif rxn in self.model.equ_arrhenius_rxns:
                file.write("\tkf_"+rxn+" = Af * exp[-Ef/R/T]")
                file.write('\n')
                file.write("\tkr_"+rxn+" = Af * exp[-dS/R] * exp[-(Ef - dH)/R/T]")
                file.write('\n')
                file.write("\t  Af (varies)  =\t" + str(self.model.Af[rxn].value))
                file.write('\n')
                file.write("\t  Ef (J/mol)   =\t" + str(self.model.Ef[rxn].value))
                file.write('\n')
                file.write("\t  dH (J/mol)   =\t" + str(self.model.dH[rxn].value))
                file.write('\n')
                file.write("\t  dS (J/K/mol) =\t" + str(self.model.dS[rxn].value))
            else:
                pass
            file.write('\n')
            file.write('\n')

        file.close()


    # Define function to unload/save a model state
    def save_model_state(self, file_name=""):
        if file_name == "":
            file_name+="saved_iso_cat_model_"
            s = str(datetime.datetime.now()).split()
            file_name+=s[0]+"--"
            s2 = s[1].split(".")[0].split(":")
            file_name+=s2[0]+"-"+s2[1]+"-"+s2[2]
            file_name+=".json"

        folder="output/"
        if not os.path.exists(folder):
            os.makedirs(folder)

        file = open(folder+file_name,"w")

        # Now, create a dictionary in json based on current model state
        obj = {}
        # Adding time states to top of dictionary for user
        #   User will likely want to specify a time state at restart
        #   Most common will likely be the final state
        obj['valid_time_states_for_restart'] = self.model.t.get_finite_elements()
        for attr in dir(self):
            if not callable(getattr(self, attr)) and not attr.startswith("__"):
                if attr!='model' and attr!='rxn_list':
                    obj[attr] = getattr(self, attr)
                #Special treatment is needed for enums in dictionaries
                elif attr=='rxn_list':
                    obj[attr] = {}
                    for rxn in getattr(self, attr):
                        obj[attr][rxn] = {}
                        obj[attr][rxn]['fixed'] = getattr(self, attr)[rxn]['fixed']
                        obj[attr][rxn]['type'] = str(getattr(self, attr)[rxn]['type'])
                #Special treatment is needed for embedded pyomo objects
                else:
                    obj['model'] = {}
                    # Grab as much relevant pyomo model information as possible
                    #   WILL be required to rebuild constraints and rediscretize model
                    '''
                        Only will save minimum needed components to rebuild a model and
                        load states. Thus, there will be numerous items that get autobuilt
                        by pyomo that we will not include here. A custom load_state function
                        will be necessary to interpret the saved data. Unforetunately, I see
                        no current way to automate this.

                        Below is the list of model objects we will save
                        ------------------------------------------------
                            model.eb            scalar      Param
                            model.ew            scalar      Param
                            model.r             scalar      Param
                            model.Ga            scalar      Param
                            model.cell_density  scalar      Param
                            model.dh            scalar      Param
                            model.diff_factor   scalar      Param
                            model.z             list        ContinuousSet
                            model.z_data        list        Set
                            model.t             list        ContinuousSet
                            model.t_data        list        Set
                            model.t_data_full   list        Set
                            model.age_set       list        Set
                            model.data_age_set  list        Set
                            model.T_set         list        Set
                            model.T             dict        Var(age_set,T_set,t)
                            model.space_velocity dict       Var(age_set,T_set,t)
                            model.v             dict        Var(age_set,T_set,z,t)
                            model.P             dict        Var(age_set,T_set,z,t)
                            model.Tref          dict        Param(age_set,T_set)
                            model.Pref          dict        Param(age_set,T_set)
                            model.rho           dict        Var(age_set,T_set,z,t)
                            model.mu            dict        Var(age_set,T_set,z,t)
                            model.Re            dict        Var(age_set,T_set,z,t)
                            model.data_T_set    list        Set
                            model.gas_set       list        Set
                            model.Cb            dict        Var(gas_set,age_set,T_set,z,t)
                            model.C             dict        Var(gas_set,age_set,T_set,z,t)
                            model.dCb_dz        dict        DerivativeVar(gas_set,age_set,T_set,z,t)
                            model.dCb_dt        dict        DerivativeVar(gas_set,age_set,T_set,z,t)
                            model.dC_dt         dict        DerivativeVar(gas_set,age_set,T_set,z,t)
                            model.km            dict        Var(gas_set,age_set,T_set,z,t)
                            model.Dm            dict        Param(gas_set)
                            model.Sc            dict        Var(gas_set,age_set,T_set,z,t)
                            model.Sh            dict        Var(gas_set,age_set,T_set,z,t)
                            model.data_gas_set  list        Set
                            model.Cb_data       dict        Param(data_gas_set,data_age_set,data_T_set,z_data,t_data)
                            model.Cb_data_full  dict        Param(data_gas_set,data_age_set,data_T_set,z_data,t_data_full)
                            model.w             dict        Param(data_gas_set,data_age_set,data_T_set)
                            model.data_surface_set  list    Set
                            model.q_data        dict        Param(data_surface_set,data_age_set,data_T_set,z_data,t_data)
                            model.q_data_full   dict        Param(data_surface_set,data_age_set,data_T_set,z_data,t_data_full)
                            model.wq            dict        Param(data_surface_set,data_age_set,data_T_set)
                            model.surf_set      list        Set
                            model.q             dict        Var(surf_set,age_set,T_set,z,t)
                            model.dq_dt         dict        DerivativeVar(surf_set,age_set,T_set,z,t)
                            model.site_set      list        Set
                            model.S             dict        Var(site_set,age_set,T_set,z,t)
                            model.Smax          dict        Param(site_set,age_set,z,t)
                            model.u_S           dict        Param(site_set,surf_set)
                            model.all_rxns      list        Set
                            model.arrhenius_rxns list       Set
                            model.equ_arrhenius_rxns list   Set
                            model.u_C           dict        Param(gas_set,all_rxns,z)
                            model.u_q           dict        Param(surf_set,all_rxns,z)
                            model.A             dict        Var(arrhenius_rxns)
                            model.B             dict        Var(arrhenius_rxns)
                            model.E             dict        Var(arrhenius_rxns)
                            model.Af            dict        Var(equ_arrhenius_rxns)
                            model.Ef            dict        Var(equ_arrhenius_rxns)
                            model.dH            dict        Var(equ_arrhenius_rxns)
                            model.dS            dict        Var(equ_arrhenius_rxns)
                            model.all_species_set list      Set
                            model.rxn_orders    dict        Param(all_rxns,all_species_set)

                            model.add_component(rxn+"_reactants", Set(initialize=react_list))
                            model.add_component(rxn+"_products", Set(initialize=prod_list))
                    '''
                    obj['model']['eb'] = self.model.eb.value
                    obj['model']['ew'] = self.model.ew.value
                    obj['model']['r'] = self.model.r.value
                    obj['model']['Ga'] = self.model.Ga.value
                    obj['model']['cell_density'] = self.model.cell_density.value
                    obj['model']['dh'] = self.model.dh.value
                    obj['model']['diff_factor'] = self.model.diff_factor.value
                    obj['model']['z'] = self.model.z.get_finite_elements()
                    if self.isDataBoundsSet == True:
                        obj['model']['z_data'] = []
                        for item in self.model.z_data:
                            obj['model']['z_data'].append(item)
                    obj['model']['t'] = self.model.t.get_finite_elements()
                    if self.isDataTimesSet == True:
                        obj['model']['t_data'] = []
                        for item in self.model.t_data:
                            obj['model']['t_data'].append(item)
                        obj['model']['t_data_full'] = []
                        for item in self.model.t_data_full:
                            obj['model']['t_data_full'].append(item)

                    obj['model']['age_set'] = []
                    for item in self.model.age_set:
                        obj['model']['age_set'].append(item)

                    if self.isDataAgeSet == True:
                        obj['model']['data_age_set'] = []
                        for item in self.model.data_age_set:
                            obj['model']['data_age_set'].append(item)

                    obj['model']['T_set'] = []
                    for item in self.model.T_set:
                        obj['model']['T_set'].append(item)

                    if self.isDataTempSet == True:
                        obj['model']['data_T_set'] = []
                        for item in self.model.data_T_set:
                            obj['model']['data_T_set'].append(item)

                    obj['model']['gas_set'] = []
                    for item in self.model.gas_set:
                        obj['model']['gas_set'].append(item)

                    if self.isDataGasSpecSet == True:
                        obj['model']['data_gas_set'] = []
                        for item in self.model.data_gas_set:
                            obj['model']['data_gas_set'].append(item)

                    if self.isDataSurfSpecSet == True:
                        obj['model']['data_surface_set'] = []
                        for item in self.model.data_surface_set:
                            obj['model']['data_surface_set'].append(item)

                    #NOTE: tuple keys must be saved as strings
                    obj['model']['T'] = {str(k):v for k, v in self.model.T.extract_values().items()}
                    obj['model']['space_velocity'] = {str(k):v for k, v in self.model.space_velocity.extract_values().items()}
                    obj['model']['v'] = {str(k):v for k, v in self.model.v.extract_values().items()}
                    obj['model']['P'] = {str(k):v for k, v in self.model.P.extract_values().items()}
                    obj['model']['Tref'] = {str(k):v for k, v in self.model.Tref.extract_values().items()}
                    obj['model']['Pref'] = {str(k):v for k, v in self.model.Pref.extract_values().items()}
                    obj['model']['rho'] = {str(k):v for k, v in self.model.rho.extract_values().items()}
                    obj['model']['mu'] = {str(k):v for k, v in self.model.mu.extract_values().items()}
                    obj['model']['Re'] = {str(k):v for k, v in self.model.Re.extract_values().items()}
                    obj['model']['Cb'] = {str(k):v for k, v in self.model.Cb.extract_values().items()}
                    obj['model']['C'] = {str(k):v for k, v in self.model.C.extract_values().items()}
                    obj['model']['dCb_dz'] = {str(k):v for k, v in self.model.dCb_dz.extract_values().items()}
                    obj['model']['dCb_dt'] = {str(k):v for k, v in self.model.dCb_dt.extract_values().items()}
                    obj['model']['dC_dt'] = {str(k):v for k, v in self.model.dC_dt.extract_values().items()}
                    obj['model']['km'] = {str(k):v for k, v in self.model.km.extract_values().items()}
                    obj['model']['Dm'] = {str(k):v for k, v in self.model.Dm.extract_values().items()}
                    obj['model']['Sc'] = {str(k):v for k, v in self.model.Sc.extract_values().items()}
                    obj['model']['Sh'] = {str(k):v for k, v in self.model.Sh.extract_values().items()}
                    obj['model']['u_C'] = {str(k):v for k, v in self.model.u_C.extract_values().items()}

                    if self.isDataGasSpecSet == True:
                        obj['model']['Cb_data'] = {str(k):v for k, v in self.model.Cb_data.extract_values().items()}
                        obj['model']['Cb_data_full'] = {str(k):v for k, v in self.model.Cb_data_full.extract_values().items()}
                        obj['model']['w'] = {str(k):v for k, v in self.model.w.extract_values().items()}

                    if self.isDataSurfSpecSet == True:
                        obj['model']['q_data'] = {str(k):v for k, v in self.model.q_data.extract_values().items()}
                        obj['model']['q_data_full'] = {str(k):v for k, v in self.model.q_data_full.extract_values().items()}
                        obj['model']['wq'] = {str(k):v for k, v in self.model.wq.extract_values().items()}

                    if self.isSurfSpecSet == True:
                        obj['model']['surf_set'] = []
                        for item in self.model.surf_set:
                            obj['model']['surf_set'].append(item)
                        obj['model']['q'] = {str(k):v for k, v in self.model.q.extract_values().items()}
                        obj['model']['dq_dt'] = {str(k):v for k, v in self.model.dq_dt.extract_values().items()}
                        obj['model']['u_q'] = {str(k):v for k, v in self.model.u_q.extract_values().items()}
                        if self.isSitesSet == True:
                            obj['model']['site_set'] = []
                            for item in self.model.site_set:
                                obj['model']['site_set'].append(item)
                            obj['model']['S'] = {str(k):v for k, v in self.model.S.extract_values().items()}
                            obj['model']['Smax'] = {str(k):v for k, v in self.model.Smax.extract_values().items()}
                            obj['model']['u_S'] = {str(k):v for k, v in self.model.u_S.extract_values().items()}

                    obj['model']['all_rxns'] = []
                    for item in self.model.all_rxns:
                        obj['model']['all_rxns'].append(item)
                        obj['model'][item+"_reactants"] = []
                        for item2 in self.model.component(item+"_reactants"):
                            obj['model'][item+"_reactants"].append(item2)
                        obj['model'][item+"_products"] = []
                        for item2 in self.model.component(item+"_products"):
                            obj['model'][item+"_products"].append(item2)

                    obj['model']['arrhenius_rxns'] = []
                    obj['model']['A'] = {}
                    obj['model']['B'] = {}
                    obj['model']['E'] = {}
                    for item in self.model.arrhenius_rxns:
                        obj['model']['arrhenius_rxns'].append(item)
                        obj['model']['A'][item] = {}
                        obj['model']['A'][item]['lower'] = self.model.A[item].lb
                        obj['model']['A'][item]['value'] = self.model.A[item].value
                        obj['model']['A'][item]['upper'] = self.model.A[item].ub
                        obj['model']['B'][item] = {}
                        obj['model']['B'][item]['lower'] = self.model.B[item].lb
                        obj['model']['B'][item]['value'] = self.model.B[item].value
                        obj['model']['B'][item]['upper'] = self.model.B[item].ub
                        obj['model']['E'][item] = {}
                        obj['model']['E'][item]['lower'] = self.model.E[item].lb
                        obj['model']['E'][item]['value'] = self.model.E[item].value
                        obj['model']['E'][item]['upper'] = self.model.E[item].ub

                    obj['model']['equ_arrhenius_rxns'] = []
                    obj['model']['Af'] = {}
                    obj['model']['Ef'] = {}
                    obj['model']['dH'] = {}
                    obj['model']['dS'] = {}
                    for item in self.model.equ_arrhenius_rxns:
                        obj['model']['equ_arrhenius_rxns'].append(item)
                        obj['model']['Af'][item] = {}
                        obj['model']['Af'][item]['lower'] = self.model.Af[item].lb
                        obj['model']['Af'][item]['value'] = self.model.Af[item].value
                        obj['model']['Af'][item]['upper'] = self.model.Af[item].ub
                        obj['model']['Ef'][item] = {}
                        obj['model']['Ef'][item]['lower'] = self.model.Ef[item].lb
                        obj['model']['Ef'][item]['value'] = self.model.Ef[item].value
                        obj['model']['Ef'][item]['upper'] = self.model.Ef[item].ub
                        obj['model']['dH'][item] = {}
                        obj['model']['dH'][item]['lower'] = self.model.dH[item].lb
                        obj['model']['dH'][item]['value'] = self.model.dH[item].value
                        obj['model']['dH'][item]['upper'] = self.model.dH[item].ub
                        obj['model']['dS'][item] = {}
                        obj['model']['dS'][item]['lower'] = self.model.dS[item].lb
                        obj['model']['dS'][item]['value'] = self.model.dS[item].value
                        obj['model']['dS'][item]['upper'] = self.model.dS[item].ub

                    obj['model']['all_species_set'] = []
                    for item in self.model.all_species_set:
                        obj['model']['all_species_set'].append(item)

                    obj['model']['rxn_orders'] = {str(k):v for k, v in self.model.rxn_orders.extract_values().items()}

        json.dump(obj,file)
        file.close()

    # Function to load full model from json file
    def load_model_full(self, file_name, reset_param_bounds=False):
        self.load_time = TIME.time()
        print("----------- Attempting to load model from file ------------\n")
        # Attempt to load json file
        obj = json.load(open(file_name))

        # Dig into the obj dictionary and setup the model
        self.set_bulk_porosity(obj['model']['eb'])
        self.set_washcoat_porosity(obj['model']['ew'])
        self.set_reactor_radius(obj['model']['r'])
        self.set_effective_diffusivity_factor(obj['model']['diff_factor'])
        self.set_cell_density(obj['model']['cell_density'])
        try:
            self.add_axial_dim(point_list=obj['model']['z'])
        except:
            print(file_name+" does not contain axial dimension")
        try:
            self.add_axial_dataset(obj['model']['z_data'])
        except:
            print(file_name+" does not contain data set in axial dimension")
        try:
            self.add_temporal_dim(point_list=obj['model']['t'])
        except:
            print(file_name+" does not contain temporal dimension")
        try:
            self.add_temporal_dataset(obj['model']['t_data_full'])
        except:
            print(file_name+" does not contain data set in temporal dimension")
        try:
            self.add_age_set(obj['model']['age_set'])
        except:
            print(file_name+" does not contain age set")
        try:
            self.add_data_age_set(obj['model']['data_age_set'])
        except:
            print(file_name+" does not contain data age set")
        try:
            self.add_temperature_set(obj['model']['T_set'])
        except:
            print(file_name+" does not contain temperature set")
        try:
            self.add_data_temperature_set(obj['model']['data_T_set'])
        except:
            print(file_name+" does not contain data temperature set")
        try:
            self.add_gas_species(obj['model']['gas_set'])
        except:
            print(file_name+" does not contain gas species set")
        try:
            self.add_data_gas_species(obj['model']['data_gas_set'])
        except:
            print(file_name+" does not contain data gas species set")
        try:
            self.add_surface_species(obj['model']['surf_set'])
        except:
            print(file_name+" does not contain surface species set")
        try:
            self.add_data_surface_species(obj['model']['data_surface_set'])
        except:
            print(file_name+" does not contain data surface species set")
        try:
            self.add_surface_sites(obj['model']['site_set'])
        except:
            print(file_name+" does not contain site species set")

        try:
            rxn_dict = {}
            for rxn in obj['rxn_list']:
                if obj['rxn_list'][rxn]['type'] == "ReactionType.EquilibriumArrhenius":
                    rxn_dict[rxn] = ReactionType.EquilibriumArrhenius
                elif obj['rxn_list'][rxn]['type'] == "ReactionType.Arrhenius":
                    rxn_dict[rxn] = ReactionType.Arrhenius
                else:
                    raise Exception("Error! Unrecognized reaction type upon loading")
            self.add_reactions(rxn_dict)
            for rxn in obj['rxn_list']:
                if obj['rxn_list'][rxn]['fixed'] == True:
                    self.fix_reaction(rxn)
                else:
                    self.unfix_reaction(rxn)
        except:
            print(file_name+" does not contain reaction set")

        # Set functions to perform BEFORE discretization
        try:
            for rxn in obj['model']['all_rxns']:
                self.model.add_component(rxn+"_reactants", Set(initialize=obj['model'][rxn+"_reactants"]))
                self.model.add_component(rxn+"_products", Set(initialize=obj['model'][rxn+"_products"]))
                self.isRxnBuilt[rxn] = True
        except:
            print(file_name+" does not contain reaction info for reactants and products")

        #Manually set data from file
        try:
            for key in obj['model']['Cb_data_full']:
                self.model.Cb_data_full[literal_eval(key)].set_value(obj['model']['Cb_data_full'][key])
            #Use manually set data to call the sub-routine to automate selection of data sub-set
            for spec in self.model.data_gas_set:
                for age in self.model.data_age_set:
                    for temp in self.model.data_T_set:
                        for loc in self.model.z_data:
                            times = []
                            values = []
                            for time in self.model.t_data_full:
                                times.append(time)
                                values.append(self.model.Cb_data_full[spec,age,temp,loc,time].value)
                            self.set_data_values_for(spec,age,temp,loc,times,values)
        except:
            print(file_name+" does not contain proper gas data for optimization")

        try:
            for key in obj['model']['q_data_full']:
                self.model.q_data_full[literal_eval(key)].set_value(obj['model']['q_data_full'][key])
            #Use manually set data to call the sub-routine to automate selection of data sub-set
            for spec in self.model.data_surface_set:
                for age in self.model.data_age_set:
                    for temp in self.model.data_T_set:
                        for loc in self.model.z_data:
                            times = []
                            values = []
                            for time in self.model.t_data_full:
                                times.append(time)
                                values.append(self.model.q_data_full[spec,age,temp,loc,time].value)
                            self.set_data_values_for(spec,age,temp,loc,times,values)
        except:
            print(file_name+" does not contain proper surface data for optimization")

        try:
            cp = 1
            dt = DiscretizationMethod.FiniteDifference
            if obj['DiscType'] == "DiscretizationMethod.FiniteDifference":
                cp = 1
                dt = DiscretizationMethod.FiniteDifference
            elif obj['DiscType'] == "DiscretizationMethod.OrthogonalCollocation":
                cp = obj['colpoints']
                dt = DiscretizationMethod.OrthogonalCollocation
            else:
                raise Exception("Error! Model did not have a valid discretization method")
            tstep = len(self.model.t.get_finite_elements())-1
            elems = len(self.model.z.get_finite_elements())-1
            self.build_constraints()
            self.discretize_model(method=dt, elems=elems, tstep=tstep, colpoints=cp)
        except:
            print(file_name+" does not contain necessary information for rebuilding and discretization")

        print("\n........... loading time-space info for all vars ..........")

        # Set functions to perform AFTER discretization
        for key in obj['model']['T']:
            self.model.T[literal_eval(key)].set_value(obj['model']['T'][key])
        for key in obj['model']['space_velocity']:
            self.model.space_velocity[literal_eval(key)].set_value(obj['model']['space_velocity'][key])
        for key in obj['model']['v']:
            self.model.v[literal_eval(key)].set_value(obj['model']['v'][key])
        for key in obj['model']['P']:
            self.model.P[literal_eval(key)].set_value(obj['model']['P'][key])
        for key in obj['model']['Tref']:
            self.model.Tref[literal_eval(key)].set_value(obj['model']['Tref'][key])
        for key in obj['model']['Pref']:
            self.model.Pref[literal_eval(key)].set_value(obj['model']['Pref'][key])
        for key in obj['model']['rho']:
            self.model.rho[literal_eval(key)].set_value(obj['model']['rho'][key])
        for key in obj['model']['mu']:
            self.model.mu[literal_eval(key)].set_value(obj['model']['mu'][key])
        for key in obj['model']['Re']:
            self.model.Re[literal_eval(key)].set_value(obj['model']['Re'][key])
        for key in obj['model']['Cb']:
            self.model.Cb[literal_eval(key)].set_value(obj['model']['Cb'][key])
        for key in obj['model']['C']:
            self.model.C[literal_eval(key)].set_value(obj['model']['C'][key])
        for key in obj['model']['dCb_dz']:
            self.model.dCb_dz[literal_eval(key)].set_value(obj['model']['dCb_dz'][key])
        for key in obj['model']['dCb_dt']:
            self.model.dCb_dt[literal_eval(key)].set_value(obj['model']['dCb_dt'][key])
        for key in obj['model']['dC_dt']:
            self.model.dC_dt[literal_eval(key)].set_value(obj['model']['dC_dt'][key])
        for key in obj['model']['km']:
            self.model.km[literal_eval(key)].set_value(obj['model']['km'][key])

        #NOTE: There is only a single key for Dm, so we don't use 'literal_eval'
        for key in obj['model']['Dm']:
            self.model.Dm[key].set_value(obj['model']['Dm'][key])

        for key in obj['model']['Sc']:
            self.model.Sc[literal_eval(key)].set_value(obj['model']['Sc'][key])
        for key in obj['model']['Sh']:
            self.model.Sh[literal_eval(key)].set_value(obj['model']['Sh'][key])
        if self.isDataGasSpecSet == True:
            for key in obj['model']['w']:
                self.model.w[literal_eval(key)].set_value(obj['model']['w'][key])
        if self.isDataSurfSpecSet == True:
            for key in obj['model']['wq']:
                self.model.wq[literal_eval(key)].set_value(obj['model']['wq'][key])
        if self.isSurfSpecSet == True:
            for key in obj['model']['q']:
                self.model.q[literal_eval(key)].set_value(obj['model']['q'][key])
            for key in obj['model']['dq_dt']:
                self.model.dq_dt[literal_eval(key)].set_value(obj['model']['dq_dt'][key])
            for key in obj['model']['u_q']:
                self.model.u_q[literal_eval(key)].set_value(obj['model']['u_q'][key])

            if self.isSitesSet == True:
                for key in obj['model']['S']:
                    self.model.S[literal_eval(key)].set_value(obj['model']['S'][key])
                for key in obj['model']['Smax']:
                    self.model.Smax[literal_eval(key)].set_value(obj['model']['Smax'][key])
                for key in obj['model']['u_S']:
                    self.model.u_S[literal_eval(key)].set_value(obj['model']['u_S'][key])

        for key in obj['model']['u_C']:
            self.model.u_C[literal_eval(key)].set_value(obj['model']['u_C'][key])
        for key in obj['model']['rxn_orders']:
            self.model.rxn_orders[literal_eval(key)].set_value(obj['model']['rxn_orders'][key])

        # Need special treatment for reaction values
        for key in obj['model']['A']:
            self.model.A[key].set_value(obj['model']['A'][key]['value'])
            if reset_param_bounds == False:
                self.model.A[key].setlb(obj['model']['A'][key]['lower'])
                self.model.A[key].setub(obj['model']['A'][key]['upper'])
            else:
                self.model.A[key].setlb(obj['model']['A'][key]['value']*0.8)
                self.model.A[key].setub(obj['model']['A'][key]['value']*1.2)
        for key in obj['model']['B']:
            self.model.B[key].set_value(obj['model']['B'][key]['value'])
            if reset_param_bounds == False:
                self.model.B[key].setlb(obj['model']['B'][key]['lower'])
                self.model.B[key].setub(obj['model']['B'][key]['upper'])
            else:
                if obj['model']['B'][key]['value'] >= 0.0:
                    self.model.B[key].setlb(obj['model']['B'][key]['value']*0.8)
                    self.model.B[key].setub(obj['model']['B'][key]['value']*1.2)
                else:
                    self.model.B[key].setlb(obj['model']['B'][key]['value']*1.2)
                    self.model.B[key].setub(obj['model']['B'][key]['value']*0.8)
        for key in obj['model']['E']:
            self.model.E[key].set_value(obj['model']['E'][key]['value'])
            if reset_param_bounds == False:
                self.model.E[key].setlb(obj['model']['E'][key]['lower'])
                self.model.E[key].setub(obj['model']['E'][key]['upper'])
            else:
                if obj['model']['E'][key]['value'] >= 0.0:
                    self.model.E[key].setlb(obj['model']['E'][key]['value']*0.8)
                    self.model.E[key].setub(obj['model']['E'][key]['value']*1.2)
                else:
                    self.model.E[key].setlb(obj['model']['E'][key]['value']*1.2)
                    self.model.E[key].setub(obj['model']['E'][key]['value']*0.8)
        for key in obj['model']['Af']:
            self.model.Af[key].set_value(obj['model']['Af'][key]['value'])
            if reset_param_bounds == False:
                self.model.Af[key].setlb(obj['model']['Af'][key]['lower'])
                self.model.Af[key].setub(obj['model']['Af'][key]['upper'])
            else:
                self.model.Af[key].setlb(obj['model']['Af'][key]['value']*0.8)
                self.model.Af[key].setub(obj['model']['Af'][key]['value']*1.2)
        for key in obj['model']['Ef']:
            self.model.Ef[key].set_value(obj['model']['Ef'][key]['value'])
            if reset_param_bounds == False:
                self.model.Ef[key].setlb(obj['model']['Ef'][key]['lower'])
                self.model.Ef[key].setub(obj['model']['Ef'][key]['upper'])
            else:
                if obj['model']['Ef'][key]['value'] >= 0.0:
                    self.model.Ef[key].setlb(obj['model']['Ef'][key]['value']*0.8)
                    self.model.Ef[key].setub(obj['model']['Ef'][key]['value']*1.2)
                else:
                    self.model.Ef[key].setlb(obj['model']['Ef'][key]['value']*1.2)
                    self.model.Ef[key].setub(obj['model']['Ef'][key]['value']*0.8)
        for key in obj['model']['dH']:
            self.model.dH[key].set_value(obj['model']['dH'][key]['value'])
            if reset_param_bounds == False:
                self.model.dH[key].setlb(obj['model']['dH'][key]['lower'])
                self.model.dH[key].setub(obj['model']['dH'][key]['upper'])
            else:
                if obj['model']['dH'][key]['value'] >= 0.0:
                    self.model.dH[key].setlb(obj['model']['dH'][key]['value']*0.8)
                    self.model.dH[key].setub(obj['model']['dH'][key]['value']*1.2)
                else:
                    self.model.dH[key].setlb(obj['model']['dH'][key]['value']*1.2)
                    self.model.dH[key].setub(obj['model']['dH'][key]['value']*0.8)
        for key in obj['model']['dS']:
            self.model.dS[key].set_value(obj['model']['dS'][key]['value'])
            if reset_param_bounds == False:
                self.model.dS[key].setlb(obj['model']['dS'][key]['lower'])
                self.model.dS[key].setub(obj['model']['dS'][key]['upper'])
            else:
                if obj['model']['dS'][key]['value'] >= 0.0:
                    self.model.dS[key].setlb(obj['model']['dS'][key]['value']*0.8)
                    self.model.dS[key].setub(obj['model']['dS'][key]['value']*1.2)
                else:
                    self.model.dS[key].setlb(obj['model']['dS'][key]['value']*1.2)
                    self.model.dS[key].setub(obj['model']['dS'][key]['value']*0.8)

        #Fix ICs and BCs
        self.model.Cb[:,:,:, :, self.model.t.first()].fix()
        self.model.C[:,:,:, :, self.model.t.first()].fix()
        if self.isSurfSpecSet == True:
            self.model.q[:,:,:, :, self.model.t.first()].fix()
        for spec in self.isInitialSet:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    self.isInitialSet[spec][age][temp] = True

        self.model.Cb[:,:,:,self.model.z.first(), :].fix()
        for spec in self.isBoundarySet:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    self.isBoundarySet[spec][age][temp] = True

        self.isInitialized = True
        self.isIsothermalTempSet = True

        self.load_time = (TIME.time() - self.load_time)
        print("============ Loading Completed in "+str(self.load_time)+" (s) ============\n")


    # Function to load a model state as an initial condition to next simulation
    #   User must provide the following:
    #   -------------------------------
    #       file_name = location and name of json file to load
    #       new_time_window = a tuple of start and end times for new simulation
    #                       (or a list of new time points to simulate)
    #
    #       Optional Arg:   state = time state to use as IC from the loaded model
    #                               (default = final state)
    #
    #   NOTE: User cannot provide new data at this stage. All data should have
    #           been provided in the prior model you attempt to load.
    #
    #   NOTE: User MUST setup new BCs before attempting to solve this loaded model
    #
    #   NOTE: User MUST also provide new temperature profiles and/or space-velocities
    #           (if applicable). Simulation will otherwise assume new temperatures
    #           are the prior temperatures extended from the final state.
    def load_model_state_as_IC(self, file_name, new_time_window, tstep=None, state=None, reset_param_bounds=False):
        print("----------- Attempting to load model from file ------------\n")
        self.load_time = TIME.time()

        # Attempt to load json file
        obj = json.load(open(file_name))

        # Check the new time window
        if type(new_time_window) is list:
            self.add_temporal_dim(point_list=new_time_window)
            tstep = len(new_time_window)-1
        elif type(new_time_window) is tuple:
            if tstep==None:
                raise Exception("Error! Cannot discretize if user does not provide number of time steps in 'tstep' arg")
            self.add_temporal_dim(start_point=new_time_window[0], end_point=new_time_window[1])
        else:
            raise Exception("Error! Argument 'new_time_window' must be tuple (start, end) or list of discrete points")


        # Check the state desired
        if state == None:
            try:
                IC_time = obj['valid_time_states_for_restart'][-1]
            except:
                raise Exception("Error! json file may not be configured correctly... No 'valid_time_states_for_restart' key found")
        else:
            try:
                if state not in obj['valid_time_states_for_restart']:
                    print("WARNING! Desired state not found in json file. Using closest available state")
                    for time in obj['valid_time_states_for_restart']:
                        if time >= state:
                            IC_time = time
                            break
                else:
                    IC_time = obj['valid_time_states_for_restart'][obj['valid_time_states_for_restart'].index(state)]
            except:
                raise Exception("Error! json file may not be configured correctly... No 'valid_time_states_for_restart' key found")

        # Dig into the obj dictionary and setup the model
        self.set_bulk_porosity(obj['model']['eb'])
        self.set_washcoat_porosity(obj['model']['ew'])
        self.set_reactor_radius(obj['model']['r'])
        self.set_effective_diffusivity_factor(obj['model']['diff_factor'])
        self.set_cell_density(obj['model']['cell_density'])
        try:
            self.add_axial_dim(point_list=obj['model']['z'])
        except:
            print(file_name+" does not contain axial dimension")
        try:
            self.add_axial_dataset(obj['model']['z_data'])
        except:
            print(file_name+" does not contain data set in axial dimension")
        try:
            self.add_temporal_dataset(obj['model']['t_data_full'])
        except:
            print(file_name+" does not contain data set in temporal dimension")
        try:
            self.add_age_set(obj['model']['age_set'])
        except:
            print(file_name+" does not contain age set")
        try:
            self.add_data_age_set(obj['model']['data_age_set'])
        except:
            print(file_name+" does not contain data age set")
        try:
            self.add_temperature_set(obj['model']['T_set'])
        except:
            print(file_name+" does not contain temperature set")
        try:
            self.add_data_temperature_set(obj['model']['data_T_set'])
        except:
            print(file_name+" does not contain data temperature set")
        try:
            self.add_gas_species(obj['model']['gas_set'])
        except:
            print(file_name+" does not contain gas species set")
        try:
            self.add_data_gas_species(obj['model']['data_gas_set'])
        except:
            print(file_name+" does not contain data gas species set")
        try:
            self.add_surface_species(obj['model']['surf_set'])
        except:
            print(file_name+" does not contain surface species set")
        try:
            self.add_data_surface_species(obj['model']['data_surface_set'])
        except:
            print(file_name+" does not contain data surface species set")
        try:
            self.add_surface_sites(obj['model']['site_set'])
        except:
            print(file_name+" does not contain site species set")

        try:
            rxn_dict = {}
            for rxn in obj['rxn_list']:
                if obj['rxn_list'][rxn]['type'] == "ReactionType.EquilibriumArrhenius":
                    rxn_dict[rxn] = ReactionType.EquilibriumArrhenius
                elif obj['rxn_list'][rxn]['type'] == "ReactionType.Arrhenius":
                    rxn_dict[rxn] = ReactionType.Arrhenius
                else:
                    raise Exception("Error! Unrecognized reaction type upon loading")
            self.add_reactions(rxn_dict)
            for rxn in obj['rxn_list']:
                if obj['rxn_list'][rxn]['fixed'] == True:
                    self.fix_reaction(rxn)
                else:
                    self.unfix_reaction(rxn)
        except:
            print(file_name+" does not contain reaction set")

        # Set functions to perform BEFORE discretization
        try:
            for rxn in obj['model']['all_rxns']:
                self.model.add_component(rxn+"_reactants", Set(initialize=obj['model'][rxn+"_reactants"]))
                self.model.add_component(rxn+"_products", Set(initialize=obj['model'][rxn+"_products"]))
                self.isRxnBuilt[rxn] = True
        except:
            print(file_name+" does not contain reaction info for reactants and products")

        #Manually set data from file
        try:
            for key in obj['model']['Cb_data_full']:
                self.model.Cb_data_full[literal_eval(key)].set_value(obj['model']['Cb_data_full'][key])
            #Use manually set data to call the sub-routine to automate selection of data sub-set
            for spec in self.model.data_gas_set:
                for age in self.model.data_age_set:
                    for temp in self.model.data_T_set:
                        for loc in self.model.z_data:
                            times = []
                            values = []
                            for time in self.model.t_data_full:
                                times.append(time)
                                values.append(self.model.Cb_data_full[spec,age,temp,loc,time].value)
                            self.set_data_values_for(spec,age,temp,loc,times,values)
        except:
            print(file_name+" does not contain proper data for optimization")

        try:
            for key in obj['model']['q_data_full']:
                self.model.q_data_full[literal_eval(key)].set_value(obj['model']['q_data_full'][key])
            #Use manually set data to call the sub-routine to automate selection of data sub-set
            for spec in self.model.data_surface_set:
                for age in self.model.data_age_set:
                    for temp in self.model.data_T_set:
                        for loc in self.model.z_data:
                            times = []
                            values = []
                            for time in self.model.t_data_full:
                                times.append(time)
                                values.append(self.model.q_data_full[spec,age,temp,loc,time].value)
                            self.set_data_values_for(spec,age,temp,loc,times,values)
        except:
            print(file_name+" does not contain proper surface data for optimization")

        try:
            cp = 1
            dt = DiscretizationMethod.FiniteDifference
            if obj['DiscType'] == "DiscretizationMethod.FiniteDifference":
                cp = 1
                dt = DiscretizationMethod.FiniteDifference
            elif obj['DiscType'] == "DiscretizationMethod.OrthogonalCollocation":
                cp = obj['colpoints']
                dt = DiscretizationMethod.OrthogonalCollocation
            else:
                raise Exception("Error! Model did not have a valid discretization method")
            elems = len(self.model.z.get_finite_elements())-1
            self.build_constraints()
            self.discretize_model(method=dt, elems=elems, tstep=tstep, colpoints=cp)
        except:
            print(file_name+" does not contain necessary information for rebuilding and discretization")

        print("\n........... loading time-space info for all vars ..........")

        # Set functions to perform AFTER discretization
        for key in obj['model']['T']:
            if literal_eval(key)[-1] == IC_time:
                self.model.T[literal_eval(key)].set_value(obj['model']['T'][key])
        for age in self.model.age_set:
            for temp in self.model.T_set:
                for loc in self.model.z:
                    for time in self.model.t:
                        self.model.T[age,temp,loc,time].set_value(self.model.T[age,temp,loc,IC_time].value)
        for key in obj['model']['P']:
            if literal_eval(key)[-1] == IC_time:
                self.model.P[literal_eval(key)].set_value(obj['model']['P'][key])
        for age in self.model.age_set:
            for temp in self.model.T_set:
                for loc in self.model.z:
                    for time in self.model.t:
                        self.model.P[age,temp,loc,time].set_value(self.model.P[age,temp,loc,IC_time].value)
        for key in obj['model']['Tref']:
            self.model.Tref[literal_eval(key)].set_value(obj['model']['Tref'][key])
        for key in obj['model']['Pref']:
            self.model.Pref[literal_eval(key)].set_value(obj['model']['Pref'][key])
        for key in obj['model']['space_velocity']:
            if literal_eval(key)[-1] == IC_time:
                self.model.space_velocity[literal_eval(key)].set_value(obj['model']['space_velocity'][key])
        for age in self.model.age_set:
            for temp in self.model.T_set:
                self.set_space_velocity(age,temp,self.model.space_velocity[age,temp,IC_time].value,self.model.Pref[age,temp].value,self.model.Tref[age,temp].value)
        for key in obj['model']['Dm']:
            self.model.Dm[key].set_value(obj['model']['Dm'][key])
        self.isVelocityRecalculated = False

        if self.isDataGasSpecSet == True:
            for key in obj['model']['w']:
                self.model.w[literal_eval(key)].set_value(obj['model']['w'][key])

        if self.isDataSurfSpecSet == True:
            for key in obj['model']['wq']:
                self.model.wq[literal_eval(key)].set_value(obj['model']['wq'][key])

        for key in obj['model']['Cb']:
            if literal_eval(key)[-1] == IC_time:
                self.model.Cb[literal_eval(key)].set_value(obj['model']['Cb'][key])
        for key in obj['model']['C']:
            if literal_eval(key)[-1] == IC_time:
                self.model.C[literal_eval(key)].set_value(obj['model']['C'][key])
        for key in obj['model']['dCb_dz']:
            if literal_eval(key)[-1] == IC_time:
                self.model.dCb_dz[literal_eval(key)].set_value(obj['model']['dCb_dz'][key])
        for key in obj['model']['dCb_dt']:
            if literal_eval(key)[-1] == IC_time:
                self.model.dCb_dt[literal_eval(key)].set_value(obj['model']['dCb_dt'][key])
        for key in obj['model']['dC_dt']:
            if literal_eval(key)[-1] == IC_time:
                self.model.dC_dt[literal_eval(key)].set_value(obj['model']['dC_dt'][key])

        for key in obj['model']['u_C']:
            self.model.u_C[literal_eval(key)].set_value(obj['model']['u_C'][key])
        for key in obj['model']['rxn_orders']:
            self.model.rxn_orders[literal_eval(key)].set_value(obj['model']['rxn_orders'][key])

        if self.isSurfSpecSet == True:
            for key in obj['model']['q']:
                if literal_eval(key)[-1] == IC_time:
                    self.model.q[literal_eval(key)].set_value(obj['model']['q'][key])
            for key in obj['model']['dq_dt']:
                if literal_eval(key)[-1] == IC_time:
                    self.model.dq_dt[literal_eval(key)].set_value(obj['model']['dq_dt'][key])
            for key in obj['model']['u_q']:
                self.model.u_q[literal_eval(key)].set_value(obj['model']['u_q'][key])

            if self.isSitesSet == True:
                for key in obj['model']['S']:
                    if literal_eval(key)[-1] == IC_time:
                        self.model.S[literal_eval(key)].set_value(obj['model']['S'][key])
                for key in obj['model']['Smax']:
                    if literal_eval(key)[-1] == IC_time:
                        self.model.Smax[literal_eval(key)].set_value(obj['model']['Smax'][key])
                for site in self.model.site_set:
                    for age in self.model.age_set:
                        for loc in self.model.z:
                            self.set_site_density(site, age, self.model.Smax[site,age,loc,IC_time].value)
                for key in obj['model']['u_S']:
                    self.model.u_S[literal_eval(key)].set_value(obj['model']['u_S'][key])

        # Need special treatment for reaction values
        for key in obj['model']['A']:
            self.model.A[key].set_value(obj['model']['A'][key]['value'])
            if reset_param_bounds == False:
                self.model.A[key].setlb(obj['model']['A'][key]['lower'])
                self.model.A[key].setub(obj['model']['A'][key]['upper'])
            else:
                self.model.A[key].setlb(obj['model']['A'][key]['value']*0.8)
                self.model.A[key].setub(obj['model']['A'][key]['value']*1.2)
        for key in obj['model']['B']:
            self.model.B[key].set_value(obj['model']['B'][key]['value'])
            if reset_param_bounds == False:
                self.model.B[key].setlb(obj['model']['B'][key]['lower'])
                self.model.B[key].setub(obj['model']['B'][key]['upper'])
            else:
                if obj['model']['B'][key]['value'] >= 0.0:
                    self.model.B[key].setlb(obj['model']['B'][key]['value']*0.8)
                    self.model.B[key].setub(obj['model']['B'][key]['value']*1.2)
                else:
                    self.model.B[key].setlb(obj['model']['B'][key]['value']*1.2)
                    self.model.B[key].setub(obj['model']['B'][key]['value']*0.8)
        for key in obj['model']['E']:
            self.model.E[key].set_value(obj['model']['E'][key]['value'])
            if reset_param_bounds == False:
                self.model.E[key].setlb(obj['model']['E'][key]['lower'])
                self.model.E[key].setub(obj['model']['E'][key]['upper'])
            else:
                if obj['model']['E'][key]['value'] >= 0.0:
                    self.model.E[key].setlb(obj['model']['E'][key]['value']*0.8)
                    self.model.E[key].setub(obj['model']['E'][key]['value']*1.2)
                else:
                    self.model.E[key].setlb(obj['model']['E'][key]['value']*1.2)
                    self.model.E[key].setub(obj['model']['E'][key]['value']*0.8)
        for key in obj['model']['Af']:
            self.model.Af[key].set_value(obj['model']['Af'][key]['value'])
            if reset_param_bounds == False:
                self.model.Af[key].setlb(obj['model']['Af'][key]['lower'])
                self.model.Af[key].setub(obj['model']['Af'][key]['upper'])
            else:
                self.model.Af[key].setlb(obj['model']['Af'][key]['value']*0.8)
                self.model.Af[key].setub(obj['model']['Af'][key]['value']*1.2)
        for key in obj['model']['Ef']:
            self.model.Ef[key].set_value(obj['model']['Ef'][key]['value'])
            if reset_param_bounds == False:
                self.model.Ef[key].setlb(obj['model']['Ef'][key]['lower'])
                self.model.Ef[key].setub(obj['model']['Ef'][key]['upper'])
            else:
                if obj['model']['Ef'][key]['value'] >= 0.0:
                    self.model.Ef[key].setlb(obj['model']['Ef'][key]['value']*0.8)
                    self.model.Ef[key].setub(obj['model']['Ef'][key]['value']*1.2)
                else:
                    self.model.Ef[key].setlb(obj['model']['Ef'][key]['value']*1.2)
                    self.model.Ef[key].setub(obj['model']['Ef'][key]['value']*0.8)
        for key in obj['model']['dH']:
            self.model.dH[key].set_value(obj['model']['dH'][key]['value'])
            if reset_param_bounds == False:
                self.model.dH[key].setlb(obj['model']['dH'][key]['lower'])
                self.model.dH[key].setub(obj['model']['dH'][key]['upper'])
            else:
                if obj['model']['dH'][key]['value'] >= 0.0:
                    self.model.dH[key].setlb(obj['model']['dH'][key]['value']*0.8)
                    self.model.dH[key].setub(obj['model']['dH'][key]['value']*1.2)
                else:
                    self.model.dH[key].setlb(obj['model']['dH'][key]['value']*1.2)
                    self.model.dH[key].setub(obj['model']['dH'][key]['value']*0.8)
        for key in obj['model']['dS']:
            self.model.dS[key].set_value(obj['model']['dS'][key]['value'])
            if reset_param_bounds == False:
                self.model.dS[key].setlb(obj['model']['dS'][key]['lower'])
                self.model.dS[key].setub(obj['model']['dS'][key]['upper'])
            else:
                if obj['model']['dS'][key]['value'] >= 0.0:
                    self.model.dS[key].setlb(obj['model']['dS'][key]['value']*0.8)
                    self.model.dS[key].setub(obj['model']['dS'][key]['value']*1.2)
                else:
                    self.model.dS[key].setlb(obj['model']['dS'][key]['value']*1.2)
                    self.model.dS[key].setub(obj['model']['dS'][key]['value']*0.8)

        #Fix ICs and BCs
        self.model.Cb[:,:,:, :, self.model.t.first()].fix()
        self.model.C[:,:,:, :, self.model.t.first()].fix()
        if self.isSurfSpecSet == True:
            self.model.q[:,:,:, :, self.model.t.first()].fix()
        for spec in self.isInitialSet:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    self.isInitialSet[spec][age][temp] = True

        self.load_time = (TIME.time() - self.load_time)
        print("============ Loading Completed in "+str(self.load_time)+" (s) ============\n")


    # Function to plot a species for all times at a series of locations
    #   User must provide...
    #       spec_list = list of names of species to plot together
    #       age_list = list of names of ages to plot together
    #       temp_list = list of names of isothermal temperatures to plot together
    #       loc_list = list of values of locations for variables
    #       display_live = (optional) If true, plots will be shown to user during runtime
    #       file_name = (optional) name of file to save
    #       file_type = (optional) type of image file to save as
    def plot_at_locations(self, spec_list, age_list, temp_list, loc_list,
                        display_live=False, file_name="", file_type=".png"):
        if type(spec_list) is not list:
            raise Exception("Error! Need to provide species as a list (even if it is just one species)")
        if type(age_list) is not list:
            raise Exception("Error! Need to provide ages as a list (even if it is just one age)")
        if type(temp_list) is not list:
            raise Exception("Error! Need to provide temperature sets as a list (even if it is just one temperature)")
        if type(loc_list) is not list:
            raise Exception("Error! Need to provide locations as a list (even if it is just one location)")

        #Check lists for errors
        for spec in spec_list:
            if spec not in self.model.all_species_set:
                raise Exception("Error! Invalid species in given list. "
                                +str(spec)+" given is not in model.all_species_set")
        for age in age_list:
            if age not in self.model.age_set:
                raise Exception("Error! Invalid age in given list. "
                                +str(age)+" given is not in model.age_set")
        for temp in temp_list:
            if temp not in self.model.T_set:
                raise Exception("Error! Invalid temperature in given list. "
                                +str(temp)+" given is not in model.T_set")
        true_loc_list = []
        for loc in loc_list:
            if loc not in self.model.z:
                print("WARNING: Given location is not a node in the mesh. Updating to nearest node")
                nearest_loc_index = self.model.z.find_nearest_index(loc)
                #if self.model.z[nearest_loc_index] not in true_loc_list:
                #    true_loc_list.append(self.model.z[nearest_loc_index])
                if self.model.z.at(nearest_loc_index) not in true_loc_list:
                    true_loc_list.append(self.model.z.at(nearest_loc_index))
            else:
                if loc not in true_loc_list:
                    true_loc_list.append(loc)


        #Check file name and type
        if file_name == "":
            for spec in spec_list:
                file_name+=spec+"_"

        folder="output/"
        if not os.path.exists(folder):
            os.makedirs(folder)

        if file_type != ".png" and file_type != ".pdf" and file_type != ".ps" and file_type != ".eps" and file_type != ".svg":
            print("Warning! Unsupported image file type...")
            print("\tDefaulting to .png")
            file_type = ".png"

        full_file_name = folder+file_name+"Plots"+file_type

        xvals = list(self.model.t.data())
        fig,ax = plt.subplots(figsize=(10,5))
        leg=[]
        # # TODO: These units may change later based on user input units
        x_units = "(min)"
        y_units = "(mol/L)"
        ylab1 = ""
        for spec in spec_list:
            ylab1 += spec+"\n"
            for age in age_list:
                for temp in temp_list:
                    for loc in true_loc_list:
                        leg_name = spec+"_"+age+"_"+temp+"_at_"+str(loc)
                        leg.append(leg_name)
                        if spec in self.model.gas_set:
                            yvals = list(self.model.Cb[spec,age,temp,loc,:].value)
                            ax.plot(xvals,yvals)
                        else:
                            if self.isSurfSpecSet == True:
                                if spec in self.model.surf_set:
                                    yvals = list(self.model.q[spec,age,temp,loc,:].value)
                                else:
                                    if self.isSitesSet == True:
                                        if spec in self.model.site_set:
                                            yvals = list(self.model.S[spec,age,temp,loc,:].value)
                                        else:
                                            raise Exception("Error! Invalid species name given. "
                                                            +str(spec)+" given does not exist in model")
                            ax.plot(xvals,yvals)

        plt.legend(leg, loc='center left', bbox_to_anchor=(1, 0.5))
        ax.set_xlabel("Time "+x_units)
        ax.set_ylabel(ylab1+y_units)
        plt.tight_layout()
        plt.savefig(full_file_name)
        if display_live == True:
            fig.show()
            print("\nDisplaying plot. Press enter to continue...(this closes the images)")
            input()
        plt.close()



    # Function to plot a speices for all locations at a series of times
    #   User must provide...
    #       spec_list = list of names of species to plot together
    #       age_list = list of names of ages to plot together
    #       temp_list = list of names of isothermal temperatures to plot together
    #       time_list = list of values of times for variables
    #       display_live = (optional) If true, plots will be shown to user during runtime
    #       file_name = (optional) name of file to save
    #       file_type = (optional) type of image file to save as
    def plot_at_times(self, spec_list, age_list, temp_list, time_list,
                        display_live=False, file_name="", file_type=".png"):
        if type(spec_list) is not list:
            raise Exception("Error! Need to provide species as a list (even if it is just one species)")
        if type(age_list) is not list:
            raise Exception("Error! Need to provide ages as a list (even if it is just one age)")
        if type(temp_list) is not list:
            raise Exception("Error! Need to provide temperature sets as a list (even if it is just one temperature)")
        if type(time_list) is not list:
            raise Exception("Error! Need to provide times as a list (even if it is just one time)")

        #Check lists for errors
        for spec in spec_list:
            if spec not in self.model.all_species_set:
                raise Exception("Error! Invalid species in given list. "
                                +str(spec)+" given is not in model.all_species_set")
        for age in age_list:
            if age not in self.model.age_set:
                raise Exception("Error! Invalid age in given list. "
                                +str(age)+" given is not in model.age_set")
        for temp in temp_list:
            if temp not in self.model.T_set:
                raise Exception("Error! Invalid temperature in given list. "
                                +str(temp)+" given is not in model.T_set")
        true_time_list = []
        for time in time_list:
            if time not in self.model.t:
                print("WARNING: Given time is not a point in the simulation. Updating to nearest time")
                nearest_time_index = self.model.t.find_nearest_index(time)
                #if self.model.t[nearest_time_index] not in true_time_list:
                #    true_time_list.append(self.model.t[nearest_time_index])
                if self.model.t.at(nearest_time_index) not in true_time_list:
                    true_time_list.append(self.model.t.at(nearest_time_index))
            else:
                if time not in true_time_list:
                    true_time_list.append(time)


        #Check file name and type
        if file_name == "":
            for spec in spec_list:
                file_name+=spec+"_"

        folder="output/"
        if not os.path.exists(folder):
            os.makedirs(folder)

        if file_type != ".png" and file_type != ".pdf" and file_type != ".ps" and file_type != ".eps" and file_type != ".svg":
            print("Warning! Unsupported image file type...")
            print("\tDefaulting to .png")
            file_type = ".png"

        full_file_name = folder+file_name+"Plots"+file_type

        xvals = list(self.model.z.data())
        fig,ax = plt.subplots(figsize=(10,5))
        leg=[]
        # # TODO: These units may change later based on user input units
        x_units = "(cm)"
        y_units = "(mol/L)"
        ylab1 = ""
        for spec in spec_list:
            ylab1 += spec+"\n"
            for age in age_list:
                for temp in temp_list:
                    for time in true_time_list:
                        leg_name = spec+"_"+age+"_"+temp+"_at_"+str(time)
                        leg.append(leg_name)
                        if spec in self.model.gas_set:
                            yvals = list(self.model.Cb[spec,age,temp,:,time].value)
                            ax.plot(xvals,yvals)
                        else:
                            if self.isSurfSpecSet == True:
                                if spec in self.model.surf_set:
                                    yvals = list(self.model.q[spec,age,temp,:,time].value)
                                else:
                                    if self.isSitesSet == True:
                                        if spec in self.model.site_set:
                                            yvals = list(self.model.S[spec,age,temp,:,time].value)
                                        else:
                                            raise Exception("Error! Invalide species name given. "
                                                            +str(spec)+" given does not exist in model")
                            ax.plot(xvals,yvals)

        plt.legend(leg, loc='center left', bbox_to_anchor=(1, 0.5))
        ax.set_xlabel("Z "+x_units)
        ax.set_ylabel(ylab1+y_units)
        plt.tight_layout()
        plt.savefig(full_file_name)
        if display_live == True:
            fig.show()
            print("\nDisplaying plot. Press enter to continue...(this closes the images)")
            input()
        plt.close()


    # Function to plot a species for all times at a series of locations
    #   User must provide...
    #       spec = nams of species to plot (must be a gas species)
    #       age = name of ages to plot
    #       temp = name of isothermal temperatures to plot
    #       loc = value of location for variables and data
    #       display_live = (optional) If true, plots will be shown to user during runtime
    #       file_name = (optional) name of file to save
    #       file_type = (optional) type of image file to save as
    def plot_vs_data(self, spec, age, temp, loc,
                    display_live=False, file_name="", file_type=".png"):
        if spec not in self.model.gas_set:
            if self.isSurfSpecSet == True:
                if spec not in self.model.surf_set:
                    raise Exception("Error! Species name not found in set of model surfaces. "
                                +str(spec)+" given is not in model.surf_set")
            else:
                raise Exception("Error! Species name not found in set of model gases. "
                            +str(spec)+" given is not in model.gas_set")
        if self.isDataGasSpecSet == True:
            if spec not in self.model.data_gas_set:
                if self.isSurfSpecSet == True:
                    if spec not in self.model.data_surface_set:
                        raise Exception("Error! Species name not found in set of data surfaces. "
                                    +str(spec)+" given is not in model.data_surface_set")
                else:
                    raise Exception("Error! Species name not found in set of data gases. "
                                +str(spec)+" given is not in model.data_gas_set")
        else:
            if self.isSurfSpecSet == True:
                if spec not in self.model.data_surface_set:
                    raise Exception("Error! Species name not found in set of data surfaces. "
                                +str(spec)+" given is not in model.data_surface_set")

        if age not in self.model.age_set:
            raise Exception("Error! Age name not found in set of model ages. "
                            +str(age)+" given is not in model.age_set")
        if age not in self.model.data_age_set:
            raise Exception("Error! Age name not found in set of data ages. "
                            +str(age)+" given is not in model.data_age_set")

        if temp not in self.model.T_set:
            raise Exception("Error! Temperature name not found in set of model temperatures. "
                            +str(temp)+" given is not in model.T_set")
        if temp not in self.model.data_T_set:
            raise Exception("Error! Temperature name not found in set of data temperatures. "
                            +str(temp)+" given is not in model.data_T_set")

        true_loc = loc
        true_data_loc = loc
        if loc not in self.model.z_data:
            raise Exception("Error! Location value not found in set of location data. "
                            +str(loc)+" given is not in model.z_data")
        if loc not in self.model.z:
            print("WARNING: Given location is not a node in the mesh. Updating to nearest node")
            nearest_loc_index = self.model.z.find_nearest_index(loc)
            #true_loc = self.model.z[nearest_loc_index]
            true_loc = self.model.z.at(nearest_loc_index)

        #Check file name and type
        if file_name == "":
            file_name+=spec+"_"+age+"_"+temp+"_at_"+str(loc)

        folder="output/"
        if not os.path.exists(folder):
            os.makedirs(folder)

        if file_type != ".png" and file_type != ".pdf" and file_type != ".ps" and file_type != ".eps" and file_type != ".svg":
            print("Warning! Unsupported image file type...")
            print("\tDefaulting to .png")
            file_type = ".png"

        full_file_name = folder+file_name+"ComparisonPlots"+file_type

        xvals_model = list(self.model.t.data())
        xvals_data = list(self.model.t_data.data())
        fig,ax = plt.subplots(figsize=(10,5))
        leg=[]
        x_units = "(min)"
        y_units = "(mol/L)"
        ylab = spec+"\n"+y_units
        xlab = "Time "+x_units

        leg.append(spec+"_Data")
        if self.isDataGasSpecSet == True:
            if spec in self.model.data_gas_set:
                yvals_data = list(self.model.Cb_data[spec,age,temp,true_data_loc,:].value)
        if self.isDataSurfSpecSet == True:
            if spec in self.model.data_surface_set:
                yvals_data = list(self.model.q_data[spec,age,temp,true_data_loc,:].value)
        ax.plot(xvals_data,yvals_data,'or')

        leg.append(spec+"_Model")
        if spec in self.model.gas_set:
            yvals_model = list(self.model.Cb[spec,age,temp,true_loc,:].value)
        else:
            yvals_model = list(self.model.q[spec,age,temp,true_loc,:].value)
        ax.plot(xvals_model,yvals_model,'-k')

        plt.legend(leg, loc='best')
        ax.set_xlabel(xlab)
        ax.set_ylabel(ylab)
        plt.tight_layout()
        plt.savefig(full_file_name)
        if display_live == True:
            fig.show()
            print("\nDisplaying plot. Press enter to continue...(this closes the images)")
            input()
        plt.close()



# Function to read in data values to be used in objective functions
#   This is the naive read function, which just reads in all information
#   given by the user. There is an optional 'factor' argument that can
#   be used to compress some of the data.
#
#   The data file should contain all time series data for each species
#   that was declared to have data associated with it. User should also
#   use names of the species that make sense in the context of the data.
#   One suggestion is the give a column name as species_age_temp since
#   the data needs to be set for each species at all aging conditions
#   and temperatures. Then, this function returns a dictionary of that
#   information that the user can use to setup the data in the model.
#
#   By default, this method returns a dictionary of lists for time
#   values and each concentration value. However, the user may request
#   to return a dictionary of tuples, where time values get rolled
#   into a tuple for each species as Data[species] = [(time, value), ...]
#   To use this feature, the time values in the input file MUST have
#   "time" in the header name.
#
#   Input file structure:
#   ---------------------
#   time    Spec1   Spec2
#   val     val_s1  val_s2
#   ...     ...     ...
#
#   First column name must be "time" or "Time" or at least contain
#   the time. Each subsequent column must have an associated species
#   name from the declared set of data names. Below each column header
#   should be the time stamped data.
def naively_read_data_file(data_file, factor=1, dict_of_tuples=False):
    Data = {}
    DataTuples = {}
    Values = {}
    TimeValue = 0
    i = 0
    ordered_list = []
    # Read in file and save to dictionary
    reset = {}
    for line in open(data_file, "r"):
        # Read in header that contains species names
        if i==0:
            firstItem = True
            for item in line.split():
                Data[item] = []
                Values[item] = 0
                reset[item] = 1
                ordered_list.append(item)
                if dict_of_tuples == True:
                    if firstItem == True and "time" not in item.lower():
                        raise Exception("Error! Time must be first column if trying to read as tuples")
                    if "time" not in item.lower():
                        DataTuples[item] = []
                firstItem = False
        # Read in data for each species
        else:
            j=0
            for value in line.split():
                Values[ordered_list[j]] += float(value)
                if dict_of_tuples == True and "time" in ordered_list[j].lower():
                    TimeValue += float(value)
                j+=1
            #End column loop
            wasCalc = False
            for item in Data:

                if reset[item] == factor:
                    Values[item] = Values[item]/float(factor)
                    if wasCalc == False:
                        temp_time = TimeValue/float(factor)
                        wasCalc = True
                    reset[item] = 1
                    if dict_of_tuples == False:
                        Data[item].append(Values[item])
                    else:
                        if "time" not in item.lower():
                            DataTuples[item].append( (temp_time, Values[item]) )
                    Values[item] = 0
                    TimeValue = 0
                else:
                    reset[item]+=1
        i+=1
    #End line loop
    if dict_of_tuples == False:
        return Data
    else:
        return DataTuples

# Helper function to intellegently select data points to simulate
#       User must provide...
#           TimeDataList = list of time values that correspond to lists in VarDataDict
#           VarDataDict = dictionary of lists of values of variables that derivatives
#                           will be calculated from
#           start_time = (optional) the first time point to return (default=0)
#           end_time = (optional) the last time point to return
#           maxStep = (optional) maximum allowable step size when selecting points
def time_point_selector(TimeDataList, VarDataDict, start_time=None, end_time=None, maxStep=None):
    if type(TimeDataList) is not list:
        raise Exception("Error! Must provide a list of time points to select from")
    if type(VarDataDict) is not dict:
        raise Exception("Error! Must provide a dictionary of lists of variable values")
    DerivativeVarDataDict = {}
    for spec in VarDataDict:
        if len(TimeDataList) != len(VarDataDict[spec]):
            raise Exception("Error! Dimensional mis-match in data sets. Must have same number of time points as corresponding values")
        if "time" not in spec.lower():
            DerivativeVarDataDict[spec] = [0.0] * len(TimeDataList)
    if maxStep==None:
        maxStep = TimeDataList[-1]/100.0
    if end_time==None:
        end_time = TimeDataList[-1]
    if start_time==None:
        start_time = 0

    selected_times = []
    selected_times.append(start_time)

    # Approximate true derivatives
    i=0
    for time in TimeDataList:
        for spec in DerivativeVarDataDict:
            if i==0:
                DerivativeVarDataDict[spec][i] = 0
            else:
                DerivativeVarDataDict[spec][i] = (VarDataDict[spec][i] - VarDataDict[spec][i-1])/(TimeDataList[i]-TimeDataList[i-1])
        i+=1

    # Normalize derivatives and change all to derivative magnitudes
    for spec in DerivativeVarDataDict:
        maxval = max(DerivativeVarDataDict[spec])
        minval = min(DerivativeVarDataDict[spec])
        val = abs(maxval)
        if abs(maxval) < abs(minval):
            val = abs(minval)
        if val < 1e-20:
            val = 1e-20
        DerivativeVarDataDict[spec][:] = [abs(x) / val for x in DerivativeVarDataDict[spec]]

    # Now, selection points based on the derivatives
    probable_times = []
    stepsizes = []
    probable_times.append(selected_times[0])
    i=0
    j=0
    for time in TimeDataList:
        if time >= start_time and time <= end_time:
            for spec in DerivativeVarDataDict:
                if DerivativeVarDataDict[spec][i] > 0.01:
                    probable_times.append(time)
                    stepsizes.append(probable_times[j+1]-probable_times[j])
                    j+=1
                    break
            # Force another step if needed to prevent too large a step
            if i>0:
                if (time-probable_times[j]) > maxStep:
                    probable_times.append(time)
                    stepsizes.append(probable_times[j+1]-probable_times[j])
                    j+=1
        i+=1
    if probable_times[-1] <= end_time:
        probable_times.append(end_time)

    minstep = min(stepsizes)

    i=0
    j=0
    for time in probable_times:
        if i>0:
            if (probable_times[i]-selected_times[j]) <= minstep*1.2:
                pass
            else:
                selected_times.append(probable_times[i])
                j+=1
        i+=1

    return selected_times
