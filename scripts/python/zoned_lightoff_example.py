# This file is a demo for the 'Isothermal_Monolith_Simulator' object

from isothermal_monolith_catalysis import *

# Testing
test = Isothermal_Monolith_Simulator()
test.add_axial_dim(0,5)         #cm
test.add_temporal_dim(0,5160)   #s

test.add_age_set("A0")
test.add_temperature_set("T0")

test.add_gas_species(["CO","O2","NO","CO2","N2"])
test.add_reactions({"r1": ReactionType.Arrhenius,
                    "r4": ReactionType.Arrhenius})

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.2)
test.set_reactor_radius(1)                  # cm
test.set_space_velocity_all_runs(8.333)     # s^-1
test.set_mass_transfer_coef(0.018667)       #m/s
test.set_surface_to_volume_ratio(5145)      #m^-1

#   Arrhenius
r1 = {"parameters": {"A": 1.00466E+18, "E": 205901.5765},
          "mol_reactants": {"CO": 1, "O2": 0.5},
          "mol_products": {"CO2": 1},
          "rxn_orders": {"CO": 1, "O2": 1}
        }

r4 = {"parameters": {"A": 2.816252679, "E": 28675.21769},
          "mol_reactants": {"CO": 1, "NO": 1},
          "mol_products": {"CO2": 1, "N2": 0.5},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

test.set_reaction_info("r1", r1)
test.set_reaction_info("r4", r4)

test.set_isothermal_temp("A0","T0",393.15) # K

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=20,elems=5,colpoints=1)

# Initial conditions and Boundary Conditions should be set AFTER discretization
#       Units of concentration here are in ppm
test.set_const_IC("CO","A0","T0",5084)
test.set_const_IC("O2","A0","T0",7080)
test.set_const_IC("NO","A0","T0",1055)
test.set_const_IC("N2","A0","T0",0)
test.set_const_IC("CO2","A0","T0",0)

test.set_const_BC("CO","A0","T0",5084)
test.set_const_BC("O2","A0","T0",7080)
test.set_const_BC("NO","A0","T0",1055)
test.set_const_BC("N2","A0","T0",0)
test.set_const_BC("CO2","A0","T0",0)

# Setup temperature ramp
test.set_temperature_ramp("A0", "T0", 120, 5160, 813.15)

# Specify a reaction zone
#   Zone is specified as a tuple: (start_zone, end_zone)
test.set_reaction_zone("r4", (2.5, 5))
#   NOTE: If you have multiple zones where a reaction may be active, then
#           you should use the function below to specify sets of zones where
#           the reaction is NOT active. This is because only the 'NOT' version
#           of this function is additive (whereas the standard function would
#           override susequent zoning information)
#test.set_reaction_zone("r4", (0, 2.5), isNotActive=True)

# Fix the kinetics to only run a simulation
test.fix_all_reactions()
test.initialize_simulator()
test.run_solver()

test.print_results_of_breakthrough(["CO","NO","O2"], "A0", "T0", file_name="Zoned_breakthrough.txt")
test.print_results_all_locations(["CO","NO","O2"], "A0", "T0", file_name="")
