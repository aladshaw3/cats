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
r5f = {"parameters": {"A": 8693470338.69636, "E":  46077.62},
          "mol_reactants": {"Z1CuOH": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"Z1CuOH": 1, "NO2": 1},
          "rxn_orders": {"Z1CuOH": 1, "NO": 1, "O2": 1}
        }

r5r = {"parameters": {"A": 21624646159.5736, "E": 85993.32},
          "mol_reactants": {"Z1CuOH": 1, "NO2": 1},
          "mol_products": {"Z1CuOH": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"Z1CuOH": 1, "NO2": 1}
        }

r6f = {"parameters": {"A": 2930191759.3159, "E": 41243.49},
          "mol_reactants": {"Z2Cu": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"Z2Cu": 1, "NO2": 1},
          "rxn_orders": {"Z2Cu": 1, "NO": 1, "O2": 1}
        }

r6r = {"parameters": {"A": 2668382121.73993, "E": 75883.94},
          "mol_reactants": {"Z2Cu": 1, "NO2": 1},
          "mol_products": {"Z2Cu": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"Z2Cu": 1, "NO2": 1}
        }


#  ---------- NH3 Oxidation to N2 Reactions ------------
r7 = {"parameters": {"A": 75039256257.0974, "E":  104631.97},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 0.75},
          "mol_products": {"Z2Cu": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r8 = {"parameters": {"A": 34648088533.0477, "E": 101159.98},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 0.75},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r9 = {"parameters": {"A": 2140619788.0508, "E": 87826.79},
          "mol_reactants": {"ZNH4": 1, "O2": 0.75},
          "mol_products": {"ZH": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }

#  ---------- NH3 Oxidation to NO Reactions ------------
r10 = {"parameters": {"A": 1.2125963904201E+024, "E": 286697.01},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 1.25},
          "mol_products": {"Z2Cu": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r11 = {"parameters": {"A": 5.64374612993001E+026, "E": 320889.54},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 1.25},
          "mol_products": {"Z2Cu-NH3": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r12 = {"parameters": {"A": 3.85202027422709E+015, "E": 190551.97},
          "mol_reactants": {"ZNH4": 1, "O2": 1.25},
          "mol_products": {"ZH": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }

#  ---------- NO-SCR Reactions ------------

r13 = {"parameters": {"A": 211839268632915, "E": 63280.61},
          "mol_reactants": {"Z1CuOH-NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z1CuOH-NH3": 1, "NO": 1, "O2": 1}
        }

r14 = {"parameters": {"A": 368328491521484, "E": 66009.12},
          "mol_reactants": {"Z2Cu-NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO": 1, "O2": 1}
        }

r15 = {"parameters": {"A": 261918000425209, "E": 63816.06},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 1}
        }

r16 = {"parameters": {"A": 7722093432753739, "E": 68627.16},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.25, "Z1CuOH": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1.5, "Z1CuOH": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z1CuOH": 1}
        }

r17 = {"parameters": {"A": 410211778749886, "E": 50645.19},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.25, "Z2Cu": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1.5, "Z2Cu": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z2Cu": 1}
        }


#  ---------- N2O Formation from NO-SCR Reactions ------------

r18 = {"parameters": {"A": 2926436039100.85, "E": 61937.87},
          "mol_reactants": {"Z2Cu-NH3": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"Z2Cu": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO": 1, "O2": 1}
        }

r19 = {"parameters": {"A": 425686209859.1, "E": 52401.18},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"Z2Cu-NH3": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 1}
        }

r20 = {"parameters": {"A": 8928540588084.07, "E": 49500.90},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.75, "Z2Cu": 1},
          "mol_products": {"ZH": 1, "N2O": 1, "H2O": 1.5, "Z2Cu": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z2Cu": 1}
        }

#  ---------- NH4NO3 Formation Reactions ------------

r21 = {"parameters": {"A": 30376764396934.3, "E": 80667.15},
          "mol_reactants": {"Z1CuOH-NH3": 2, "NO2": 2},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 1, "Z1CuOH-NH4NO3": 1},
          "rxn_orders": {"Z1CuOH-NH3": 1, "NO2": 1}
        }

r22 = {"parameters": {"A": 321317251271.568, "E": 58852.13},
          "mol_reactants": {"Z2Cu-NH3": 2, "NO2": 2},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 1, "Z2Cu-NH4NO3": 1},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO2": 1}
        }

r23 = {"parameters": {"A": 34639536013378.2, "E": 83577.92},
          "mol_reactants": {"Z2Cu-(NH3)2": 2, "NO2": 2},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 1, "H2O": 1, "Z2Cu-NH4NO3": 1},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO2": 1}
        }

r24 = {"parameters": {"A": 21054660584031.1, "E": 78979.50},
          "mol_reactants": {"ZNH4": 2, "NO2": 2},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1, "ZH-NH4NO3": 1},
          "rxn_orders": {"ZNH4": 1, "NO2": 1}
        }

