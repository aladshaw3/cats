# This script will just hold the reactions for future runs. These reactions will
#   store both the activation energy and pre-exponential terms such that these
#   dictionaries will be valid at all temperatures. Multi-temperature runs will
#   use these for direct optimization. 

#   EquilibriumArrhenius
r1_equ = {"parameters": {"A": 250000, "E": 0, "dH": -54547.9, "dS": -29.9943},
          "mol_reactants": {"Z1CuOH": 1, "NH3": 1},
          "mol_products": {"Z1CuOH-NH3": 1},
          "rxn_orders": {"Z1CuOH": 1, "NH3": 1, "Z1CuOH-NH3": 1}
        }
r2a_equ = {"parameters": {"A": 300000, "E": 0, "dH": -78073.843, "dS": -35.311574},
          "mol_reactants": {"Z2Cu": 1, "NH3": 1},
          "mol_products": {"Z2Cu-NH3": 1},
          "rxn_orders": {"Z2Cu": 1, "NH3": 1, "Z2Cu-NH3": 1}
        }
r2b_equ = {"parameters": {"A": 150000, "E": 0, "dH": -78064.167, "dS": -46.821878},
          "mol_reactants": {"Z2Cu-NH3": 1, "NH3": 1},
          "mol_products": {"Z2Cu-(NH3)2": 1},
          "rxn_orders": {"Z2Cu-NH3": 1, "NH3": 1, "Z2Cu-(NH3)2": 1}
        }
r3_equ = {"parameters": {"A": 2500000, "E": 0, "dH": -91860.8, "dS": -28.9292},
          "mol_reactants": {"ZH": 1, "NH3": 1},
          "mol_products": {"ZNH4": 1},
          "rxn_orders": {"ZH": 1, "NH3": 1, "ZNH4": 1}
        }
r4a_equ = {"parameters": {"A": 44000, "E": 0, "dH": -32099.1, "dS": -24.2494},
          "mol_reactants": {"Z1CuOH": 1, "H2O": 1},
          "mol_products": {"Z1CuOH-H2O": 1},
          "rxn_orders": {"Z1CuOH": 1, "H2O": 1, "Z1CuOH-H2O": 1}
        }
r4b_equ = {"parameters": {"A": 70000, "E": 0, "dH": -28889.23, "dS": -26.674},
          "mol_reactants": {"Z2Cu": 1, "H2O": 1},
          "mol_products": {"Z2Cu-H2O": 1},
          "rxn_orders": {"Z2Cu": 1, "H2O": 1, "Z2Cu-H2O": 1}
        }

# Arrhenius Reactions
#  ---------- NO Oxidation Reactions ------------
r5f = {"parameters": {"A": 10621246.8881622, "E": 0},
          "mol_reactants": {"Z1CuOH": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"Z1CuOH": 1, "NO2": 1},
          "rxn_orders": {"Z1CuOH": 1, "NO": 1, "O2": 1}
        }

r5r = {"parameters": {"A": 69687.3139664707, "E": 0},
          "mol_reactants": {"Z1CuOH": 1, "NO2": 1},
          "mol_products": {"Z1CuOH": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"Z1CuOH": 1, "NO2": 1}
        }

r6f = {"parameters": {"A": 7366086.69489048, "E": 0},
          "mol_reactants": {"Z2Cu": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"Z2Cu": 1, "NO2": 1},
          "rxn_orders": {"Z2Cu": 1, "NO": 1, "O2": 1}
        }

r6r = {"parameters": {"A": 44545.1369466204, "E": 0},
          "mol_reactants": {"Z2Cu": 1, "NO2": 1},
          "mol_products": {"Z2Cu": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"Z2Cu": 1, "NO2": 1}
        }


