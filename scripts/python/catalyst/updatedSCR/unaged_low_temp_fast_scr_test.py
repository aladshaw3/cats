import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

#Importing all reaction dictionaries
from rxns_v5 import *

# Create dict to iterate through
rxn_list = {"r5f": r5f,"r5r": r5r,"r6f": r6f,"r6r": r6r,"r7": r7,"r8": r8,"r9": r9,
            "r10": r10,"r11": r11,"r12": r12,"r13": r13,"r14": r14,
            "r15": r15,"r16": r16,"r17": r17,"r18": r18,"r19": r19,"r20": r20,
            "r21": r21,"r22": r22,"r23": r23,"r24": r24,"r25": r25,
            "r26": r26,"r27": r27,"r28": r28,"r29": r29,"r30": r30,"r31": r31,
            "r32": r32,"r33": r33,"r34": r34,"r35": r35,"r36": r36,
            "r37": r37,"r38": r38,"r39": r39}

O2 = 0.002330029
H2O = 0.001174
NO = 145
NO2 = 145
Tstr = "T0"

data = naively_read_data_file("inputfiles/FastSCR_150_to_250_data.txt",factor=5)
temp_data = naively_read_data_file("inputfiles/FastSCR_150_to_250_temp.txt",factor=5)
data_tup = naively_read_data_file("inputfiles/FastSCR_150_to_250_protocol.txt",
                                    factor=5,dict_of_tuples=True)

time_list = time_point_selector(data["time"], data)

sim = Isothermal_Monolith_Simulator()
sim.add_axial_dim(0,5)
sim.add_axial_dataset(5)       # Location of observations (in cm)

sim.add_temporal_dim(point_list=time_list)
sim.add_temporal_dataset(data["time"])   #Temporal observations (in min)

sim.add_age_set(["Unaged"])
sim.add_data_age_set(["Unaged"])  # Data observations can be a sub-set

sim.add_temperature_set([Tstr])
sim.add_data_temperature_set([Tstr])     # Data observations can be a sub-set

sim.add_gas_species(["NH3","H2O","O2","NO","NO2","N2O","N2"])
sim.add_data_gas_species(["NH3","NO","NO2","N2O"])    # Data observations can be a sub-set

sim.set_data_values_for("NH3","Unaged",Tstr,5,data["time"],data["NH3_Unaged"])
sim.set_data_values_for("NO","Unaged",Tstr,5,data["time"],data["NO_Unaged"])
sim.set_data_values_for("NO2","Unaged",Tstr,5,data["time"],data["NO2_Unaged"])
sim.set_data_values_for("N2O","Unaged",Tstr,5,data["time"],data["N2O_Unaged"])

sim.add_surface_species(["Z1CuOH-NH3",
                        "Z2Cu-NH3",
                        "Z2Cu-(NH3)2",
                        "ZNH4",
                        "Z1CuOH-H2O",
                        "Z2Cu-H2O",
                        "Z1CuOH-NH4NO3",
                        "Z2Cu-NH4NO3",
                        "ZH-NH4NO3"])
sim.add_surface_sites(["Z1CuOH","Z2Cu","ZH","CuO"])

sim.add_reactions({"r1": ReactionType.EquilibriumArrhenius,
                    "r2a": ReactionType.EquilibriumArrhenius,
                    "r2b": ReactionType.EquilibriumArrhenius,
                    "r3": ReactionType.EquilibriumArrhenius,
                    "r4a": ReactionType.EquilibriumArrhenius,
                    "r4b": ReactionType.EquilibriumArrhenius,

                    # NO Oxidation
                    "r5f": ReactionType.Arrhenius,
                    "r5r": ReactionType.Arrhenius,
                    "r6f": ReactionType.Arrhenius,
                    "r6r": ReactionType.Arrhenius,

                    #NH3 Oxidation to N2
                    "r7": ReactionType.Arrhenius,
                    "r8": ReactionType.Arrhenius,
                    "r9": ReactionType.Arrhenius,

                    #NH3 Oxidation to NO
                    "r10": ReactionType.Arrhenius,
                    "r11": ReactionType.Arrhenius,
                    "r12": ReactionType.Arrhenius,

                    #NO SCR
                    "r13": ReactionType.Arrhenius,
                    "r14": ReactionType.Arrhenius,
                    "r15": ReactionType.Arrhenius,
                    "r16": ReactionType.Arrhenius,
                    "r17": ReactionType.Arrhenius,

                    #N2O Formation from NO SCR
                    "r18": ReactionType.Arrhenius,
                    "r19": ReactionType.Arrhenius,
                    "r20": ReactionType.Arrhenius,

                    #NH4NO3 Formation
                    "r21": ReactionType.Arrhenius,
                    "r22": ReactionType.Arrhenius,
                    "r23": ReactionType.Arrhenius,
                    "r24": ReactionType.Arrhenius,

                    #NH4NO3 Fast SCR
                    "r25": ReactionType.Arrhenius,
                    "r26": ReactionType.Arrhenius,
                    "r27": ReactionType.Arrhenius,

                    #NH4NO3 NO2 SCR
                    "r28": ReactionType.Arrhenius,
                    "r29": ReactionType.Arrhenius,
                    "r30": ReactionType.Arrhenius,

                    #NH4NO3 N2O Formation
                    "r31": ReactionType.Arrhenius,
                    "r32": ReactionType.Arrhenius,
                    "r33": ReactionType.Arrhenius,

                    #CuO NH3 Oxidation @ High Temp
                    "r34": ReactionType.Arrhenius,
                    "r35": ReactionType.Arrhenius,
                    "r36": ReactionType.Arrhenius,

                    #N2O formation from NH3 oxidation
                    "r37": ReactionType.Arrhenius,
                    "r38": ReactionType.Arrhenius,
                    "r39": ReactionType.Arrhenius
                    })

