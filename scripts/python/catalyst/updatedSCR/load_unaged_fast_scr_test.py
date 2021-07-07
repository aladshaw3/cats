#This file is used to rerun a simulation using newly found parameters.
#The purpose is for additional refinement of kinetics. We will reuse this
#script for additional optimization passes.

import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

Tstr = "T0"
run = "02"
oldrun=""

readfile = 'output/FastSCR_lowtemp_model'+oldrun+'.json'
writefile = "FastSCR_lowtemp_model"+run+".json"

sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()

#  ============= Modify parameter bounds =================
#   Specify modifications to parameter boundaries (default = +/- 20%)
upper = 1+0.0125
lower = 1-0.0125
for rxn in sim.model.arrhenius_rxns:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))
    sim.set_reaction_param_bounds(rxn, "E", bounds=(sim.model.E[rxn].value*lower,sim.model.E[rxn].value*upper))

sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")

# Problematic reactions: r10, r11, r12, r34, r37, r38, r39 (all NH3 oxidation reactions)
sim.fix_reaction("r10")
sim.fix_reaction("r11")
sim.fix_reaction("r12")
sim.fix_reaction("r34")
sim.fix_reaction("r37")
sim.fix_reaction("r38")
sim.fix_reaction("r39")

# Other oxidation reactions: r7, r8, r9, r35, r36
sim.fix_reaction("r7")
sim.fix_reaction("r8")
sim.fix_reaction("r9")
sim.fix_reaction("r35")
sim.fix_reaction("r36")

# Fix std SCR reactions
sim.fix_reaction("r5f")
sim.fix_reaction("r5r")
sim.fix_reaction("r6f")
sim.fix_reaction("r6r")

sim.fix_reaction("r13")
sim.fix_reaction("r14")
sim.fix_reaction("r15")
sim.fix_reaction("r16")
sim.fix_reaction("r17")

sim.fix_reaction("r18")
sim.fix_reaction("r19")
sim.fix_reaction("r20")

#call solver
sim.finalize_auto_scaling()
sim.run_solver()

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, file_name="Unaged_FastSCR_lowtemp_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, 0, file_name="Unaged_FastSCR_lowtemp_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", Tstr, file_name="Unaged_FastSCR_lowtemp_average_ads.txt")

sim.print_kinetic_parameter_info(file_name="FastSCR_lowtemp_opt_params"+run+".txt")
sim.save_model_state(file_name=writefile)

sim.plot_vs_data("NH3", "Unaged", Tstr, 5, display_live=False, file_name="unaged_NH3_fastSCR_run"+run)

sim.plot_vs_data("NO", "Unaged", Tstr, 5, display_live=False, file_name="unaged_NO_fastSCR_run"+run)

sim.plot_vs_data("NO2", "Unaged", Tstr, 5, display_live=False, file_name="unaged_NO2_fastSCR_run"+run)

sim.plot_vs_data("N2O", "Unaged", Tstr, 5, display_live=False, file_name="unaged_N2O_fastSCR_run"+run)
