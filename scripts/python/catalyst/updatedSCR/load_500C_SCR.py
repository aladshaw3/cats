#This file is used to rerun a simulation using newly found parameters.
#The purpose is for additional refinement of kinetics. We will reuse this
#script for additional optimization passes.

import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Create a simulator object and Load a full model from json
run = "05"                              #update this number to reflect changes in runs
readfile = 'output/500C_model04.json'     #update this name to reflect which model to load
writefile = "500C_model"+run+".json"

#NOTE: Other output names can remain the same, most important thing is .json file
sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()
sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")

# NOTE: This downward bias helps tremendously with the fits (try at higher temps as well)
old_rxns = ["r5f","r5r","r6f","r6r","r7","r8","r9","r13","r14","r15","r18","r19"]
new_rxns = ["r16","r17","r20","r21","r22","r23","r24","r25","r26","r27","r28","r29","r30","r31","r32","r33"]
new_oxd_rxns = ["r10","r11","r12"]
cuo_rxns = ["r34","r35","r36"]
n2o_rxns = ["r37","r38","r39"]

upper = 1+1
lower = 1-0.5
for rxn in old_rxns:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))
    #sim.fix_reaction(rxn)

upper = 1+1
lower = 1-0.5
for rxn in new_rxns:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))
    #sim.fix_reaction(rxn)

upper_val = 20000
lower_val = 10000
upper = 1+5
lower = 1-0.2
for rxn in new_oxd_rxns:
    #sim.set_reaction_param_bounds(rxn, "A", bounds=(lower_val,upper_val))
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))
    #sim.fix_reaction(rxn)
#sim.set_reaction_param_bounds("r12", "A", bounds=(350,700))

upper_val = 400000
lower_val = 100000
upper = 1+5
lower = 1-0.2
for rxn in cuo_rxns:
    #sim.set_reaction_param_bounds(rxn, "A", bounds=(lower_val,upper_val))
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))
    #sim.fix_reaction(rxn)
#sim.set_reaction_param_bounds("r36", "A", bounds=(10000,40000))

upper_val = 10000
lower_val = 0
upper = 1+5
lower = 1-0.2
for rxn in n2o_rxns:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(lower_val,upper_val))
    #sim.fix_reaction(rxn)
#sim.set_reaction_param_bounds("r37", "A", bounds=(500,10000))
#sim.set_reaction_param_bounds("r38", "A", bounds=(35,700))
#sim.set_reaction_param_bounds("r39", "A", bounds=(0.0035,0.7))

#Customize the weight factors
sim.auto_select_all_weight_factors()

#Select specific weight factor windows based on observed data
sim.ignore_weight_factor("NH3","Unaged","500C",time_window=(70,150))
sim.ignore_weight_factor("NO","Unaged","500C",time_window=(70,150))
sim.ignore_weight_factor("NO2","Unaged","500C",time_window=(70,150))
sim.ignore_weight_factor("N2O","Unaged","500C",time_window=(70,150))

sim.ignore_weight_factor("NH3","2hr","500C",time_window=(128,150))
sim.ignore_weight_factor("NO","2hr","500C",time_window=(128,150))
sim.ignore_weight_factor("NO2","2hr","500C",time_window=(128,150))
sim.ignore_weight_factor("N2O","2hr","500C",time_window=(128,150))
sim.ignore_weight_factor("NH3","2hr","500C",time_window=(85,95))
sim.ignore_weight_factor("NO","2hr","500C",time_window=(85,95))
sim.ignore_weight_factor("NO2","2hr","500C",time_window=(85,95))
sim.ignore_weight_factor("N2O","2hr","500C",time_window=(85,95))

sim.ignore_weight_factor("NH3","4hr","500C",time_window=(51,60))
sim.ignore_weight_factor("NO","4hr","500C",time_window=(51,60))
sim.ignore_weight_factor("NO2","4hr","500C",time_window=(51,60))
sim.ignore_weight_factor("N2O","4hr","500C",time_window=(51,60))
sim.ignore_weight_factor("NH3","4hr","500C",time_window=(94,105))
sim.ignore_weight_factor("NO","4hr","500C",time_window=(94,105))
sim.ignore_weight_factor("NO2","4hr","500C",time_window=(94,105))
sim.ignore_weight_factor("N2O","4hr","500C",time_window=(94,105))

sim.ignore_weight_factor("NH3","8hr","500C",time_window=(75,85))
sim.ignore_weight_factor("NO","8hr","500C",time_window=(75,85))
sim.ignore_weight_factor("NO2","8hr","500C",time_window=(75,85))
sim.ignore_weight_factor("N2O","8hr","500C",time_window=(75,85))
sim.ignore_weight_factor("NH3","8hr","500C",time_window=(100,116))
sim.ignore_weight_factor("NO","8hr","500C",time_window=(100,116))
sim.ignore_weight_factor("NO2","8hr","500C",time_window=(100,116))
sim.ignore_weight_factor("N2O","8hr","500C",time_window=(100,116))

sim.ignore_weight_factor("NH3","16hr","500C",time_window=(83,100))
sim.ignore_weight_factor("NO","16hr","500C",time_window=(83,100))
sim.ignore_weight_factor("NO2","16hr","500C",time_window=(83,100))
sim.ignore_weight_factor("N2O","16hr","500C",time_window=(83,100))
sim.ignore_weight_factor("NH3","16hr","500C",time_window=(118,130))
sim.ignore_weight_factor("NO","16hr","500C",time_window=(118,130))
sim.ignore_weight_factor("NO2","16hr","500C",time_window=(118,130))
sim.ignore_weight_factor("N2O","16hr","500C",time_window=(118,130))

sim.finalize_auto_scaling()
sim.run_solver()

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "500C", file_name="Unaged_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "500C", 0, file_name="Unaged_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", "500C", file_name="Unaged_SCR_500C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "500C", file_name="2hr_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "500C", 0, file_name="2hr_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "2hr", "500C", file_name="2hr_SCR_500C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "500C", file_name="4hr_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "500C", 0, file_name="4hr_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "4hr", "500C", file_name="4hr_SCR_500C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "500C", file_name="8hr_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "500C", 0, file_name="8hr_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "8hr", "500C", file_name="8hr_SCR_500C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "500C", file_name="16hr_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "500C", 0, file_name="16hr_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "16hr", "500C", file_name="16hr_SCR_500C_average_ads.txt")

sim.print_kinetic_parameter_info(file_name="500C_opt_params"+run+".txt")
sim.save_model_state(file_name=writefile)
