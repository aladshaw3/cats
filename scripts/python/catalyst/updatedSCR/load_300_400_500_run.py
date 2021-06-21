#This file is used to rerun a simulation using newly found parameters.
#The purpose is for additional refinement of kinetics. We will reuse this
#script for additional optimization passes.

import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *
import json


# Create a simulator object and Load a full model from json
run = "03"                              #update this number to reflect changes in runs
oldrun="02"                               #update this name to reflect which model to load
readfile = 'output/300C_400C_500C_model'+oldrun+'.json'
writefile = "300C_400C_500C_model"+run+".json"

'''
obj = json.load(open(readfile))
for key in obj['model']['A']:
    print(key)
    print(obj['model']['A'][key]['value'])
    print()
exit()
'''
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

#  ============= Modify parameter bounds =================
#sim.fix_all_reactions()
upper = 1+0.3
lower = 1-0.3
for rxn in sim.model.arrhenius_rxns:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))
    sim.set_reaction_param_bounds(rxn, "E", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))

#Customize the weight factors
sim.auto_select_all_weight_factors()

# ============================== 300 C ==================================
#Select specific weight factor windows based on observed data
sim.ignore_weight_factor("NH3","Unaged","300C",time_window=(137,150))
sim.ignore_weight_factor("NO","Unaged","300C",time_window=(137,150))
sim.ignore_weight_factor("NO2","Unaged","300C",time_window=(137,150))
sim.ignore_weight_factor("N2O","Unaged","300C",time_window=(137,150))

sim.ignore_weight_factor("NH3","2hr","300C",time_window=(126,150))
sim.ignore_weight_factor("NO","2hr","300C",time_window=(126,150))
sim.ignore_weight_factor("NO2","2hr","300C",time_window=(126,150))
sim.ignore_weight_factor("N2O","2hr","300C",time_window=(126,150))

sim.ignore_weight_factor("NH3","4hr","300C",time_window=(120,150))
sim.ignore_weight_factor("NO","4hr","300C",time_window=(120,150))
sim.ignore_weight_factor("NO2","4hr","300C",time_window=(120,150))
sim.ignore_weight_factor("N2O","4hr","300C",time_window=(120,150))

sim.ignore_weight_factor("NH3","8hr","300C",time_window=(116,150))
sim.ignore_weight_factor("NO","8hr","300C",time_window=(116,150))
sim.ignore_weight_factor("NO2","8hr","300C",time_window=(116,150))
sim.ignore_weight_factor("N2O","8hr","300C",time_window=(116,150))

sim.ignore_weight_factor("NH3","16hr","300C",time_window=(110,150))
sim.ignore_weight_factor("NO","16hr","300C",time_window=(110,150))
sim.ignore_weight_factor("NO2","16hr","300C",time_window=(110,150))
sim.ignore_weight_factor("N2O","16hr","300C",time_window=(110,150))

# ============================== 400 C ==================================
#Select specific weight factor windows based on observed data
sim.ignore_weight_factor("NH3","Unaged","400C",time_window=(83,150))
sim.ignore_weight_factor("NO","Unaged","400C",time_window=(83,150))
sim.ignore_weight_factor("NO2","Unaged","400C",time_window=(83,150))
sim.ignore_weight_factor("N2O","Unaged","400C",time_window=(83,150))

sim.ignore_weight_factor("NH3","2hr","400C",time_window=(95,150))
sim.ignore_weight_factor("NO","2hr","400C",time_window=(95,150))
sim.ignore_weight_factor("NO2","2hr","400C",time_window=(95,150))
sim.ignore_weight_factor("N2O","2hr","400C",time_window=(95,150))

sim.ignore_weight_factor("NH3","4hr","400C",time_window=(87,150))
sim.ignore_weight_factor("NO","4hr","400C",time_window=(87,150))
sim.ignore_weight_factor("NO2","4hr","400C",time_window=(87,150))
sim.ignore_weight_factor("N2O","4hr","400C",time_window=(87,150))

sim.ignore_weight_factor("NH3","8hr","400C",time_window=(90,150))
sim.ignore_weight_factor("NO","8hr","400C",time_window=(90,150))
sim.ignore_weight_factor("NO2","8hr","400C",time_window=(90,150))
sim.ignore_weight_factor("N2O","8hr","400C",time_window=(90,150))

sim.ignore_weight_factor("NH3","16hr","400C",time_window=(90,150))
sim.ignore_weight_factor("NO","16hr","400C",time_window=(90,150))
sim.ignore_weight_factor("NO2","16hr","400C",time_window=(90,150))
sim.ignore_weight_factor("N2O","16hr","400C",time_window=(90,150))

# ============================== 500 C ==================================
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


#call solver
sim.finalize_auto_scaling()
sim.run_solver()

# ========================================== 300C ============================================================
sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "300C", file_name="Unaged_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "300C", 0, file_name="Unaged_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", "300C", file_name="Unaged_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "300C", file_name="2hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "300C", 0, file_name="2hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "2hr", "300C", file_name="2hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "300C", file_name="4hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "300C", 0, file_name="4hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "4hr", "300C", file_name="4hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "300C", file_name="8hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "300C", 0, file_name="8hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "8hr", "300C", file_name="8hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "300C", file_name="16hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "300C", 0, file_name="16hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "16hr", "300C", file_name="16hr_SCR_300C_average_ads.txt")

# ========================================== 400C ============================================================
sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "400C", file_name="Unaged_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "400C", 0, file_name="Unaged_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", "400C", file_name="Unaged_SCR_400C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "400C", file_name="2hr_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "400C", 0, file_name="2hr_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "2hr", "400C", file_name="2hr_SCR_400C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "400C", file_name="4hr_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "400C", 0, file_name="4hr_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "4hr", "400C", file_name="4hr_SCR_400C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "400C", file_name="8hr_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "400C", 0, file_name="8hr_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "8hr", "400C", file_name="8hr_SCR_400C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "400C", file_name="16hr_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "400C", 0, file_name="16hr_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "16hr", "400C", file_name="16hr_SCR_400C_average_ads.txt")

# ========================================== 500C ============================================================
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

sim.print_kinetic_parameter_info(file_name="300C_400C_500C_opt_params"+run+".txt")
sim.save_model_state(file_name=writefile)
