# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Use random numbers for basic MC approach
import random

# NOTE: We don't really need to go beyond 60 min for this case
#       Beyond that point, concentrations are very near zero and
#       convergence becomes problematic

# Give x, y, z for the HC (CxHyOz)
HC_name = "toluene"
x = 7
y = 8
z = 0
MC_iter = 1000

data = naively_read_data_file("inputfiles/"+HC_name+"_lightoff_history.txt",factor=10)
temp_data = naively_read_data_file("inputfiles/"+HC_name+"_temp_history.txt",factor=10)

time_list = time_point_selector(data["time"], data)

sim = Isothermal_Monolith_Simulator()
sim.add_axial_dim(0,5)         #cm
sim.add_axial_dataset(5)

sim.add_temporal_dim(point_list=time_list)
sim.add_temporal_dataset(data["time"])

sim.add_age_set("A0")
sim.add_data_age_set("A0")

sim.add_temperature_set("T0")
sim.add_data_temperature_set("T0")

sim.add_gas_species(["HC","CO","NO","N2O","NH3","H2","O2","H2O"])
sim.add_data_gas_species(["HC","CO","NO","N2O","NH3","H2"])

sim.set_data_values_for("HC","A0","T0",5,data["time"],data["HC"])
sim.set_data_values_for("CO","A0","T0",5,data["time"],data["CO"])
sim.set_data_values_for("NO","A0","T0",5,data["time"],data["NO"])
sim.set_data_values_for("N2O","A0","T0",5,data["time"],data["N2O"])
sim.set_data_values_for("NH3","A0","T0",5,data["time"],data["NH3"])
sim.set_data_values_for("H2","A0","T0",5,data["time"],data["H2"])

sim.add_reactions({"r1": ReactionType.Arrhenius,
                    "r2f": ReactionType.Arrhenius,
                    "r2r": ReactionType.Arrhenius,
                    "r3": ReactionType.Arrhenius,
                    "r4": ReactionType.Arrhenius,
                    "r5": ReactionType.Arrhenius,
                    "r6": ReactionType.Arrhenius,
                    "r7": ReactionType.Arrhenius,
                    "r8": ReactionType.Arrhenius,
                    "r9": ReactionType.Arrhenius,
                    "r10": ReactionType.Arrhenius,
                    "r11": ReactionType.Arrhenius,
                    "r12": ReactionType.Arrhenius,
                    "r13": ReactionType.Arrhenius,
                    "r14": ReactionType.Arrhenius,
                    "r15": ReactionType.Arrhenius,
                    "r16": ReactionType.Arrhenius,
                    "r17": ReactionType.Arrhenius,
                    "r18": ReactionType.Arrhenius
                    })

sim.set_bulk_porosity(0.3309)
sim.set_washcoat_porosity(0.4)
sim.set_reactor_radius(1)
sim.set_space_velocity_all_runs(500)
sim.set_cell_density(62)

# CO + 0.5 O2 --> CO2
r1 = {"parameters": {"A": 2.05E+18, "E": 110521.4141},
          "mol_reactants": {"CO": 1, "O2": 0.5},
          "mol_products": {},
          "rxn_orders": {"CO": 1, "O2": 1}
        }

# H2 + 0.5 O2 --> H2O
r2f = {"parameters": {"A": 46157501893, "E": 40443.38926},
          "mol_reactants": {"H2": 1, "O2": 0.5},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "O2": 1}
        }

# H2 + 0.5 O2 <-- H2O
r2r = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"H2O": 1},
          "mol_products": {"H2": 1, "O2": 0.5},
          "rxn_orders": {"H2O": 1}
        }

# CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
r3 = {"parameters": {"A": 6.37E+17, "E":  112652.853},
          "mol_reactants": {"HC": 1, "O2": (x + y/4 - z/2)},
          "mol_products": {"H2O": y/2},
          "rxn_orders": {"HC": 1, "O2": 1}
        }

