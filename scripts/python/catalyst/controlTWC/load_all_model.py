# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

run = "02"
oldrun="01"

readfile = 'output/all_model'+oldrun+'.json'
writefile = "all_model"+run+".json"

sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()

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

sim.fix_reaction("r11")

for rxn in sim.model.arrhenius_rxns:
    sim.set_reaction_param_bounds(rxn, "A", factor=0.3)
    sim.set_reaction_param_bounds(rxn, "E", factor=0.1)

sim.fix_all_reactions()
# H2/NO
sim.unfix_reaction("r6")
sim.unfix_reaction("r7")
sim.unfix_reaction("r14")

# CO/NO
sim.unfix_reaction("r4")
sim.unfix_reaction("r5")
sim.unfix_reaction("r8")

# Will need to rerun auto_select_all_weight_factors() to add later times back
sim.auto_select_all_weight_factors()

#sim.ignore_weight_factor("N2O","A0","T0",time_window=(0,110))
#sim.ignore_weight_factor("NO","A0","T0",time_window=(0,110))
#sim.ignore_weight_factor("NH3","A0","T0",time_window=(0,110))
sim.ignore_weight_factor("H2","A0","T0",time_window=(0,110))

#sim.ignore_weight_factor("N2O","A1","T0",time_window=(0,110))
#sim.ignore_weight_factor("NO","A1","T0",time_window=(0,110))
#sim.ignore_weight_factor("NH3","A1","T0",time_window=(0,110))
sim.ignore_weight_factor("H2","A1","T0",time_window=(0,110))

sim.ignore_weight_factor("N2O","A2","T0",time_window=(0,110))
sim.ignore_weight_factor("NO","A2","T0",time_window=(0,110))
sim.ignore_weight_factor("NH3","A2","T0",time_window=(0,110))
sim.ignore_weight_factor("H2","A2","T0",time_window=(0,110))

sim.ignore_weight_factor("N2O","A3","T0",time_window=(0,110))
sim.ignore_weight_factor("NO","A3","T0",time_window=(0,110))
sim.ignore_weight_factor("NH3","A3","T0",time_window=(0,110))
sim.ignore_weight_factor("H2","A3","T0",time_window=(0,110))

#call solver
sim.finalize_auto_scaling()
sim.run_solver()

exp_name = {}
exp_name["A0"] = "CO2_H2O_CO_H2_NO"
exp_name["A1"] = "CO2_H2O_CO_NO"
exp_name["A2"] = "CO2_H2O_CO_H2"
exp_name["A3"] = "CO2_H2O_CO"


age="A0"
sim.plot_vs_data("CO", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-CO-out")
sim.plot_vs_data("NO", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-NO-out")
sim.plot_vs_data("NH3", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-NH3-out")
sim.plot_vs_data("N2O", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-N2O-out")
sim.plot_vs_data("H2", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-H2-out")

sim.print_results_of_breakthrough(["CO","NO","NH3","N2O","H2","O2","H2O","CO2"],
                                age, "T0", file_name=exp_name[age]+"_lightoff"+".txt", include_temp=True)


age="A1"
sim.plot_vs_data("CO", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-CO-out")
sim.plot_vs_data("NO", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-NO-out")
sim.plot_vs_data("NH3", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-NH3-out")
sim.plot_vs_data("N2O", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-N2O-out")
sim.plot_vs_data("H2", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-H2-out")

sim.print_results_of_breakthrough(["CO","NO","NH3","N2O","H2","O2","H2O","CO2"],
                                age, "T0", file_name=exp_name[age]+"_lightoff"+".txt", include_temp=True)


age="A2"
sim.plot_vs_data("CO", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-CO-out")
sim.plot_vs_data("NO", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-NO-out")
sim.plot_vs_data("NH3", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-NH3-out")
sim.plot_vs_data("N2O", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-N2O-out")
sim.plot_vs_data("H2", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-H2-out")

sim.print_results_of_breakthrough(["CO","NO","NH3","N2O","H2","O2","H2O","CO2"],
                                age, "T0", file_name=exp_name[age]+"_lightoff"+".txt", include_temp=True)

age="A3"
sim.plot_vs_data("CO", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-CO-out")
sim.plot_vs_data("NO", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-NO-out")
sim.plot_vs_data("NH3", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-NH3-out")
sim.plot_vs_data("N2O", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-N2O-out")
sim.plot_vs_data("H2", age, "T0", 5, display_live=False, file_name="exp-"+exp_name[age]+"-H2-out")

sim.print_results_of_breakthrough(["CO","NO","NH3","N2O","H2","O2","H2O","CO2"],
                                age, "T0", file_name=exp_name[age]+"_lightoff"+".txt", include_temp=True)

sim.print_kinetic_parameter_info(file_name="all_params"+run+".txt")
sim.save_model_state(file_name=writefile)
