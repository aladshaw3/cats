# This file is a demo for the 'Nonisothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')

from catalyst.nonisothermal_monolith_catalysis import *

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
        60,
        65,
        70]

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
        1.97E-07,
        1e-8,
        1e-9]

# Testing
test = Nonisothermal_Monolith_Simulator()
test.add_axial_dim(0,5)
test.add_axial_dataset(5)       # Location of observations (in cm)

test.add_temporal_dim(0,60)
test.add_temporal_dataset(times)         #Temporal observations (in min)

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
test.set_washcoat_porosity(0.4)
test.set_reactor_radius(1)                      # cm
test.set_space_velocity_all_runs(1000)          # volumes per min
test.set_cell_density(62)                       # 62 cells per cm^2 (~400 cpsi)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"q1": 1}}
test.set_site_balance("S1",s1_data)

# Reaction specification information (must correspond to correct reaction type)

#   EquilibriumArrhenius
#       NOTE: You can provide parameter bounds here, or later
r1_equ = {"parameters": {"A": 25000, "E": 0,
                        #"A_lb": 2500, "A_ub": 2500000000,
                        "dH": -54000, "dS": 30},
          "mol_reactants": {"S1": 1, "NH3": 1},
          "mol_products": {"q1": 1},
          "rxn_orders": {"S1": 1, "NH3": 1, "q1": 1}
        }
test.set_reaction_info("r1", r1_equ)

#Manually change individual parameter bounds
test.set_reaction_param_bounds("r1","A",bounds=(2500, 2500000000))
test.set_reaction_param_bounds("r1","dH",factor=10)
test.set_reaction_param_bounds("r1","dS",factor=0.4)

test.set_site_density("S1","Unaged",0.1152619)

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=20,elems=5,colpoints=2)

# Set temperature info after discretizer
test.set_const_temperature_IC("Unaged","250C",250+273.15)
test.set_const_temperature_BC("Unaged","250C",250+273.15)
test.set_const_ambient_temperature("Unaged","250C",250+273.15)

# Initial conditions and Boundary Conditions should be set AFTER setting temperatures
test.set_const_IC_in_ppm("NH3","Unaged","250C",0)
test.set_const_IC("q1","Unaged","250C",0)
test.set_time_dependent_BC_in_ppm("NH3","Unaged","250C",
                            time_value_pairs=[(5,300), (30,0)],
                            initial_value=0)

# Fix the kinetics and/or heats of reaction to only run a simulation
#test.fix_all_reactions()
test.model.dHrxn["r1"].set_value(-54000)
#test.model.dHrxn["r1"].set_value(0)

test.fix_all_heats()

#test.isObjectiveSet = False
#test.model.del_component(test.model.obj)

test.initialize_auto_scaling()
test.initialize_simulator(console_out=False)
#test.model.cpg.pprint()
test.finalize_auto_scaling()
test.run_solver()

test.print_results_of_breakthrough(["NH3"], "Unaged", "250C", file_name="noniso_ads.txt", include_temp=True)

test.save_model_state(file_name="noniso_example.json")

test.print_kinetic_parameter_info(file_name="noniso_example_params.txt")

test.plot_at_locations(["NH3"], ["Unaged"], ["250C"], [5], display_live=False)
test.plot_at_locations(["q1","S1"], ["Unaged"], ["250C"], [5], display_live=False)

test.plot_at_locations(["NH3"], ["Unaged"], ["250C"], [0,1,2,3,4,5], display_live=False)
test.plot_at_locations(["q1","S1"], ["Unaged"], ["250C"], [0,1,2,3,4,5], display_live=False)

test.plot_at_times(["q1"], ["Unaged"], ["250C"], [0,10,20,30,40,50,60], display_live=False)
test.plot_at_times(["NH3"], ["Unaged"], ["250C"], [0,10,20,30,40,50,60], display_live=False)

test.plot_vs_data("NH3", "Unaged", "250C", 5, display_live=True)

test.plot_temperature_at_locations(["Unaged"], ["250C"], [5], display_live=True)

test.plot_temperature_at_times(["Unaged"], ["250C"], [5,10,15], display_live=False)
