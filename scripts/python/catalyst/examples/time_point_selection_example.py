# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

# Read in the data (data is now a dictionary containing the data we want)
data = naively_read_data_file("inputfiles/scr_sample_input.txt", factor=1)

time_list = time_point_selector(data["time"], data)

test = Isothermal_Monolith_Simulator()
test.add_axial_dim(0,5)
test.add_axial_dataset(5)       # Location of observations (in cm)

test.add_temporal_dim(point_list=time_list)
test.add_temporal_dataset(data["time"])   #Temporal observations (in s)

test.add_age_set("Unaged")
test.add_data_age_set("Unaged")             # Data observations can be a sub-set

test.add_temperature_set("250C")
test.add_data_temperature_set("250C")     # Data observations can be a sub-set

test.add_gas_species(["NH3","H2O","O2","NO","NO2","N2O","N2"])
test.add_data_gas_species(["NH3","NO","NO2","N2O"])    # Data observations can be a sub-set

test.set_data_values_for("NH3","Unaged","250C",5,data["time"],data["NH3"])
test.set_data_values_for("NO","Unaged","250C",5,data["time"],data["NO"])
test.set_data_values_for("NO2","Unaged","250C",5,data["time"],data["NO2"])
test.set_data_values_for("N2O","Unaged","250C",5,data["time"],data["N2O"])

#Clear up memory space after we don't need the dictionary anymore
data.clear()

test.add_surface_species(["q1","q2a","q2b","q3a","q3b","q3c","q4a","q4b"])
test.add_surface_sites(["S1","S2","S3a","S3b","S3c"])
test.add_reactions({"r1": ReactionType.EquilibriumArrhenius,
                    "r2a": ReactionType.EquilibriumArrhenius,
                    "r2b": ReactionType.EquilibriumArrhenius,
                    "r3a": ReactionType.EquilibriumArrhenius,
                    "r3b": ReactionType.EquilibriumArrhenius,
                    "r3c": ReactionType.EquilibriumArrhenius,
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
                    "r28": ReactionType.Arrhenius,
                    "r29": ReactionType.Arrhenius,
                    "r30": ReactionType.Arrhenius,
                    "r31f": ReactionType.Arrhenius,
                    "r31r": ReactionType.Arrhenius,
                    "r32": ReactionType.Arrhenius,
                    "r33": ReactionType.Arrhenius,
                    "r34": ReactionType.Arrhenius,
                    "r35": ReactionType.Arrhenius,
                    "r36": ReactionType.Arrhenius,
                    "r37": ReactionType.Arrhenius,
                    "r38": ReactionType.Arrhenius,
                    "r39f": ReactionType.Arrhenius,
                    "r39r": ReactionType.Arrhenius,
                    "r40": ReactionType.Arrhenius,
                    "r41": ReactionType.Arrhenius,
                    "r42": ReactionType.Arrhenius,
                    "r43": ReactionType.Arrhenius,
                    "r44": ReactionType.Arrhenius
                    })

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.2)
test.set_reactor_radius(1)
test.set_space_velocity_all_runs(1000)      #volumes/min
test.set_cell_density(62)                   # 62 cells per cm^2 (~400 cpsi)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"q1": 1, "q4a": 1}}
s2_data = {"mol_occupancy": {"q2a": 1, "q2b": 1, "q4b": 1}}
s3a_data = {"mol_occupancy": {"q3a": 1}}
s3b_data = {"mol_occupancy": {"q3b": 1}}
s3c_data = {"mol_occupancy": {"q3c": 1}}

test.set_site_balance("S1",s1_data)
test.set_site_balance("S2",s2_data)
test.set_site_balance("S3a",s3a_data)
test.set_site_balance("S3b",s3b_data)
test.set_site_balance("S3c",s3c_data)

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
r3a_equ = {"parameters": {"A": 2500000, "E": 0, "dH": -91860.8, "dS": -28.9292},
          "mol_reactants": {"S3a": 1, "NH3": 1},
          "mol_products": {"q3a": 1},
          "rxn_orders": {"S3a": 1, "NH3": 1, "q3a": 1}
        }
r3b_equ = {"parameters": {"A": 2500000, "E": 0, "dH": -91860.8, "dS": -28.9292},
          "mol_reactants": {"S3b": 1, "NH3": 1},
          "mol_products": {"q3b": 1},
          "rxn_orders": {"S3b": 1, "NH3": 1, "q3b": 1}
        }
