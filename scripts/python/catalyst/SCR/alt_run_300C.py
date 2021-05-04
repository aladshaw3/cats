# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Read in the data (data is now a dictionary containing the data we want)
data = naively_read_data_file("inputfiles/SCR_all-ages_300C.txt",factor=5)

# Testing
sim = Isothermal_Monolith_Simulator()
sim.add_axial_dim(0,5)
sim.add_axial_dataset(5)       # Location of observations (in cm)

sim.add_temporal_dim(0,137)
sim.add_temporal_dataset(data["time"])   #Temporal observations (in s)

sim.add_age_set(["Unaged","2hr","4hr","8hr","16hr"])
sim.add_data_age_set(["Unaged","2hr","4hr","8hr","16hr"])  # Data observations can be a sub-set

sim.add_temperature_set(["300C"])
sim.add_data_temperature_set(["300C"])     # Data observations can be a sub-set

sim.add_gas_species(["NH3","H2O","O2","NO","NO2","N2O","N2"])
sim.add_data_gas_species(["NH3","NO","NO2","N2O"])    # Data observations can be a sub-set

sim.set_data_values_for("NH3","Unaged","300C",5,data["time"],data["NH3_Unaged"])
sim.set_data_values_for("NO","Unaged","300C",5,data["time"],data["NO_Unaged"])
sim.set_data_values_for("NO2","Unaged","300C",5,data["time"],data["NO2_Unaged"])
sim.set_data_values_for("N2O","Unaged","300C",5,data["time"],data["N2O_Unaged"])

sim.set_data_values_for("NH3","2hr","300C",5,data["time"],data["NH3_2hr"])
sim.set_data_values_for("NO","2hr","300C",5,data["time"],data["NO_2hr"])
sim.set_data_values_for("NO2","2hr","300C",5,data["time"],data["NO2_2hr"])
sim.set_data_values_for("N2O","2hr","300C",5,data["time"],data["N2O_2hr"])

sim.set_data_values_for("NH3","4hr","300C",5,data["time"],data["NH3_4hr"])
sim.set_data_values_for("NO","4hr","300C",5,data["time"],data["NO_4hr"])
sim.set_data_values_for("NO2","4hr","300C",5,data["time"],data["NO2_4hr"])
sim.set_data_values_for("N2O","4hr","300C",5,data["time"],data["N2O_4hr"])

sim.set_data_values_for("NH3","8hr","300C",5,data["time"],data["NH3_8hr"])
sim.set_data_values_for("NO","8hr","300C",5,data["time"],data["NO_8hr"])
sim.set_data_values_for("NO2","8hr","300C",5,data["time"],data["NO2_8hr"])
sim.set_data_values_for("N2O","8hr","300C",5,data["time"],data["N2O_8hr"])

sim.set_data_values_for("NH3","16hr","300C",5,data["time"],data["NH3_16hr"])
sim.set_data_values_for("NO","16hr","300C",5,data["time"],data["NO_16hr"])
sim.set_data_values_for("NO2","16hr","300C",5,data["time"],data["NO2_16hr"])
sim.set_data_values_for("N2O","16hr","300C",5,data["time"],data["N2O_16hr"])

#Clear up memory space after we don't need the dictionary anymore
data.clear()

