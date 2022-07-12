# Use this set as a starting point

# This script will just hold the reactions for future runs. These reactions will
#   store both the activation energy and pre-exponential terms such that these
#   dictionaries will be valid at all temperatures. Multi-temperature runs will
#   use these for direct optimization.

#   EquilibriumArrhenius
r1_equ = {"parameters": {"A": 198500, "E": 0, "dH": -54547.9, "dS": -29.9943},
          "mol_reactants": {"Z1CuOH": 1, "NH3": 1},
          "mol_products": {"Z1CuOH-NH3": 1},
          "rxn_orders": {"Z1CuOH": 1, "NH3": 1, "Z1CuOH-NH3": 1}
        }
r2a_equ = {"parameters": {"A": 278200, "E": 0, "dH": -78073.843, "dS": -35.311574},
          "mol_reactants": {"Z2Cu": 1, "NH3": 1},
          "mol_products": {"Z2Cu-NH3": 1},
          "rxn_orders": {"Z2Cu": 1, "NH3": 1, "Z2Cu-NH3": 1}
        }
r2b_equ = {"parameters": {"A": 139100, "E": 0, "dH": -78064.167, "dS": -46.821878},
          "mol_reactants": {"Z2Cu-NH3": 1, "NH3": 1},
          "mol_products": {"Z2Cu-(NH3)2": 1},
          "rxn_orders": {"Z2Cu-NH3": 1, "NH3": 1, "Z2Cu-(NH3)2": 1}
        }
r3_equ = {"parameters": {"A": 1346000, "E": 0, "dH": -91860.8, "dS": -28.9292},
          "mol_reactants": {"ZH": 1, "NH3": 1},
          "mol_products": {"ZNH4": 1},
          "rxn_orders": {"ZH": 1, "NH3": 1, "ZNH4": 1}
        }
r4a_equ = {"parameters": {"A": 50136, "E": 0, "dH": -32099.1, "dS": -24.2494},
          "mol_reactants": {"Z1CuOH": 1, "H2O": 1},
          "mol_products": {"Z1CuOH-H2O": 1},
          "rxn_orders": {"Z1CuOH": 1, "H2O": 1, "Z1CuOH-H2O": 1}
        }
r4b_equ = {"parameters": {"A": 61580, "E": 0, "dH": -28889.23, "dS": -26.674},
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
r10 = {"parameters": {"A": 3.00708980881736E+021, "E": 264372.573707305},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 1.25},
          "mol_products": {"Z2Cu": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r11 = {"parameters": {"A": 5.00241449799262E+021, "E": 266700.909300748},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 1.25},
          "mol_products": {"Z2Cu-NH3": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r12 = {"parameters": {"A": 1.73648545789896E+021, "E": 262542.766347393},
          "mol_reactants": {"ZNH4": 1, "O2": 1.25},
          "mol_products": {"ZH": 1, "NO": 1, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }

#  ---------- NO-SCR Reactions ------------

r13 = {"parameters": {"A": 158934896906195, "E": 61217.0869171797},
          "mol_reactants": {"Z1CuOH-NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z1CuOH-NH3": 1, "NO": 1, "O2": 1}
        }

r14 = {"parameters": {"A": 276342772543379, "E": 63945.5969171797},
          "mol_reactants": {"Z2Cu-NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO": 1, "O2": 1}
        }

r15 = {"parameters": {"A": 196507053031761, "E": 61752.5369171797},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 1}
        }

r16 = {"parameters": {"A": 5793591205044520, "E": 66563.6369171797},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.25, "Z1CuOH": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1.5, "Z1CuOH": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z1CuOH": 1}
        }

r17 = {"parameters": {"A": 307766200223700, "E": 48581.6669171797},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.25, "Z2Cu": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1.5, "Z2Cu": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z2Cu": 1}
        }


#  ---------- N2O Formation from NO-SCR Reactions ------------

r18 = {"parameters": {"A": 2195592975649.08, "E": 59874.3469171797},
          "mol_reactants": {"Z2Cu-NH3": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"Z2Cu": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO": 1, "O2": 1}
        }

r19 = {"parameters": {"A": 319376073732.502, "E": 50337.6569171797},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"Z2Cu-NH3": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 1}
        }

r20 = {"parameters": {"A": 6698742339169.11, "E": 47437.3769171797},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.75, "Z2Cu": 1},
          "mol_products": {"ZH": 1, "N2O": 1, "H2O": 1.5, "Z2Cu": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z2Cu": 1}
        }

#  ---------- NH4NO3 Formation Reactions ------------

r21 = {"parameters": {"A": 13725167148853.1, "E": 75075.4063936518},
          "mol_reactants": {"Z1CuOH-NH3": 2, "NO2": 2},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 1, "Z1CuOH-NH4NO3": 1},
          "rxn_orders": {"Z1CuOH-NH3": 1, "NO2": 1}
        }

r22 = {"parameters": {"A": 145181130020.463, "E": 53260.3863936518},
          "mol_reactants": {"Z2Cu-NH3": 2, "NO2": 2},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 1, "Z2Cu-NH4NO3": 1},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO2": 1}
        }

r23 = {"parameters": {"A": 15651219976223.6, "E": 77986.1763936518},
          "mol_reactants": {"Z2Cu-(NH3)2": 2, "NO2": 2},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 1, "H2O": 1, "Z2Cu-NH4NO3": 1},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO2": 1}
        }