r3c_equ = {"parameters": {"A": 2500000, "E": 0, "dH": -91860.8, "dS": -28.9292},
          "mol_reactants": {"S3c": 1, "NH3": 1},
          "mol_products": {"q3c": 1},
          "rxn_orders": {"S3c": 1, "NH3": 1, "q3c": 1}
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

r7f = {"parameters": {"A": 95.5, "E": 0},
          "mol_reactants": {"S1": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"S1": 1, "NO2": 1},
          "rxn_orders": {"S1": 1, "NO": 1, "O2": 1}
        }

r7r = {"parameters": {"A": 0.0030557, "E": 0},
          "mol_reactants": {"S1": 1, "NO2": 1},
          "mol_products": {"S1": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"S1": 1, "NO2": 1}
        }

r8 = {"parameters": {"A": 29185410.5, "E": 0},
          "mol_reactants": {"q1": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"S1": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q1": 1, "NO": 1, "O2": 1}
        }

r9 = {"parameters": {"A": 0, "E": 0},
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
r13a = {"parameters": {"A": 10.876, "E": 0},
          "mol_reactants": {"q2a": 1, "O2": 0.75},
          "mol_products": {"S2": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "O2": 1}
        }

r14a = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2a": 1, "O2": 1.25},
          "mol_products": {"S2": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "O2": 1}
        }

r15af = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"S2": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"S2": 1, "NO2": 1},
          "rxn_orders": {"S2": 1, "NO": 1, "O2": 1}
        }

r15ar = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"S2": 1, "NO2": 1},
          "mol_products": {"S2": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"S2": 1, "NO2": 1}
        }

r16a = {"parameters": {"A": 37921503.8, "E": 0},
          "mol_reactants": {"q2a": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"S2": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "NO": 1, "O2": 1}
        }

r17a = {"parameters": {"A": 5781635.3, "E": 0},
          "mol_reactants": {"q2a": 1, "NO2": 1},
          "mol_products": {"S2": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q2a": 1, "NO2": 1}
        }

r18a = {"parameters": {"A": 2872371.2, "E": 0},
          "mol_reactants": {"q2a": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"S2": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q2a": 1, "NO2": 1, "O2": 1}
        }

r19a = {"parameters": {"A": 0, "E": 0},
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
r13b = {"parameters": {"A": 0, "E": 0},
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

r16b = {"parameters": {"A": 115523331.4, "E": 0},
          "mol_reactants": {"q2b": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"q2a": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "NO": 1, "O2": 1}
        }

r17b = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2b": 1, "NO2": 1},
          "mol_products": {"q2a": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q2b": 1, "NO2": 1}
        }

r18b = {"parameters": {"A": 66820446.5, "E": 0},
          "mol_reactants": {"q2b": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"q2a": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "NO2": 1, "O2": 1}
        }

r19b = {"parameters": {"A": 15338440.7, "E": 0},
          "mol_reactants": {"q2b": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"q2a": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "NO": 1, "O2": 1}
        }

r20b = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q2b": 1, "NO": 0.5, "NO2": 0.5},
          "mol_products": {"q2a": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q2b": 1, "NO": 1, "NO2": 1}
        }

#  ---------- q3a reactions ------------
r21 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3a": 1, "O2": 0.75},
          "mol_products": {"S3a": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"q3a": 1, "O2": 1}
        }

r22 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3a": 1, "O2": 1.25},
          "mol_products": {"S3a": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"q3a": 1, "O2": 1}
        }

r23f = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"S3a": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"S3a": 1, "NO2": 1},
          "rxn_orders": {"S3a": 1, "NO": 1, "O2": 1}
        }

r23r = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"S3a": 1, "NO2": 1},
          "mol_products": {"S3a": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"S3a": 1, "NO2": 1}
        }

