# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Testing
test = Isothermal_Monolith_Simulator()
test.add_axial_dim(0,5)
test.add_temporal_dim(0,20)

test.add_age_set(["Unaged","2hr"])
test.add_temperature_set(["150C","250C"])

test.add_gas_species("NH3")
test.add_surface_species("q1")
test.add_surface_sites("S1")
test.add_reactions({"r1": ReactionType.EquilibriumArrhenius})

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.2)
test.set_reactor_radius(1)                      #cm
test.set_space_velocity("Unaged","150C",1000)   #volumes / min
test.set_space_velocity("Unaged","250C",1500)
test.set_space_velocity("2hr","150C",500)
test.set_space_velocity("2hr","250C",750)
test.set_cell_density(62)                   # 62 cells per cm^2 (~400 cpsi)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"q1": 1}}
test.set_site_balance("S1",s1_data)

# Reaction specification information (must correspond to correct reaction type)

#   EquilibriumArrhenius
r1_equ = {"parameters": {"A": 250000, "E": 0, "dH": -50000, "dS": 30},
          "mol_reactants": {"S1": 1, "NH3": 1},
          "mol_products": {"q1": 1},
          "rxn_orders": {"S1": 1, "NH3": 1, "q1": 1}
        }

test.set_reaction_info("r1", r1_equ)

test.set_site_density("S1","Unaged",0.1152619)
test.set_site_density("S1","2hr",0.05152619)
test.set_isothermal_temp("Unaged","250C",250+273.15)
test.set_isothermal_temp("Unaged","150C",150+273.15)
test.set_isothermal_temp("2hr","250C",250+273.15)
test.set_isothermal_temp("2hr","150C",150+273.15)

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=10,elems=5,colpoints=1)

# Initial conditions and Boundary Conditions should be set AFTER discretization
test.set_const_IC("NH3","Unaged","150C",0)
test.set_const_IC("q1","Unaged","150C",0)
test.set_const_BC("NH3","Unaged","150C",6.94E-6)

test.set_const_IC("NH3","Unaged","250C",0)
test.set_const_IC("q1","Unaged","250C",0)
test.set_const_BC("NH3","Unaged","250C",6.94E-6)

test.set_const_IC("NH3","2hr","150C",0)
test.set_const_IC("q1","2hr","150C",0)
test.set_const_BC("NH3","2hr","150C",6.94E-6)

test.set_const_IC("NH3","2hr","250C",0)
test.set_const_IC("q1","2hr","250C",0)
test.set_const_BC("NH3","2hr","250C",6.94E-6)

# Fix the kinetics to only run a simulation
test.fix_all_reactions()

# Run initializer and solver
test.initialize_simulator()
test.run_solver()

test.save_model_state(file_name="example3.json")

test.print_results_all_locations(["NH3"], "Unaged", "250C", file_name="")

test.print_results_of_breakthrough(["NH3"], "Unaged", "150C", file_name="")
test.print_results_of_integral_average(["q1"], "Unaged", "150C", file_name="")

test.print_results_of_breakthrough(["NH3"], "Unaged", "250C", file_name="")
test.print_results_of_integral_average(["q1"], "Unaged", "250C", file_name="")

test.print_results_of_breakthrough(["NH3"], "2hr", "150C", file_name="")
test.print_results_of_integral_average(["q1"], "2hr", "150C", file_name="")

test.print_results_of_breakthrough(["NH3"], "2hr", "250C", file_name="")
test.print_results_of_integral_average(["q1"], "2hr", "250C", file_name="")

test.plot_at_locations(["NH3"], ["Unaged","2hr"], ["150C","250C"], [5], display_live=False)
test.plot_at_locations(["q1","S1"], ["Unaged","2hr"], ["150C","250C"], [5], display_live=False)
