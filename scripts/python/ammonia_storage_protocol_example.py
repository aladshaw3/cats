# This file is a demo for the 'Isothermal_Monolith_Simulator' object

from isothermal_monolith_catalysis import *

# Testing
test = Isothermal_Monolith_Simulator()
test.add_axial_dim(0,5)
test.add_temporal_dim(0,306)

test.add_age_set("Unaged")
test.add_temperature_set("150C")

test.add_gas_species(["NH3","H2O"])
test.add_surface_species(["q1","q2a","q2b","q3a","q3b","q3c","q4a","q4b"])
test.add_surface_sites(["S1","S2","S3a","S3b","S3c"])
test.add_reactions({"r1": ReactionType.EquilibriumArrhenius,
                    "r2a": ReactionType.EquilibriumArrhenius,
                    "r2b": ReactionType.EquilibriumArrhenius,
                    "r3a": ReactionType.EquilibriumArrhenius,
                    "r3b": ReactionType.EquilibriumArrhenius,
                    "r3c": ReactionType.EquilibriumArrhenius,
                    "r4a": ReactionType.EquilibriumArrhenius,
                    "r4b": ReactionType.EquilibriumArrhenius
                    })

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.2)
test.set_linear_velocity(7555.15)
test.set_mass_transfer_coef(1.12)
test.set_surface_to_volume_ratio(5145)

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

test.set_reaction_info("r1", r1_equ)
test.set_reaction_info("r2a", r2a_equ)
test.set_reaction_info("r2b", r2b_equ)
test.set_reaction_info("r3a", r3a_equ)
test.set_reaction_info("r3b", r3b_equ)
test.set_reaction_info("r3c", r3c_equ)
test.set_reaction_info("r4a", r4a_equ)
test.set_reaction_info("r4b", r4b_equ)

test.set_site_density("S1","Unaged",0.052619016)
test.set_site_density("S2","Unaged",0.023125746)
test.set_site_density("S3a","Unaged",0.01632)
test.set_site_density("S3b","Unaged",0.003233)
test.set_site_density("S3c","Unaged",0.006699)

test.set_isothermal_temp("Unaged","150C",150+273.15)

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=100,elems=5,colpoints=1)

# Initial conditions and Boundary Conditions should be set AFTER discretization
test.set_const_IC("NH3","Unaged","150C",0)
test.set_const_IC("H2O","Unaged","150C",0.001337966847917)

test.set_const_IC("q1","Unaged","150C",0)
test.set_const_IC("q2a","Unaged","150C",0)
test.set_const_IC("q2b","Unaged","150C",0)
test.set_const_IC("q3a","Unaged","150C",0)
test.set_const_IC("q3b","Unaged","150C",0)
test.set_const_IC("q3c","Unaged","150C",0)
test.set_const_IC("q4a","Unaged","150C",0)
test.set_const_IC("q4b","Unaged","150C",0)

test.set_const_BC("H2O","Unaged","150C",0.001337966847917)

test.set_time_dependent_BC("NH3","Unaged","150C",
                            time_value_pairs=[(2.09166667,2.88105E-05),
                                              (15.925,2.28698E-05),
                                              (24.425,1.70674E-05),
                                              (32.7583333,1.13344E-05),
                                              (42.425,5.76691E-06),
                                              (55.0916667,2.87521E-06),
                                              (77.0916667,1.43838E-06),
                                              (109.091667,7.21421E-07),
                                              (154.925,3.67254E-07),
                                              (225.425,3.81105E-09)],
                            initial_value=0)

test.set_temperature_ramp("Unaged", "150C", 225.425, 305.3, 809.5651714)

# Fix the kinetics to only run a simulation
test.fix_all_reactions()
test.initialize_simulator(console_out=True)
test.run_solver()

test.print_results_of_breakthrough(["NH3"], "Unaged", "150C", file_name="")
test.print_results_of_integral_average(["q1","q2a","q2b","q3a","q3b","q3c"],
                                        "Unaged", "150C", file_name="")
