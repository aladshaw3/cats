# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Give x, y, z for the HC (CxHyOz)
HC_name = "toluene"
x = 7
y = 8
z = 0

O2_in = 6500
CO2_in = 130000
H2O_in = 130000
CO_in = 5000    #5070
H2_in = 1670
NO_in = 1070    #1040
NH3_in = 0
N2O_in = 0
HC_in = 3000/x

data = naively_read_data_file("inputfiles/"+HC_name+"_lightoff_history.txt",factor=2)
temp_data = naively_read_data_file("inputfiles/"+HC_name+"_temp_history.txt",factor=2)

time_list = time_point_selector(data["time"], data, end_time=60)

sim = Isothermal_Monolith_Simulator()
sim.add_axial_dim(0,5)         #cm
sim.add_axial_dataset(5)

sim.add_temporal_dim(point_list=time_list)
sim.add_temporal_dataset(data["time"])

sim.add_age_set("A0")
sim.add_data_age_set("A0")

sim.add_temperature_set("T0")
sim.add_data_temperature_set("T0")

sim.add_gas_species(["HC","CO","NO","N2O","NH3","H2","O2","H2O","CO2"])
sim.add_data_gas_species(["HC","CO","NO","N2O","NH3","H2"])

sim.set_data_values_for("HC","A0","T0",5,data["time"],data["HC"])
sim.set_data_values_for("CO","A0","T0",5,data["time"],data["CO"])
sim.set_data_values_for("NO","A0","T0",5,data["time"],data["NO"])
sim.set_data_values_for("N2O","A0","T0",5,data["time"],data["N2O"])
sim.set_data_values_for("NH3","A0","T0",5,data["time"],data["NH3"])
sim.set_data_values_for("H2","A0","T0",5,data["time"],data["H2"])

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

                    # NH3 + NO + 0.25 O2 --> 1.5 H2O (+ N2)
                    "r15": ReactionType.Arrhenius
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
r4 = {"parameters": {"A": 3.473335911420499e+36, "E": 304924.98618328216},
          "mol_reactants": {"CO": 1, "NO": 1},
          "mol_products": {"CO2": 1},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# CO + 2 NO --> CO2 + N2O
r5 = {"parameters": {"A": 3.174729324826581e+22, "E": 170429.67328083533},
          "mol_reactants": {"CO": 1, "NO": 2},
          "mol_products": {"CO2": 1, "N2O": 1},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# 2.5 CO + NO + 1.5 H2O --> 2.5 CO2 + NH3
r8 = {"parameters": {"A": 1.8767305119846367e+38, "E": 304127.76066024584},
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
r6 = {"parameters": {"A": 9.075483439125227e+16, "E": 90733.41643967327},
          "mol_reactants": {"H2": 2.5, "NO": 1},
          "mol_products": {"NH3": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# H2 + NO --> H2O (+ 0.5 N2)
r7 = {"parameters": {"A": 190025116968837.8, "E": 62830.56919380204},
          "mol_reactants": {"H2": 1, "NO": 1},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# H2 + 2 NO --> N2O + H2O
r14 = {"parameters": {"A": 606598964637.8237, "E": 43487.90521352834},
          "mol_reactants": {"H2": 1, "NO": 2},
          "mol_products": {"N2O": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# NH3 + NO + 0.25 O2 --> 1.5 H2O (+ N2)
r15 = {"parameters": {"A": 1.0E+41, "E": 300000},
          "mol_reactants": {"NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"H2O": 1.5},
          "rxn_orders": {"NH3": 1, "NO": 1, "O2": 1}
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
sim.set_reaction_info("r15", r15)

sim.build_constraints()
sim.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=90,elems=20,colpoints=2)

# Setup temperature information from data
sim.set_temperature_from_data("A0", "T0", temp_data, {"T_in": 0, "T_mid": 2.5, "T_out": 5})

# ICs in ppm
sim.set_const_IC_in_ppm("HC","A0","T0",HC_in)
sim.set_const_IC_in_ppm("CO","A0","T0",CO_in)
sim.set_const_IC_in_ppm("NO","A0","T0",NO_in)
sim.set_const_IC_in_ppm("N2O","A0","T0",N2O_in)
sim.set_const_IC_in_ppm("NH3","A0","T0",NH3_in)
sim.set_const_IC_in_ppm("H2","A0","T0",H2_in)
sim.set_const_IC_in_ppm("O2","A0","T0",O2_in)
sim.set_const_IC_in_ppm("H2O","A0","T0",H2O_in)
sim.set_const_IC_in_ppm("CO2","A0","T0",CO2_in)

# BCs in ppm
sim.set_const_BC_in_ppm("HC","A0","T0",HC_in, auto_init=True)
sim.set_const_BC_in_ppm("CO","A0","T0",CO_in, auto_init=True)
sim.set_const_BC_in_ppm("NO","A0","T0",NO_in, auto_init=True)
sim.set_const_BC_in_ppm("N2O","A0","T0",N2O_in, auto_init=True)
sim.set_const_BC_in_ppm("NH3","A0","T0",NH3_in, auto_init=True)
sim.set_const_BC_in_ppm("H2","A0","T0",H2_in, auto_init=True)
sim.set_const_BC_in_ppm("O2","A0","T0",O2_in, auto_init=True)
sim.set_const_BC_in_ppm("H2O","A0","T0",H2O_in, auto_init=True)
sim.set_const_BC_in_ppm("CO2","A0","T0",CO2_in, auto_init=True)

# Fix all reactions for simulation mode only
sim.fix_all_reactions()

# ========== Selecting weight factors
sim.auto_select_all_weight_factors()


#sim.ignore_weight_factor("N2O","A0","T0",time_window=(0,110))
#sim.ignore_weight_factor("NO","A0","T0",time_window=(0,110))
#sim.ignore_weight_factor("NH3","A0","T0",time_window=(0,110))
sim.ignore_weight_factor("H2","A0","T0",time_window=(0,110))


sim.initialize_auto_scaling()
sim.initialize_simulator(console_out=False, restart_on_warning=True, restart_on_error=True)

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

sim.print_results_of_breakthrough(["HC","CO","NO","NH3","N2O","H2","O2","H2O"],
                                    "A0", "T0", file_name=HC_name+"_lightoff.txt", include_temp=True)

sim.print_kinetic_parameter_info(file_name=HC_name+"_params.txt")
sim.save_model_state(file_name=HC_name+"_model.json")
