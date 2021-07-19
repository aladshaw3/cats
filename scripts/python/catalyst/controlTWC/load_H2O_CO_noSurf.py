# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Read in data
exp_name = "H2O_CO"

run = "10"
oldrun="09"

readfile = 'output/'+exp_name+'_model'+oldrun+'.json'
writefile = exp_name+"_model"+run+".json"

sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()

# CO + H2O --> CO2 + H2
#r11

for rxn in sim.model.arrhenius_rxns:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(0.9*sim.model.A[rxn].value,2*sim.model.A[rxn].value))
    sim.set_reaction_param_bounds(rxn, "E", bounds=(0.9*sim.model.E[rxn].value,1.3*sim.model.E[rxn].value))

# Will need to rerun auto_select_all_weight_factors() to add later times back
sim.auto_select_all_weight_factors()


#call solver
sim.finalize_auto_scaling()
sim.run_solver()

sim.plot_vs_data("CO", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-CO-out")
sim.plot_vs_data("NO", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-NO-out")
sim.plot_vs_data("NH3", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-NH3-out")
sim.plot_vs_data("N2O", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-N2O-out")
sim.plot_vs_data("H2", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-H2-out")

sim.print_results_of_breakthrough(["CO","NO","NH3","N2O","H2","O2","H2O","CO2"],
                                "A0", "T0", file_name=exp_name+"_lightoff"+".txt", include_temp=True)
sim.print_kinetic_parameter_info(file_name=exp_name+"_params"+run+".txt")
sim.save_model_state(file_name=writefile)
