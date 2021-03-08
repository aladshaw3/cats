# This file is a demo for the 'Isothermal_Monolith_Simulator' object

from isothermal_monolith_catalysis import *

# Testing
test = Isothermal_Monolith_Simulator()
test.add_axial_dim(0,5)
test.add_temporal_dim(0,60)

test.add_age_set("Unaged")
test.add_temperature_set("250C")

test.add_gas_species("NH3")
test.add_surface_species("q1")
test.add_surface_sites("S1")
test.add_reactions({"r1": ReactionType.EquilibriumArrhenius})

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.2)
test.set_linear_velocity(15110)
test.set_mass_transfer_coef(1.12)
test.set_surface_to_volume_ratio(5757.541)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"q1": 1}}
test.set_site_balance("S1",s1_data)

# Reaction specification information (must correspond to correct reaction type)

#   EquilibriumArrhenius
r1_equ = {"parameters": {"A": 250000, "E": 0, "dH": 0, "dS": 108.3467},
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
                    tstep=50,elems=20,colpoints=1)

# Initial conditions and Boundary Conditions should be set AFTER discretization
test.set_const_IC("NH3","Unaged","250C",0)
test.set_const_IC("q1","Unaged","250C",0)
test.set_time_dependent_BC("NH3","Unaged","250C",
                            time_value_pairs=[(0,6.94E-6), (25,0)],
                            initial_value=0)

# Fix the kinetics to only run a simulation
test.fix_all_reactions()
test.run_solver()

test.print_results_of_breakthrough(["NH3"], "Unaged", "250C", file_name="")
test.print_results_of_integral_average(["q1","S1"], "Unaged", "250C", file_name="")
test.print_results_all_locations(["NH3"], "Unaged", "250C", file_name="")
