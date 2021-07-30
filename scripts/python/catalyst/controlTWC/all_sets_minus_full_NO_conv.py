# NOTE: This model had issues with convergence. Seems to have gotten better
#   by switching to OrthogonalCollocation with 3 colpoints and doing a
#   higher level of spatial discretization

# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Read in data
exp_name = {}
exp_name["A0"] = "CO2_H2O_CO_H2_NO"
exp_name["A1"] = "CO2_H2O_CO_NO"
exp_name["A2"] = "CO2_H2O_CO_H2"
exp_name["A3"] = "CO2_H2O_CO"

O2_in = {}
CO2_in = {}
H2O_in = {}
CO_in = {}
H2_in = {}
NO_in = {}
NH3_in = {}
N2O_in = {}

O2_in["A0"] = 2635
CO2_in["A0"] = 130000
H2O_in["A0"] = 130000
CO_in["A0"] = 5000
H2_in["A0"] = 1670
NO_in["A0"] = 1070
NH3_in["A0"] = 0
N2O_in["A0"] = 0

O2_in["A1"] = 1800
CO2_in["A1"] = 130000
H2O_in["A1"] = 130000
CO_in["A1"] = 5000
H2_in["A1"] = 0
NO_in["A1"] = 1070
NH3_in["A1"] = 0
N2O_in["A1"] = 0

O2_in["A2"] = 3135
CO2_in["A2"] = 130000
H2O_in["A2"] = 130000
CO_in["A2"] = 5000
H2_in["A2"] = 1670
NO_in["A2"] = 0
NH3_in["A2"] = 0
N2O_in["A2"] = 0

O2_in["A3"] = 2300
CO2_in["A3"] = 130000
H2O_in["A3"] = 130000
CO_in["A3"] = 5000
H2_in["A3"] = 0
NO_in["A3"] = 0
NH3_in["A3"] = 0
N2O_in["A3"] = 0

data = {}
temp_data = {}

data["A0"] = naively_read_data_file("inputfiles/"+exp_name["A0"]+"_lightoff.txt",factor=2)
temp_data["A0"] = naively_read_data_file("inputfiles/"+exp_name["A0"]+"_temp.txt",factor=2)

data["A1"] = naively_read_data_file("inputfiles/"+exp_name["A1"]+"_lightoff.txt",factor=2)
temp_data["A1"] = naively_read_data_file("inputfiles/"+exp_name["A1"]+"_temp.txt",factor=2)

data["A2"] = naively_read_data_file("inputfiles/"+exp_name["A2"]+"_lightoff.txt",factor=2)
temp_data["A2"] = naively_read_data_file("inputfiles/"+exp_name["A2"]+"_temp.txt",factor=2)

data["A3"] = naively_read_data_file("inputfiles/"+exp_name["A3"]+"_lightoff.txt",factor=2)
temp_data["A3"] = naively_read_data_file("inputfiles/"+exp_name["A3"]+"_temp.txt",factor=2)

time_list = time_point_selector(data["A0"]["time"], data["A0"], end_time=60)

sim = Isothermal_Monolith_Simulator()

sim.add_axial_dim(0,5)         #cm
sim.add_axial_dataset(5)

sim.add_temporal_dim(point_list=time_list)
sim.add_temporal_dataset(data["A0"]["time"])

sim.add_age_set(["A0","A1","A2","A3"])
sim.add_data_age_set(["A0","A1","A2","A3"])

sim.add_temperature_set("T0")
sim.add_data_temperature_set("T0")

sim.add_gas_species(["CO","NO","N2O","NH3","H2","O2","H2O","CO2"])
sim.add_data_gas_species(["CO","NO","N2O","NH3","H2"])

sim.set_data_values_for("CO","A0","T0",5,data["A0"]["time"],data["A0"]["CO"])
sim.set_data_values_for("NO","A0","T0",5,data["A0"]["time"],data["A0"]["NO"])
sim.set_data_values_for("N2O","A0","T0",5,data["A0"]["time"],data["A0"]["N2O"])
sim.set_data_values_for("NH3","A0","T0",5,data["A0"]["time"],data["A0"]["NH3"])
sim.set_data_values_for("H2","A0","T0",5,data["A0"]["time"],data["A0"]["H2"])

sim.set_data_values_for("CO","A1","T0",5,data["A0"]["time"],data["A1"]["CO"])
sim.set_data_values_for("NO","A1","T0",5,data["A0"]["time"],data["A1"]["NO"])
sim.set_data_values_for("N2O","A1","T0",5,data["A0"]["time"],data["A1"]["N2O"])
sim.set_data_values_for("NH3","A1","T0",5,data["A0"]["time"],data["A1"]["NH3"])
sim.set_data_values_for("H2","A1","T0",5,data["A0"]["time"],data["A1"]["H2"])

