# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Read in data
exp_name = "CO2_H2O_H2_NO"

run = "01"
oldrun=""

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

# Need to add new constraints
def six_to_seven(m):
    k6_this = arrhenius_rate_const(m.A["r6"], 0, m.E["r6"], 450)
    k6_inhib = arrhenius_rate_const(9.08E+16, 0, 90733, 450)

    k7_this = arrhenius_rate_const(m.A["r7"], 0, m.E["r7"], 450)
    k7_inhib = arrhenius_rate_const(1.9E+14, 0, 62830, 450)

    return (k6_this/k6_inhib) == (k7_this/k7_inhib)

def six_to_14(m):
    k6_this = arrhenius_rate_const(m.A["r6"], 0, m.E["r6"], 450)
    k6_inhib = arrhenius_rate_const(9.08E+16, 0, 90733, 450)

    k14_this = arrhenius_rate_const(m.A["r14"], 0, m.E["r14"], 450)
    k14_inhib = arrhenius_rate_const(6.06599E+11, 0, 43487, 450)

    return (k6_this/k6_inhib) == (k14_this/k14_inhib)

def seven_to_14(m):
    k7_this = arrhenius_rate_const(m.A["r7"], 0, m.E["r7"], 450)
    k7_inhib = arrhenius_rate_const(1.9E+14, 0, 62830, 450)

    k14_this = arrhenius_rate_const(m.A["r14"], 0, m.E["r14"], 450)
    k14_inhib = arrhenius_rate_const(6.06599E+11, 0, 43487, 450)

    return (k7_this/k7_inhib) == (k14_this/k14_inhib)

def six_to_seven_low(m):
    k6_this = arrhenius_rate_const(m.A["r6"], 0, m.E["r6"], 450)
    k6_inhib = arrhenius_rate_const(9.08E+16, 0, 90733, 450)

    k7_this = arrhenius_rate_const(m.A["r7"], 0, m.E["r7"], 450)
    k7_inhib = arrhenius_rate_const(1.9E+14, 0, 62830, 450)

    return (k6_this/k6_inhib) == (k7_this/k7_inhib)

def six_to_14_low(m):
    k6_this = arrhenius_rate_const(m.A["r6"], 0, m.E["r6"], 380)
    k6_inhib = arrhenius_rate_const(9.08E+16, 0, 90733, 380)

    k14_this = arrhenius_rate_const(m.A["r14"], 0, m.E["r14"], 380)
    k14_inhib = arrhenius_rate_const(6.06599E+11, 0, 43487, 380)

    return (k6_this/k6_inhib) == (k14_this/k14_inhib)

def six_to_seven_high(m):
    k6_this = arrhenius_rate_const(m.A["r6"], 0, m.E["r6"], 666)
    k6_inhib = arrhenius_rate_const(9.08E+16, 0, 90733, 666)

    k7_this = arrhenius_rate_const(m.A["r7"], 0, m.E["r7"], 666)
    k7_inhib = arrhenius_rate_const(1.9E+14, 0, 62830, 666)

    return (k6_this/k6_inhib) <= 1

def six_to_14_high(m):
    k6_this = arrhenius_rate_const(m.A["r6"], 0, m.E["r6"], 666)
    k6_inhib = arrhenius_rate_const(9.08E+16, 0, 90733, 666)

    k14_this = arrhenius_rate_const(m.A["r14"], 0, m.E["r14"], 666)
    k14_inhib = arrhenius_rate_const(6.06599E+11, 0, 43487, 666)

    return (k14_this/k14_inhib) <= 1

sim.model.six27 = Constraint(rule=six_to_seven)
sim.model.six214 = Constraint(rule=six_to_14)
#sim.model.seven214 = Constraint(rule=seven_to_14)

sim.model.six27l = Constraint(rule=six_to_seven_low)
sim.model.six214l = Constraint(rule=six_to_14_low)

sim.model.six27h = Constraint(rule=six_to_seven_high)
sim.model.six214h = Constraint(rule=six_to_14_high)

# Will need to rerun auto_select_all_weight_factors() to add later times back
sim.auto_select_all_weight_factors()

#sim.ignore_weight_factor("N2O","A0","T0",time_window=(0,40))
#sim.ignore_weight_factor("NO","A0","T0",time_window=(0,40))
sim.ignore_weight_factor("NH3","A0","T0",time_window=(25,35))
sim.ignore_weight_factor("H2","A0","T0",time_window=(0,110))

#call solver
sim.finalize_auto_scaling()
opt = {'max_iter': 3000}
sim.run_solver(options=opt)

sim.plot_vs_data("CO", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-CO-out")
sim.plot_vs_data("NO", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-NO-out")
sim.plot_vs_data("NH3", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-NH3-out")
sim.plot_vs_data("N2O", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-N2O-out")
sim.plot_vs_data("H2", "A0", "T0", 5, display_live=False, file_name="exp-"+exp_name+"-H2-out")

sim.print_results_of_breakthrough(["CO","NO","NH3","N2O","H2","O2","H2O","CO2"],
                                "A0", "T0", file_name=exp_name+"_lightoff"+".txt", include_temp=True)
sim.print_kinetic_parameter_info(file_name=exp_name+"_params"+run+".txt")
sim.save_model_state(file_name=writefile)
