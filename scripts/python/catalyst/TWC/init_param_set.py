# CO + 0.5 O2 --> CO2
r1 = {"parameters": {"A": 2.05E+18, "E": 110521.4141},
          "mol_reactants": {"CO": 1, "O2": 0.5},
          "mol_products": {},
          "rxn_orders": {"CO": 1, "O2": 1}
        }

# H2 + 0.5 O2 --> H2O
r2 = {"parameters": {"A": 46157501893, "E": 40443.38926},
          "mol_reactants": {"H2": 1, "O2": 0.5},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "O2": 1}
        }

# CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
r3 = {"parameters": {"A": 6.37E+17, "E":  112652.853},
          "mol_reactants": {"HC": 1, "O2": (x + y/4 - z/2)},
          "mol_products": {"H2O": y/2},
          "rxn_orders": {"HC": 1, "O2": 1}
        }

# CO + NO --> CO2 + 0.5 N2
r4 = {"parameters": {"A": 9.85111E+14, "E":  130481.2229},
          "mol_reactants": {"CO": 1, "NO": 1},
          "mol_products": {},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# CO + 2 NO --> N2O + CO2
r5 = {"parameters": {"A": 9.83667E+14, "E": 132741.1425},
          "mol_reactants": {"CO": 1, "NO": 2},
          "mol_products": {"N2O": 1},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# 2.5 H2 + NO --> NH3 + H2O
r6 = {"parameters": {"A": 2.17911E+15, "E": 77531.59042},
          "mol_reactants": {"H2": 2.5, "NO": 1},
          "mol_products": {"NH3": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# H2 + NO --> H2O + 0.5 N2
r7 = {"parameters": {"A": 2.75E+16, "E": 112920.0924},
          "mol_reactants": {"H2": 1, "NO": 1},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# 2.5 CO + NO + 1.5 H2O --> NH3 + 2.5 CO2
r8 = {"parameters": {"A": 9.98873E+14, "E":  116323.3955},
          "mol_reactants": {"CO": 2.5, "NO": 1, "H2O": 1.5},
          "mol_products": {"NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2O": 1}
        }

# CO + NO + 1.5 H2 --> NH3 + CO2
r9 = {"parameters": {"A": 1E+15, "E":  114999.6822},
          "mol_reactants": {"CO": 1, "NO": 1, "H2": 1.5},
          "mol_products": {"NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2": 1}
        }

# CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
r10 = {"parameters": {"A": 3.72E+17, "E": 110475.8891},
          "mol_reactants": {"HC": 1, "NO": (2*x + y/2 - z)},
          "mol_products": {"H2O": y/2},
          "rxn_orders": {"HC": 1, "NO": 1}
        }

# CO + H2O --> CO2 + H2
r11 = {"parameters": {"A": 2.33E+16, "E": 115968.1085},
          "mol_reactants": {"CO": 1, "H2O": 1},
          "mol_products": {"H2": 1},
          "rxn_orders": {"CO": 1, "H2O": 1}
        }

# CxHyOz + x H2O --> x CO + (x + (y/2)) H2 + (z/2) O2
r12 = {"parameters": {"A": 36753619.4, "E":  30005.30375},
          "mol_reactants": {"HC": 1, "H2O": x},
          "mol_products": {"CO": x, "H2": (x + y/2), "O2": z/2},
          "rxn_orders": {"HC": 1, "H2O": 1}
        }

# N2O + CO --> N2 + CO2
r13 = {"parameters": {"A": 2.22E+17, "E":  95838.98253},
          "mol_reactants": {"N2O": 1, "CO": 1},
          "mol_products": {},
          "rxn_orders": {"N2O": 1, "CO": 1}
        }

# H2 + 2 NO --> N2O + H2O
r14 = {"parameters": {"A": 1.17999E+11, "E":  37524.05203},
          "mol_reactants": {"H2": 1, "NO": 2},
          "mol_products": {"N2O": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# N2O + CO + O2 --> 2 NO + CO2
r15 = {"parameters": {"A": 9.99871E+14, "E":  114932.6086},
          "mol_reactants": {"N2O": 1, "CO": 1, "O2": 1},
          "mol_products": {"NO": 2},
          "rxn_orders": {"N2O": 1, "CO": 1, "O2": 1}
        }

# CxHyOz + NO + (2x + ((y/2) - (3/2)) - z - 1) O2 --> x CO2 + ((y/2) - (3/2)) H2O + NH3
r16 = {"parameters": {"A": 9.99871E+14, "E": 115105.6884},
          "mol_reactants": {"HC": 1, "NO": 1, "O2": (2*x + (y/2 - (3/2)) - z - 1)},
          "mol_products": {"H2O": (y/2 - (3/2)), "NH3": 1},
          "rxn_orders": {"HC": 1, "NO": 1, "O2": 1}
        }

# 2 NH3 + 1.5 O2 --> N2 + 3 H2O
r17 = {"parameters": {"A": 1.80668E+13, "E": 62310.78927},
          "mol_reactants": {"NH3": 2, "O2": 1.5},
          "mol_products": {"H2O": 3},
          "rxn_orders": {"NH3": 1, "O2": 1}
        }

# CxHyOz + 2 NO + (x + (y/4) - (z/2) - (1/2)) O2 --> N2O + x CO2 + (y/2) H2O
r18 = {"parameters": {"A": 9.99936E+14, "E": 115060.3755},
          "mol_reactants": {"HC": 1, "NO": 2, "O2": (x + (y/4) - (z/2) - (1/2))},
          "mol_products": {"N2O": 1, "H2O": y/2},
          "rxn_orders": {"HC": 1, "NO": 1, "O2": 1}
        }