r24 = {"parameters": {"A": 9513150643765.07, "E": 73387.7563936518},
          "mol_reactants": {"ZNH4": 2, "NO2": 2},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1, "ZH-NH4NO3": 1},
          "rxn_orders": {"ZNH4": 1, "NO2": 1}
        }

#  ---------- NH4NO3 Fast SCR Reactions ------------

r25 = {"parameters": {"A": 226043372451.468, "E": 53126.0063936518},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1, "NO": 1},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1, "NO": 1}
        }

r26 = {"parameters": {"A": 85288248447.6855, "E": 49266.4263936518},
          "mol_reactants": {"Z2Cu-NH4NO3": 1, "NO": 1},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1, "NO": 1}
        }

r27 = {"parameters": {"A": 9713469804.52266, "E": 39309.8263936518},
          "mol_reactants": {"ZH-NH4NO3": 1, "NO": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"ZH-NH4NO3": 1, "NO": 1}
        }

#  ---------- NH4NO3 NO2 SCR Reactions ------------

r28 = {"parameters": {"A": 183578.417658479, "E": 56946.0263936518},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1},
          "mol_products": {"Z1CuOH-NH3": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1}
        }

r29 = {"parameters": {"A": 2667072.90885306, "E": 70419.8063936518},
          "mol_reactants": {"Z2Cu-NH4NO3": 1},
          "mol_products": {"Z2Cu-NH3": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1}
        }

r30 = {"parameters": {"A": 128573.994477963, "E": 55857.3863936518},
          "mol_reactants": {"ZH-NH4NO3": 1},
          "mol_products": {"ZNH4": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"ZH-NH4NO3": 1}
        }

#  ---------- NH4NO3 N2O Formation Reactions ------------

r31 = {"parameters": {"A": 28372964.584683, "E": 93110.3563936519},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1},
          "mol_products": {"Z1CuOH": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1}
        }

r32 = {"parameters": {"A": 7156161.2710666, "E": 83735.8563936518},
          "mol_reactants": {"Z2Cu-NH4NO3": 1},
          "mol_products": {"Z2Cu": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1}
        }

r33 = {"parameters": {"A": 18828.095111708, "E": 53546.2763936518},
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

r35 = {"parameters": {"A": 3654870966252980, "E": 161014.79},
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

r37 = {"parameters": {"A": 6.75050772045435E+021, "E": 288488.94},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 1},
          "mol_products": {"Z2Cu": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r38 = {"parameters": {"A": 1.04801E+22, "E": 290624.89},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 1},
          "mol_products": {"Z2Cu-NH3": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r39 = {"parameters": {"A": 3.23131E+21, "E": 285451.76},
          "mol_reactants": {"ZNH4": 1, "O2": 1},
          "mol_products": {"ZH": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }
