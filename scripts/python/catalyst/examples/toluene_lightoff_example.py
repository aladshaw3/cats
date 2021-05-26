# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# NOTE: We don't really need to go beyond 60 min for this case
#       Beyond that point, concentrations are very near zero and
#       convergence becomes problematic

# # TODO: Add cut-off time in time point selector
# # TODO: Add methods to give temperature info via data file
# # TODO: Add a "cut-off" in the solver/initializer for very high temps or fast kinetics

# Give x, y, z for the HC (CxHyOz)
x = 7
y = 8
z = 0

data = naively_read_data_file("inputfiles/toluene_lightoff_history.txt",factor=10)
temp_data = naively_read_data_file("inputfiles/toluene_temp_history.txt",factor=10)

time_list = time_point_selector(data["time"], data, end_time=55)

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
r1 = {"parameters": {"A": 6.62312E+36, "E": 305664.46 },
          "mol_reactants": {"CO": 1, "O2": 0.5},
          "mol_products": {},
          "rxn_orders": {"CO": 1, "O2": 1}
        }

# H2 + 0.5 O2 --> H2O
r2f = {"parameters": {"A": 1.34471E+13, "E": 58281.55 },
          "mol_reactants": {"H2": 1, "O2": 0.5},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "O2": 1}
        }

# H2 + 0.5 O2 <-- H2O
r2r = {"parameters": {"A": 48276942.38, "E":  65974.93 },
          "mol_reactants": {"H2O": 1},
          "mol_products": {"H2": 1, "O2": 0.5},
          "rxn_orders": {"H2O": 1}
        }

# CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
r3 = {"parameters": {"A": 5.96037E+25, "E":  208691.04 },
          "mol_reactants": {"HC": 1, "O2": (x + y/4 - z/2)},
          "mol_products": {"H2O": y/2},
          "rxn_orders": {"HC": 1, "O2": 1}
        }

# CO + NO --> CO2 + 0.5 N2
r4 = {"parameters": {"A": 17034145694, "E":  39002.51 },
          "mol_reactants": {"CO": 1, "NO": 1},
          "mol_products": {},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# CO + 2 NO --> N2O + CO2
r5 = {"parameters": {"A": 1.5871E+12, "E": 47794.51},
          "mol_reactants": {"CO": 1, "NO": 2},
          "mol_products": {"N2O": 1},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# 2.5 H2 + NO --> NH3 + H2O
r6 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"H2": 2.5, "NO": 1},
          "mol_products": {"NH3": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# H2 + NO --> H2O + 0.5 N2
r7 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"H2": 1, "NO": 1},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# 2.5 CO + NO + 1.5 H2O --> NH3 + 2.5 CO2
r8 = {"parameters": {"A": 3.53466E+15, "E":  139750.55},
          "mol_reactants": {"CO": 2.5, "NO": 1, "H2O": 1.5},
          "mol_products": {"NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2O": 1}
        }

# CO + NO + 1.5 H2 --> NH3 + CO2
r9 = {"parameters": {"A": 0, "E":  0},
          "mol_reactants": {"CO": 1, "NO": 1, "H2": 1.5},
          "mol_products": {"NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2": 1}
        }

# CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
r10 = {"parameters": {"A": 2.40428E+40, "E":   343782.59},
          "mol_reactants": {"HC": 1, "NO": (2*x + y/2 - z)},
          "mol_products": {"H2O": y/2},
          "rxn_orders": {"HC": 1, "NO": 1}
        }

# CO + H2O --> CO2 + H2
r11 = {"parameters": {"A": 0, "E":  0},
          "mol_reactants": {"CO": 1, "H2O": 1},
          "mol_products": {"H2": 1},
          "rxn_orders": {"CO": 1, "H2O": 1}
        }

# CxHyOz + x H2O --> x CO + (x + (y/2)) H2 + (z/2) O2
r12 = {"parameters": {"A": 0, "E":  0},
          "mol_reactants": {"HC": 1, "H2O": x},
          "mol_products": {"CO": x, "H2": (x + y/2), "O2": z/2},
          "rxn_orders": {"HC": 1, "H2O": 1}
        }

# N2O + CO --> N2 + CO2
r13 = {"parameters": {"A": 0, "E":  0},
          "mol_reactants": {"N2O": 1, "CO": 1},
          "mol_products": {},
          "rxn_orders": {"N2O": 1, "CO": 1}
        }

# H2 + 2 NO --> N2O + H2O
r14 = {"parameters": {"A": 0, "E":  0},
          "mol_reactants": {"H2": 1, "NO": 2},
          "mol_products": {"N2O": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# N2O + CO + O2 --> 2 NO + CO2
r15 = {"parameters": {"A": 3.33609E+31, "E":  243898.52},
          "mol_reactants": {"N2O": 1, "CO": 1, "O2": 1},
          "mol_products": {"NO": 2},
          "rxn_orders": {"N2O": 1, "CO": 1, "O2": 1}
        }

# CxHyOz + NO + (2x + ((y/2) - (3/2)) - z - 1) O2 --> x CO2 + ((y/2) - (3/2)) H2O + NH3
r16 = {"parameters": {"A": 2.37838E+80, "E":   800042.39},
          "mol_reactants": {"HC": 1, "NO": 1, "O2": (2*x + (y/2 - (3/2)) - z - 1)},
          "mol_products": {"H2O": (y/2 - (3/2)), "NH3": 1},
          "rxn_orders": {"HC": 1, "NO": 1, "O2": 1}
        }

# 2 NH3 + 1.5 O2 --> N2 + 3 H2O
r17 = {"parameters": {"A": 3.3418E+23, "E": 229017.60},
          "mol_reactants": {"NH3": 2, "O2": 1.5},
          "mol_products": {"H2O": 3},
          "rxn_orders": {"NH3": 1, "O2": 1}
        }

# CxHyOz + 2 NO + (x + (y/4) - (z/2) - (1/2)) O2 --> N2O + x CO2 + (y/2) H2O
r18 = {"parameters": {"A": 3.3418E+23, "E": 229017.60},
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

# Sample
sim.set_isothermal_temp("A0","T0",380)
sim.set_temperature_ramp("A0", "T0", 14, 92, 825)

# Setup reaction zones for each reaction
#sim.set_reaction_zone("r4", (2.5, 5))

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
sim.fix_all_reactions()

sim.initialize_auto_scaling(scale_to=0.1)
options={'print_user_options': 'yes',
        'linear_solver': LinearSolverMethod.MA27,
        'tol': 1e-8,
        'acceptable_tol': 1e-8,
        'compl_inf_tol': 1e-8,
        'constr_viol_tol': 1e-8,
        'max_iter': 3000,
        'obj_scaling_factor': 1,
        'diverging_iterates_tol': 1e50}
sim.initialize_simulator(console_out=False, options=options)

sim.plot_vs_data("CO", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("NO", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("HC", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("NH3", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("N2O", "A0", "T0", 5, display_live=False)
sim.plot_vs_data("H2", "A0", "T0", 5, display_live=False)
