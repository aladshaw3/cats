#This file is used to rerun a simulation using newly found parameters.
#The purpose is for additional refinement of kinetics. We will reuse this
#script for additional optimization passes

import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Create a simulator object and Load a full model from json
run = "02"                              #update this number to reflect changes in runs
readfile = 'output/350C_model.json'     #update this name to reflect which model to load
writefile = "350C_model"+run+".json"

#NOTE: Other output names can remain the same, most important thing is .json file
sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()

sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3a")
sim.fix_reaction("r3b")
sim.fix_reaction("r3c")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")

for rxn in sim.model.arrhenius_rxns:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*0.8,sim.model.A[rxn].value*1.01))

sim.set_reaction_param_bounds("r29", "A", bounds=(sim.model.A["r29"].value*0.90,sim.model.A["r29"].value*1.20))
sim.set_reaction_param_bounds("r37", "A", bounds=(sim.model.A["r37"].value*0.90,sim.model.A["r37"].value*1.20))

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
