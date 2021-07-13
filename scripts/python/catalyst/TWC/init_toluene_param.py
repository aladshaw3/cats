# CO + 0.5 O2 --> CO2
r1 = {"parameters": {"A": 2.175036531247799e+27, "E": 212815.22529668908},
          "mol_reactants": {"CO": 1, "O2": 0.5},
          "mol_products": {},
          "rxn_orders": {"CO": 1, "O2": 1}
        }

# H2 + 0.5 O2 --> H2O
r2 = {"parameters": {"A": 56411797229.26792, "E": 40802.16380505239},
          "mol_reactants": {"H2": 1, "O2": 0.5},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "O2": 1}
        }

# CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
r3 = {"parameters": {"A": 6.317756823476671e+16, "E":  106089.98952725054},
          "mol_reactants": {"HC": 1, "O2": (x + y/4 - z/2)},
          "mol_products": {"H2O": y/2},
          "rxn_orders": {"HC": 1, "O2": 1}
        }

# CO + NO --> CO2 + 0.5 N2
r4 = {"parameters": {"A": 151365280981609.56, "E":  69754.00512703191},
          "mol_reactants": {"CO": 1, "NO": 1},
          "mol_products": {},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# CO + 2 NO --> N2O + CO2
r5 = {"parameters": {"A": 94204346969285.95, "E": 62818.61272250955},
          "mol_reactants": {"CO": 1, "NO": 2},
          "mol_products": {"N2O": 1},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

# 2.5 H2 + NO --> NH3 + H2O
r6 = {"parameters": {"A": 1.1332607140030007e+18, "E": 129811.99579289768},
          "mol_reactants": {"H2": 2.5, "NO": 1},
          "mol_products": {"NH3": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# H2 + NO --> H2O + 0.5 N2
r7 = {"parameters": {"A": 1.4608734911873062e+17, "E": 103291.08400119682},
          "mol_reactants": {"H2": 1, "NO": 1},
          "mol_products": {"H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# 2.5 CO + NO + 1.5 H2O --> NH3 + 2.5 CO2
r8 = {"parameters": {"A": 3.6648739962321007e+34, "E":  321784.272387431},
          "mol_reactants": {"CO": 2.5, "NO": 1, "H2O": 1.5},
          "mol_products": {"NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2O": 1}
        }

# CO + NO + 1.5 H2 --> NH3 + CO2
r9 = {"parameters": {"A": 2.118809420213033e+19, "E":  77692.74820144736},
          "mol_reactants": {"CO": 1, "NO": 1, "H2": 1.5},
          "mol_products": {"NH3": 1},
          "rxn_orders": {"CO": 1, "NO": 1, "H2": 1}
        }

# CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
r10 = {"parameters": {"A": 5.054337782103795e+16, "E": 212652.21990526174},
          "mol_reactants": {"HC": 1, "NO": (2*x + y/2 - z)},
          "mol_products": {"H2O": y/2},
          "rxn_orders": {"HC": 1, "NO": 1}
        }

# CO + H2O --> CO2 + H2
r11 = {"parameters": {"A": 2.5942974208237076e+18, "E": 138827.058546965},
          "mol_reactants": {"CO": 1, "H2O": 1},
          "mol_products": {"H2": 1},
          "rxn_orders": {"CO": 1, "H2O": 1}
        }

# CxHyOz + x H2O --> x CO + (x + (y/2)) H2 + (z/2) O2
r12 = {"parameters": {"A": 3.027280843131197e+16, "E":  136060.42328447563},
          "mol_reactants": {"HC": 1, "H2O": x},
          "mol_products": {"CO": x, "H2": (x + y/2), "O2": z/2},
          "rxn_orders": {"HC": 1, "H2O": 1}
        }

# N2O + CO --> N2 + CO2
r13 = {"parameters": {"A": 2.3592422261127775e+49, "E":  482799.7858379085},
          "mol_reactants": {"N2O": 1, "CO": 1},
          "mol_products": {},
          "rxn_orders": {"N2O": 1, "CO": 1}
        }

# H2 + 2 NO --> N2O + H2O
r14 = {"parameters": {"A": 540032718.0871441, "E":  22397.672290375373},
          "mol_reactants": {"H2": 1, "NO": 2},
          "mol_products": {"N2O": 1, "H2O": 1},
          "rxn_orders": {"H2": 1, "NO": 1}
        }

# N2O + CO + O2 --> 2 NO + CO2
r15 = {"parameters": {"A": 5.6361920372847455e+22, "E":  103411.21165457887},
          "mol_reactants": {"N2O": 1, "CO": 1, "O2": 1},
          "mol_products": {"NO": 2},
          "rxn_orders": {"N2O": 1, "CO": 1, "O2": 1}
        }

# CxHyOz + NO + (2x + ((y/2) - (3/2)) - z - 1) O2 --> x CO2 + ((y/2) - (3/2)) H2O + NH3
r16 = {"parameters": {"A": 5.855653403581361e+16, "E": 147516.06614174473},
          "mol_reactants": {"HC": 1, "NO": 1, "O2": (2*x + (y/2 - (3/2)) - z - 1)},
          "mol_products": {"H2O": (y/2 - (3/2)), "NH3": 1},
          "rxn_orders": {"HC": 1, "NO": 1, "O2": 1}
        }

# 2 NH3 + 1.5 O2 --> N2 + 3 H2O
r17 = {"parameters": {"A": 925261068035259.0, "E": 101892.27192457915},
          "mol_reactants": {"NH3": 2, "O2": 1.5},
          "mol_products": {"H2O": 3},
          "rxn_orders": {"NH3": 1, "O2": 1}
        }

# CxHyOz + 2 NO + (x + (y/4) - (z/2) - (1/2)) O2 --> N2O + x CO2 + (y/2) H2O
r18 = {"parameters": {"A": 5.366248921630829e+16, "E": 162946.90649225743},
          "mol_reactants": {"HC": 1, "NO": 2, "O2": (x + (y/4) - (z/2) - (1/2))},
          "mol_products": {"N2O": 1, "H2O": y/2},
          "rxn_orders": {"HC": 1, "NO": 1, "O2": 1}
        }
