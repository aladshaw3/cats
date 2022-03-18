# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

#Importing all reaction dictionaries
from rxns_v4 import *

# Read in the data (data is now a dictionary containing the data we want)
data = naively_read_data_file("inputfiles/SCR_all_data.txt",factor=2)

time_list = time_point_selector(data["time"], data, end_time=149)

#Factor 2x with a cutoff time of 149 gives 216 discretization points
#   NOTE: This requires ~ 30 GB of RAM using 5 nodes with FD
print("Total number of data points = " + str(len(data["time"])*(len(data.keys())-1-4)))
print("Number of time-series data points = " + str(len(data["time"])))
print("Number of time-series model points = " + str(len(time_list)))

sim = Isothermal_Monolith_Simulator()
sim.add_axial_dim(0,5)
sim.add_axial_dataset(5)       # Location of observations (in cm)

sim.add_temporal_dim(point_list=time_list)
sim.add_temporal_dataset(data["time"])   #Temporal observations (in min)

sim.add_age_set(["Unaged","2hr","4hr","8hr","16hr"])
sim.add_data_age_set(["Unaged","2hr","4hr","8hr","16hr"])  # Data observations can be a sub-set

sim.add_temperature_set(["300C","400C","500C"])
sim.add_data_temperature_set(["300C","400C","500C"])     # Data observations can be a sub-set


sim.add_gas_species(["NH3","H2O","O2","NO","NO2","N2O","N2"])
sim.add_data_gas_species(["NH3","NO","NO2","N2O"])    # Data observations can be a sub-set

sim.set_data_values_for("NH3","Unaged","300C",5,data["time"],data["NH3_Unaged_300C"])
sim.set_data_values_for("NO","Unaged","300C",5,data["time"],data["NH3_Unaged_300C"])
sim.set_data_values_for("NO2","Unaged","300C",5,data["time"],data["NH3_Unaged_300C"])
sim.set_data_values_for("N2O","Unaged","300C",5,data["time"],data["NH3_Unaged_300C"])

sim.set_data_values_for("NH3","2hr","300C",5,data["time"],data["NH3_2hr_300C"])
sim.set_data_values_for("NO","2hr","300C",5,data["time"],data["NO_2hr_300C"])
sim.set_data_values_for("NO2","2hr","300C",5,data["time"],data["NO2_2hr_300C"])
sim.set_data_values_for("N2O","2hr","300C",5,data["time"],data["N2O_2hr_300C"])

sim.set_data_values_for("NH3","4hr","300C",5,data["time"],data["NH3_4hr_300C"])
sim.set_data_values_for("NO","4hr","300C",5,data["time"],data["NO_4hr_300C"])
sim.set_data_values_for("NO2","4hr","300C",5,data["time"],data["NO2_4hr_300C"])
sim.set_data_values_for("N2O","4hr","300C",5,data["time"],data["N2O_4hr_300C"])

sim.set_data_values_for("NH3","8hr","300C",5,data["time"],data["NH3_8hr_300C"])
sim.set_data_values_for("NO","8hr","300C",5,data["time"],data["NO_8hr_300C"])
sim.set_data_values_for("NO2","8hr","300C",5,data["time"],data["NO2_8hr_300C"])
sim.set_data_values_for("N2O","8hr","300C",5,data["time"],data["N2O_8hr_300C"])

sim.set_data_values_for("NH3","16hr","300C",5,data["time"],data["NH3_16hr_300C"])
sim.set_data_values_for("NO","16hr","300C",5,data["time"],data["NO_16hr_300C"])
sim.set_data_values_for("NO2","16hr","300C",5,data["time"],data["NO2_16hr_300C"])
sim.set_data_values_for("N2O","16hr","300C",5,data["time"],data["N2O_16hr_300C"])


sim.set_data_values_for("NH3","Unaged","400C",5,data["time"],data["NH3_Unaged_400C"])
sim.set_data_values_for("NO","Unaged","400C",5,data["time"],data["NH3_Unaged_400C"])
sim.set_data_values_for("NO2","Unaged","400C",5,data["time"],data["NH3_Unaged_400C"])
sim.set_data_values_for("N2O","Unaged","400C",5,data["time"],data["NH3_Unaged_400C"])

sim.set_data_values_for("NH3","2hr","400C",5,data["time"],data["NH3_2hr_400C"])
sim.set_data_values_for("NO","2hr","400C",5,data["time"],data["NO_2hr_400C"])
sim.set_data_values_for("NO2","2hr","400C",5,data["time"],data["NO2_2hr_400C"])
sim.set_data_values_for("N2O","2hr","400C",5,data["time"],data["N2O_2hr_400C"])

sim.set_data_values_for("NH3","4hr","400C",5,data["time"],data["NH3_4hr_400C"])
sim.set_data_values_for("NO","4hr","400C",5,data["time"],data["NO_4hr_400C"])
sim.set_data_values_for("NO2","4hr","400C",5,data["time"],data["NO2_4hr_400C"])
sim.set_data_values_for("N2O","4hr","400C",5,data["time"],data["N2O_4hr_400C"])

sim.set_data_values_for("NH3","8hr","400C",5,data["time"],data["NH3_8hr_400C"])
sim.set_data_values_for("NO","8hr","400C",5,data["time"],data["NO_8hr_400C"])
sim.set_data_values_for("NO2","8hr","400C",5,data["time"],data["NO2_8hr_400C"])
sim.set_data_values_for("N2O","8hr","400C",5,data["time"],data["N2O_8hr_400C"])