sim.add_surface_species(["q1","q2a","q2b","q3","q4a","q4b"])
sim.add_surface_sites(["S1","S2","S3"])
sim.add_reactions({"r1": ReactionType.EquilibriumArrhenius,
                    "r2a": ReactionType.EquilibriumArrhenius,
                    "r2b": ReactionType.EquilibriumArrhenius,
                    "r3": ReactionType.EquilibriumArrhenius,
                    "r4a": ReactionType.EquilibriumArrhenius,
                    "r4b": ReactionType.EquilibriumArrhenius,
                    "r5": ReactionType.Arrhenius,
                    "r6": ReactionType.Arrhenius,
                    "r7f": ReactionType.Arrhenius,
                    "r7r": ReactionType.Arrhenius,
                    "r8": ReactionType.Arrhenius,
                    "r9": ReactionType.Arrhenius,
                    "r10": ReactionType.Arrhenius,
                    "r11": ReactionType.Arrhenius,
                    "r12": ReactionType.Arrhenius,
                    "r13a": ReactionType.Arrhenius,
                    "r14a": ReactionType.Arrhenius,
                    "r15af": ReactionType.Arrhenius,
                    "r15ar": ReactionType.Arrhenius,
                    "r16a": ReactionType.Arrhenius,
                    "r17a": ReactionType.Arrhenius,
                    "r18a": ReactionType.Arrhenius,
                    "r19a": ReactionType.Arrhenius,
                    "r20a": ReactionType.Arrhenius,
                    "r13b": ReactionType.Arrhenius,
                    "r14b": ReactionType.Arrhenius,
                    "r15bf": ReactionType.Arrhenius,
                    "r15br": ReactionType.Arrhenius,
                    "r16b": ReactionType.Arrhenius,
                    "r17b": ReactionType.Arrhenius,
                    "r18b": ReactionType.Arrhenius,
                    "r19b": ReactionType.Arrhenius,
                    "r20b": ReactionType.Arrhenius,
                    "r21": ReactionType.Arrhenius,
                    "r22": ReactionType.Arrhenius,
                    "r23f": ReactionType.Arrhenius,
                    "r23r": ReactionType.Arrhenius,
                    "r24": ReactionType.Arrhenius,
                    "r25": ReactionType.Arrhenius,
                    "r26": ReactionType.Arrhenius,
                    "r27": ReactionType.Arrhenius,
                    "r28": ReactionType.Arrhenius
                    })

sim.set_bulk_porosity(0.3309)
sim.set_washcoat_porosity(0.4)
sim.set_reactor_radius(1)
sim.set_space_velocity_all_runs(1000)      #volumes/min
sim.set_cell_density(62)                   # 62 cells per cm^2 (~400 cpsi)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"q1": 1, "q4a": 1}}
s2_data = {"mol_occupancy": {"q2a": 1, "q2b": 1, "q4b": 1}}
s3_data = {"mol_occupancy": {"q3": 1}}

sim.set_site_balance("S1",s1_data)
sim.set_site_balance("S2",s2_data)
sim.set_site_balance("S3",s3_data)

# Reaction specification information (must correspond to correct reaction type)

#   EquilibriumArrhenius
r1_equ = {"parameters": {"A": 250000, "E": 0, "dH": -54547.9, "dS": -29.9943},
          "mol_reactants": {"S1": 1, "NH3": 1},
          "mol_products": {"q1": 1},
          "rxn_orders": {"S1": 1, "NH3": 1, "q1": 1}
        }
r2a_equ = {"parameters": {"A": 300000, "E": 0, "dH": -78073.843, "dS": -35.311574},
          "mol_reactants": {"S2": 1, "NH3": 1},
          "mol_products": {"q2a": 1},
          "rxn_orders": {"S2": 1, "NH3": 1, "q2a": 1}
        }
r2b_equ = {"parameters": {"A": 150000, "E": 0, "dH": -78064.167, "dS": -46.821878},
          "mol_reactants": {"q2a": 1, "NH3": 1},
          "mol_products": {"q2b": 1},
          "rxn_orders": {"q2a": 1, "NH3": 1, "q2b": 1}
        }
r3_equ = {"parameters": {"A": 2500000, "E": 0, "dH": -91860.8, "dS": -28.9292},
          "mol_reactants": {"S3": 1, "NH3": 1},
          "mol_products": {"q3": 1},
          "rxn_orders": {"S3": 1, "NH3": 1, "q3": 1}
        }
r4a_equ = {"parameters": {"A": 44000, "E": 0, "dH": -32099.1, "dS": -24.2494},
          "mol_reactants": {"S1": 1, "H2O": 1},
          "mol_products": {"q4a": 1},
          "rxn_orders": {"S1": 1, "H2O": 1, "q4a": 1}
        }
r4b_equ = {"parameters": {"A": 70000, "E": 0, "dH": -28889.23, "dS": -26.674},
          "mol_reactants": {"S2": 1, "H2O": 1},
          "mol_products": {"q4b": 1},
          "rxn_orders": {"S2": 1, "H2O": 1, "q4b": 1}
        }

# Arrhenius Reactions

#  ---------- q1 reactions ------------
r5 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q1": 1, "O2": 0.75},
          "mol_products": {"S1": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"q1": 1, "O2": 1}
        }