sim.set_bulk_porosity(0.3309)
sim.set_washcoat_porosity(0.4)
sim.set_reactor_radius(1)
sim.set_space_velocity_all_runs(1000)      #volumes/min
sim.set_cell_density(62)                   # 62 cells per cm^2 (~400 cpsi)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"Z1CuOH-NH3": 1, "Z1CuOH-H2O": 1, "Z1CuOH-NH4NO3": 1}}
s2_data = {"mol_occupancy": {"Z2Cu-NH3": 1, "Z2Cu-(NH3)2": 1, "Z2Cu-H2O": 1, "Z2Cu-NH4NO3": 1}}
s3_data = {"mol_occupancy": {"ZNH4": 1, "ZH-NH4NO3": 1}}
CuO_data = {"mol_occupancy": {}}

sim.set_site_balance("Z1CuOH",s1_data)
sim.set_site_balance("Z2Cu",s2_data)
sim.set_site_balance("ZH",s3_data)
sim.set_site_balance("CuO",CuO_data)

sim.set_reaction_info("r1", r1_equ)
sim.set_reaction_info("r2a", r2a_equ)
sim.set_reaction_info("r2b", r2b_equ)
sim.set_reaction_info("r3", r3_equ)
sim.set_reaction_info("r4a", r4a_equ)
sim.set_reaction_info("r4b", r4b_equ)

sim.set_reaction_info("r5f", r5f)
sim.set_reaction_info("r5r", r5r)
sim.set_reaction_info("r6f", r6f)
sim.set_reaction_info("r6r", r6r)

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
sim.set_reaction_info("r19", r19)
sim.set_reaction_info("r20", r20)

sim.set_reaction_info("r21", r21)
sim.set_reaction_info("r22", r22)
sim.set_reaction_info("r23", r23)
sim.set_reaction_info("r24", r24)

sim.set_reaction_info("r25", r25)
sim.set_reaction_info("r26", r26)
sim.set_reaction_info("r27", r27)

sim.set_reaction_info("r28", r28)
sim.set_reaction_info("r29", r29)
sim.set_reaction_info("r30", r30)

sim.set_reaction_info("r31", r31)
sim.set_reaction_info("r32", r32)
sim.set_reaction_info("r33", r33)

sim.set_reaction_info("r34", r34)
sim.set_reaction_info("r35", r35)
sim.set_reaction_info("r36", r36)

sim.set_reaction_info("r37", r37)
sim.set_reaction_info("r38", r38)
sim.set_reaction_info("r39", r39)

# ----------------- Unaged Site Densities -----------
sim.set_site_density("Z1CuOH","Unaged",0.052619016)
sim.set_site_density("Z2Cu","Unaged",0.023125746)
sim.set_site_density("ZH","Unaged",0.01632+0.003233+0.006699)
sim.set_site_density("CuO","Unaged",0.001147378)


# Build the constraints then discretize
sim.build_constraints()
sim.discretize_model(method=DiscretizationMethod.OrthogonalCollocation,
                    tstep=90,elems=5,colpoints=2)


sim.set_temperature_from_data("Unaged", Tstr, temp_data, {"T": 5})

# ---------------- Unaged ICs ------------------
sim.set_const_IC("O2","Unaged",Tstr,O2)
sim.set_const_IC("H2O","Unaged",Tstr,H2O)
sim.set_const_IC("NH3","Unaged",Tstr,0)
sim.set_const_IC_in_ppm("NO","Unaged",Tstr,NO)
sim.set_const_IC_in_ppm("NO2","Unaged",Tstr,NO2)
sim.set_const_IC("N2O","Unaged",Tstr,0)
sim.set_const_IC("N2","Unaged",Tstr,0.0184)

