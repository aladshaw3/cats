# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Give x, y, z for the HC (CxHyOz)
HC_name = "toluene"

run = "01"
oldrun=""

readfile = 'output/'+HC_name+'_model'+oldrun+'.json'
writefile = HC_name+"_model"+run+".json"

sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

# CO + 0.5 O2 --> CO2
#"r1": ReactionType.Arrhenius,

# H2 + 0.5 O2 --> H2O
#"r2": ReactionType.Arrhenius,

# CO + NO --> CO2 (+ 0.5 N2)
#"r4": ReactionType.Arrhenius,

# CO + 2 NO --> CO2 + N2O
#"r5": ReactionType.Arrhenius,

# 2.5 CO + NO + 1.5 H2O --> 2.5 CO2 + NH3
#"r8": ReactionType.Arrhenius,

# CO + H2O <-- --> CO2 + H2
#"r11": ReactionType.EquilibriumArrhenius,

# 2.5 H2 + NO --> NH3 + H2O
#"r6": ReactionType.Arrhenius,

# H2 + NO --> H2O (+ 0.5 N2)
#"r7": ReactionType.Arrhenius,

# H2 + 2 NO --> N2O + H2O
#"r14": ReactionType.Arrhenius,

# NH3 + NO + 0.25 O2 --> 1.5 H2O (+ N2)
#"r15": ReactionType.Arrhenius,

# HC oxidation
# CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
#"r3": ReactionType.Arrhenius,

# HC Steam Reforming
# CxHyOz + x H2O --> x CO + (x + (y/2)) H2 + (z/2) O2
#"r12": ReactionType.Arrhenius,

# HC NO reduction
# CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
#"r10": ReactionType.Arrhenius,

sim.fix_all_reactions()

# NOTE: If the rates are "inhibited", then we want the activation energies to increase

# CO/O2 (opt this first)
rxn = "r1"
sim.unfix_reaction(rxn)
sim.set_reaction_param_bounds(rxn, "E", bounds=(sim.model.E[rxn].value*0.99, sim.model.E[rxn].value*1.2))
sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*0.99, sim.model.A[rxn].value*2))

# CO/NO
rxn = "r4"
sim.unfix_reaction("r4")
sim.set_reaction_param_bounds(rxn, "E", bounds=(sim.model.E[rxn].value*0.99, sim.model.E[rxn].value*1.2))
sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*0.99, sim.model.A[rxn].value*2))

rxn = "r5"
sim.unfix_reaction("r5")
sim.set_reaction_param_bounds(rxn, "E", bounds=(sim.model.E[rxn].value*0.99, sim.model.E[rxn].value*1.2))
sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*0.99, sim.model.A[rxn].value*2))

rxn = "r8"
sim.unfix_reaction("r8")
sim.set_reaction_param_bounds(rxn, "E", bounds=(sim.model.E[rxn].value*0.99, sim.model.E[rxn].value*1.2))
sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*0.99, sim.model.A[rxn].value*2))

# H2/NO (Don't let these vary?)
#sim.unfix_reaction("r6")
#sim.unfix_reaction("r7")
#sim.unfix_reaction("r14")

# HC reactions
sim.unfix_reaction("r3")
sim.unfix_reaction("r10")

sim.fix_all_reactions()

# ========== Selecting weight factors
sim.auto_select_all_weight_factors()


#sim.ignore_weight_factor("N2O","A0","T0",time_window=(0,110))
#sim.ignore_weight_factor("NO","A0","T0",time_window=(0,110))
#sim.ignore_weight_factor("NH3","A0","T0",time_window=(0,110))
sim.ignore_weight_factor("H2","A0","T0",time_window=(0,110))

sim.finalize_auto_scaling()
sim.run_solver()

name = HC_name+"_CO"
sim.plot_vs_data("CO", "A0", "T0", 5, display_live=False, file_name=name)

name = HC_name+"_NO"
sim.plot_vs_data("NO", "A0", "T0", 5, display_live=False, file_name=name)

name = HC_name+"_HC"
sim.plot_vs_data("HC", "A0", "T0", 5, display_live=False, file_name=name)

name = HC_name+"_NH3"
sim.plot_vs_data("NH3", "A0", "T0", 5, display_live=False, file_name=name)

name = HC_name+"_N2O"
sim.plot_vs_data("N2O", "A0", "T0", 5, display_live=False, file_name=name)

name = HC_name+"_H2"
sim.plot_vs_data("H2", "A0", "T0", 5, display_live=False, file_name=name)

sim.plot_at_times(["CO"], ["A0"], ["T0"], [30, 35, 40, 45, 50],
                display_live=False, file_name=HC_name+"_CO-profile-out")

sim.plot_at_times(["O2"], ["A0"], ["T0"], [30, 35, 40, 45, 50],
                display_live=False, file_name=HC_name+"_O2-profile-out")

sim.plot_at_times(["HC"], ["A0"], ["T0"], [30, 35, 40, 45, 50],
                display_live=False, file_name=HC_name+"_HC-profile-out")

sim.plot_at_times(["NO"], ["A0"], ["T0"], [30, 35, 40, 45, 50],
                display_live=False, file_name=HC_name+"_NO-profile-out")

sim.plot_at_locations(["O2"], ["A0"], ["T0"], [0, 5], display_live=False, file_name=HC_name+"_O2-out")
sim.print_results_of_breakthrough(["HC","CO","NO","NH3","N2O","H2","O2","H2O"],
                                    "A0", "T0", file_name=HC_name+"_lightoff.txt", include_temp=True)

sim.print_results_of_integral_average(["CO","NO","HC"], "A0", "T0", file_name=HC_name+"_avgs-used-for-inhibition.txt")

sim.print_kinetic_parameter_info(file_name=HC_name+"_params"+run+".txt")
sim.save_model_state(file_name=writefile)