r6 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q1": 1, "O2": 1.25},
          "mol_products": {"S1": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"q1": 1, "O2": 1}
        }

r7f = {"parameters": {"A": 490000, "E": 0},
          "mol_reactants": {"S1": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"S1": 1, "NO2": 1},
          "rxn_orders": {"S1": 1, "NO": 1, "O2": 1}
        }

r7r = {"parameters": {"A": 300, "E": 0},
          "mol_reactants": {"S1": 1, "NO2": 1},
          "mol_products": {"S1": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"S1": 1, "NO2": 1}
        }

r8 = {"parameters": {"A": 450000000, "E": 0},
          "mol_reactants": {"q1": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"S1": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q1": 1, "NO": 1, "O2": 1}
        }

r9 = {"parameters": {"A": 2400000, "E": 0},
          "mol_reactants": {"q1": 1, "NO2": 1},
          "mol_products": {"S1": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q1": 1, "NO2": 1}
        }

r10 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q1": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"S1": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q1": 1, "NO2": 1, "O2": 1}
        }

r11 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q1": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"S1": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q1": 1, "NO": 1, "O2": 1}
        }

r12 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q1": 1, "NO": 0.5, "NO2": 0.5},
          "mol_products": {"S1": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q1": 1, "NO": 1, "NO2": 1}
        }


#  ---------- q2a reactions ------------
r13a = {"parameters": {"A": 34, "E": 0},
          "mol_reactants": {"q2a": 1, "O2": 0.75},
          "mol_products": {"S2": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "O2": 1}
        }

r14a = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2a": 1, "O2": 1.25},
          "mol_products": {"S2": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "O2": 1}
        }

r15af = {"parameters": {"A": 490000, "E": 0},
          "mol_reactants": {"S2": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"S2": 1, "NO2": 1},
          "rxn_orders": {"S2": 1, "NO": 1, "O2": 1}
        }

r15ar = {"parameters": {"A": 300, "E": 0},
          "mol_reactants": {"S2": 1, "NO2": 1},
          "mol_products": {"S2": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"S2": 1, "NO2": 1}
        }

r16a = {"parameters": {"A": 450000000, "E": 0},
          "mol_reactants": {"q2a": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"S2": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "NO": 1, "O2": 1}
        }

r17a = {"parameters": {"A": 2400000, "E": 0},
          "mol_reactants": {"q2a": 1, "NO2": 1},
          "mol_products": {"S2": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q2a": 1, "NO2": 1}
        }

r18a = {"parameters": {"A": 53000000, "E": 0},
          "mol_reactants": {"q2a": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"S2": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "NO2": 1, "O2": 1}
        }

r19a = {"parameters": {"A": 7400000, "E": 0},
          "mol_reactants": {"q2a": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"S2": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "NO": 1, "O2": 1}
        }

r20a = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2a": 1, "NO": 0.5, "NO2": 0.5},
          "mol_products": {"S2": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "NO": 1, "NO2": 1}
        }

#  ---------- q2b reactions ------------
r13b = {"parameters": {"A": 34, "E": 0},
          "mol_reactants": {"q2b": 1, "O2": 0.75},
          "mol_products": {"q2a": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "O2": 1}
        }

r14b = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2b": 1, "O2": 1.25},
          "mol_products": {"q2a": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "O2": 1}
        }

r15bf = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2b": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"q2a": 1, "NO2": 1},
          "rxn_orders": {"q2b": 1, "NO": 1, "O2": 1}
        }

r15br = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2a": 1, "NO2": 1},
          "mol_products": {"q2b": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"q2b": 1, "NO2": 1}
        }

r16b = {"parameters": {"A": 450000000, "E": 0},
          "mol_reactants": {"q2b": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"q2a": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "NO": 1, "O2": 1}
        }

r17b = {"parameters": {"A": 2400000, "E": 0},
          "mol_reactants": {"q2b": 1, "NO2": 1},
          "mol_products": {"q2a": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q2b": 1, "NO2": 1}
        }

r18b = {"parameters": {"A": 53000000, "E": 0},
          "mol_reactants": {"q2b": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"q2a": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "NO2": 1, "O2": 1}
        }

r19b = {"parameters": {"A": 7400000, "E": 0},
          "mol_reactants": {"q2b": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"q2a": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "NO": 1, "O2": 1}
        }

r20b = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2b": 1, "NO": 0.5, "NO2": 0.5},
          "mol_products": {"q2a": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "NO": 1, "NO2": 1}
        }

