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
r5f = {"parameters": {"A": 11695552804.8967, "E":  47276.5598305903},
          "mol_reactants": {"Z1CuOH": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"Z1CuOH": 1, "NO2": 1},
          "rxn_orders": {"Z1CuOH": 1, "NO": 1, "O2": 1}
        }

r5r = {"parameters": {"A": 15221221335.6318, "E": 83661.4960321029},
          "mol_reactants": {"Z1CuOH": 1, "NO2": 1},
          "mol_products": {"Z1CuOH": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"Z1CuOH": 1, "NO2": 1}
        }

r6f = {"parameters": {"A": 1764591354.12529, "E": 40292.573419771},
          "mol_reactants": {"Z2Cu": 1, "NO": 1, "O2": 0.5},
          "mol_products": {"Z2Cu": 1, "NO2": 1},
          "rxn_orders": {"Z2Cu": 1, "NO": 1, "O2": 1}
        }

r6r = {"parameters": {"A": 445004565.411014, "E": 66133.7226681343},
          "mol_reactants": {"Z2Cu": 1, "NO2": 1},
          "mol_products": {"Z2Cu": 1, "NO": 1, "O2": 0.5},
          "rxn_orders": {"Z2Cu": 1, "NO2": 1}
        }


#  ---------- NH3 Oxidation to N2 Reactions ------------
r7 = {"parameters": {"A": 201354205156.26, "E":  109893.989315212},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 0.75},
          "mol_products": {"Z2Cu": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r8 = {"parameters": {"A": 79258458661.5525, "E": 105475.829659577},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 0.75},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r9 = {"parameters": {"A": 4782418398.20257, "E": 92930.2488072898},
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

r13 = {"parameters": {"A": 215448914486920, "E": 64369.0048614155},
          "mol_reactants": {"Z1CuOH-NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z1CuOH-NH3": 1, "NO": 1, "O2": 1}
        }

r14 = {"parameters": {"A": 480755185877306, "E": 68458.0907606441},
          "mol_reactants": {"Z2Cu-NH3": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO": 1, "O2": 1}
        }

r15 = {"parameters": {"A": 193808453827601, "E": 62840.8727236646},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 0.25},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 1}
        }

r16 = {"parameters": {"A": 1.97353517884464E+016, "E": 74710.7188194458},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.25, "Z1CuOH": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1.5, "Z1CuOH": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z1CuOH": 1}
        }

r17 = {"parameters": {"A": 416908818419927, "E": 51733.2741199806},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.25, "Z2Cu": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1.5, "Z2Cu": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z2Cu": 1}
        }


#  ---------- N2O Formation from NO-SCR Reactions ------------

r18 = {"parameters": {"A": 9852117774702.59, "E": 68097.5857311348},
          "mol_reactants": {"Z2Cu-NH3": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"Z2Cu": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO": 1, "O2": 1}
        }

r19 = {"parameters": {"A": 549134642312.816, "E": 53348.7939925618},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 0.75},
          "mol_products": {"Z2Cu-NH3": 1, "N2O": 1, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO": 1, "O2": 1}
        }

r20 = {"parameters": {"A": 24297420482808.3, "E": 54973.4705433069},
          "mol_reactants": {"ZNH4": 1, "NO": 1, "O2": 0.75, "Z2Cu": 1},
          "mol_products": {"ZH": 1, "N2O": 1, "H2O": 1.5, "Z2Cu": 1},
          "rxn_orders": {"ZNH4": 1, "NO": 1, "O2": 1, "Z2Cu": 1}
        }

#  ---------- NH4NO3 Formation Reactions ------------

r21 = {"parameters": {"A": 61079678445489.3, "E": 83494.3924095186},
          "mol_reactants": {"Z1CuOH-NH3": 2, "NO2": 2},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 1, "Z1CuOH-NH4NO3": 1},
          "rxn_orders": {"Z1CuOH-NH3": 1, "NO2": 1}
        }

r22 = {"parameters": {"A": 259776678898.91, "E": 57780.7938624414},
          "mol_reactants": {"Z2Cu-NH3": 2, "NO2": 2},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 1, "Z2Cu-NH4NO3": 1},
          "rxn_orders": {"Z2Cu-NH3": 1, "NO2": 1}
        }

r23 = {"parameters": {"A": 36780633935525.6, "E": 83966.979173924},
          "mol_reactants": {"Z2Cu-(NH3)2": 2, "NO2": 2},
          "mol_products": {"Z2Cu-NH3": 1, "N2": 1, "H2O": 1, "Z2Cu-NH4NO3": 1},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "NO2": 1}
        }

