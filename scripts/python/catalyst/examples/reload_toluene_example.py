#This file is used to rerun a simulation using newly found parameters.
#The purpose is for additional refinement of kinetics. We will reuse this
#script for additional optimization passes.

import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

HC_name = "toluene"

# Create a simulator object and Load a full model from json
run = "02"                              #update this number to reflect changes in runs
load = ""                               #update this number to reflect changes in load
readfile = 'output/'+HC_name+'_model'+load+'.json'     #update this name to reflect which model to load
writefile = HC_name+"_model"+run+".json"

#NOTE: Other output names can remain the same, most important thing is .json file
sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()

for rxn in sim.model.arrhenius_rxns:
    sim.set_reaction_param_bounds(rxn, "A", factor=0.2)
    sim.set_reaction_param_bounds(rxn, "E", factor=0.2)


sim.finalize_auto_scaling()
sim.run_solver()

sim.plot_vs_data("CO", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("NO", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("HC", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("NH3", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("N2O", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("H2", "A0", "T0", 5, display_live=False)

sim.print_results_of_breakthrough(["HC","CO","NO","NH3","N2O","H2","O2","H2O"],
                                "A0", "T0", file_name=HC_name+"_lightoff.txt", include_temp=True)

sim.print_kinetic_parameter_info(file_name=HC_name+"_params"+run+".txt")
sim.save_model_state(file_name=writefile)