sim.set_data_values_for("NH3","16hr","400C",5,data["time"],data["NH3_16hr_400C"])
sim.set_data_values_for("NO","16hr","400C",5,data["time"],data["NO_16hr_400C"])
sim.set_data_values_for("NO2","16hr","400C",5,data["time"],data["NO2_16hr_400C"])
sim.set_data_values_for("N2O","16hr","400C",5,data["time"],data["N2O_16hr_400C"])


sim.set_data_values_for("NH3","Unaged","500C",5,data["time"],data["NH3_Unaged_500C"])
sim.set_data_values_for("NO","Unaged","500C",5,data["time"],data["NH3_Unaged_500C"])
sim.set_data_values_for("NO2","Unaged","500C",5,data["time"],data["NH3_Unaged_500C"])
sim.set_data_values_for("N2O","Unaged","500C",5,data["time"],data["NH3_Unaged_500C"])

sim.set_data_values_for("NH3","2hr","500C",5,data["time"],data["NH3_2hr_500C"])
sim.set_data_values_for("NO","2hr","500C",5,data["time"],data["NO_2hr_500C"])
sim.set_data_values_for("NO2","2hr","500C",5,data["time"],data["NO2_2hr_500C"])
sim.set_data_values_for("N2O","2hr","500C",5,data["time"],data["N2O_2hr_500C"])

sim.set_data_values_for("NH3","4hr","500C",5,data["time"],data["NH3_4hr_500C"])
sim.set_data_values_for("NO","4hr","500C",5,data["time"],data["NO_4hr_500C"])
sim.set_data_values_for("NO2","4hr","500C",5,data["time"],data["NO2_4hr_500C"])
sim.set_data_values_for("N2O","4hr","500C",5,data["time"],data["N2O_4hr_500C"])

sim.set_data_values_for("NH3","8hr","500C",5,data["time"],data["NH3_8hr_500C"])
sim.set_data_values_for("NO","8hr","500C",5,data["time"],data["NO_8hr_500C"])
sim.set_data_values_for("NO2","8hr","500C",5,data["time"],data["NO2_8hr_500C"])
sim.set_data_values_for("N2O","8hr","500C",5,data["time"],data["N2O_8hr_500C"])

sim.set_data_values_for("NH3","16hr","500C",5,data["time"],data["NH3_16hr_500C"])
sim.set_data_values_for("NO","16hr","500C",5,data["time"],data["NO_16hr_500C"])
sim.set_data_values_for("NO2","16hr","500C",5,data["time"],data["NO2_16hr_500C"])
sim.set_data_values_for("N2O","16hr","500C",5,data["time"],data["N2O_16hr_500C"])

#Clear up memory space after we don't need the dictionary anymore
data.clear()

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

sim.set_bulk_porosity(0.8)
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

# ----------------- 2hr Site Densities -----------
sim.set_site_density("Z1CuOH","2hr",0.051274815)
sim.set_site_density("Z2Cu","2hr",0.025820144)
sim.set_site_density("ZH","2hr",0.009147918+0.000423397+0.008572669)
sim.set_site_density("CuO","2hr",2.0144E-05)

# ----------------- 4hr Site Densities -----------
sim.set_site_density("Z1CuOH","4hr",0.049679956)
sim.set_site_density("Z2Cu","4hr",0.02692473)
sim.set_site_density("ZH","4hr",0.005127864+5.54458E-05+0.009298203)
sim.set_site_density("CuO","4hr",7.85352E-07)

# ----------------- 8hr Site Densities -----------
sim.set_site_density("Z1CuOH","8hr",0.04838926)
sim.set_site_density("Z2Cu","8hr",0.026648589)
sim.set_site_density("ZH","8hr",0.001611258+9.50848E-07+0.009687883)
sim.set_site_density("CuO","8hr",4.54455E-09)

# ----------------- 16hr Site Densities -----------
sim.set_site_density("Z1CuOH","16hr",0.050359742)
sim.set_site_density("Z2Cu","16hr",0.025179871)
sim.set_site_density("ZH","16hr",0.000159082+2.79637E-10+0.009755058)
sim.set_site_density("CuO","16hr",2.33028E-12)

# Setup all temperatures
sim.set_isothermal_temp("Unaged","300C",300+273.15)
sim.set_isothermal_temp("2hr","300C",300+273.15)
sim.set_isothermal_temp("4hr","300C",300+273.15)
sim.set_isothermal_temp("8hr","300C",300+273.15)
sim.set_isothermal_temp("16hr","300C",300+273.15)

sim.set_isothermal_temp("Unaged","400C",400+273.15)
sim.set_isothermal_temp("2hr","400C",400+273.15)
sim.set_isothermal_temp("4hr","400C",400+273.15)
sim.set_isothermal_temp("8hr","400C",400+273.15)
sim.set_isothermal_temp("16hr","400C",400+273.15)

sim.set_isothermal_temp("Unaged","500C",500+273.15)
sim.set_isothermal_temp("2hr","500C",500+273.15)
sim.set_isothermal_temp("4hr","500C",500+273.15)
sim.set_isothermal_temp("8hr","500C",500+273.15)
sim.set_isothermal_temp("16hr","500C",500+273.15)