#  ---------- NH4NO3 Fast SCR Reactions ------------

r25 = {"parameters": {"A": 500282888651.05, "E": 58717.75},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1, "NO": 1},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1, "NO": 1}
        }

r26 = {"parameters": {"A": 188761346279.054, "E": 54858.17},
          "mol_reactants": {"Z2Cu-NH4NO3": 1, "NO": 1},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1, "NO": 1}
        }

r27 = {"parameters": {"A": 21498010226.6642, "E": 44901.57},
          "mol_reactants": {"ZH-NH4NO3": 1, "NO": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"ZH-NH4NO3": 1, "NO": 1}
        }

#  ---------- NH4NO3 NO2 SCR Reactions ------------

r28 = {"parameters": {"A": 6276203916.38501, "E": 62537.77},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1},
          "mol_products": {"Z1CuOH-NH3": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1}
        }

r29 = {"parameters": {"A": 103292420877.651, "E": 76011.55},
          "mol_reactants": {"Z2Cu-NH4NO3": 1},
          "mol_products": {"Z2Cu-NH3": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1}
        }

r30 = {"parameters": {"A": 5058837027.06195, "E": 61449.13},
          "mol_reactants": {"ZH-NH4NO3": 1},
          "mol_products": {"ZNH4": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"ZH-NH4NO3": 1}
        }

#  ---------- NH4NO3 N2O Formation Reactions ------------

r31 = {"parameters": {"A": 682496088388.681, "E": 98702.10},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1},
          "mol_products": {"Z1CuOH": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1}
        }

r32 = {"parameters": {"A": 119859301801.73, "E": 89327.60},
          "mol_reactants": {"Z2Cu-NH4NO3": 1},
          "mol_products": {"Z2Cu": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1}
        }

r33 = {"parameters": {"A": 240860119.889452, "E": 59138.02},
          "mol_reactants": {"ZH-NH4NO3": 1},
          "mol_products": {"ZH": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"ZH-NH4NO3": 1}
        }

#  ---------- CuO High Temp NH3 oxidation reactions ------------

r34 = {"parameters": {"A": 2.84360655644905E+029, "E": 337783.27},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 0.75},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "N2": 0.5},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

r35 = {"parameters": {"A": 3654870966252987, "E": 161014.79},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 1.25},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "NO": 1},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

r36 = {"parameters": {"A": 4.68906490186431E+016, "E": 180163.64},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 1},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "N2O": 0.5},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

#  ---------- N2O formation from NH3 oxidation ------------

r37 = {"parameters": {"A": 3.52600654817229E+023, "E": 296711.61},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 1},
          "mol_products": {"Z2Cu": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r38 = {"parameters": {"A": 1.28077386836454E+035, "E": 469982.15},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 1},
          "mol_products": {"Z2Cu-NH3": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r39 = {"parameters": {"A": 132164.695490384, "E": 114388.81},
          "mol_reactants": {"ZNH4": 1, "O2": 1},
          "mol_products": {"ZH": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }
