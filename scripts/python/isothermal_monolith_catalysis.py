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

# Other import statements
import yaml
import os.path
from os import path
from enum import Enum

# Define an Enum class for reaction types
class ReactionType(Enum):
    Arrhenius = 1
    EquilibriumArrhenius = 2

# Define an Enum class for discretizer types
class DiscretizationMethod(Enum):
    OrthogonalCollocation = 1
    FiniteDifference = 2

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
#                   eb*dCb/dt + eb*v*dCb/dz = -Ga*km*(Cb - C)
#
#           Mass balance in the washcoat (Mandatory)
#
#                   ew*(1-eb)*dC/dt = Ga*km*(Cb - C) + (1-eb)*SUM(all i, u_ci * ri)
#
#           Surface species reaction terms (Optional, if surface species not needed)
#
#                   dq/dt = SUM(all i, u_qi * ri)
#
#           Specific Site Balances (Optional, but required if tracking surface species)
#
#                   Smax = S + SUM(all qi, u_si*qi) = 0


# TODO: Delete notes and testing
'''
name = "Cb"
# This will add a component by name
self.model.add_component(name, Var())
# How to check if component by name already exists
if self.model.find_component("r") == None:
    self.model.add_component("r", Param())
else:
    print("ERROR! Component name already exists")

self.model.pprint()

# This will fetch a component by name
self.model.component(name).pprint()
'''