# Build the constraints then discretize
sim.build_constraints()
sim.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=90,elems=5,colpoints=2)

#print("\nPress enter to continue...")
#input()

# ================== 300C ======================
# ---------------- Unaged ICs ------------------
sim.set_const_IC("O2","Unaged","300C",0.002126764)
sim.set_const_IC("H2O","Unaged","300C",0.001074836)
sim.set_const_IC("NH3","Unaged","300C",0)
sim.set_const_IC("NO","Unaged","300C",0)
sim.set_const_IC("NO2","Unaged","300C",0)
sim.set_const_IC("N2O","Unaged","300C",0)
sim.set_const_IC("N2","Unaged","300C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","Unaged","300C",0)
sim.set_const_IC("Z2Cu-NH3","Unaged","300C",0)
sim.set_const_IC("Z2Cu-(NH3)2","Unaged","300C",0)
sim.set_const_IC("ZNH4","Unaged","300C",0)
sim.set_const_IC("Z1CuOH-H2O","Unaged","300C",0)
sim.set_const_IC("Z2Cu-H2O","Unaged","300C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","Unaged","300C",0)
sim.set_const_IC("Z2Cu-NH4NO3","Unaged","300C",0)
sim.set_const_IC("ZH-NH4NO3","Unaged","300C",0)

# ---------------- 2hr ICs ------------------
sim.set_const_IC("O2","2hr","300C",0.002126764)
sim.set_const_IC("H2O","2hr","300C",0.001053496)
sim.set_const_IC("NH3","2hr","300C",0)
sim.set_const_IC("NO","2hr","300C",0)
sim.set_const_IC("NO2","2hr","300C",0)
sim.set_const_IC("N2O","2hr","300C",0)
sim.set_const_IC("N2","2hr","300C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","2hr","300C",0)
sim.set_const_IC("Z2Cu-NH3","2hr","300C",0)
sim.set_const_IC("Z2Cu-(NH3)2","2hr","300C",0)
sim.set_const_IC("ZNH4","2hr","300C",0)
sim.set_const_IC("Z1CuOH-H2O","2hr","300C",0)
sim.set_const_IC("Z2Cu-H2O","2hr","300C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","2hr","300C",0)
sim.set_const_IC("Z2Cu-NH4NO3","2hr","300C",0)
sim.set_const_IC("ZH-NH4NO3","2hr","300C",0)

# ---------------- 4hr ICs ------------------
sim.set_const_IC("O2","4hr","300C",0.002126764)
sim.set_const_IC("H2O","4hr","300C",0.001070552)
sim.set_const_IC("NH3","4hr","300C",0)
sim.set_const_IC("NO","4hr","300C",0)
sim.set_const_IC("NO2","4hr","300C",0)
sim.set_const_IC("N2O","4hr","300C",0)
sim.set_const_IC("N2","4hr","300C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","4hr","300C",0)
sim.set_const_IC("Z2Cu-NH3","4hr","300C",0)
sim.set_const_IC("Z2Cu-(NH3)2","4hr","300C",0)
sim.set_const_IC("ZNH4","4hr","300C",0)
sim.set_const_IC("Z1CuOH-H2O","4hr","300C",0)
sim.set_const_IC("Z2Cu-H2O","4hr","300C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","4hr","300C",0)
sim.set_const_IC("Z2Cu-NH4NO3","4hr","300C",0)
sim.set_const_IC("ZH-NH4NO3","4hr","300C",0)

# ---------------- 8hr ICs ------------------
sim.set_const_IC("O2","8hr","300C",0.002126764)
sim.set_const_IC("H2O","8hr","300C",0.001059042)
sim.set_const_IC("NH3","8hr","300C",0)
sim.set_const_IC("NO","8hr","300C",0)
sim.set_const_IC("NO2","8hr","300C",0)
sim.set_const_IC("N2O","8hr","300C",0)
sim.set_const_IC("N2","8hr","300C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","8hr","300C",0)
sim.set_const_IC("Z2Cu-NH3","8hr","300C",0)
sim.set_const_IC("Z2Cu-(NH3)2","8hr","300C",0)
sim.set_const_IC("ZNH4","8hr","300C",0)
sim.set_const_IC("Z1CuOH-H2O","8hr","300C",0)
sim.set_const_IC("Z2Cu-H2O","8hr","300C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","8hr","300C",0)
sim.set_const_IC("Z2Cu-NH4NO3","8hr","300C",0)
sim.set_const_IC("ZH-NH4NO3","8hr","300C",0)

# ---------------- 16hr ICs ------------------
sim.set_const_IC("O2","16hr","300C",0.002126764)
sim.set_const_IC("H2O","16hr","300C",0.001060656)
sim.set_const_IC("NH3","16hr","300C",0)
sim.set_const_IC("NO","16hr","300C",0)
sim.set_const_IC("NO2","16hr","300C",0)
sim.set_const_IC("N2O","16hr","300C",0)
sim.set_const_IC("N2","16hr","300C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","16hr","300C",0)
sim.set_const_IC("Z2Cu-NH3","16hr","300C",0)
sim.set_const_IC("Z2Cu-(NH3)2","16hr","300C",0)
sim.set_const_IC("ZNH4","16hr","300C",0)
sim.set_const_IC("Z1CuOH-H2O","16hr","300C",0)
sim.set_const_IC("Z2Cu-H2O","16hr","300C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","16hr","300C",0)
sim.set_const_IC("Z2Cu-NH4NO3","16hr","300C",0)
sim.set_const_IC("ZH-NH4NO3","16hr","300C",0)


