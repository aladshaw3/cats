# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Read in data
exp_name = "CO2_H2O_CO_H2_NO"

run = "05"
oldrun="04"

readfile = 'output/'+exp_name+'_model'+oldrun+'.json'
writefile = exp_name+"_model"+run+".json"

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

#call solver
sim.finalize_auto_scaling()
sim.run_solver()

sim.plot_vs_data("CO", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-CO-out")
sim.plot_vs_data("NO", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-NO-out")
sim.plot_vs_data("NH3", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-NH3-out")
sim.plot_vs_data("N2O", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-N2O-out")
sim.plot_vs_data("H2", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-H2-out")
sim.plot_at_locations(["O2"], ["A0"], ["T0"], [0, 5], display_live=False, file_name="exp-"+exp_name+"-O2-out")

sim.plot_at_times(["CO"], ["A0"], ["T0"], [30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80],
                display_live=False, file_name="exp-"+exp_name+"-COprofile-out")

sim.print_results_of_breakthrough(["CO","NO","NH3","N2O","H2","O2","H2O","CO2"],
                                "A0", "T0", file_name=exp_name+"_lightoff"+".txt", include_temp=True)
sim.print_kinetic_parameter_info(file_name=exp_name+"_params"+run+".txt")
sim.save_model_state(file_name=writefile)
