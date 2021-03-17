# This file is a demo for the 'Isothermal_Monolith_Simulator' object

from isothermal_monolith_catalysis import *

# Fake data for testing
times = [3,
        6,
        9,
        12,
        15,
        18,
        21,
        24,
        27,
        30,
        33,
        36,
        39,
        42,
        45,
        48,
        51,
        54,
        57,
        60]

data = [9.66E-21,
        1.36E-07,
        1.61E-07,
        1.28E-06,
        1.70E-06,
        6.56E-06,
        6.78E-06,
        6.90E-06,
        6.56E-06,
        3.06E-06,
        9.37E-07,
        3.14E-07,
        4.31E-07,
        1.68E-07,
        3.44E-07,
        2.35E-07,
        2.91E-07,
        2.95E-07,
        1.52E-07,
        1.97E-07]

# Testing
test = Isothermal_Monolith_Simulator()
test.add_axial_dim(0,5)
test.add_axial_dataset(5)       # Location of observations (in cm)

test.add_temporal_dim(0,60)
test.add_temporal_dataset(times)         #Temporal observations (in s)

test.add_age_set("Unaged")
test.add_data_age_set("Unaged")             # Data observations can be a sub-set

test.add_temperature_set("250C")
test.add_data_temperature_set("250C")     # Data observations can be a sub-set

test.add_gas_species("NH3")
test.add_data_gas_species("NH3")         # Data observations can be a sub-set

# Set data as (spec, age, temp, loc, time_list, value_list)
test.set_data_values_for("NH3","Unaged","250C",5,times,data)

test.add_surface_species("q1")
test.add_surface_sites("S1")
test.add_reactions({"r1": ReactionType.EquilibriumArrhenius})

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.2)
test.set_reactor_radius(1)
test.set_space_velocity_all_runs(1000)
test.set_mass_transfer_coef(1.12)
test.set_surface_to_volume_ratio(5757.541)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"q1": 1}}
test.set_site_balance("S1",s1_data)

# Reaction specification information (must correspond to correct reaction type)

#   EquilibriumArrhenius
r1_equ = {"parameters": {"A": 2500000000, "E": 0, "dH": -54000, "dS": 30},
          "mol_reactants": {"S1": 1, "NH3": 1},
          "mol_products": {"q1": 1},
          "rxn_orders": {"S1": 1, "NH3": 1, "q1": 1}
        }

test.set_reaction_info("r1", r1_equ)

test.set_site_density("S1","Unaged",0.1152619)
test.set_isothermal_temp("Unaged","250C",250+273.15)

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=20,elems=5,colpoints=1)

# Initial conditions and Boundary Conditions should be set AFTER discretization
test.set_const_IC("NH3","Unaged","250C",0)
test.set_const_IC("q1","Unaged","250C",0)
test.set_time_dependent_BC("NH3","Unaged","250C",
                            time_value_pairs=[(5,6.94E-6), (30,0)],
                            initial_value=0)

# Fix the kinetics to only run a simulation
#test.fix_all_reactions()

# Objective weight factor
#test.set_weight_factor("NH3","Unaged","250C",1e10)

# Manually adding scaling factors to the model
test.model.scaling_factor = Suffix(direction=Suffix.EXPORT)


test.model.scaling_factor.set_value(test.model.Cb, 1e6)
test.model.scaling_factor.set_value(test.model.C, 1e6)
test.model.scaling_factor.set_value(test.model.q, 10)
test.model.scaling_factor.set_value(test.model.S, 10)
#test.model.scaling_factor.set_value(test.model.dCb_dt, 1e6)
#test.model.scaling_factor.set_value(test.model.dCb_dz, 1e6)
#test.model.scaling_factor.set_value(test.model.dC_dt, 1e6)
#test.model.scaling_factor.set_value(test.model.dq_dt, 1e6)


test.model.scaling_factor.set_value(test.model.obj, 1e12)
'''
test.model.scaling_factor.set_value(test.model.bulk_cons, 1e4)
test.model.scaling_factor.set_value(test.model.pore_cons, 1e4)
test.model.scaling_factor.set_value(test.model.surf_cons, 1e4)
test.model.scaling_factor.set_value(test.model.site_cons, 1e4)
'''

test.model.scaling_factor.set_value(test.model.Af, 1/2500000000)
test.model.scaling_factor.set_value(test.model.Ef, 1)
test.model.scaling_factor.set_value(test.model.dH, 1/54000)
test.model.scaling_factor.set_value(test.model.dS, 1/30)

# Reasonable solutions cannot be obtained without variable scaling 

test.initialize_simulator()
test.run_solver()

#test.model.obj.pprint()

test.print_results_of_breakthrough(["NH3"], "Unaged", "250C", file_name="")
test.print_results_of_integral_average(["q1","S1"], "Unaged", "250C", file_name="")
test.print_results_all_locations(["NH3","q1","S1"], "Unaged", "250C", file_name="")