# ================== 400C ======================
# ---------------- Unaged ICs ------------------
sim.set_const_IC("O2","Unaged","400C",0.00181082201282586)
sim.set_const_IC("H2O","Unaged","400C",0.000902536109168929)
sim.set_const_IC("NH3","Unaged","400C",0)
sim.set_const_IC("NO","Unaged","400C",0)
sim.set_const_IC("NO2","Unaged","400C",0)
sim.set_const_IC("N2O","Unaged","400C",0)
sim.set_const_IC("N2","Unaged","400C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","Unaged","400C",0)
sim.set_const_IC("Z2Cu-NH3","Unaged","400C",0)
sim.set_const_IC("Z2Cu-(NH3)2","Unaged","400C",0)
sim.set_const_IC("ZNH4","Unaged","400C",0)
sim.set_const_IC("Z1CuOH-H2O","Unaged","400C",0)
sim.set_const_IC("Z2Cu-H2O","Unaged","400C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","Unaged","400C",0)
sim.set_const_IC("Z2Cu-NH4NO3","Unaged","400C",0)
sim.set_const_IC("ZH-NH4NO3","Unaged","400C",0)

# ---------------- 2hr ICs ------------------
sim.set_const_IC("O2","2hr","400C",0.00181082201282586)
sim.set_const_IC("H2O","2hr","400C",0.000902536109168929)
sim.set_const_IC("NH3","2hr","400C",0)
sim.set_const_IC("NO","2hr","400C",0)
sim.set_const_IC("NO2","2hr","400C",0)
sim.set_const_IC("N2O","2hr","400C",0)
sim.set_const_IC("N2","2hr","400C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","2hr","400C",0)
sim.set_const_IC("Z2Cu-NH3","2hr","400C",0)
sim.set_const_IC("Z2Cu-(NH3)2","2hr","400C",0)
sim.set_const_IC("ZNH4","2hr","400C",0)
sim.set_const_IC("Z1CuOH-H2O","2hr","400C",0)
sim.set_const_IC("Z2Cu-H2O","2hr","400C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","2hr","400C",0)
sim.set_const_IC("Z2Cu-NH4NO3","2hr","400C",0)
sim.set_const_IC("ZH-NH4NO3","2hr","400C",0)

# ---------------- 4hr ICs ------------------
sim.set_const_IC("O2","4hr","400C",0.00181082201282586)
sim.set_const_IC("H2O","4hr","400C",0.000902536109168929)
sim.set_const_IC("NH3","4hr","400C",0)
sim.set_const_IC("NO","4hr","400C",0)
sim.set_const_IC("NO2","4hr","400C",0)
sim.set_const_IC("N2O","4hr","400C",0)
sim.set_const_IC("N2","4hr","400C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","4hr","400C",0)
sim.set_const_IC("Z2Cu-NH3","4hr","400C",0)
sim.set_const_IC("Z2Cu-(NH3)2","4hr","400C",0)
sim.set_const_IC("ZNH4","4hr","400C",0)
sim.set_const_IC("Z1CuOH-H2O","4hr","400C",0)
sim.set_const_IC("Z2Cu-H2O","4hr","400C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","4hr","400C",0)
sim.set_const_IC("Z2Cu-NH4NO3","4hr","400C",0)
sim.set_const_IC("ZH-NH4NO3","4hr","400C",0)

# ---------------- 8hr ICs ------------------
sim.set_const_IC("O2","8hr","400C",0.00181082201282586)
sim.set_const_IC("H2O","8hr","400C",0.000902536109168929)
sim.set_const_IC("NH3","8hr","400C",0)
sim.set_const_IC("NO","8hr","400C",0)
sim.set_const_IC("NO2","8hr","400C",0)
sim.set_const_IC("N2O","8hr","400C",0)
sim.set_const_IC("N2","8hr","400C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","8hr","400C",0)
sim.set_const_IC("Z2Cu-NH3","8hr","400C",0)
sim.set_const_IC("Z2Cu-(NH3)2","8hr","400C",0)
sim.set_const_IC("ZNH4","8hr","400C",0)
sim.set_const_IC("Z1CuOH-H2O","8hr","400C",0)
sim.set_const_IC("Z2Cu-H2O","8hr","400C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","8hr","400C",0)
sim.set_const_IC("Z2Cu-NH4NO3","8hr","400C",0)
sim.set_const_IC("ZH-NH4NO3","8hr","400C",0)

# ---------------- 16hr ICs ------------------
sim.set_const_IC("O2","16hr","400C",0.00181082201282586)
sim.set_const_IC("H2O","16hr","400C",0.000902536109168929)
sim.set_const_IC("NH3","16hr","400C",0)
sim.set_const_IC("NO","16hr","400C",0)
sim.set_const_IC("NO2","16hr","400C",0)
sim.set_const_IC("N2O","16hr","400C",0)
sim.set_const_IC("N2","16hr","400C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","16hr","400C",0)
sim.set_const_IC("Z2Cu-NH3","16hr","400C",0)
sim.set_const_IC("Z2Cu-(NH3)2","16hr","400C",0)
sim.set_const_IC("ZNH4","16hr","400C",0)
sim.set_const_IC("Z1CuOH-H2O","16hr","400C",0)
sim.set_const_IC("Z2Cu-H2O","16hr","400C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","16hr","400C",0)
sim.set_const_IC("Z2Cu-NH4NO3","16hr","400C",0)
sim.set_const_IC("ZH-NH4NO3","16hr","400C",0)


