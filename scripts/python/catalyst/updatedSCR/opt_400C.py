#This file is used to rerun a simulation using newly found parameters.
#The purpose is for additional refinement of kinetics. We will reuse this
#script for additional optimization passes.

import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

Tstr = "400C"
run = "03"
oldrun="02"

readfile = 'output/'+Tstr+'_model'+oldrun+'.json'
writefile = Tstr+"_model"+run+".json"

sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()

# Fix the isotherm parameters (we assume that these are knowns)
sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")

#  ============= Modify parameter bounds =================
#   Specify modifications to parameter boundaries (default = +/- 20%)


#call solver
sim.finalize_auto_scaling()
sim.run_solver()

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, file_name="Unaged_SCR_"+Tstr+"_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, 0, file_name="Unaged_SCR_"+Tstr+"_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", Tstr, file_name="Unaged_SCR_"+Tstr+"_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", Tstr, file_name="2hr_SCR_"+Tstr+"_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", Tstr, 0, file_name="2hr_SCR_"+Tstr+"_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "2hr", Tstr, file_name="2hr_SCR_"+Tstr+"_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", Tstr, file_name="4hr_SCR_"+Tstr+"_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", Tstr, 0, file_name="4hr_SCR_"+Tstr+"_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "4hr", Tstr, file_name="4hr_SCR_"+Tstr+"_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", Tstr, file_name="8hr_SCR_"+Tstr+"_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", Tstr, 0, file_name="8hr_SCR_"+Tstr+"_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "8hr", Tstr, file_name="8hr_SCR_"+Tstr+"_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", Tstr, file_name="16hr_SCR_"+Tstr+"_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", Tstr, 0, file_name="16hr_SCR_"+Tstr+"_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "16hr", Tstr, file_name="16hr_SCR_"+Tstr+"_average_ads.txt")

sim.print_kinetic_parameter_info(file_name=Tstr+"_opt_params"+run+".txt")
sim.save_model_state(file_name=writefile)

sim.plot_vs_data("NH3", "Unaged", Tstr, 5, display_live=False)
sim.plot_vs_data("NH3", "2hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NH3", "4hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NH3", "8hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NH3", "16hr", Tstr, 5, display_live=False)

sim.plot_vs_data("NO", "Unaged", Tstr, 5, display_live=False)
sim.plot_vs_data("NO", "2hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NO", "4hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NO", "8hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NO", "16hr", Tstr, 5, display_live=False)

sim.plot_vs_data("NO2", "Unaged", Tstr, 5, display_live=False)
sim.plot_vs_data("NO2", "2hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NO2", "4hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NO2", "8hr", Tstr, 5, display_live=False)
sim.plot_vs_data("NO2", "16hr", Tstr, 5, display_live=False)

sim.plot_vs_data("N2O", "Unaged", Tstr, 5, display_live=False)
sim.plot_vs_data("N2O", "2hr", Tstr, 5, display_live=False)
sim.plot_vs_data("N2O", "4hr", Tstr, 5, display_live=False)
sim.plot_vs_data("N2O", "8hr", Tstr, 5, display_live=False)
sim.plot_vs_data("N2O", "16hr", Tstr, 5, display_live=False)