sim.set_const_IC("Z1CuOH-NH3","Unaged",Tstr,0)
sim.set_const_IC("Z2Cu-NH3","Unaged",Tstr,0)
sim.set_const_IC("Z2Cu-(NH3)2","Unaged",Tstr,0)
sim.set_const_IC("ZNH4","Unaged",Tstr,0)
sim.set_const_IC("Z1CuOH-H2O","Unaged",Tstr,0)
sim.set_const_IC("Z2Cu-H2O","Unaged",Tstr,0)
sim.set_const_IC("Z1CuOH-NH4NO3","Unaged",Tstr,0)
sim.set_const_IC("Z2Cu-NH4NO3","Unaged",Tstr,0)
sim.set_const_IC("ZH-NH4NO3","Unaged",Tstr,0)

# ---------------- Unaged BCs ------------------
sim.set_time_dependent_BC("O2","Unaged",Tstr,
                            time_value_pairs=data_tup["O2_Unaged"],
                            initial_value=O2)

sim.set_time_dependent_BC("H2O","Unaged",Tstr,
                            time_value_pairs=data_tup["H2O_Unaged"],
                            initial_value=H2O)

sim.set_time_dependent_BC("NH3","Unaged",Tstr,
                            time_value_pairs=data_tup["NH3_Unaged"],
                            initial_value=0)
'''
sim.set_time_dependent_BC("NO","Unaged",Tstr,
                            time_value_pairs=data_tup["NO_Unaged"],
                            initial_value=NO)

sim.set_time_dependent_BC("NO2","Unaged",Tstr,
                            time_value_pairs=data_tup["NO2_Unaged"],
                            initial_value=NO2)
'''

sim.set_const_BC_in_ppm("NO","Unaged",Tstr,NO)
sim.set_const_BC_in_ppm("NO2","Unaged",Tstr,NO2)
sim.set_const_BC("N2O","Unaged",Tstr,0)

sim.set_const_BC("N2","Unaged",Tstr,0.0184)

# Fix all reactions for simulation mode only
sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")

sim.fix_all_reactions()

#Customize the weight factors
sim.auto_select_all_weight_factors()

sim.ignore_weight_factor("NH3","Unaged",Tstr,time_window=(390,510))
sim.ignore_weight_factor("NO","Unaged",Tstr,time_window=(390,510))
sim.ignore_weight_factor("NO2","Unaged",Tstr,time_window=(390,510))
sim.ignore_weight_factor("N2O","Unaged",Tstr,time_window=(390,510))

sim.initialize_auto_scaling()
sim.initialize_simulator()

sim.finalize_auto_scaling()
sim.run_solver()

'''
#NOTE: For some reason, IPOPT is pushing values outside of the bounds I set
sim.unfix_all_reactions()

upper = 1+0.0125
lower = 1-0.0125
for rxn in rxn_list:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))
    sim.set_reaction_param_bounds(rxn, "E", bounds=(sim.model.E[rxn].value*lower,sim.model.E[rxn].value*upper))

sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")

# Problematic reactions: r10, r11, r12, r34, r37, r38, r39 (all NH3 oxidation reactions)
sim.fix_reaction("r10")
sim.fix_reaction("r11")
sim.fix_reaction("r12")
sim.fix_reaction("r34")
sim.fix_reaction("r37")
sim.fix_reaction("r38")
sim.fix_reaction("r39")

# Other oxidation reactions: r7, r8, r9, r35, r36
sim.fix_reaction("r7")
sim.fix_reaction("r8")
sim.fix_reaction("r9")
sim.fix_reaction("r35")
sim.fix_reaction("r36")

# Fix std SCR reactions
sim.fix_reaction("r5f")
sim.fix_reaction("r5r")
sim.fix_reaction("r6f")
sim.fix_reaction("r6r")

sim.fix_reaction("r13")
sim.fix_reaction("r14")
sim.fix_reaction("r15")
sim.fix_reaction("r16")
sim.fix_reaction("r17")

sim.fix_reaction("r18")
sim.fix_reaction("r19")
sim.fix_reaction("r20")


sim.run_solver()
'''

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, file_name="Unaged_FastSCR_lowtemp_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, 0, file_name="Unaged_FastSCR_lowtemp_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", Tstr, file_name="Unaged_FastSCR_lowtemp_average_ads.txt")

sim.print_kinetic_parameter_info(file_name="FastSCR_lowtemp_opt_params.txt")
sim.save_model_state(file_name="FastSCR_lowtemp_model.json")

sim.plot_vs_data("NH3", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("NO", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("NO2", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("N2O", "Unaged", Tstr, 5, display_live=False)