# ================== 500C ======================
# ---------------- Unaged ICs ------------------
sim.set_const_IC("O2","Unaged","500C",0.001576608)
sim.set_const_IC("H2O","Unaged","500C",0.000785801)
sim.set_const_IC("NH3","Unaged","500C",0)
sim.set_const_IC("NO","Unaged","500C",0)
sim.set_const_IC("NO2","Unaged","500C",0)
sim.set_const_IC("N2O","Unaged","500C",0)
sim.set_const_IC("N2","Unaged","500C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","Unaged","500C",0)
sim.set_const_IC("Z2Cu-NH3","Unaged","500C",0)
sim.set_const_IC("Z2Cu-(NH3)2","Unaged","500C",0)
sim.set_const_IC("ZNH4","Unaged","500C",0)
sim.set_const_IC("Z1CuOH-H2O","Unaged","500C",0)
sim.set_const_IC("Z2Cu-H2O","Unaged","500C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","Unaged","500C",0)
sim.set_const_IC("Z2Cu-NH4NO3","Unaged","500C",0)
sim.set_const_IC("ZH-NH4NO3","Unaged","500C",0)

# ---------------- 2hr ICs ------------------
sim.set_const_IC("O2","2hr","500C",0.001576608)
sim.set_const_IC("H2O","2hr","500C",0.000785801)
sim.set_const_IC("NH3","2hr","500C",0)
sim.set_const_IC("NO","2hr","500C",0)
sim.set_const_IC("NO2","2hr","500C",0)
sim.set_const_IC("N2O","2hr","500C",0)
sim.set_const_IC("N2","2hr","500C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","2hr","500C",0)
sim.set_const_IC("Z2Cu-NH3","2hr","500C",0)
sim.set_const_IC("Z2Cu-(NH3)2","2hr","500C",0)
sim.set_const_IC("ZNH4","2hr","500C",0)
sim.set_const_IC("Z1CuOH-H2O","2hr","500C",0)
sim.set_const_IC("Z2Cu-H2O","2hr","500C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","2hr","500C",0)
sim.set_const_IC("Z2Cu-NH4NO3","2hr","500C",0)
sim.set_const_IC("ZH-NH4NO3","2hr","500C",0)

# ---------------- 4hr ICs ------------------
sim.set_const_IC("O2","4hr","500C",0.001576608)
sim.set_const_IC("H2O","4hr","500C",0.000785801)
sim.set_const_IC("NH3","4hr","500C",0)
sim.set_const_IC("NO","4hr","500C",0)
sim.set_const_IC("NO2","4hr","500C",0)
sim.set_const_IC("N2O","4hr","500C",0)
sim.set_const_IC("N2","4hr","500C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","4hr","500C",0)
sim.set_const_IC("Z2Cu-NH3","4hr","500C",0)
sim.set_const_IC("Z2Cu-(NH3)2","4hr","500C",0)
sim.set_const_IC("ZNH4","4hr","500C",0)
sim.set_const_IC("Z1CuOH-H2O","4hr","500C",0)
sim.set_const_IC("Z2Cu-H2O","4hr","500C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","4hr","500C",0)
sim.set_const_IC("Z2Cu-NH4NO3","4hr","500C",0)
sim.set_const_IC("ZH-NH4NO3","4hr","500C",0)

# ---------------- 8hr ICs ------------------
sim.set_const_IC("O2","8hr","500C",0.001576608)
sim.set_const_IC("H2O","8hr","500C",0.000785801)
sim.set_const_IC("NH3","8hr","500C",0)
sim.set_const_IC("NO","8hr","500C",0)
sim.set_const_IC("NO2","8hr","500C",0)
sim.set_const_IC("N2O","8hr","500C",0)
sim.set_const_IC("N2","8hr","500C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","8hr","500C",0)
sim.set_const_IC("Z2Cu-NH3","8hr","500C",0)
sim.set_const_IC("Z2Cu-(NH3)2","8hr","500C",0)
sim.set_const_IC("ZNH4","8hr","500C",0)
sim.set_const_IC("Z1CuOH-H2O","8hr","500C",0)
sim.set_const_IC("Z2Cu-H2O","8hr","500C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","8hr","500C",0)
sim.set_const_IC("Z2Cu-NH4NO3","8hr","500C",0)
sim.set_const_IC("ZH-NH4NO3","8hr","500C",0)

# ---------------- 16hr ICs ------------------
sim.set_const_IC("O2","16hr","500C",0.001576608)
sim.set_const_IC("H2O","16hr","500C",0.000785801)
sim.set_const_IC("NH3","16hr","500C",0)
sim.set_const_IC("NO","16hr","500C",0)
sim.set_const_IC("NO2","16hr","500C",0)
sim.set_const_IC("N2O","16hr","500C",0)
sim.set_const_IC("N2","16hr","500C",0.0184)