r24 = {"parameters": {"A": 22180633078107.6, "E": 79233.2283994908},
          "mol_reactants": {"ZNH4": 2, "NO2": 2},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 1, "ZH-NH4NO3": 1},
          "rxn_orders": {"ZNH4": 1, "NO2": 1}
        }

#  ---------- NH4NO3 Fast SCR Reactions ------------

r25 = {"parameters": {"A": 340807778596.086, "E": 57076.4903369081},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1, "NO": 1},
          "mol_products": {"Z1CuOH": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1, "NO": 1}
        }

r26 = {"parameters": {"A": 140168884361.986, "E": 53769.7525025954},
          "mol_reactants": {"Z2Cu-NH4NO3": 1, "NO": 1},
          "mol_products": {"Z2Cu": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1, "NO": 1}
        }

r27 = {"parameters": {"A": 10195907983.8165, "E": 42011.8593378868},
          "mol_reactants": {"ZH-NH4NO3": 1, "NO": 1},
          "mol_products": {"ZH": 1, "N2": 1, "H2O": 2, "NO2": 1},
          "rxn_orders": {"ZH-NH4NO3": 1, "NO": 1}
        }

#  ---------- NH4NO3 NO2 SCR Reactions ------------

r28 = {"parameters": {"A": 2024225123.25513, "E": 58293.7932758567},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1},
          "mol_products": {"Z1CuOH-NH3": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1}
        }

r29 = {"parameters": {"A": 69152214644.0385, "E": 74567.8909428358},
          "mol_reactants": {"Z2Cu-NH4NO3": 1},
          "mol_products": {"Z2Cu-NH3": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1}
        }

r30 = {"parameters": {"A": 3361145899.93281, "E": 59909.6436388672},
          "mol_reactants": {"ZH-NH4NO3": 1},
          "mol_products": {"ZNH4": 1, "O2": 0.25, "H2O": 0.5, "NO2": 1},
          "rxn_orders": {"ZH-NH4NO3": 1}
        }

#  ---------- NH4NO3 N2O Formation Reactions ------------

r31 = {"parameters": {"A": 1278235834647.23, "E": 101177.340892},
          "mol_reactants": {"Z1CuOH-NH4NO3": 1},
          "mol_products": {"Z1CuOH": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"Z1CuOH-NH4NO3": 1}
        }

r32 = {"parameters": {"A": 134526137966.133, "E": 89774.9281706735},
          "mol_reactants": {"Z2Cu-NH4NO3": 1},
          "mol_products": {"Z2Cu": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"Z2Cu-NH4NO3": 1}
        }

r33 = {"parameters": {"A": 71249563.4633147, "E": 54523.7406235893},
          "mol_reactants": {"ZH-NH4NO3": 1},
          "mol_products": {"ZH": 1, "H2O": 2, "N2O": 1},
          "rxn_orders": {"ZH-NH4NO3": 1}
        }

#  ---------- CuO High Temp NH3 oxidation reactions ------------

r34 = {"parameters": {"A": 1.26594277811734E+029, "E": 333936.493966001},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 0.75},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "N2": 0.5},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

r35 = {"parameters": {"A": 1.20378287403003E+015, "E": 155911.730978232},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 1.25},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "NO": 1},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

r36 = {"parameters": {"A": 8932897626666786, "E": 172494.810216271},
          "mol_reactants": {"ZNH4": 1, "CuO": 1, "O2": 1},
          "mol_products": {"ZH": 1, "CuO": 1, "H2O": 1.5, "N2O": 0.5},
          "rxn_orders": {"ZNH4": 1, "CuO": 1, "O2": 1}
        }

#  ---------- N2O formation from NH3 oxidation ------------

r37 = {"parameters": {"A": 6.62238991110137E+021, "E": 288305.846299422},
          "mol_reactants": {"Z2Cu-NH3": 1, "O2": 1},
          "mol_products": {"Z2Cu": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-NH3": 1, "O2": 1}
        }

r38 = {"parameters": {"A": 1.04800621637885E+022, "E": 290624.890817422},
          "mol_reactants": {"Z2Cu-(NH3)2": 1, "O2": 1},
          "mol_products": {"Z2Cu-NH3": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"Z2Cu-(NH3)2": 1, "O2": 1}
        }

r39 = {"parameters": {"A": 3.23131379494304E+021, "E": 285451.764901793},
          "mol_reactants": {"ZNH4": 1, "O2": 1},
          "mol_products": {"ZH": 1, "N2O": 0.5, "H2O": 1.5},
          "rxn_orders": {"ZNH4": 1, "O2": 1}
        }
