# This file is a demo for the 'Isothermal_Monolith_Simulator' object
import sys
sys.path.append('../..')

from catalyst.isothermal_monolith_catalysis import *
# # TODO: Modify model save/load to accommodate new infor
# # TODO: Add unit test for adding weight factors

# Fake data for testing
times = [1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30]

data = [1.28974E-17,
        2.68312E-17,
        4.06564E-17,
        5.3727E-17,
        0.009580668,
        0.018367207,
        0.028776912,
        0.042714283,
        0.051162187,
        0.067497076,
        0.075562396,
        0.092561437,
        0.09546322,
        0.105378353,
        0.10793464,
        0.105547164,
        0.109986865,
        0.118470458,
        0.114271973,
        0.116700814,
        0.112250971,
        0.116830351,
        0.107776986,
        0.113460716,
        0.113466493,
        0.108930678,
        0.116875105,
        0.111202321,
        0.111202712,
        0.107798742]

nh3_data = [9.80E-21,
            1.00E-20,
            1.00E-20,
            1.00E-20,
            2.32E-06,
            2.52E-06,
            2.69E-06,
            3.26E-06,
            3.71E-06,
            4.19E-06,
            4.94E-06,
            5.50E-06,
            5.50E-06,
            5.89E-06,
            6.81E-06,
            6.62E-06,
            6.74E-06,
            6.60E-06,
            6.92E-06,
            7.08E-06,
            6.68E-06,
            6.76E-06,
            6.90E-06,
            6.69E-06,
            7.25E-06,
            7.18E-06,
            6.84E-06,
            6.98E-06,
            6.63E-06,
            6.84E-06]


# Testing
test = Isothermal_Monolith_Simulator()
test.add_axial_dim(0,0.1)
test.add_axial_dataset(0.05)

test.add_temporal_dim(0,30)
test.add_temporal_dataset(times)

test.add_age_set("Unaged")
test.add_data_age_set("Unaged")

test.add_temperature_set("250C")
test.add_data_temperature_set("250C")

test.add_gas_species("NH3")
test.add_data_gas_species("NH3")

test.add_surface_species("q1")
test.add_data_surface_species("q1")

test.set_data_values_for("q1","Unaged","250C",0.05,times,data)
test.set_data_values_for("NH3","Unaged","250C",0.05,times,nh3_data)

test.add_surface_sites("S1")
test.add_reactions({"r1": ReactionType.EquilibriumArrhenius})

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.6)
test.set_reactor_radius(1)                      #cm
test.set_space_velocity_all_runs(1000)          #volumes per min
test.set_cell_density(62)                       # 62 cells per cm^2 (~400 cpsi)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"q1": 1}}
test.set_site_balance("S1",s1_data)

# Reaction specification information (must correspond to correct reaction type)

#   EquilibriumArrhenius
#       NOTE: You can provide parameter bounds here, or later
r1_equ = {"parameters": {"A": 100000, "E": 0,
                        "dH": -54000, "dS": 30},
          "mol_reactants": {"S1": 1, "NH3": 1},
          "mol_products": {"q1": 1},
          "rxn_orders": {"S1": 1, "NH3": 1, "q1": 1}
        }
test.set_reaction_info("r1", r1_equ)

test.set_site_density("S1","Unaged",0.1152619)

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.OrthogonalCollocation,
                    tstep=30,elems=2,colpoints=2)

test.set_isothermal_temp("Unaged","250C",250+273.15)

# Initial conditions and Boundary Conditions should be set AFTER discretization
test.set_const_IC_in_ppm("NH3","Unaged","250C",0)

test.set_const_IC("q1","Unaged","250C",0)

test.set_time_dependent_BC_in_ppm("NH3","Unaged","250C",
                            time_value_pairs=[(5,300)],
                            initial_value=0)


test.initialize_auto_scaling()
test.initialize_simulator()

test.auto_select_all_weight_factors()

test.finalize_auto_scaling()
test.run_solver()

test.print_results_of_breakthrough(["NH3"], "Unaged", "250C",
                                    file_name="surface_fitting_breakthrough.txt")
test.print_results_of_integral_average(["q1","S1"], "Unaged", "250C",
                                    file_name="surface_fitting_integral.txt")
test.print_results_all_locations(["NH3","q1","S1"], "Unaged", "250C",
                                    file_name="surface_fitting_all.txt")

test.save_model_state(file_name="surface_example.json")

test.print_kinetic_parameter_info(file_name="surface_example_params.txt")

test.plot_vs_data("q1", "Unaged", "250C", 0.05, display_live=True)

test.plot_vs_data("NH3", "Unaged", "250C", 0.05, display_live=True)


# ------------------------------------------------------------------------------
test2 = Isothermal_Monolith_Simulator()

test2.load_model_full("output/surface_example.json", reset_param_bounds=False)

test2.plot_vs_data("q1", "Unaged", "250C", 0.05, display_live=True)
