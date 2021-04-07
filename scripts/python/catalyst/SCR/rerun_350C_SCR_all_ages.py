#This file is used to rerun a simulation using newly found parameters.
#The purpose is for additional refinement of kinetics. We will reuse this
#script for additional optimization passes.

import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Create a simulator object and Load a full model from json
run = "03"                              #update this number to reflect changes in runs
readfile = 'output/350C_model02.json'     #update this name to reflect which model to load
writefile = "350C_model"+run+".json"

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

#sim.fix_all_reactions()
'''
sim.unfix_reaction("r5")
sim.unfix_reaction("r6")

sim.unfix_reaction("r13a")
sim.unfix_reaction("r14a")

sim.unfix_reaction("r13b")
sim.unfix_reaction("r14b")

sim.unfix_reaction("r21")
sim.unfix_reaction("r22")

sim.unfix_reaction("r29")
sim.unfix_reaction("r30")

sim.unfix_reaction("r37")
sim.unfix_reaction("r38")
'''
#Manually update some parameter bounds to see if we can get better fits
#sim.set_reaction_param_bounds("r37","A",factor=100)
#sim.set_reaction_param_bounds("r38","A",factor=100)


sim.finalize_auto_scaling()
sim.run_solver()

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "350C", file_name="Unaged_SCR_350C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "350C", 0, file_name="Unaged_SCR_350C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "Unaged", "350C", file_name="Unaged_SCR_350C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "350C", file_name="2hr_SCR_350C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "350C", 0, file_name="2hr_SCR_350C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "2hr", "350C", file_name="2hr_SCR_350C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "350C", file_name="4hr_SCR_350C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "350C", 0, file_name="4hr_SCR_350C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "4hr", "350C", file_name="4hr_SCR_350C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "350C", file_name="8hr_SCR_350C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "350C", 0, file_name="8hr_SCR_350C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "8hr", "350C", file_name="8hr_SCR_350C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "350C", file_name="16hr_SCR_350C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "350C", 0, file_name="16hr_SCR_350C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "16hr", "350C", file_name="16hr_SCR_350C_average_ads.txt")

sim.print_kinetic_parameter_info(file_name="350C_opt_params.txt")
sim.save_model_state(file_name=writefile)