sim.set_data_values_for("CO","A2","T0",5,data["A0"]["time"],data["A2"]["CO"])
sim.set_data_values_for("NO","A2","T0",5,data["A0"]["time"],data["A2"]["NO"])
sim.set_data_values_for("N2O","A2","T0",5,data["A0"]["time"],data["A2"]["N2O"])
sim.set_data_values_for("NH3","A2","T0",5,data["A0"]["time"],data["A2"]["NH3"])
sim.set_data_values_for("H2","A2","T0",5,data["A0"]["time"],data["A2"]["H2"])

sim.set_data_values_for("CO","A3","T0",5,data["A0"]["time"],data["A3"]["CO"])
sim.set_data_values_for("NO","A3","T0",5,data["A0"]["time"],data["A3"]["NO"])
sim.set_data_values_for("N2O","A3","T0",5,data["A0"]["time"],data["A3"]["N2O"])
sim.set_data_values_for("NH3","A3","T0",5,data["A0"]["time"],data["A3"]["NH3"])
sim.set_data_values_for("H2","A3","T0",5,data["A0"]["time"],data["A3"]["H2"])

sim.add_reactions({
                    # CO + 0.5 O2 --> CO2
                    "r1": ReactionType.Arrhenius,

                    # H2 + 0.5 O2 --> H2O
                    "r2": ReactionType.Arrhenius,

                    # CO + NO --> CO2 (+ 0.5 N2)
                    "r4": ReactionType.Arrhenius,

                    # CO + 2 NO --> CO2 + N2O
                    "r5": ReactionType.Arrhenius,

                    # 2.5 CO + NO + 1.5 H2O --> 2.5 CO2 + NH3
                    "r8": ReactionType.Arrhenius,

                    # CO + H2O <-- --> CO2 + H2
                    "r11": ReactionType.EquilibriumArrhenius,

                    # 2.5 H2 + NO --> NH3 + H2O
                    "r6": ReactionType.Arrhenius,

                    # H2 + NO --> H2O (+ 0.5 N2)
                    "r7": ReactionType.Arrhenius,

                    # H2 + 2 NO --> N2O + H2O
                    "r14": ReactionType.Arrhenius,
                  })

sim.set_bulk_porosity(0.775)
sim.set_washcoat_porosity(0.4)
sim.set_reactor_radius(1)
sim.set_space_velocity_all_runs(500)
sim.set_cell_density(93)

# CO + 0.5 O2 --> CO2
r1 = {"parameters": {"A": 1.6550871137667489e+31, "E": 235293.33281046877},
          "mol_reactants": {"CO": 1, "O2": 0.5},
          "mol_products": {"CO2": 1},
          "rxn_orders": {"CO": 1, "O2": 1}
        }

# H2 + 0.5 O2 --> H2O
r2 = {"parameters": {"A": 1.733658868809338e+24, "E": 158891.38869742613},
          "mol_reactants": {"H2": 1, "O2": 0.5},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "O2": 1}
        }

