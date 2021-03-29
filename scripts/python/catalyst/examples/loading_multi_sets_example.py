import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Create a simulator object and Load a full model from json
test = Isothermal_Monolith_Simulator()
test.load_model_state_as_IC('output/example3.json', new_time_window=(20,80), tstep=60)

#NOTE: When there are multiple data sets, user MUST provide BCs for all conditions
#       (i.e., all species, aging conditions, and temperature sets)
test.set_time_dependent_BC("NH3","Unaged","150C",
                            time_value_pairs=[(30,0)],
                            initial_value=6.94E-6)
test.set_temperature_ramp("Unaged", "150C", 30, 80, 500+273)

test.set_time_dependent_BC("NH3","Unaged","250C",
                            time_value_pairs=[(30,0)],
                            initial_value=6.94E-6)
test.set_temperature_ramp("Unaged", "250C", 30, 80, 500+273)

test.set_time_dependent_BC("NH3","2hr","150C",
                            time_value_pairs=[(30,0)],
                            initial_value=6.94E-6)
test.set_temperature_ramp("2hr", "150C", 30, 80, 500+273)

test.set_time_dependent_BC("NH3","2hr","250C",
                            time_value_pairs=[(30,0)],
                            initial_value=6.94E-6)
test.set_temperature_ramp("2hr", "250C", 30, 80, 500+273)

test.fix_all_reactions()

test.initialize_auto_scaling()
test.initialize_simulator()

test.finalize_auto_scaling()
test.run_solver()

test.print_results_of_breakthrough(["NH3"], "Unaged", "150C", file_name="")
test.print_results_of_integral_average(["q1"], "Unaged", "150C", file_name="")

test.print_results_of_breakthrough(["NH3"], "Unaged", "250C", file_name="")
test.print_results_of_integral_average(["q1"], "Unaged", "250C", file_name="")

test.print_results_of_breakthrough(["NH3"], "2hr", "150C", file_name="")
test.print_results_of_integral_average(["q1"], "2hr", "150C", file_name="")

test.print_results_of_breakthrough(["NH3"], "2hr", "250C", file_name="")
test.print_results_of_integral_average(["q1"], "2hr", "250C", file_name="")