#  ---------- NH3 Oxidation to N2 Reactions ------------
r7 = {"parameters": {"A": 11209.19749306, "E": 0},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 0.75},
          "mol_products": {"Z2Cu": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r8 = {"parameters": {"A": 8628.92250137833, "E": 0},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 0.75},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r9 = {"parameters": {"A": 3725.67758336868, "E": 0},
          "mol_reactants": {"ZNH4": 1, "O2": 0.75},
          "mol_products": {"ZH": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }

#  ---------- NH3 Oxidation to NO Reactions ------------
r10 = {"parameters": {"A": 2039682.02993256, "E": 0},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 1.25},
          "mol_products": {"Z2Cu": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r11 = {"parameters": {"A": 60480565.6928142, "E": 0},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 1.25},
          "mol_products": {"Z2Cu-NH3": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r12 = {"parameters": {"A": 2263.444365474, "E": 0},
          "mol_reactants": {"ZNH4": 1, "O2": 1.25},
          "mol_products": {"ZH": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }

#  ---------- NO-SCR Reactions ------------

r13 = {"parameters": {"A": 15595794885.2373, "E": 0},
          "mol_reactants": {"Z1CuOH-NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z1CuOH-NH3": 1, "NO": 1, "O2": 1}
        }

r14 = {"parameters": {"A": 18200752117.3511, "E": 0},
          "mol_reactants": {"Z2Cu-NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO": 1, "O2": 1}
        }

r15 = {"parameters": {"A": 17895370001.2145, "E": 0},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 1}
        }

r16 = {"parameters": {"A": 260291186980.644, "E": 0},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.25, "Z1CuOH": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1.5, "Z1CuOH": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z1CuOH": 1}
        }

r17 = {"parameters": {"A": 191331964139.727, "E": 0},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.25, "Z2Cu": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1.5, "Z2Cu": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z2Cu": 1}
        }


#  ---------- N2O Formation from NO-SCR Reactions ------------

r18 = {"parameters": {"A": 262152791.983322, "E": 0},
          "mol_reactants": {"Z2Cu-NH3": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"Z2Cu": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO": 1, "O2": 1}
        }

r19 = {"parameters": {"A": 174234904.103855, "E": 0},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"Z2Cu-NH3": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 1}
        }

r20 = {"parameters": {"A": 4922357171.45753, "E": 0},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.75, "Z2Cu": 1},
          "mol_products": {"ZH": 1, "N2O": 1, "H2O": 1.5, "Z2Cu": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z2Cu": 1}
        }

#  ---------- NH4NO3 Formation Reactions ------------

r21 = {"parameters": {"A": 176367152.320444, "E": 0},
          "mol_reactants": {"Z1CuOH-NH3": 2, "NO2": 2},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 1, "Z1CuOH-NH4NO3": 1},
          "rxn_orders": {"Z1CuOH-NH3": 1, "NO2": 1}
        }

r22 = {"parameters": {"A": 64602111.9809884, "E": 0},
          "mol_reactants": {"Z2Cu-NH3": 2, "NO2": 2},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 1, "Z2Cu-NH4NO3": 1},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO2": 1}
        }

r23 = {"parameters": {"A": 168022891.877971, "E": 0},
          "mol_reactants": {"Z2Cu-(NH3)2": 2, "NO2": 2},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 1, "H2O": 1, "Z2Cu-NH4NO3": 1},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO2": 1}
        }

r24 = {"parameters": {"A": 156372424.952128, "E": 0},
          "mol_reactants": {"ZNH4": 2, "NO2": 2},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1, "ZH-NH4NO3": 1},
          "rxn_orders": {"ZNH4": 1, "NO2": 1}
        }

#  ---------- NH4NO3 Fast SCR Reactions ------------

r25 = {"parameters": {"A": 94833884.2792555, "E": 0},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1, "NO": 1},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1, "NO": 1}
        }

r26 = {"parameters": {"A": 55824127.3615727, "E": 0},
          "mol_reactants": {"Z2Cu-NH4NO3": 1, "NO": 1},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1, "NO": 1}
        }

r27 = {"parameters": {"A": 32509628.2641949, "E": 0},
          "mol_reactants": {"ZH-NH4NO3": 1, "NO": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"ZH-NH4NO3": 1, "NO": 1}
        }

#  ---------- NH4NO3 NO2 SCR Reactions ------------

r28 = {"parameters": {"A": 588920.000893384, "E": 0},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1},
          "mol_products": {"Z1CuOH-NH3": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1}
        }

r29 = {"parameters": {"A": 1184609.98403304, "E": 0},
          "mol_reactants": {"Z2Cu-NH4NO3": 1},
          "mol_products": {"Z2Cu-NH3": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1}
        }

r30 = {"parameters": {"A": 651430.51678019, "E": 0},
          "mol_reactants": {"ZH-NH4NO3": 1},
          "mol_products": {"ZNH4": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"ZH-NH4NO3": 1}
        }

#  ---------- NH4NO3 N2O Formation Reactions ------------

r31 = {"parameters": {"A": 384602.716331004, "E": 0},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1},
          "mol_products": {"Z1CuOH": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1}
        }

r32 = {"parameters": {"A": 280420.67717765, "E": 0},
          "mol_reactants": {"Z2Cu-NH4NO3": 1},
          "mol_products": {"Z2Cu": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1}
        }

r33 = {"parameters": {"A": 46311.6291751424, "E": 0},
          "mol_reactants": {"ZH-NH4NO3": 1},
          "mol_products": {"ZH": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"ZH-NH4NO3": 1}
        }

#  ---------- CuO High Temp NH3 oxidation reactions ------------

r34 = {"parameters": {"A": 1820506445.01069, "E": 0},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 0.75},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "N2": 0.5},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

r35 = {"parameters": {"A": 1337820.92927024, "E": 0},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 1.25},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "NO": 1},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

r36 = {"parameters": {"A": 933356.579690862, "E": 0},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 1},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "N2O": 0.5},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

#  ---------- N2O formation from NH3 oxidation ------------

r37 = {"parameters": {"A": 133472.347179727, "E": 0},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 1},
          "mol_products": {"Z2Cu": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r38 = {"parameters": {"A": 5685385.28253767, "E": 0},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 1},
          "mol_products": {"Z2Cu-NH3": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r39 = {"parameters": {"A": 0.005689907286157, "E": 0},
          "mol_reactants": {"ZNH4": 1, "O2": 1},
          "mol_products": {"ZH": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }
