import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Create a simulator object and Load a full model from json
test = Isothermal_Monolith_Simulator()
test.load_model_full('output/example.json')
test.fix_all_reactions()

test.initialize_auto_scaling()
test.initialize_simulator()

test.finalize_auto_scaling()
test.run_solver()

test.print_results_of_breakthrough(["NH3"], "Unaged", "250C", file_name="loaded_breakthrough.txt")
test.print_results_of_integral_average(["q1"], "Unaged", "250C", file_name="loaded_integral.txt")

test2 = Isothermal_Monolith_Simulator()
test2.load_model_full('output/example2.json')

test2.fix_all_reactions()
#Skip autoscaling since ppm problem is already well scaled
test2.initialize_simulator()
test2.run_solver()
