import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Create a simulator object and Load a full model from json
test = Isothermal_Monolith_Simulator()
test.load_model_state_as_IC('output/example.json', new_time_window=(60,119), tstep=60)

#Unlike when loading a full model, you MUST now add in new BCs before solving
#       Additionally, you will need to add new temperature ramps, space-velocities,
#       and/or inlet pressures if needed. Otherwise, model will assume that the
#       temperatures, velocities, and pressures are carried over from the last
#       state and remain constant.
test.set_const_BC("NH3","Unaged","250C",0)
test.set_temperature_ramp("Unaged", "250C", 60, 120, 500+273)

test.fix_all_reactions()

test.initialize_auto_scaling()
test.initialize_simulator(console_out=False)

test.finalize_auto_scaling()
test.run_solver()

test.print_results_of_breakthrough(["NH3"], "Unaged", "250C", file_name="loaded_state_breakthrough.txt")
test.print_results_of_integral_average(["q1"], "Unaged", "250C", file_name="loaded_state_integral.txt")