#  ---------- q3 reactions ------------
r21 = {"parameters": {"A": 34, "E": 0},
          "mol_reactants": {"q3": 1, "O2": 0.75},
          "mol_products": {"S3": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"q3": 1, "O2": 1}
        }

r22 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3": 1, "O2": 1.25},
          "mol_products": {"S3": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"q3": 1, "O2": 1}
        }

r23f = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"S3": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"S3": 1, "NO2": 1},
          "rxn_orders": {"S3": 1, "NO": 1, "O2": 1}
        }

r23r = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"S3": 1, "NO2": 1},
          "mol_products": {"S3": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"S3": 1, "NO2": 1}
        }

r24 = {"parameters": {"A": 450000000, "E": 0},
          "mol_reactants": {"q3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"S3": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q3": 1, "NO": 1, "O2": 1}
        }

r25 = {"parameters": {"A": 2400000, "E": 0},
          "mol_reactants": {"q3": 1, "NO2": 1},
          "mol_products": {"S3": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q3": 1, "NO2": 1}
        }

r26 = {"parameters": {"A": 53000000, "E": 0},
          "mol_reactants": {"q3": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"S3": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q3": 1, "NO2": 1, "O2": 1}
        }

r27 = {"parameters": {"A": 7400000, "E": 0},
          "mol_reactants": {"q3": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"S3": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q3": 1, "NO": 1, "O2": 1}
        }

r28 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3": 1, "NO": 0.5, "NO2": 0.5},
          "mol_products": {"S3": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q3": 1, "NO": 1, "NO2": 1}
        }

sim.set_reaction_info("r1", r1_equ)
sim.set_reaction_info("r2a", r2a_equ)
sim.set_reaction_info("r2b", r2b_equ)
sim.set_reaction_info("r3", r3_equ)
sim.set_reaction_info("r4a", r4a_equ)
sim.set_reaction_info("r4b", r4b_equ)

sim.set_reaction_info("r5", r5)
sim.set_reaction_info("r6", r6)
sim.set_reaction_info("r7f", r7f)
sim.set_reaction_info("r7r", r7r)
sim.set_reaction_info("r8", r8)
sim.set_reaction_info("r9", r9)
sim.set_reaction_info("r10", r10)
sim.set_reaction_info("r11", r11)
sim.set_reaction_info("r12", r12)

sim.set_reaction_info("r13a", r13a)
sim.set_reaction_info("r14a", r14a)
sim.set_reaction_info("r15af", r15af)
sim.set_reaction_info("r15ar", r15ar)
sim.set_reaction_info("r16a", r16a)
sim.set_reaction_info("r17a", r17a)
sim.set_reaction_info("r18a", r18a)
sim.set_reaction_info("r19a", r19a)
sim.set_reaction_info("r20a", r20a)

sim.set_reaction_info("r13b", r13b)
sim.set_reaction_info("r14b", r14b)
sim.set_reaction_info("r15bf", r15bf)
sim.set_reaction_info("r15br", r15br)
sim.set_reaction_info("r16b", r16b)
sim.set_reaction_info("r17b", r17b)
sim.set_reaction_info("r18b", r18b)
sim.set_reaction_info("r19b", r19b)
sim.set_reaction_info("r20b", r20b)

sim.set_reaction_info("r21", r21)
sim.set_reaction_info("r22", r22)
sim.set_reaction_info("r23f", r23f)
sim.set_reaction_info("r23r", r23r)
sim.set_reaction_info("r24", r24)
sim.set_reaction_info("r25", r25)
sim.set_reaction_info("r26", r26)
sim.set_reaction_info("r27", r27)
sim.set_reaction_info("r28", r28)


# ----------------- Unaged Site Densities -----------
sim.set_site_density("S1","Unaged",0.052619016)
sim.set_site_density("S2","Unaged",0.023125746)
sim.set_site_density("S3","Unaged",0.01632+0.003233+0.006699)

# ----------------- 2hr Site Densities -----------
sim.set_site_density("S1","2hr",0.051274815)
sim.set_site_density("S2","2hr",0.025820144)
sim.set_site_density("S3","2hr",0.009147918+0.000423397+0.008572669)

# ----------------- 4hr Site Densities -----------
sim.set_site_density("S1","4hr",0.049679956)
sim.set_site_density("S2","4hr",0.02692473)
sim.set_site_density("S3","4hr",0.005127864+5.54458E-05+0.009298203)

# ----------------- 8hr Site Densities -----------
sim.set_site_density("S1","8hr",0.04838926)
sim.set_site_density("S2","8hr",0.026648589)
sim.set_site_density("S3","8hr",0.001611258+9.50848E-07+0.009687883)

# ----------------- 16hr Site Densities -----------
sim.set_site_density("S1","16hr",0.050359742)
sim.set_site_density("S2","16hr",0.025179871)
sim.set_site_density("S3","16hr",0.000159082+2.79637E-10+0.009755058)


sim.set_isothermal_temp("Unaged","300C",300+273.15)
sim.set_isothermal_temp("2hr","300C",300+273.15)
sim.set_isothermal_temp("4hr","300C",300+273.15)
sim.set_isothermal_temp("8hr","300C",300+273.15)
sim.set_isothermal_temp("16hr","300C",300+273.15)

# Build the constraints then discretize
sim.build_constraints()
sim.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=137,elems=5,colpoints=2)

# Initial conditions and Boundary Conditions should be set AFTER discretization

# ---------------- Unaged ICs ------------------
sim.set_const_IC("O2","Unaged","300C",0.002126764)
sim.set_const_IC("H2O","Unaged","300C",0.001074836)
sim.set_const_IC("NH3","Unaged","300C",0)
sim.set_const_IC("NO","Unaged","300C",0)
sim.set_const_IC("NO2","Unaged","300C",0)
sim.set_const_IC("N2O","Unaged","300C",0)
sim.set_const_IC("N2","Unaged","300C",0.0184)

sim.set_const_IC("q1","Unaged","300C",0)
sim.set_const_IC("q2a","Unaged","300C",0)
sim.set_const_IC("q2b","Unaged","300C",0)
sim.set_const_IC("q3","Unaged","300C",0)
sim.set_const_IC("q4a","Unaged","300C",0)
sim.set_const_IC("q4b","Unaged","300C",0)

# ---------------- 2hr ICs ------------------
sim.set_const_IC("O2","2hr","300C",0.002126764)
sim.set_const_IC("H2O","2hr","300C",0.001053496)
sim.set_const_IC("NH3","2hr","300C",0)
sim.set_const_IC("NO","2hr","300C",0)
sim.set_const_IC("NO2","2hr","300C",0)
sim.set_const_IC("N2O","2hr","300C",0)
sim.set_const_IC("N2","2hr","300C",0.0184)

sim.set_const_IC("q1","2hr","300C",0)
sim.set_const_IC("q2a","2hr","300C",0)
sim.set_const_IC("q2b","2hr","300C",0)
sim.set_const_IC("q3","2hr","300C",0)
sim.set_const_IC("q4a","2hr","300C",0)
sim.set_const_IC("q4b","2hr","300C",0)

# ---------------- 4hr ICs ------------------
sim.set_const_IC("O2","4hr","300C",0.002126764)
sim.set_const_IC("H2O","4hr","300C",0.001070552)
sim.set_const_IC("NH3","4hr","300C",0)
sim.set_const_IC("NO","4hr","300C",0)
sim.set_const_IC("NO2","4hr","300C",0)
sim.set_const_IC("N2O","4hr","300C",0)
sim.set_const_IC("N2","4hr","300C",0.0184)

sim.set_const_IC("q1","4hr","300C",0)
sim.set_const_IC("q2a","4hr","300C",0)
sim.set_const_IC("q2b","4hr","300C",0)
sim.set_const_IC("q3","4hr","300C",0)
sim.set_const_IC("q4a","4hr","300C",0)
sim.set_const_IC("q4b","4hr","300C",0)

# ---------------- 8hr ICs ------------------
sim.set_const_IC("O2","8hr","300C",0.002126764)
sim.set_const_IC("H2O","8hr","300C",0.001059042)
sim.set_const_IC("NH3","8hr","300C",0)
sim.set_const_IC("NO","8hr","300C",0)
sim.set_const_IC("NO2","8hr","300C",0)
sim.set_const_IC("N2O","8hr","300C",0)
sim.set_const_IC("N2","8hr","300C",0.0184)

sim.set_const_IC("q1","8hr","300C",0)
sim.set_const_IC("q2a","8hr","300C",0)
sim.set_const_IC("q2b","8hr","300C",0)
sim.set_const_IC("q3","8hr","300C",0)
sim.set_const_IC("q4a","8hr","300C",0)
sim.set_const_IC("q4b","8hr","300C",0)

# ---------------- 16hr ICs ------------------
sim.set_const_IC("O2","16hr","300C",0.002126764)
sim.set_const_IC("H2O","16hr","300C",0.001060656)
sim.set_const_IC("NH3","16hr","300C",0)
sim.set_const_IC("NO","16hr","300C",0)
sim.set_const_IC("NO2","16hr","300C",0)
sim.set_const_IC("N2O","16hr","300C",0)
sim.set_const_IC("N2","16hr","300C",0.0184)

sim.set_const_IC("q1","16hr","300C",0)
sim.set_const_IC("q2a","16hr","300C",0)
sim.set_const_IC("q2b","16hr","300C",0)
sim.set_const_IC("q3","16hr","300C",0)
sim.set_const_IC("q4a","16hr","300C",0)
sim.set_const_IC("q4b","16hr","300C",0)


# ---------------- Unaged BCs ------------------
sim.set_time_dependent_BC("O2","Unaged","300C",
                            time_value_pairs=[(2.258,4.253E-5),
                                              (20.925,0.002126764)],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","Unaged","300C",
                            time_value_pairs=[(4.25,0.001056024),
                                              (21.758,0.001044021)],
                            initial_value=0.001074836)

sim.set_time_dependent_BC("NH3","Unaged","300C",
                            time_value_pairs=[(2.258,6.33114E-6),
                                              (37.591,0),
                                              (49.758,6.33114E-6),
                                              (76.925,0),
                                              (99.258,6.33114E-6),
                                              (120.258,0)],
                            initial_value=0)

sim.set_time_dependent_BC("NO","Unaged","300C",
                            time_value_pairs=[(37.591, 6.33114E-6),
                                              (86.758,3.1426E-6),
                                              (129.425,6.33114E-6)],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","Unaged","300C",
                            time_value_pairs=[(86.758,3.1426E-6),
                                              (129.425,0)],
                            initial_value=0)

sim.set_const_BC("N2O","Unaged","300C",0)

sim.set_const_BC("N2","Unaged","300C",0.0184)


# ---------------- 2hr BCs ------------------
sim.set_time_dependent_BC("O2","2hr","300C",
                            time_value_pairs=[(2.091,4.253E-5),
                                              (18.758,0.002126764)],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","2hr","300C",
                            time_value_pairs=[(3.925,0.001046895),
                                              (19.091,0.001035631)],
                            initial_value=0.001053496)

sim.set_time_dependent_BC("NH3","2hr","300C",
                            time_value_pairs=[(2.091,6.33114E-6),
                                              (27.925,0),
                                              (37.758,6.33114E-6),
                                              (62.591,0),
                                              (79.258,6.33114E-6),
                                              (110.425,0)],
                            initial_value=0)

sim.set_time_dependent_BC("NO","2hr","300C",
                            time_value_pairs=[(27.925,6.33114E-6),
                                              (72.258,3.1426E-6),
                                              (118.591,6.33114E-6)],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","2hr","300C",
                            time_value_pairs=[(72.258,3.1426E-6),
                                              (118.591,0)],
                            initial_value=0)

sim.set_const_BC("N2O","2hr","300C",0)

sim.set_const_BC("N2","2hr","300C",0.0184)


# ---------------- 4hr BCs ------------------
sim.set_time_dependent_BC("O2","4hr","300C",
                            time_value_pairs=[(2.091,4.253E-5),
                                              (20.591,0.002126764)],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","4hr","300C",
                            time_value_pairs=[(3.591,0.001043685)],
                            initial_value=0.001070552)

sim.set_time_dependent_BC("NH3","4hr","300C",
                            time_value_pairs=[(2.091,6.33114E-6),
                                              (29.758,0),
                                              (38.258,6.33114E-6),
                                              (61.758,0),
                                              (77.591,6.33114E-6),
                                              (104.925,0)],
                            initial_value=0)

sim.set_time_dependent_BC("NO","4hr","300C",
                            time_value_pairs=[(29.758,6.33114E-6),
                                              (70.091,3.1426E-6),
                                              (113.258,6.33114E-6)],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","4hr","300C",
                            time_value_pairs=[(70.091,3.1426E-6),
                                              (113.258,0)],
                            initial_value=0)

sim.set_const_BC("N2O","4hr","300C",0)

sim.set_const_BC("N2","4hr","300C",0.0184)


# ---------------- 8hr BCs ------------------
sim.set_time_dependent_BC("O2","8hr","300C",
                            time_value_pairs=[(2.091,4.253E-5),
                                              (19.591,0.002126764)],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","8hr","300C",
                            time_value_pairs=[(1.925,0.001036373)],
                            initial_value=0.001059042)

sim.set_time_dependent_BC("NH3","8hr","300C",
                            time_value_pairs=[(2.091,6.33114E-6),
                                              (29.591,0),
                                              (37.591,6.33114E-6),
                                              (58.591,0),
                                              (74.925,6.33114E-6),
                                              (99.591,0)],
                            initial_value=0)

sim.set_time_dependent_BC("NO","8hr","300C",
                            time_value_pairs=[(29.591,6.33114E-6),
                                              (67.091,3.1426E-6),
                                              (108.091,6.33114E-6)],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","8hr","300C",
                            time_value_pairs=[(67.091,3.1426E-6),
                                              (108.091,0)],
                            initial_value=0)

sim.set_const_BC("N2O","8hr","300C",0)

sim.set_const_BC("N2","8hr","300C",0.0184)


# ---------------- 16hr BCs ------------------
sim.set_time_dependent_BC("O2","16hr","300C",
                            time_value_pairs=[(2.091,4.253E-5),
                                              (19.091,0.002126764)],
                            initial_value=0.002126764)

sim.set_time_dependent_BC("H2O","16hr","300C",
                            time_value_pairs=[(19.258,0.001037011)],
                            initial_value=0.001060656)

sim.set_time_dependent_BC("NH3","16hr","300C",
                            time_value_pairs=[(2.091,6.33114E-6),
                                              (27.758,0),
                                              (35.925,6.33114E-6),
                                              (55.091,0),
                                              (71.925,6.33114E-6),
                                              (94.091,0)],
                            initial_value=0)

sim.set_time_dependent_BC("NO","16hr","300C",
                            time_value_pairs=[(27.758,6.33114E-6),
                                              (63.925,3.1426E-6),
                                              (102.591,6.33114E-6)],
                            initial_value=0)

sim.set_time_dependent_BC("NO2","16hr","300C",
                            time_value_pairs=[(63.925,3.1426E-6),
                                              (102.591,0)],
                            initial_value=0)

sim.set_const_BC("N2O","16hr","300C",0)

sim.set_const_BC("N2","16hr","300C",0.0184)

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
sim.finalize_auto_scaling()
sim.run_solver()

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "300C", file_name="Unaged_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", "300C", 0, file_name="Unaged_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3"],
                                        "Unaged", "300C", file_name="Unaged_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "300C", file_name="2hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "2hr", "300C", 0, file_name="2hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3"],
                                        "2hr", "300C", file_name="2hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "300C", file_name="4hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "4hr", "300C", 0, file_name="4hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3"],
                                        "4hr", "300C", file_name="4hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "300C", file_name="8hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "8hr", "300C", 0, file_name="8hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3"],
                                        "8hr", "300C", file_name="8hr_SCR_300C_average_ads.txt")

sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "300C", file_name="16hr_SCR_300C_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "16hr", "300C", 0, file_name="16hr_SCR_300C_bypass.txt")
sim.print_results_of_integral_average(["q1","q2a","q2b","q3"],
                                        "16hr", "300C", file_name="16hr_SCR_300C_average_ads.txt")

sim.print_kinetic_parameter_info(file_name="300C_opt_params.txt")
sim.save_model_state(file_name="300C_model.json")