# CO + NO --> CO2 (+ 0.5 N2)
r4 = {"parameters": {"A": 5.944712403015287e+35, "E": 288911.6551645578},
          "mol_reactants": {"CO": 1, "NO": 1},
          "mol_products": {"CO2": 1},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# CO + 2 NO --> CO2 + N2O
r5 = {"parameters": {"A": 4.531565577134861e+22, "E": 172729.35335935783},
          "mol_reactants": {"CO": 1, "NO": 2},
          "mol_products": {"CO2": 1, "N2O": 1},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# 2.5 CO + NO + 1.5 H2O --> 2.5 CO2 + NH3
r8 = {"parameters": {"A": 2.121957620589748e+36, "E": 276479.9127631233},
          "mol_reactants": {"CO": 2.5, "NO": 1, "H2O": 1.5},
          "mol_products": {"CO2": 2.5, "NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2O": 1}
        }

# CO + H2O <-- --> CO2 + H2
r11 = {"parameters": {"A": 1.8429782328496848e+17, "E": 136610.55181420766,
                        "dH": 16769.16637626293, "dS": 139.10839203326302},
          "mol_reactants": {"CO": 1, "H2O": 1},
          "mol_products": {"H2": 1, "CO2": 1},
          "rxn_orders": {"CO": 1, "H2O": 1, "CO2": 1, "H2": 1}
        }


# 2.5 H2 + NO --> NH3 + H2O
r6 = {"parameters": {"A": 9.95335198921378e+16, "E": 91153.14726353942},
          "mol_reactants": {"H2": 2.5, "NO": 1},
          "mol_products": {"NH3": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# H2 + NO --> H2O (+ 0.5 N2)
r7 = {"parameters": {"A": 146174784865665.53, "E": 62475.804035616624},
          "mol_reactants": {"H2": 1, "NO": 1},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# H2 + 2 NO --> N2O + H2O
r14 = {"parameters": {"A": 497645518401.7446, "E": 42780.25225053141},
          "mol_reactants": {"H2": 1, "NO": 2},
          "mol_products": {"N2O": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

sim.set_reaction_info("r1", r1)
sim.set_reaction_info("r4", r4)
sim.set_reaction_info("r5", r5)
sim.set_reaction_info("r8", r8)
sim.set_reaction_info("r2", r2)
sim.set_reaction_info("r11", r11)
sim.set_reaction_info("r6", r6)
sim.set_reaction_info("r7", r7)
sim.set_reaction_info("r14", r14)

sim.build_constraints()
sim.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=90,elems=20,colpoints=2)

# Setup temperature information from data
sim.set_temperature_from_data("A0", "T0", temp_data["A0"], {"T_in": 0, "T_mid": 2.5, "T_out": 5})
sim.set_temperature_from_data("A1", "T0", temp_data["A1"], {"T_in": 0, "T_mid": 2.5, "T_out": 5})
sim.set_temperature_from_data("A2", "T0", temp_data["A2"], {"T_in": 0, "T_mid": 2.5, "T_out": 5})
sim.set_temperature_from_data("A3", "T0", temp_data["A3"], {"T_in": 0, "T_mid": 2.5, "T_out": 5})

# Setup reaction zones for each reaction
#   These are just guesses for now (Assuming the co-reactions between CO and NO
#       only occur on Pd/Rh zone)
#-------------------------------------------------------------------------------

# Maybe I should not consider this as a 'zone'
# NOTE: The current 'zone' method introduces a sharp discontinuity
#       That discontinuity may be introducing some numerical instability

#sim.set_reaction_zone("r4", (2.5, 5))
#sim.set_reaction_zone("r5", (2.5, 5))
#sim.set_reaction_zone("r8", (2.5, 5))

'''
sim.set_reaction_zone("r9", (2.5, 5))
sim.set_reaction_zone("r15", (2.5, 5))
'''


# ICs in ppm
sim.set_const_IC_in_ppm("CO","A0","T0",CO_in["A0"])
sim.set_const_IC_in_ppm("NO","A0","T0",NO_in["A0"])
sim.set_const_IC_in_ppm("N2O","A0","T0",N2O_in["A0"])
sim.set_const_IC_in_ppm("NH3","A0","T0",NH3_in["A0"])
sim.set_const_IC_in_ppm("H2","A0","T0",H2_in["A0"])
sim.set_const_IC_in_ppm("O2","A0","T0",O2_in["A0"])
sim.set_const_IC_in_ppm("H2O","A0","T0",H2O_in["A0"])
sim.set_const_IC_in_ppm("CO2","A0","T0",CO2_in["A0"])

sim.set_const_IC_in_ppm("CO","A1","T0",CO_in["A1"])
sim.set_const_IC_in_ppm("NO","A1","T0",NO_in["A1"])
sim.set_const_IC_in_ppm("N2O","A1","T0",N2O_in["A1"])
sim.set_const_IC_in_ppm("NH3","A1","T0",NH3_in["A1"])
sim.set_const_IC_in_ppm("H2","A1","T0",H2_in["A1"])
sim.set_const_IC_in_ppm("O2","A1","T0",O2_in["A1"])
sim.set_const_IC_in_ppm("H2O","A1","T0",H2O_in["A1"])
sim.set_const_IC_in_ppm("CO2","A1","T0",CO2_in["A1"])

sim.set_const_IC_in_ppm("CO","A2","T0",CO_in["A2"])
sim.set_const_IC_in_ppm("NO","A2","T0",NO_in["A2"])
sim.set_const_IC_in_ppm("N2O","A2","T0",N2O_in["A2"])
sim.set_const_IC_in_ppm("NH3","A2","T0",NH3_in["A2"])
sim.set_const_IC_in_ppm("H2","A2","T0",H2_in["A2"])
sim.set_const_IC_in_ppm("O2","A2","T0",O2_in["A2"])
sim.set_const_IC_in_ppm("H2O","A2","T0",H2O_in["A2"])
sim.set_const_IC_in_ppm("CO2","A2","T0",CO2_in["A2"])

sim.set_const_IC_in_ppm("CO","A3","T0",CO_in["A3"])
sim.set_const_IC_in_ppm("NO","A3","T0",NO_in["A3"])
sim.set_const_IC_in_ppm("N2O","A3","T0",N2O_in["A3"])
sim.set_const_IC_in_ppm("NH3","A3","T0",NH3_in["A3"])
sim.set_const_IC_in_ppm("H2","A3","T0",H2_in["A3"])
sim.set_const_IC_in_ppm("O2","A3","T0",O2_in["A3"])
sim.set_const_IC_in_ppm("H2O","A3","T0",H2O_in["A3"])
sim.set_const_IC_in_ppm("CO2","A3","T0",CO2_in["A3"])

# BCs in ppm
sim.set_const_BC_in_ppm("CO","A0","T0",CO_in["A0"], auto_init=True)
sim.set_const_BC_in_ppm("NO","A0","T0",NO_in["A0"], auto_init=True)
sim.set_const_BC_in_ppm("N2O","A0","T0",N2O_in["A0"], auto_init=True)
sim.set_const_BC_in_ppm("NH3","A0","T0",NH3_in["A0"], auto_init=True)
sim.set_const_BC_in_ppm("H2","A0","T0",H2_in["A0"], auto_init=True)
sim.set_const_BC_in_ppm("O2","A0","T0",O2_in["A0"], auto_init=True)
sim.set_const_BC_in_ppm("H2O","A0","T0",H2O_in["A0"], auto_init=True)
sim.set_const_BC_in_ppm("CO2","A0","T0",CO2_in["A0"], auto_init=True)

sim.set_const_BC_in_ppm("CO","A1","T0",CO_in["A1"], auto_init=True)
sim.set_const_BC_in_ppm("NO","A1","T0",NO_in["A1"], auto_init=True)
sim.set_const_BC_in_ppm("N2O","A1","T0",N2O_in["A1"], auto_init=True)
sim.set_const_BC_in_ppm("NH3","A1","T0",NH3_in["A1"], auto_init=True)
sim.set_const_BC_in_ppm("H2","A1","T0",H2_in["A1"], auto_init=True)
sim.set_const_BC_in_ppm("O2","A1","T0",O2_in["A1"], auto_init=True)
sim.set_const_BC_in_ppm("H2O","A1","T0",H2O_in["A1"], auto_init=True)
sim.set_const_BC_in_ppm("CO2","A1","T0",CO2_in["A1"], auto_init=True)

sim.set_const_BC_in_ppm("CO","A2","T0",CO_in["A2"], auto_init=True)
sim.set_const_BC_in_ppm("NO","A2","T0",NO_in["A2"], auto_init=True)
sim.set_const_BC_in_ppm("N2O","A2","T0",N2O_in["A2"], auto_init=True)
sim.set_const_BC_in_ppm("NH3","A2","T0",NH3_in["A2"], auto_init=True)
sim.set_const_BC_in_ppm("H2","A2","T0",H2_in["A2"], auto_init=True)
sim.set_const_BC_in_ppm("O2","A2","T0",O2_in["A2"], auto_init=True)
sim.set_const_BC_in_ppm("H2O","A2","T0",H2O_in["A2"], auto_init=True)
sim.set_const_BC_in_ppm("CO2","A2","T0",CO2_in["A2"], auto_init=True)

sim.set_const_BC_in_ppm("CO","A3","T0",CO_in["A3"], auto_init=True)
sim.set_const_BC_in_ppm("NO","A3","T0",NO_in["A3"], auto_init=True)
sim.set_const_BC_in_ppm("N2O","A3","T0",N2O_in["A3"], auto_init=True)
sim.set_const_BC_in_ppm("NH3","A3","T0",NH3_in["A3"], auto_init=True)
sim.set_const_BC_in_ppm("H2","A3","T0",H2_in["A3"], auto_init=True)
sim.set_const_BC_in_ppm("O2","A3","T0",O2_in["A3"], auto_init=True)
sim.set_const_BC_in_ppm("H2O","A3","T0",H2O_in["A3"], auto_init=True)
sim.set_const_BC_in_ppm("CO2","A3","T0",CO2_in["A3"], auto_init=True)


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

sim.fix_all_reactions()

#NOTE: It is possible that the solver returns an 'ok' and 'optimal' status for a problem that was not solved...
sim.initialize_auto_scaling()
sim.initialize_simulator(console_out=False, restart_on_warning=True, restart_on_error=True)

sim.finalize_auto_scaling()
sim.run_solver()

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

sim.print_kinetic_parameter_info(file_name="all_params"+".txt")
sim.save_model_state(file_name="all_model"+".json")