sim.set_const_IC("Z1CuOH-NH3","16hr","500C",0)
sim.set_const_IC("Z2Cu-NH3","16hr","500C",0)
sim.set_const_IC("Z2Cu-(NH3)2","16hr","500C",0)
sim.set_const_IC("ZNH4","16hr","500C",0)
sim.set_const_IC("Z1CuOH-H2O","16hr","500C",0)
sim.set_const_IC("Z2Cu-H2O","16hr","500C",0)
sim.set_const_IC("Z1CuOH-NH4NO3","16hr","500C",0)
sim.set_const_IC("Z2Cu-NH4NO3","16hr","500C",0)
sim.set_const_IC("ZH-NH4NO3","16hr","500C",0)



# =============================== 300C =======================================
#Read in data tuples to use as BCs
data_tup_300 = naively_read_data_file("inputfiles/protocol_SCR_all-ages_300C.txt",
                                    factor=1,dict_of_tuples=True)

# ---------------- Unaged BCs ------------------
sim.set_time_dependent_BC("O2","Unaged","300C",
                            time_value_pairs=data_tup_300["O2_Unaged"],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","Unaged","300C",
                            time_value_pairs=data_tup_300["H2O_Unaged"],
                            initial_value=0.001074836)

sim.set_time_dependent_BC("NH3","Unaged","300C",
                            time_value_pairs=data_tup_300["NH3_Unaged"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","Unaged","300C",
                            time_value_pairs=data_tup_300["NO_Unaged"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","Unaged","300C",
                            time_value_pairs=data_tup_300["NO2_Unaged"],
                            initial_value=0)

sim.set_const_BC("N2O","Unaged","300C",0)

sim.set_const_BC("N2","Unaged","300C",0.0184)


# ---------------- 2hr BCs ------------------
sim.set_time_dependent_BC("O2","2hr","300C",
                            time_value_pairs=data_tup_300["O2_2hr"],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","2hr","300C",
                            time_value_pairs=data_tup_300["H2O_2hr"],
                            initial_value=0.001053496)

sim.set_time_dependent_BC("NH3","2hr","300C",
                            time_value_pairs=data_tup_300["NH3_2hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","2hr","300C",
                            time_value_pairs=data_tup_300["NO_2hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","2hr","300C",
                            time_value_pairs=data_tup_300["NO2_2hr"],
                            initial_value=0)

sim.set_const_BC("N2O","2hr","300C",0)

sim.set_const_BC("N2","2hr","300C",0.0184)


# ---------------- 4hr BCs ------------------
sim.set_time_dependent_BC("O2","4hr","300C",
                            time_value_pairs=data_tup_300["O2_4hr"],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","4hr","300C",
                            time_value_pairs=data_tup_300["H2O_4hr"],
                            initial_value=0.001070552)

sim.set_time_dependent_BC("NH3","4hr","300C",
                            time_value_pairs=data_tup_300["NH3_4hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","4hr","300C",
                            time_value_pairs=data_tup_300["NO_4hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","4hr","300C",
                            time_value_pairs=data_tup_300["NO2_4hr"],
                            initial_value=0)

sim.set_const_BC("N2O","4hr","300C",0)

sim.set_const_BC("N2","4hr","300C",0.0184)


# ---------------- 8hr BCs ------------------
sim.set_time_dependent_BC("O2","8hr","300C",
                            time_value_pairs=data_tup_300["O2_8hr"],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","8hr","300C",
                            time_value_pairs=data_tup_300["H2O_8hr"],
                            initial_value=0.001059042)

sim.set_time_dependent_BC("NH3","8hr","300C",
                            time_value_pairs=data_tup_300["NH3_8hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","8hr","300C",
                            time_value_pairs=data_tup_300["NO_8hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","8hr","300C",
                            time_value_pairs=data_tup_300["NO2_8hr"],
                            initial_value=0)

sim.set_const_BC("N2O","8hr","300C",0)

sim.set_const_BC("N2","8hr","300C",0.0184)


# ---------------- 16hr BCs ------------------
sim.set_time_dependent_BC("O2","16hr","300C",
                            time_value_pairs=data_tup_300["O2_16hr"],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","16hr","300C",
                            time_value_pairs=data_tup_300["H2O_16hr"],
                            initial_value=0.001060656)

sim.set_time_dependent_BC("NH3","16hr","300C",
                            time_value_pairs=data_tup_300["NH3_16hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","16hr","300C",
                            time_value_pairs=data_tup_300["NO_16hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","16hr","300C",
                            time_value_pairs=data_tup_300["NO2_16hr"],
                            initial_value=0)

sim.set_const_BC("N2O","16hr","300C",0)

sim.set_const_BC("N2","16hr","300C",0.0184)

data_tup_300.clear()

# =============================== 400C =======================================
#Read in data tuples to use as BCs
data_tup_400 = naively_read_data_file("inputfiles/protocol_SCR_all-ages_400C.txt",
                                    factor=1,dict_of_tuples=True)

# ---------------- Unaged BCs ------------------
sim.set_time_dependent_BC("O2","Unaged","400C",
                            time_value_pairs=data_tup_400["O2_Unaged"],
                            initial_value=0.001956118)

sim.set_time_dependent_BC("H2O","Unaged","400C",
                            time_value_pairs=data_tup_400["H2O_Unaged"],
                            initial_value=0.000974953352944018)

sim.set_time_dependent_BC("NH3","Unaged","400C",
                            time_value_pairs=data_tup_400["NH3_Unaged"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","Unaged","400C",
                            time_value_pairs=data_tup_400["NO_Unaged"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","Unaged","400C",
                            time_value_pairs=data_tup_400["NO2_Unaged"],
                            initial_value=0)

sim.set_const_BC("N2O","Unaged","400C",0)

sim.set_const_BC("N2","Unaged","400C",0.0184)


# ---------------- 2hr BCs ------------------
sim.set_time_dependent_BC("O2","2hr","400C",
                            time_value_pairs=data_tup_400["O2_2hr"],
                            initial_value=0.001956118)

sim.set_time_dependent_BC("H2O","2hr","400C",
                            time_value_pairs=data_tup_400["H2O_2hr"],
                            initial_value=0.000974953352944018)

sim.set_time_dependent_BC("NH3","2hr","400C",
                            time_value_pairs=data_tup_400["NH3_2hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","2hr","400C",
                            time_value_pairs=data_tup_400["NO_2hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","2hr","400C",
                            time_value_pairs=data_tup_400["NO2_2hr"],
                            initial_value=0)

sim.set_const_BC("N2O","2hr","400C",0)

sim.set_const_BC("N2","2hr","400C",0.0184)


# ---------------- 4hr BCs ------------------
sim.set_time_dependent_BC("O2","4hr","400C",
                            time_value_pairs=data_tup_400["O2_4hr"],
                            initial_value=0.001956118)

sim.set_time_dependent_BC("H2O","4hr","400C",
                            time_value_pairs=data_tup_400["H2O_4hr"],
                            initial_value=0.000974953352944018)

sim.set_time_dependent_BC("NH3","4hr","400C",
                            time_value_pairs=data_tup_400["NH3_4hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","4hr","400C",
                            time_value_pairs=data_tup_400["NO_4hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","4hr","400C",
                            time_value_pairs=data_tup_400["NO2_4hr"],
                            initial_value=0)

sim.set_const_BC("N2O","4hr","400C",0)

sim.set_const_BC("N2","4hr","400C",0.0184)


# ---------------- 8hr BCs ------------------
sim.set_time_dependent_BC("O2","8hr","400C",
                            time_value_pairs=data_tup_400["O2_8hr"],
                            initial_value=0.001956118)

sim.set_time_dependent_BC("H2O","8hr","400C",
                            time_value_pairs=data_tup_400["H2O_8hr"],
                            initial_value=0.000974953352944018)

sim.set_time_dependent_BC("NH3","8hr","400C",
                            time_value_pairs=data_tup_400["NH3_8hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","8hr","400C",
                            time_value_pairs=data_tup_400["NO_8hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","8hr","400C",
                            time_value_pairs=data_tup_400["NO2_8hr"],
                            initial_value=0)

sim.set_const_BC("N2O","8hr","400C",0)

sim.set_const_BC("N2","8hr","400C",0.0184)


# ---------------- 16hr BCs ------------------
sim.set_time_dependent_BC("O2","16hr","400C",
                            time_value_pairs=data_tup_400["O2_16hr"],
                            initial_value=0.001956118)

sim.set_time_dependent_BC("H2O","16hr","400C",
                            time_value_pairs=data_tup_400["H2O_16hr"],
                            initial_value=0.000974953352944018)

sim.set_time_dependent_BC("NH3","16hr","400C",
                            time_value_pairs=data_tup_400["NH3_16hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","16hr","400C",
                            time_value_pairs=data_tup_400["NO_16hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","16hr","400C",
                            time_value_pairs=data_tup_400["NO2_16hr"],
                            initial_value=0)

sim.set_const_BC("N2O","16hr","400C",0)

sim.set_const_BC("N2","16hr","400C",0.0184)

data_tup_400.clear()

# =============================== 500C =======================================
#Read in data tuples to use as BCs
data_tup_500 = naively_read_data_file("inputfiles/protocol_SCR_all-ages_500C.txt",
                                    factor=1,dict_of_tuples=True)

# ---------------- Unaged BCs ------------------
sim.set_time_dependent_BC("O2","Unaged","500C",
                            time_value_pairs=data_tup_500["O2_Unaged"],
                            initial_value=0.001576608)

sim.set_time_dependent_BC("H2O","Unaged","500C",
                            time_value_pairs=data_tup_500["H2O_Unaged"],
                            initial_value=0.000785801)

sim.set_time_dependent_BC("NH3","Unaged","500C",
                            time_value_pairs=data_tup_500["NH3_Unaged"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","Unaged","500C",
                            time_value_pairs=data_tup_500["NO_Unaged"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","Unaged","500C",
                            time_value_pairs=data_tup_500["NO2_Unaged"],
                            initial_value=0)

sim.set_const_BC("N2O","Unaged","500C",0)

sim.set_const_BC("N2","Unaged","500C",0.0184)


# ---------------- 2hr BCs ------------------
sim.set_time_dependent_BC("O2","2hr","500C",
                            time_value_pairs=data_tup_500["O2_2hr"],
                            initial_value=0.001576608)

sim.set_time_dependent_BC("H2O","2hr","500C",
                            time_value_pairs=data_tup_500["H2O_2hr"],
                            initial_value=0.000785801)

sim.set_time_dependent_BC("NH3","2hr","500C",
                            time_value_pairs=data_tup_500["NH3_2hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","2hr","500C",
                            time_value_pairs=data_tup_500["NO_2hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","2hr","500C",
                            time_value_pairs=data_tup_500["NO2_2hr"],
                            initial_value=0)

sim.set_const_BC("N2O","2hr","500C",0)

sim.set_const_BC("N2","2hr","500C",0.0184)


# ---------------- 4hr BCs ------------------
sim.set_time_dependent_BC("O2","4hr","500C",
                            time_value_pairs=data_tup_500["O2_4hr"],
                            initial_value=0.001576608)

sim.set_time_dependent_BC("H2O","4hr","500C",
                            time_value_pairs=data_tup_500["H2O_4hr"],
                            initial_value=0.000785801)

sim.set_time_dependent_BC("NH3","4hr","500C",
                            time_value_pairs=data_tup_500["NH3_4hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","4hr","500C",
                            time_value_pairs=data_tup_500["NO_4hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","4hr","500C",
                            time_value_pairs=data_tup_500["NO2_4hr"],
                            initial_value=0)

sim.set_const_BC("N2O","4hr","500C",0)

sim.set_const_BC("N2","4hr","500C",0.0184)


# ---------------- 8hr BCs ------------------
sim.set_time_dependent_BC("O2","8hr","500C",
                            time_value_pairs=data_tup_500["O2_8hr"],
                            initial_value=0.001576608)

sim.set_time_dependent_BC("H2O","8hr","500C",
                            time_value_pairs=data_tup_500["H2O_8hr"],
                            initial_value=0.000785801)

sim.set_time_dependent_BC("NH3","8hr","500C",
                            time_value_pairs=data_tup_500["NH3_8hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","8hr","500C",
                            time_value_pairs=data_tup_500["NO_8hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","8hr","500C",
                            time_value_pairs=data_tup_500["NO2_8hr"],
                            initial_value=0)

sim.set_const_BC("N2O","8hr","500C",0)

sim.set_const_BC("N2","8hr","500C",0.0184)


# ---------------- 16hr BCs ------------------
sim.set_time_dependent_BC("O2","16hr","500C",
                            time_value_pairs=data_tup_500["O2_16hr"],
                            initial_value=0.001576608)

sim.set_time_dependent_BC("H2O","16hr","500C",
                            time_value_pairs=data_tup_500["H2O_16hr"],
                            initial_value=0.000785801)

sim.set_time_dependent_BC("NH3","16hr","500C",
                            time_value_pairs=data_tup_500["NH3_16hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO","16hr","500C",
                            time_value_pairs=data_tup_500["NO_16hr"],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","16hr","500C",
                            time_value_pairs=data_tup_500["NO2_16hr"],
                            initial_value=0)

sim.set_const_BC("N2O","16hr","500C",0)

sim.set_const_BC("N2","16hr","500C",0.0184)

data_tup_500.clear()

# Fix the kinetics to only run a simulation
sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")

# Fix all reactions for simulation mode only
sim.fix_all_reactions()


sim.initialize_auto_scaling()
sim.initialize_simulator()


# ========================================== 300C ============================================================
sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "300C", file_name="Unaged_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "300C", 0, file_name="Unaged_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", "300C", file_name="Unaged_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "300C", file_name="2hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "300C", 0, file_name="2hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "2hr", "300C", file_name="2hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "300C", file_name="4hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "300C", 0, file_name="4hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "4hr", "300C", file_name="4hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "300C", file_name="8hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "300C", 0, file_name="8hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "8hr", "300C", file_name="8hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "300C", file_name="16hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "300C", 0, file_name="16hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "16hr", "300C", file_name="16hr_SCR_300C_average_ads.txt")

# ========================================== 400C ============================================================
sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "400C", file_name="Unaged_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "400C", 0, file_name="Unaged_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", "400C", file_name="Unaged_SCR_400C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "400C", file_name="2hr_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "400C", 0, file_name="2hr_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "2hr", "400C", file_name="2hr_SCR_400C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "400C", file_name="4hr_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "400C", 0, file_name="4hr_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "4hr", "400C", file_name="4hr_SCR_400C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "400C", file_name="8hr_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "400C", 0, file_name="8hr_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "8hr", "400C", file_name="8hr_SCR_400C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "400C", file_name="16hr_SCR_400C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "400C", 0, file_name="16hr_SCR_400C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "16hr", "400C", file_name="16hr_SCR_400C_average_ads.txt")

# ========================================== 500C ============================================================
sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "500C", file_name="Unaged_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "500C", 0, file_name="Unaged_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", "500C", file_name="Unaged_SCR_500C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "500C", file_name="2hr_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "500C", 0, file_name="2hr_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "2hr", "500C", file_name="2hr_SCR_500C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "500C", file_name="4hr_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "500C", 0, file_name="4hr_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "4hr", "500C", file_name="4hr_SCR_500C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "500C", file_name="8hr_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "500C", 0, file_name="8hr_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "8hr", "500C", file_name="8hr_SCR_500C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "500C", file_name="16hr_SCR_500C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "500C", 0, file_name="16hr_SCR_500C_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "16hr", "500C", file_name="16hr_SCR_500C_average_ads.txt")

sim.print_kinetic_parameter_info(file_name="300C_400C_500C_opt_params.txt")
sim.save_model_state(file_name="300C_400C_500C_model.json")
