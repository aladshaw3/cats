#This file is used to rerun a simulation using newly found parameters.
#The purpose is for additional refinement of kinetics. We will reuse this
#script for additional optimization passes.

import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Create a simulator object and Load a full model from json
run = "02"                              #update this number to reflect changes in runs
readfile = 'output/250C_model.json'     #update this name to reflect which model to load
writefile = "250C_model"+run+".json"

#NOTE: Other output names can remain the same, most important thing is .json file
sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3a")
sim.fix_reaction("r3b")
sim.fix_reaction("r3c")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")

#Should fix also the reactions for ammonia oxidation (need them to keep their relevence)
#sim.fix_reaction("r5")
#sim.fix_reaction("r13a")
#sim.fix_reaction("r13b")
#sim.fix_reaction("r21")
#sim.fix_reaction("r29")
#sim.fix_reaction("r37")
sim.fix_all_reactions()

sim.finalize_auto_scaling()
sim.run_solver()

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "250C", file_name="Unaged_SCR_250C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "250C", 0, file_name="Unaged_SCR_250C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "Unaged", "250C", file_name="Unaged_SCR_250C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "250C", file_name="2hr_SCR_250C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "250C", 0, file_name="2hr_SCR_250C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "2hr", "250C", file_name="2hr_SCR_250C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "250C", file_name="4hr_SCR_250C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "250C", 0, file_name="4hr_SCR_250C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "4hr", "250C", file_name="4hr_SCR_250C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "250C", file_name="8hr_SCR_250C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "250C", 0, file_name="8hr_SCR_250C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "8hr", "250C", file_name="8hr_SCR_250C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "250C", file_name="16hr_SCR_250C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "250C", 0, file_name="16hr_SCR_250C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "16hr", "250C", file_name="16hr_SCR_250C_average_ads.txt")

sim.print_kinetic_parameter_info(file_name="250C_opt_params.txt")
sim.save_model_state(file_name=writefile)

sim.print_results_all_locations(["NH3","q3a","S3a"], "Unaged", "250C", file_name="check_res.txt")
