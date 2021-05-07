# This file is a demo for the 'Nonisothermal_Monolith_Simulator' object
#       Demo is to setup a coupled system for inert gas
import sys
sys.path.append('../..')

from catalyst.nonisothermal_monolith_catalysis import *

# Testing
test = Nonisothermal_Monolith_Simulator()
test.add_axial_dim(0,5)

test.add_temporal_dim(0,5)

test.add_age_set("Unaged")

test.add_temperature_set("250C")

test.add_gas_species("N2")

# NOTE: Even if you have no reactions, you still need to call this function
#       Just pass a blank dictionary to it.
test.add_reactions({})

# # TODO: Add a boundary for porosity of 1
#test.set_bulk_porosity(0.9999)
test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.4)
test.set_reactor_radius(1)                      # cm
# # TODO: Add the ability to change space velocity as a function of time
# # TODO: Add a boundary for velocity of zero
#test.set_space_velocity_all_runs(1e-6)          # volumes per min
test.set_space_velocity_all_runs(1000)   
test.set_cell_density(62)                       # 62 cells per cm^2 (~400 cpsi)

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=20,elems=5,colpoints=2)

# Set temperature info after discretizer
test.set_const_temperature_IC("Unaged","250C",250+273.15)
test.set_const_temperature_BC("Unaged","250C",250+273.15)
test.set_const_ambient_temperature("Unaged","250C",25+273.15)

# Initial conditions and Boundary Conditions should be set AFTER setting temperatures
test.set_const_IC_in_ppm("N2","Unaged","250C",7900000)
test.set_time_dependent_BC_in_ppm("N2","Unaged","250C",
                            time_value_pairs=[(5,7900000), (30,7900000)],
                            initial_value=7900000)

# Fix the kinetics and/or heats of reaction to only run a simulation
test.fix_all_reactions()
test.fix_all_heats()

test.initialize_auto_scaling()
test.initialize_simulator(console_out=False)

test.finalize_auto_scaling()
options={'max_iter': 100}
test.run_solver(options=options)

test.plot_temperature_at_locations(["Unaged"], ["250C"], [5], display_live=True)

test.plot_temperature_at_times(["Unaged"], ["250C"], [5,10,15], display_live=False)