r24 = {"parameters": {"A": 46478388.4, "E": 0},
          "mol_reactants": {"q3a": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"S3a": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q3a": 1, "NO": 1, "O2": 1}
        }

r25 = {"parameters": {"A": 453315.1, "E": 0},
          "mol_reactants": {"q3a": 1, "NO2": 1},
          "mol_products": {"S3a": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q3a": 1, "NO2": 1}
        }

r26 = {"parameters": {"A": 1.444E-7, "E": 0},
          "mol_reactants": {"q3a": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"S3a": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q3a": 1, "NO2": 1, "O2": 1}
        }

r27 = {"parameters": {"A": 1752309.7, "E": 0},
          "mol_reactants": {"q3a": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"S3a": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q3a": 1, "NO": 1, "O2": 1}
        }

r28 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3a": 1, "NO": 0.5, "NO2": 0.5},
          "mol_products": {"S3a": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q3a": 1, "NO": 1, "NO2": 1}
        }

#  ---------- q3b reactions ------------
r29 = {"parameters": {"A": 46.355, "E": 0},
          "mol_reactants": {"q3b": 1, "O2": 0.75},
          "mol_products": {"S3b": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"q3b": 1, "O2": 1}
        }

r30 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3b": 1, "O2": 1.25},
          "mol_products": {"S3b": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"q3b": 1, "O2": 1}
        }

r31f = {"parameters": {"A": 2044887.5, "E": 0},
          "mol_reactants": {"S3b": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"S3b": 1, "NO2": 1},
          "rxn_orders": {"S3b": 1, "NO": 1, "O2": 1}
        }

r31r = {"parameters": {"A": 274.039, "E": 0},
          "mol_reactants": {"S3b": 1, "NO2": 1},
          "mol_products": {"S3b": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"S3b": 1, "NO2": 1}
        }

r32 = {"parameters": {"A": 487708871.7, "E": 0},
          "mol_reactants": {"q3b": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"S3b": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q3b": 1, "NO": 1, "O2": 1}
        }

r33 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3b": 1, "NO2": 1},
          "mol_products": {"S3b": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q3b": 1, "NO2": 1}
        }

r34 = {"parameters": {"A": 480939227.2, "E": 0},
          "mol_reactants": {"q3b": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"S3b": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q3b": 1, "NO2": 1, "O2": 1}
        }

r35 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3b": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"S3b": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q3b": 1, "NO": 1, "O2": 1}
        }

r36 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3b": 1, "NO": 0.5, "NO2": 0.5},
          "mol_products": {"S3b": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q3b": 1, "NO": 1, "NO2": 1}
        }

#  ---------- q3c reactions ------------
r37 = {"parameters": {"A": 0.15775, "E": 0},
          "mol_reactants": {"q3c": 1, "O2": 0.75},
          "mol_products": {"S3c": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"q3c": 1, "O2": 1}
        }

r38 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3c": 1, "O2": 1.25},
          "mol_products": {"S3c": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"q3c": 1, "O2": 1}
        }

r39f = {"parameters": {"A": 1118261.3, "E": 0},
          "mol_reactants": {"S3c": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"S3c": 1, "NO2": 1},
          "rxn_orders": {"S3c": 1, "NO": 1, "O2": 1}
        }

r39r = {"parameters": {"A": 113.703, "E": 0},
          "mol_reactants": {"S3c": 1, "NO2": 1},
          "mol_products": {"S3c": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"S3c": 1, "NO2": 1}
        }

r40 = {"parameters": {"A": 942488128.7, "E": 0},
          "mol_reactants": {"q3c": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"S3c": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q3c": 1, "NO": 1, "O2": 1}
        }

r41 = {"parameters": {"A": 3952095.5, "E": 0},
          "mol_reactants": {"q3c": 1, "NO2": 1},
          "mol_products": {"S3c": 1, "N2": 1, "H2O": 1.5, "O2": 0.25},
          "rxn_orders": {"q3c": 1, "NO2": 1}
        }

r42 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3c": 1, "NO2": 1, "O2": 0.25},
          "mol_products": {"S3c": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q3c": 1, "NO2": 1, "O2": 1}
        }

r43 = {"parameters": {"A": 13814346.1, "E": 0},
          "mol_reactants": {"q3c": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"S3c": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"q3c": 1, "NO": 1, "O2": 1}
        }

r44 = {"parameters": {"A": 0, "E": 0},
          "mol_reactants": {"q3c": 1, "NO": 0.5, "NO2": 0.5},
          "mol_products": {"S3c": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"q3c": 1, "NO": 1, "NO2": 1}
        }

test.set_reaction_info("r1", r1_equ)
test.set_reaction_info("r2a", r2a_equ)
test.set_reaction_info("r2b", r2b_equ)
test.set_reaction_info("r3a", r3a_equ)
test.set_reaction_info("r3b", r3b_equ)
test.set_reaction_info("r3c", r3c_equ)
test.set_reaction_info("r4a", r4a_equ)
test.set_reaction_info("r4b", r4b_equ)

test.set_reaction_info("r5", r5)
test.set_reaction_info("r6", r6)
test.set_reaction_info("r7f", r7f)
test.set_reaction_info("r7r", r7r)
test.set_reaction_info("r8", r8)
test.set_reaction_info("r9", r9)
test.set_reaction_info("r10", r10)
test.set_reaction_info("r11", r11)
test.set_reaction_info("r12", r12)

test.set_reaction_info("r13a", r13a)
test.set_reaction_info("r14a", r14a)
test.set_reaction_info("r15af", r15af)
test.set_reaction_info("r15ar", r15ar)
test.set_reaction_info("r16a", r16a)
test.set_reaction_info("r17a", r17a)
test.set_reaction_info("r18a", r18a)
test.set_reaction_info("r19a", r19a)
test.set_reaction_info("r20a", r20a)

test.set_reaction_info("r13b", r13b)
test.set_reaction_info("r14b", r14b)
test.set_reaction_info("r15bf", r15bf)
test.set_reaction_info("r15br", r15br)
test.set_reaction_info("r16b", r16b)
test.set_reaction_info("r17b", r17b)
test.set_reaction_info("r18b", r18b)
test.set_reaction_info("r19b", r19b)
test.set_reaction_info("r20b", r20b)

test.set_reaction_info("r21", r21)
test.set_reaction_info("r22", r22)
test.set_reaction_info("r23f", r23f)
test.set_reaction_info("r23r", r23r)
test.set_reaction_info("r24", r24)
test.set_reaction_info("r25", r25)
test.set_reaction_info("r26", r26)
test.set_reaction_info("r27", r27)
test.set_reaction_info("r28", r28)

test.set_reaction_info("r29", r29)
test.set_reaction_info("r30", r30)
test.set_reaction_info("r31f", r31f)
test.set_reaction_info("r31r", r31r)
test.set_reaction_info("r32", r32)
test.set_reaction_info("r33", r33)
test.set_reaction_info("r34", r34)
test.set_reaction_info("r35", r35)
test.set_reaction_info("r36", r36)

test.set_reaction_info("r37", r37)
test.set_reaction_info("r38", r38)
test.set_reaction_info("r39f", r39f)
test.set_reaction_info("r39r", r39r)
test.set_reaction_info("r40", r40)
test.set_reaction_info("r41", r41)
test.set_reaction_info("r42", r42)
test.set_reaction_info("r43", r43)
test.set_reaction_info("r44", r44)

test.set_site_density("S1","Unaged",0.052619016)
test.set_site_density("S2","Unaged",0.023125746)
test.set_site_density("S3a","Unaged",0.01632)
test.set_site_density("S3b","Unaged",0.003233)
test.set_site_density("S3c","Unaged",0.006699)

test.set_isothermal_temp("Unaged","250C",250+273.15)

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=200,elems=5,colpoints=1)

# Initial conditions and Boundary Conditions should be set AFTER discretization
test.set_const_IC("O2","Unaged","250C",0.002330029)
test.set_const_IC("H2O","Unaged","250C",0.001174)
test.set_const_IC("NH3","Unaged","250C",0)
test.set_const_IC("NO","Unaged","250C",0)
test.set_const_IC("NO2","Unaged","250C",0)
test.set_const_IC("N2O","Unaged","250C",0)
test.set_const_IC("N2","Unaged","250C",0.0184)

test.set_const_IC("q1","Unaged","250C",0)
test.set_const_IC("q2a","Unaged","250C",0)
test.set_const_IC("q2b","Unaged","250C",0)
test.set_const_IC("q3a","Unaged","250C",0)
test.set_const_IC("q3b","Unaged","250C",0)
test.set_const_IC("q3c","Unaged","250C",0)
test.set_const_IC("q4a","Unaged","250C",0)
test.set_const_IC("q4b","Unaged","250C",0)


test.set_time_dependent_BC("O2","Unaged","250C",
                            time_value_pairs=[(2.0917,4.66006E-5),
                                              (29.758,0.002330029)],
                            initial_value=0.002330029)

test.set_time_dependent_BC("H2O","Unaged","250C",
                            time_value_pairs=[(3.5917,0.00115689),
                                              (31.5,0.001144255),
                                              (203.5,0.00113886)],
                            initial_value=0.001174)

test.set_time_dependent_BC("NH3","Unaged","250C",
                            time_value_pairs=[(2.0917,6.9499E-6),
                                              (40.75,0),
                                              (56.2583,6.9499E-6),
                                              (101.425,0),
                                              (130.425,6.9499E-6),
                                              (190.7583,0)],
                            initial_value=0)

test.set_time_dependent_BC("NO","Unaged","250C",
                            time_value_pairs=[(40.75,6.9239E-6),
                                              (116.925,3.44803E-6),
                                              (203.7583,6.9239E-6)],
                            initial_value=0)

test.set_time_dependent_BC("NO2","Unaged","250C",
                            time_value_pairs=[(116.925,3.37554E-6),
                                              (203.7583,0)],
                            initial_value=0)

test.set_const_BC("N2O","Unaged","250C",0)

test.set_const_BC("N2","Unaged","250C",0.0184)

# Fix the kinetics to only run a simulation
test.fix_reaction("r1")
test.fix_reaction("r2a")
test.fix_reaction("r2b")
test.fix_reaction("r3a")
test.fix_reaction("r3b")
test.fix_reaction("r3c")
test.fix_reaction("r4a")
test.fix_reaction("r4b")

# Fix all kinetics, then only unfix some reactions
test.fix_all_reactions()

test.initialize_auto_scaling()
test.initialize_simulator()
test.finalize_auto_scaling()
test.run_solver()

test.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                            "Unaged", "250C", file_name="time_test.txt")