class Isothermal_Monolith_Simulator(object):
    #Default constructor
    # Pass a list of species names (Specs) for the mass balances
    def __init__(self):
        # Create an empty concrete model
        self.model = ConcreteModel()

        # Add the mandatory components to the model
        #       TODO:     (?) Make all parameters into Var objects (?)
        self.model.eb = Param(within=NonNegativeReals, initialize=0.3309, mutable=True, units=None)
        self.model.ew = Param(within=NonNegativeReals, initialize=0.2, mutable=True, units=None)
        self.model.v = Param(within=Reals, initialize=15110, mutable=True, units=units.cm/units.min)
        self.model.km = Param(within=NonNegativeReals, initialize=1.12, mutable=True, units=units.m/units.min)
        self.model.Ga = Param(within=NonNegativeReals, initialize=5757.541, mutable=True, units=units.m**-1)

        # Add some tracking boolean statements
        self.isBoundsSet = False
        self.isTimesSet = False
        self.isTempSet = False
        self.temp_list = {}
        self.isAgeSet = False
        self.age_list = {}
        self.isGasSpecSet = False
        self.gas_list = {}
        self.isSurfSpecSet = False
        self.surf_list = {}
        self.isSitesSet = False
        self.site_list = {}
        self.isRxnSet = False
        self.isRxnBuilt = False
        self.rxn_list = {}
        self.isConBuilt = False
        self.isDiscrete = False
        self.isInitialSet = {}
        self.isBoundarySet = {}

    # Add a continuous set for spatial dimension (current expected units = cm)
    def add_axial_dim(self, start_point, end_point, point_list=[]):
        if point_list == []:
            self.model.z = ContinuousSet(bounds=(start_point,end_point))
        else:
            self.model.z = ContinuousSet(initialize=point_list)
        self.isBoundsSet = True

    # Add a continuous set for temporal dimension (current expected units = min)
    def add_temporal_dim(self, start_point, end_point, point_list=[]):
        if point_list == []:
            self.model.t = ContinuousSet(bounds=(start_point,end_point))
        else:
            self.model.t = ContinuousSet(initialize=point_list)
        self.isTimesSet = True


    # Add a param set for aging times/conditions [Can be reals, ints, or strings]
    #
    #       Access to model.age param is as follows:
    #       ---------------------------------------
    #           model.age[age, time] =
    #                       catalyst age at simulation time
    def add_age_set(self, ages):
        if self.isTimesSet == False:
            print("Error! Time dimension must be set first!")
            exit()

        if type(ages) is list:
            i=0
            for item in ages:
                key = "age_"+str(i)
                self.age_list[key] = item
                i+=1
            self.model.age_set = Set(initialize=ages)
            self.model.age = Param(self.model.age_set, self.model.t,
                                within=Any, mutable=True, units=None)
            for age in self.model.age_set:
                for time in self.model.t:
                    self.model.age[age, time].set_value(age)
        else:
            self.age_list["age_0"] = ages
            self.model.age_set = Set(initialize=[ages])
            self.model.age = Param(self.model.age_set, self.model.t,
                                    within=Any, mutable=True, units=units.K)
            for age in self.model.age_set:
                for time in self.model.t:
                    self.model.age[age, time].set_value(age)

        self.isAgeSet = True

    # Add a param set for isothermal temperatures [Must be reals]
    #       Currently expects temperatures in K
    #
    #       Access to model.T param is as follows:
    #       ---------------------------------------
    #           model.T[age, temperature, time] =
    #                       isothermal temperature for aging condition at simulation time
    def add_temperature_set(self, temps):
        if self.isTimesSet == False:
            print("Error! Time dimension must be set first!")
            exit()

        if self.isAgeSet == False:
            print("Error! Catalyst ages must be set first!")
            exit()

        if type(temps) is list:
            self.model.T_set = Set(initialize=temps)
            self.model.T = Param(self.model.age_set, self.model.T_set, self.model.t,
                                domain=NonNegativeReals, mutable=True, units=units.K)
            for age in self.model.age_set:
                for temperature in self.model.T_set:
                    for time in self.model.t:
                        self.model.T[age, temperature, time].set_value(298)
        else:
            self.model.T_set = Set(initialize=[temps])
            self.model.T = Param(self.model.age_set, self.model.T_set, self.model.t,
                                        domain=NonNegativeReals, mutable=True, units=units.K)
            for age in self.model.age_set:
                for temperature in self.model.T_set:
                    for time in self.model.t:
                        self.model.T[age, temperature, time].set_value(298)
        self.isTempSet = True

    # Add gas species (both bulk and washcoat) [Must be strings]
    #       Currently expects species concentrations in mol/L
    #
    #       Access to model.Cb and model.C Vars is as follows:
    #       ---------------------------------------
    #           model.Cb( or model.C )[species, age, temperature, location, time] =
    #                       bulk/pore concentration of given species, at given
    #                       aging condition, at given temperature, at given
    #                       axial location, at given simulation time
    #
    #       Access to model.Cb_in Param is as follows:
    #       ---------------------------------------
    #           model.Cb_in[species, age, temperature, time] =
    #                       bulk concentration of given species, at given
    #                       aging condition, at given temperature, at given
    #                       simulation time
    def add_gas_species(self, gas_species):
        if self.isTimesSet == False or self.isBoundsSet == False:
            print("Error! Cannot specify gas species until the time and bounds are set")
            exit()
        if self.isTempSet == False or self.isAgeSet == False:
            print("Error! Cannot specify gas species until the temperatures and ages are set")
            exit()

        if type(gas_species) is list:
            for item in gas_species:
                if isinstance(item, str):
                    self.gas_list[item] = {"bulk": item+"_b",
                                            "washcoat": item+"_w",
                                            "inlet": item+"_in"}
                else:
                    print("Error! Gas species must be a string")
                    exit()
            self.model.gas_set = Set(initialize=gas_species)
            self.model.Cb = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                            self.model.z, self.model.t,
                            domain=NonNegativeReals, bounds=(1e-20,1e5),
                            initialize=1e-20, units=units.mol/units.L)
            self.model.C = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                            self.model.z, self.model.t,
                            domain=NonNegativeReals, bounds=(1e-20,1e5),
                            initialize=1e-20, units=units.mol/units.L)
            self.model.Cb_in = Param(self.model.gas_set, self.model.age_set, self.model.T_set,
                            self.model.t,
                            within=NonNegativeReals, initialize=1e-20,
                            mutable=True, units=units.mol/units.L)
        else:
            if isinstance(gas_species, str):
                self.gas_list[gas_species] = {"bulk": gas_species+"_b",
                                            "washcoat": gas_species+"_w",
                                            "inlet": gas_species+"_in"}
                self.model.gas_set = Set(initialize=[gas_species])
                self.model.Cb = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                                self.model.z, self.model.t,
                                domain=NonNegativeReals, bounds=(1e-20,1e5),
                                initialize=1e-20, units=units.mol/units.L)
                self.model.C = Var(self.model.gas_set, self.model.age_set, self.model.T_set,
                                self.model.z, self.model.t,
                                domain=NonNegativeReals, bounds=(1e-20,1e5),
                                initialize=1e-20, units=units.mol/units.L)
                self.model.Cb_in = Param(self.model.gas_set, self.model.age_set, self.model.T_set,
                                self.model.t,
                                within=NonNegativeReals, initialize=1e-20,
                                mutable=True, units=units.mol/units.L)
            else:
                print("Error! Gas species must be a string")
                exit()
        self.isGasSpecSet = True
        for spec in self.model.gas_set:
            self.isBoundarySet[spec] = False
        self.model.dCb_dz = DerivativeVar(self.model.Cb, wrt=self.model.z, units=units.mol/units.L/units.min)
        self.model.dCb_dt = DerivativeVar(self.model.Cb, wrt=self.model.t, units=units.mol/units.L/units.min)
        self.model.dC_dt = DerivativeVar(self.model.C, wrt=self.model.t, units=units.mol/units.L/units.min)

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
            print("Error! Cannot specify surface species without having gas species")
            exit()
        if type(surf_species) is list:
            for item in surf_species:
                if isinstance(item, str):
                    self.surf_list[item] = item
                else:
                    print("Error! Surface species must be a string")
                    exit()
            self.model.surf_set = Set(initialize=surf_species)
            self.model.q = Var(self.model.surf_set, self.model.age_set, self.model.T_set,
                            self.model.z, self.model.t,
                            domain=NonNegativeReals, bounds=(1e-20,1e5),
                            initialize=1e-20, units=units.mol/units.L)
        else:
            if isinstance(surf_species, str):
                self.surf_list[surf_species] = surf_species
                self.model.surf_set = Set(initialize=[surf_species])
                self.model.q = Var(self.model.surf_set, self.model.age_set, self.model.T_set,
                                self.model.z, self.model.t,
                                domain=NonNegativeReals, bounds=(1e-20,1e5),
                                initialize=1e-20, units=units.mol/units.L)
            else:
                print("Error! Surface species must be a string")
                exit()
        self.isSurfSpecSet = True
        self.model.dq_dt = DerivativeVar(self.model.q, wrt=self.model.t, units=units.mol/units.L/units.min)

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
            print("Error! Cannot specify surface sites without having surface species")
            exit()
        if type(sites) is list:
            for item in sites:
                if isinstance(item, str):
                    self.site_list[item] = item
                else:
                    print("Error! Surface site must be a string")
                    exit()
            self.model.site_set = Set(initialize=sites)
            self.model.S = Var(self.model.site_set, self.model.age_set, self.model.T_set,
                            self.model.z, self.model.t,
                            domain=NonNegativeReals, bounds=(1e-20,1e5),
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
                                domain=NonNegativeReals, bounds=(1e-20,1e5),
                                initialize=1e-20, units=units.mol/units.L)
                self.model.Smax = Param(self.model.site_set, self.model.age_set,
                                self.model.z, self.model.t,
                                within=NonNegativeReals, initialize=1e-20,
                                mutable=True, units=units.mol/units.L)
            else:
                print("Error! Surface sites must be a string")
                exit()

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
            print("Error! Cannot specify reactions before defining species")
            exit()

        if type(rxns) is not dict:
            print("Error! Must specify reactions using a formatted dictionary")
            exit()

        # Iterate through the reaction list
        arr_rxn_list = []
        arr_equ_rxn_list = []
        full_rxn_list = []
        for r in rxns:
            full_rxn_list.append(r)
            # Determine what to do with different reaction types
            if rxns[r] == ReactionType.Arrhenius:
                arr_rxn_list.append(r)
            elif rxns[r] == ReactionType.EquilibriumArrhenius:
                arr_equ_rxn_list.append(r)
            else:
                print("Error! Unsupported 'ReactionType' object")
                exit()

        # Setup model with all reactions (store sets for each type)
        self.model.all_rxns = Set(initialize=full_rxn_list)
        self.model.arrhenius_rxns = Set(initialize=arr_rxn_list)
        self.model.equ_arrhenius_rxns = Set(initialize=arr_equ_rxn_list)

        # All reactions (regardless of type) have some impact on mass balances
        #           Access is [species, rxn]
        self.model.u_C = Param(self.model.gas_set, self.model.all_rxns, domain=Reals,
                                initialize=0, mutable=True)
        if self.isSurfSpecSet == True:
            self.model.u_q = Param(self.model.surf_set, self.model.all_rxns, domain=Reals,
                                    initialize=0, mutable=True)

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
            self.isInitialSet[spec] = False
        #       Access is [rxn, species]
        self.model.rxn_orders = Param(self.model.all_rxns, self.model.all_species_set,
                                    domain=Reals, initialize=0, mutable=True)
        self.isRxnSet = True
        self.rxn_list = rxns

    #========= Setup functions for parameters ===============
    def set_bulk_porosity(self, eb):
        if eb > 1 or eb < 0:
            print("Error! Porosity must be a value between 0 and 1")
            exit()
        self.model.eb.set_value(eb)

    def set_washcoat_porosity(self, ew):
        if ew > 1 or ew < 0:
            print("Error! Porosity must be a value between 0 and 1")
            exit()
        self.model.ew.set_value(ew)

    def set_linear_velocity(self, v):
        self.model.v.set_value(v)

    def set_mass_transfer_coef(self, km):
        self.model.km.set_value(km)

    def set_surface_to_volume_ratio(self, Ga):
        self.model.Ga.set_value(Ga)

    # Site density is a function of aging, thus you provide the
    #       name of the site you want to set and the age that the
    #       given value would correspond to
    def set_site_density(self, site, age, value):
        if self.isSitesSet == False:
            print("Error! Did not specify the existance of surface sites")
            exit()
        for loc in self.model.z:
            for time in self.model.t:
                self.model.Smax[site, age, loc, time].set_value(value)

    # Set the isothermal temperatures for a simulation
    #   Sets all to a constant, can be changed later
    def set_isothermal_temp(self,age,temp,value):
        for time in self.model.t:
            self.model.T[age,temp,time].set_value(value)

    # Setup site balance information (in needed)
    #       To setup the information for a site balance, pass the name of the
    #       site (site) you want to specify, then pass a dictionary containing
    #       relevant site balance information
    def set_site_balance(self, site, info):
        if self.isSitesSet == False:
            print("Error! Cannot set site balance info before specifying that there are sites")
            exit()
        if type(info) is not dict:
            print("Error! Must specify site balances using a formatted dictionary")
            exit()
        if "mol_occupancy" not in info:
            print("Error! Must specify reaction 'mol_occupancy' in dictionary")
            exit()
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
            print("Error! Cannot set reaction parameters before declaring reaction types")
            exit()
        if type(info) is not dict:
            print("Error! Must specify reactions using a formatted dictionary")
            exit()
        if "parameters" not in info:
            print("Error! Must specify reaction 'parameters' in dictionary")
            exit()
        if "mol_reactants" not in info:
            print("Error! Must specify reaction 'mol_reactants' in dictionary")
            exit()
        if "mol_products" not in info:
            print("Error! Must specify reaction 'mol_products' in dictionary")
            exit()
        if "rxn_orders" not in info:
            print("Error! Must specify reaction 'rxn_orders' in dictionary")
            exit()
        if rxn in self.model.arrhenius_rxns:
            self.model.A[rxn].set_value(info["parameters"]["A"])
            self.model.E[rxn].set_value(info["parameters"]["E"])
            try:
                self.model.B[rxn].set_value(info["parameters"]["B"])
            except:
                self.model.B[rxn].set_value(0)
                self.model.B[rxn].fix()
        elif rxn in self.model.equ_arrhenius_rxns:
            self.model.Af[rxn].set_value(info["parameters"]["A"])
            self.model.Ef[rxn].set_value(info["parameters"]["E"])
            self.model.dH[rxn].set_value(info["parameters"]["dH"])
            self.model.dS[rxn].set_value(info["parameters"]["dS"])
        else:
            print("Error! Given reaction name does not exist in model")
            exit()

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
            self.model.u_C[spec,rxn].set_value(u_C_sum)

        if self.isSurfSpecSet == True:
            for spec in self.model.surf_set:
                u_q_sum = 0
                if spec in info["mol_reactants"]:
                    u_q_sum -= info["mol_reactants"][spec]
                if spec in info["mol_products"]:
                    u_q_sum += info["mol_products"][spec]
                self.model.u_q[spec,rxn].set_value(u_q_sum)

        # Set reaction order information
        for spec in self.model.all_species_set:
            if spec in info["rxn_orders"]:
                self.model.rxn_orders[rxn,spec].set_value(info["rxn_orders"][spec])

        self.isRxnBuilt = True

    # Define a single arrhenius rate function to be used in the model
    #       This function assumes the reaction index (rxn) is valid
    def arrhenius_rate_func(self, rxn, model, age, temp, loc, time):
        r = 0
        k = arrhenius_rate_const(model.A[rxn], model.B[rxn], model.E[rxn], model.T[age,temp,time])
        r=k
        for spec in model.component(rxn+"_reactants"):
            if spec in model.gas_set:
                r=r*model.C[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
            if spec in model.surf_set:
                r=r*model.q[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
            if spec in model.site_set:
                r=r*model.S[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
        return r

    # Define a single equilibrium arrhenius rate function to be used in the model
    #       This function assumes the reaction index (rxn) is valid
    def equilibrium_arrhenius_rate_func(self, rxn, model, age, temp, loc, time):
        r = 0
        (Ar, Er) = equilibrium_arrhenius_consts(model.Af[rxn], model.Ef[rxn], model.dH[rxn], model.dS[rxn])
        kf = arrhenius_rate_const(model.Af[rxn], 0, model.Ef[rxn], model.T[age,temp,time])
        kr = arrhenius_rate_const(Ar, 0, Er, model.T[age,temp,time])
        rf=kf
        rr=kr
        for spec in model.component(rxn+"_reactants"):
            if spec in model.gas_set:
                rf=rf*model.C[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
            if spec in model.surf_set:
                rf=rf*model.q[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
            if spec in model.site_set:
                rf=rf*model.S[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
        for spec in model.component(rxn+"_products"):
             if spec in model.gas_set:
                 rr=rr*model.C[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
             if spec in model.surf_set:
                 rr=rr*model.q[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
             if spec in model.site_set:
                 rr=rr*model.S[spec,age,temp,loc,time]**model.rxn_orders[rxn,spec]
        r = rf-rr
        return r

    # Define a function for the reaction sum for gas species
    def reaction_sum_gas(self, gas_spec, model, age, temp, loc, time):
        r_sum=0
        for r in model.arrhenius_rxns:
            r_sum += model.u_C[gas_spec,r]*self.arrhenius_rate_func(r, model, age, temp, loc, time)
        for re in model.equ_arrhenius_rxns:
            r_sum += model.u_C[gas_spec,re]*self.equilibrium_arrhenius_rate_func(re, model, age, temp, loc, time)
        return r_sum

    # Define a function for the reaction sum for surface species
    def reaction_sum_surf(self, surf_spec, model, age, temp, loc, time):
        r_sum=0
        for r in model.arrhenius_rxns:
            r_sum += model.u_q[surf_spec,r]*self.arrhenius_rate_func(r, model, age, temp, loc, time)
        for re in model.equ_arrhenius_rxns:
            r_sum += model.u_q[surf_spec,re]*self.equilibrium_arrhenius_rate_func(re, model, age, temp, loc, time)
        return r_sum

    # Define a function for the site sum
    def site_sum(self, site_spec, model, age, temp, loc, time):
        sum = 0
        for surf_spec in model.surf_set:
            sum+=model.u_S[site_spec,surf_spec]*model.q[surf_spec,age,temp,loc,time]
        return sum

    # Bulk mass balance constraint
    def bulk_mb_constraint(self, m, gas, age, temp, z, t):
        return m.eb*m.dCb_dt[gas, age, temp, z, t] + m.eb*m.v*m.dCb_dz[gas, age, temp, z, t] == -m.Ga*m.km*(m.Cb[gas, age, temp, z, t] - m.C[gas, age, temp, z, t])

    # Washcoat mass balance constraint
    def pore_mb_constraint(self, m, gas, age, temp, z, t):
        rxn_sum=self.reaction_sum_gas(gas, m, age, temp, z, t)
        return m.ew*(1-m.eb)*m.dC_dt[gas, age, temp, z, t] == m.Ga*m.km*(m.Cb[gas, age, temp, z, t] - m.C[gas, age, temp, z, t]) + (1-m.eb)*rxn_sum

    # Adsorption/surface mass balance constraint
    def surf_mb_constraint(self, m, surf, age, temp, z, t):
        rxn_sum=self.reaction_sum_surf(surf, m, age, temp, z, t)
        return m.dq_dt[surf, age, temp, z, t] == rxn_sum

    # Site density balance constraint
    def site_bal_constraint(self, m, site, age, temp, z, t):
        sum=self.site_sum(site, m, age, temp, z, t)
        return m.Smax[site,age,z,t] - m.S[site, age, temp, z, t] - sum == 0

    # Build Constraints
    def build_constraints(self):
        if self.isRxnBuilt == False:
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
        self.isConBuilt = True

    # Apply a discretizer
    def discretize_model(self, method=DiscretizationMethod.FiniteDifference, elems=20, tstep=100, colpoints=1):
        if self.isConBuilt == False:
            print("Error! Must build the constraints before calling a discretizer")
            exit()

        # Apply the discretizer method
        fd_discretizer = TransformationFactory('dae.finite_difference')
        # Secondary discretizer is for orthogonal collocation methods (if desired)
        oc_discretizer = TransformationFactory('dae.collocation')

        # discretization in time
        fd_discretizer.apply_to(self.model,nfe=tstep,wrt=self.model.t,scheme='BACKWARD')

        if method == DiscretizationMethod.FiniteDifference:
            fd_discretizer.apply_to(self.model,nfe=elems,wrt=self.model.z,scheme='BACKWARD')
        elif method == DiscretizationMethod.OrthogonalCollocation:
            oc_discretizer.apply_to(self.model,nfe=elems,wrt=self.model.z,ncp=colpoints,scheme='LAGRANGE-RADAU')
        else:
            print("Error! Unrecognized discretization method")
            exit()

        # Before exiting, we should initialize some additional parameters that
        #   the discretizer doesn't already handle

        #       Initialize Cb_in
        for spec in self.model.gas_set:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    val = value(self.model.Cb_in[spec,age,temp,self.model.t.first()])
                    for time in self.model.t:
                        self.model.Cb_in[spec,age,temp, time].set_value(val)

        #       Initialize T
        for age in self.model.age_set:
            for temp in self.model.T_set:
                val = value(self.model.T[age,temp,self.model.t.first()])
                for time in self.model.t:
                    self.model.T[age,temp,time] = val

        #       Initialize age set
        for age in self.model.age_set:
            val = value(self.model.age[age,self.model.t.first()])
            for time in self.model.t:
                self.model.age[age,time].set_value(val)

        #       Initialize Smax
        if self.isSitesSet == True:
            for site in self.model.site_set:
                for age in self.model.age_set:
                    val = value(self.model.Smax[site,age,self.model.z.first(),self.model.t.first()])
                    for loc in self.model.z:
                        for time in self.model.t:
                            self.model.Smax[site,age,loc,time].set_value(val)

        # For PDE portions, fix the first time derivative at the first node
        for spec in self.model.gas_set:
            for age in self.model.age_set:
                for temp in self.model.T_set:
                    self.model.dCb_dt[spec,age,temp,self.model.z.first(),self.model.t.first()].set_value(0)
                    self.model.dCb_dt[spec,age,temp,self.model.z.first(),self.model.t.first()].fix()

        self.isDiscrete = True

    # Set constant initial conditions
    def set_const_IC(self,spec,age,temp,value):
        if spec in self.model.gas_set:
            self.model.Cb[spec,age,temp, :, self.model.t.first()].set_value(value)
            self.model.Cb[spec,age,temp, :, self.model.t.first()].fix()
            self.model.C[spec,age,temp, :, self.model.t.first()].set_value(value)
            self.model.C[spec,age,temp, :, self.model.t.first()].fix()
            self.isInitialSet[spec] = True
        if spec in self.model.surf_set:
            self.model.q[spec,age,temp, :, self.model.t.first()].set_value(value)
            self.model.q[spec,age,temp, :, self.model.t.first()].fix()
            self.isInitialSet[spec] = True
        if spec in self.model.site_set:
            # Do not set this initial value (not a time dependent variable)
            self.isInitialSet[spec] = True

    # Set constant boundary conditions
    def set_const_BC(self,spec,age,temp,value):
        if spec not in self.model.gas_set:
            print("Error! Cannot specify boundary value for non-gas species")
            exit()

        if self.isInitialSet[spec] == False:
            print("Error! User must specify initial conditions before boundary conditions")
            exit()

        for time in self.model.t:
            self.model.Cb_in[spec,age,temp, time].set_value(value)

        self.model.Cb[spec,age,temp,self.model.z.first(), :].set_value(value)
        self.model.Cb[spec,age,temp,self.model.z.first(), :].fix()
        self.isBoundarySet[spec] = True


    # Function to fix all kinetic vars
    def fix_all_reactions(self):
        for r in self.model.arrhenius_rxns:
            self.model.A[r].fix()
            self.model.B[r].fix()
            self.model.E[r].fix()
        for re in self.model.equ_arrhenius_rxns:
            self.model.Af[re].fix()
            self.model.Ef[re].fix()
            self.model.dH[re].fix()
            self.model.dS[re].fix()

    # Function to fix only a given reaction
    def fix_reaction(self, rxn):
        if rxn in self.model.arrhenius_rxns:
            self.model.A[rxn].fix()
            self.model.B[rxn].fix()
            self.model.E[rxn].fix()
        if rxn in self.model.equ_arrhenius_rxns:
            self.model.Af[rxn].fix()
            self.model.Ef[rxn].fix()
            self.model.dH[rxn].fix()
            self.model.dS[rxn].fix()

    # Function to fix all equilibrium relations
    def fix_all_equilibrium_relations(self):
        for re in self.model.equ_arrhenius_rxns:
            self.model.dH[re].fix()
            self.model.dS[re].fix()

    # Function to fix a given equilibrium relation
    def fix_equilibrium_relation(self, rxn):
        if rxn in self.model.equ_arrhenius_rxns:
            self.model.dH[rxn].fix()
            self.model.dS[rxn].fix()

    # # TODO: Add a solver (Check for existance of objective function or data)
