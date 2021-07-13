# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

HC_name = "methane"
run = "1"
oldrun="0"

readfile = 'output/'+HC_name+'_model'+oldrun+'.json'
writefile = HC_name+"_model"+run+".json"

sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()

# CO + 0.5 O2 --> CO2
#r1

# H2 + 0.5 O2 --> H2O5
#r2

# CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
#r3

# CO + NO --> CO2 + 0.5 N2
#r4

# CO + 2 NO --> N2O + CO2
#r5

# 2.5 H2 + NO --> NH3 + H2O
#r6

# H2 + NO --> H2O + 0.5 N2
#r7

# 2.5 CO + NO + 1.5 H2O --> NH3 + 2.5 CO2
#r8

# CO + NO + 1.5 H2 --> NH3 + CO2
#r9

# CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
#r10

# CO + H2O --> CO2 + H2
#r11

# CxHyOz + x H2O --> x CO + (x + (y/2)) H2 + (z/2) O2
#r12

# N2O + CO --> N2 + CO2
#r13

# H2 + 2 NO --> N2O + H2O
#r14

# N2O + CO + O2 --> 2 NO + CO2
#r15

# CxHyOz + NO + (2x + ((y/2) - (3/2)) - z - 1) O2 --> x CO2 + ((y/2) - (3/2)) H2O + NH3
#r16

# 2 NH3 + 1.5 O2 --> N2 + 3 H2O
#r17

# CxHyOz + 2 NO + (x + (y/4) - (z/2) - (1/2)) O2 --> N2O + x CO2 + (y/2) H2O
#r18


#  ============= Modify parameter bounds =================
#   Specify modifications to parameter boundaries (default = +/- 20%)
H2_rxns = ["r2","r6","r9","r11","r12","r14"]

HC_rxns = ["r3","r10","r12","r16","r18"]

for rxn in sim.model.arrhenius_rxns:
    sim.set_reaction_param_bounds(rxn, "A", factor=0.2)
    sim.set_reaction_param_bounds(rxn, "E", factor=0.2)

#sim.fix_all_reactions()

#for rxn in HC_rxns:
    #sim.model.A[rxn].set_value(1e15)
    #sim.model.E[rxn].set_value(150000)

#    sim.unfix_reaction(rxn)
#    sim.set_reaction_param_bounds(rxn, "A", factor=0.15)
#    sim.set_reaction_param_bounds(rxn, "E", factor=0.15)

# Will need to rerun auto_select_all_weight_factors() to add later times back
sim.auto_select_all_weight_factors()


#call solver
sim.finalize_auto_scaling()
sim.run_solver()

name = HC_name+"_CO_"+str(run)
sim.plot_vs_data("CO", "A0", "T0", 5, display_live=False, file_name=name)
name = HC_name+"_NO_"+str(run)
sim.plot_vs_data("NO", "A0", "T0", 5, display_live=False, file_name=name)
name = HC_name+"_HC_"+str(run)
sim.plot_vs_data("HC", "A0", "T0", 5, display_live=False, file_name=name)
name = HC_name+"_NH3_"+str(run)
sim.plot_vs_data("NH3", "A0", "T0", 5, display_live=False, file_name=name)
name = HC_name+"_N2O_"+str(run)
sim.plot_vs_data("N2O", "A0", "T0", 5, display_live=False, file_name=name)
name = HC_name+"_H2_"+str(run)
sim.plot_vs_data("H2", "A0", "T0", 5, display_live=False, file_name=name)

sim.print_results_of_breakthrough(["HC","CO","NO","NH3","N2O","H2","O2","H2O"],
                                "A0", "T0", file_name=HC_name+"_lightoff"+str(run)+".txt", include_temp=True)
sim.print_kinetic_parameter_info(file_name=HC_name+"_params"+str(run)+".txt")
sim.save_model_state(file_name=writefile)