# CO + NO --> CO2 + 0.5 N2
r4 = {"parameters": {"A": 9.85111E+14, "E":  130481.2229},
          "mol_reactants": {"CO": 1, "NO": 1},
          "mol_products": {},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# CO + 2 NO --> N2O + CO2
r5 = {"parameters": {"A": 9.83667E+14, "E": 132741.1425},
          "mol_reactants": {"CO": 1, "NO": 2},
          "mol_products": {"N2O": 1},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# 2.5 H2 + NO --> NH3 + H2O
r6 = {"parameters": {"A": 2.17911E+15, "E": 77531.59042},
          "mol_reactants": {"H2": 2.5, "NO": 1},
          "mol_products": {"NH3": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# H2 + NO --> H2O + 0.5 N2
r7 = {"parameters": {"A": 2.75E+16, "E": 112920.0924},
          "mol_reactants": {"H2": 1, "NO": 1},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# 2.5 CO + NO + 1.5 H2O --> NH3 + 2.5 CO2
r8 = {"parameters": {"A": 9.98873E+14, "E":  116323.3955},
          "mol_reactants": {"CO": 2.5, "NO": 1, "H2O": 1.5},
          "mol_products": {"NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2O": 1}
        }

# CO + NO + 1.5 H2 --> NH3 + CO2
r9 = {"parameters": {"A": 1E+15, "E":  114999.6822},
          "mol_reactants": {"CO": 1, "NO": 1, "H2": 1.5},
          "mol_products": {"NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2": 1}
        }

# CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
r10 = {"parameters": {"A": 3.72E+17, "E": 110475.8891},
          "mol_reactants": {"HC": 1, "NO": (2*x + y/2 - z)},
          "mol_products": {"H2O": y/2},
          "rxn_orders": {"HC": 1, "NO": 1}
        }

# CO + H2O --> CO2 + H2
r11 = {"parameters": {"A": 2.33E+16, "E": 115968.1085},
          "mol_reactants": {"CO": 1, "H2O": 1},
          "mol_products": {"H2": 1},
          "rxn_orders": {"CO": 1, "H2O": 1}
        }

# CxHyOz + x H2O --> x CO + (x + (y/2)) H2 + (z/2) O2
r12 = {"parameters": {"A": 36753619.4, "E":  30005.30375},
          "mol_reactants": {"HC": 1, "H2O": x},
          "mol_products": {"CO": x, "H2": (x + y/2), "O2": z/2},
          "rxn_orders": {"HC": 1, "H2O": 1}
        }

# N2O + CO --> N2 + CO2
r13 = {"parameters": {"A": 2.22E+17, "E":  95838.98253},
          "mol_reactants": {"N2O": 1, "CO": 1},
          "mol_products": {},
          "rxn_orders": {"N2O": 1, "CO": 1}
        }

# H2 + 2 NO --> N2O + H2O
r14 = {"parameters": {"A": 1.17999E+11, "E":  37524.05203},
          "mol_reactants": {"H2": 1, "NO": 2},
          "mol_products": {"N2O": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# N2O + CO + O2 --> 2 NO + CO2
r15 = {"parameters": {"A": 9.99871E+14, "E":  114932.6086},
          "mol_reactants": {"N2O": 1, "CO": 1, "O2": 1},
          "mol_products": {"NO": 2},
          "rxn_orders": {"N2O": 1, "CO": 1, "O2": 1}
        }

# CxHyOz + NO + (2x + ((y/2) - (3/2)) - z - 1) O2 --> x CO2 + ((y/2) - (3/2)) H2O + NH3
r16 = {"parameters": {"A": 9.99871E+14, "E": 115105.6884},
          "mol_reactants": {"HC": 1, "NO": 1, "O2": (2*x + (y/2 - (3/2)) - z - 1)},
          "mol_products": {"H2O": (y/2 - (3/2)), "NH3": 1},
          "rxn_orders": {"HC": 1, "NO": 1, "O2": 1}
        }

# 2 NH3 + 1.5 O2 --> N2 + 3 H2O
r17 = {"parameters": {"A": 1.80668E+13, "E": 62310.78927},
          "mol_reactants": {"NH3": 2, "O2": 1.5},
          "mol_products": {"H2O": 3},
          "rxn_orders": {"NH3": 1, "O2": 1}
        }

# CxHyOz + 2 NO + (x + (y/4) - (z/2) - (1/2)) O2 --> N2O + x CO2 + (y/2) H2O
r18 = {"parameters": {"A": 9.99936E+14, "E": 115060.3755},
          "mol_reactants": {"HC": 1, "NO": 2, "O2": (x + (y/4) - (z/2) - (1/2))},
          "mol_products": {"N2O": 1, "H2O": y/2},
          "rxn_orders": {"HC": 1, "NO": 1, "O2": 1}
        }

sim.set_reaction_info("r1", r1)
sim.set_reaction_info("r2f", r2f)
sim.set_reaction_info("r2r", r2r)
sim.set_reaction_info("r3", r3)
sim.set_reaction_info("r4", r4)
sim.set_reaction_info("r5", r5)
sim.set_reaction_info("r6", r6)
sim.set_reaction_info("r7", r7)
sim.set_reaction_info("r8", r8)
sim.set_reaction_info("r9", r9)
sim.set_reaction_info("r10", r10)
sim.set_reaction_info("r11", r11)
sim.set_reaction_info("r12", r12)
sim.set_reaction_info("r13", r13)
sim.set_reaction_info("r14", r14)
sim.set_reaction_info("r15", r15)
sim.set_reaction_info("r16", r16)
sim.set_reaction_info("r17", r17)
sim.set_reaction_info("r18", r18)

sim.build_constraints()
sim.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=90,elems=10,colpoints=2)

# Setup temperature information from data
sim.set_temperature_from_data("A0", "T0", temp_data, {"T_in": 0, "T_mid": 2.5, "T_out": 5})

# Setup reaction zones for each reaction
#   These are just guesses for now (Assuming the co-reactions between CO and NO
#       only occur on Pd/Rh zone)
#-------------------------------------------------------------------------------
#sim.set_reaction_zone("r4", (2.5, 5))
#sim.set_reaction_zone("r5", (2.5, 5))
#sim.set_reaction_zone("r8", (2.5, 5))
#sim.set_reaction_zone("r9", (2.5, 5))

# ICs in ppm
sim.set_const_IC_in_ppm("HC","A0","T0",3000/x)
sim.set_const_IC_in_ppm("CO","A0","T0",5055.615333)
sim.set_const_IC_in_ppm("NO","A0","T0",893.3438106)
sim.set_const_IC_in_ppm("N2O","A0","T0",59.78555023)
sim.set_const_IC_in_ppm("NH3","A0","T0",1.1629042)
sim.set_const_IC_in_ppm("H2","A0","T0",1610.22121)
sim.set_const_IC_in_ppm("O2","A0","T0",6500)
sim.set_const_IC_in_ppm("H2O","A0","T0",131905.812)

# BCs in ppm
sim.set_const_BC_in_ppm("HC","A0","T0",3000/x)
sim.set_const_BC_in_ppm("CO","A0","T0",5069.361883)
sim.set_const_BC_in_ppm("NO","A0","T0",1038.238168)
sim.set_const_BC_in_ppm("N2O","A0","T0",0)
sim.set_const_BC_in_ppm("NH3","A0","T0",0)
sim.set_const_BC_in_ppm("H2","A0","T0",1670)
sim.set_const_BC_in_ppm("O2","A0","T0",6500)
sim.set_const_BC_in_ppm("H2O","A0","T0",131905.812)

# Fix all reactions for simulation mode only
#sim.fix_all_reactions()

file = open(HC_name+"_iterations.txt","w")
file.write('iter\tobj\n')
sim.auto_select_all_weight_factors()
obj = 0
for i in range(MC_iter):
    print("\nMC iter =\t"+str(i)+"\n")
    if i > 0:
        for rxn in sim.model.arrhenius_rxns:
            #sim.set_reaction_param_bounds(rxn, "A", factor=100)
            #sim.set_reaction_param_bounds(rxn, "E", factor=5)

            #Pick random sets
            Apow = random.uniform(6, 22)
            Aval = random.uniform(pow(10,Apow-1), pow(10,Apow+1))
            Eval = random.uniform(20000, 300000)
            sim.model.A[rxn].set_value(Aval)
            sim.model.E[rxn].set_value(Eval)
            if rxn == "r2r":
                sim.model.A[rxn].set_value(0)
                sim.model.E[rxn].set_value(0)

            sim.set_reaction_param_bounds(rxn, "A", factor=0.1)
            sim.set_reaction_param_bounds(rxn, "E", factor=0.1)

    sim.initialize_auto_scaling()
    sim.initialize_simulator()

    #sim.finalize_auto_scaling()
    #sim.run_solver()

    obj = value(sim.model.obj)
    file.write(str(i)+'\t'+str(obj)+'\n')
    print(str(i)+'\t'+str(obj)+'\n')

    name = HC_name+"_CO_"+str(i)
    sim.plot_vs_data("CO", "A0", "T0", 5, display_live=False, file_name=name)
    name = HC_name+"_NO_"+str(i)
    sim.plot_vs_data("NO", "A0", "T0", 5, display_live=False, file_name=name)
    name = HC_name+"_HC_"+str(i)
    sim.plot_vs_data("HC", "A0", "T0", 5, display_live=False, file_name=name)
    name = HC_name+"_NH3_"+str(i)
    sim.plot_vs_data("NH3", "A0", "T0", 5, display_live=False, file_name=name)
    name = HC_name+"_N2O_"+str(i)
    sim.plot_vs_data("N2O", "A0", "T0", 5, display_live=False, file_name=name)
    name = HC_name+"_H2_"+str(i)
    sim.plot_vs_data("H2", "A0", "T0", 5, display_live=False, file_name=name)

    sim.print_results_of_breakthrough(["HC","CO","NO","NH3","N2O","H2","O2","H2O"],
                                    "A0", "T0", file_name=HC_name+"_lightoff"+str(i)+".txt", include_temp=True)
    sim.print_kinetic_parameter_info(file_name=HC_name+"_params"+str(i)+".txt")
    sim.save_model_state(file_name=HC_name+"_model"+str(i)+".json")

file.close()
