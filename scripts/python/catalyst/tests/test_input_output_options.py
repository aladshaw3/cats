''' Testing of input and output options '''
import sys
sys.path.append('../..')

import unittest
import pytest
from catalyst.isothermal_monolith_catalysis import *

import logging

__author__ = "Austin Ladshaw"

_log = logging.getLogger(__name__)

# Start test class
class TestIsothermalCatalystInputOutputOptions():
    @pytest.fixture(scope="class")
    def isothermal_io_object(self):
        test = Isothermal_Monolith_Simulator()
        return test

    @pytest.fixture(scope="class")
    def isothermal_io_object_with_surface_data(self):
        test = Isothermal_Monolith_Simulator()
        return test

    @pytest.mark.build
    def test_add_axial_dataset(self, isothermal_io_object):
        test = isothermal_io_object

        test.add_axial_dim(0,5)
        test.add_axial_dataset([2.5,5])

        assert hasattr(test.model, 'z_data')
        assert isinstance(test.model.z_data, Set)
        assert len(test.model.z_data) == 2

    @pytest.mark.build
    def test_read_data_file_for_inputs(self, isothermal_io_object):
        test = isothermal_io_object

        data = naively_read_data_file("sample_data.txt", factor=2)

        assert len(data["time"]) == 20
        assert len(data["NH3_2.5"]) == 20
        assert len(data["NH3_5"]) == 20

        assert pytest.approx(7.5E-10, rel=1e-3) == data["NH3_2.5"][6]
        assert pytest.approx(1E-10, rel=1e-3) == data["NH3_5"][6]
        assert pytest.approx(6.75, rel=1e-3) == data["time"][6]

        assert pytest.approx(0.0000057, rel=1e-3) == data["NH3_2.5"][12]
        assert pytest.approx(0.000000006, rel=1e-3) == data["NH3_5"][12]
        assert pytest.approx(12.75, rel=1e-3) == data["time"][12]

        time_list = time_point_selector(data["time"], data)

        assert len(time_list) == 11
        assert (time_list[0]) == 0

        time_list.pop()

        test.add_temporal_dim(point_list=time_list)
        test.add_temporal_dataset(data["time"])

        assert hasattr(test.model, 't_data')
        assert isinstance(test.model.t_data, Set)
        assert len(test.model.t_data) == 18

        assert hasattr(test.model, 't_data_full')
        assert isinstance(test.model.t_data_full, Set)
        assert len(test.model.t_data_full) == 20

        test.add_age_set("Unaged")
        test.add_data_age_set("Unaged")

        assert hasattr(test.model, 'data_age_set')
        assert isinstance(test.model.data_age_set, Set)
        assert len(test.model.data_age_set) == 1

        test.add_temperature_set("250C")
        test.add_data_temperature_set("250C")

        assert hasattr(test.model, 'data_T_set')
        assert isinstance(test.model.data_T_set, Set)
        assert len(test.model.data_T_set) == 1

        test.add_gas_species(["NH3","H2O"])
        test.add_data_gas_species(["NH3"])

        assert hasattr(test.model, 'data_gas_set')
        assert isinstance(test.model.data_gas_set, Set)
        assert len(test.model.data_gas_set) == 1

        assert hasattr(test.model, 'Cb_data')
        assert isinstance(test.model.Cb_data, Param)

        assert hasattr(test.model, 'Cb_data_full')
        assert isinstance(test.model.Cb_data_full, Param)

        assert hasattr(test.model, 'w')
        assert isinstance(test.model.w, Param)

        test.set_data_values_for("NH3","Unaged","250C",2.5,data["time"],data["NH3_2.5"])
        test.set_data_values_for("NH3","Unaged","250C",5,data["time"],data["NH3_5"])

        assert (test.isDataValuesSet["NH3"][2.5]) == True
        assert (test.isDataValuesSet["NH3"][5]) == True

        assert pytest.approx(0.0000057, rel=1e-3) == test.model.Cb_data["NH3","Unaged","250C",2.5,12.75].value
        assert pytest.approx(0.000000006, rel=1e-3) == test.model.Cb_data["NH3","Unaged","250C",5,12.75].value

    @pytest.mark.build
    def test_read_data_list_for_inputs(self, isothermal_io_object_with_surface_data):
        test = isothermal_io_object_with_surface_data

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
        test.add_axial_dim(0,0.1)
        test.add_axial_dataset(0.05)

        test.add_temporal_dim(0,30)
        test.add_temporal_dataset(times)

        assert hasattr(test.model, 't_data')
        assert isinstance(test.model.t_data, Set)
        assert len(test.model.t_data) == len(times)

        assert hasattr(test.model, 't_data_full')
        assert isinstance(test.model.t_data_full, Set)
        assert len(test.model.t_data_full) == len(times)

        test.add_age_set("Unaged")
        test.add_data_age_set("Unaged")

        test.add_temperature_set("250C")
        test.add_data_temperature_set("250C")

        test.add_gas_species("NH3")
        test.add_data_gas_species("NH3")

        test.add_surface_species("q1")
        test.add_data_surface_species("q1")

        assert hasattr(test.model, 'q_data')
        assert isinstance(test.model.q_data, Param)

        assert hasattr(test.model, 'q_data_full')
        assert isinstance(test.model.q_data_full, Param)

        assert hasattr(test.model, 'wq')
        assert isinstance(test.model.wq, Param)

        test.set_data_values_for("q1","Unaged","250C",0.05,times,data)
        test.set_data_values_for("NH3","Unaged","250C",0.05,times,nh3_data)

        assert (test.isDataValuesSet["NH3"][0.05]) == True
        assert (test.isDataValuesSet["q1"][0.05]) == True

        assert pytest.approx(2.32E-06, rel=1e-3) == test.model.Cb_data["NH3","Unaged","250C",0.05,5].value
        assert pytest.approx(0.009580668, rel=1e-3) == test.model.q_data["q1","Unaged","250C",0.05,5].value

        test.add_surface_sites("S1")
        test.add_reactions({"r1": ReactionType.EquilibriumArrhenius})

        test.set_bulk_porosity(0.3309)
        test.set_washcoat_porosity(0.6)
        test.set_reactor_radius(1)
        test.set_space_velocity_all_runs(1000)
        test.set_cell_density(62)

        s1_data = {"mol_occupancy": {"q1": 1}}
        test.set_site_balance("S1",s1_data)

        r1_equ = {"parameters": {"A": 100000, "E": 0,
                                "dH": -54000, "dS": 30},
                  "mol_reactants": {"S1": 1, "NH3": 1},
                  "mol_products": {"q1": 1},
                  "rxn_orders": {"S1": 1, "NH3": 1, "q1": 1}
                }
        test.set_reaction_info("r1", r1_equ)

        test.set_site_density("S1","Unaged",0.1152619)

    @pytest.mark.build
    def test_build_mixed_objective(self, isothermal_io_object_with_surface_data):
        test = isothermal_io_object_with_surface_data

        test.build_constraints()
        test.discretize_model(method=DiscretizationMethod.OrthogonalCollocation,
                            tstep=30,elems=2,colpoints=2)

        test.set_isothermal_temp("Unaged","250C",250+273.15)

        test.set_const_IC_in_ppm("NH3","Unaged","250C",0)

        test.set_const_IC("q1","Unaged","250C",0)

        test.set_time_dependent_BC_in_ppm("NH3","Unaged","250C",
                                    time_value_pairs=[(5,300)],
                                    initial_value=0)

        assert hasattr(test.model, 'obj')
        assert isinstance(test.model.obj, Objective)

        assert pytest.approx(0.24584164283488227, rel=1e-3) == value(test.model.obj)

    @pytest.mark.solver
    def test_mixed_run_initialize(self, isothermal_io_object_with_surface_data):
        test = isothermal_io_object_with_surface_data

        test.initialize_auto_scaling()
        (stat1, cond1) = test.initialize_simulator()

        assert cond1 == TerminationCondition.optimal
        assert stat1 == SolverStatus.ok

    @pytest.mark.build
    def test_all_weight_factors(self, isothermal_io_object_with_surface_data):
        test = isothermal_io_object_with_surface_data

        test.auto_select_all_weight_factors()

        assert pytest.approx(8.440922883914233, rel=1e-3) == test.model.wq["q1","Unaged","250C", test.model.t_data.first()].value
        assert pytest.approx(137931.0344827586, rel=1e-3) == test.model.w["NH3","Unaged","250C", test.model.t_data.first()].value

    @pytest.mark.solver
    def test_mixed_run_solver(self, isothermal_io_object_with_surface_data):
        test = isothermal_io_object_with_surface_data

        test.finalize_auto_scaling()
        (stat1, cond1) = test.run_solver()

        assert cond1 == TerminationCondition.optimal
        assert stat1 == SolverStatus.ok

    @pytest.mark.build
    def test_read_data_file_for_BCs(self, isothermal_io_object):
        test = isothermal_io_object

        test.add_surface_species(["q1"])
        test.add_surface_sites(["S1"])
        test.add_reactions({"r1": ReactionType.Arrhenius})

        test.set_bulk_porosity(0.3309)
        test.set_washcoat_porosity(0.6)
        test.set_reactor_radius(1)
        test.set_space_velocity_all_runs(1000)
        test.set_cell_density(62)

        s1_data = {"mol_occupancy": {"q1": 1}}
        test.set_site_balance("S1",s1_data)

        r1 = {"parameters": {"A": 250000, "E": 0,
                            "A_lb": 25000, "A_ub": 2500000},
                  "mol_reactants": {"S1": 1, "NH3": 1},
                  "mol_products": {"q1": 1},
                  "rxn_orders": {"S1": 1, "NH3": 1}
                }
        test.set_reaction_info("r1", r1)

        test.set_site_density("S1","Unaged",0.1088)

        test.set_isothermal_temp("Unaged","250C",250+273.15)

        test.build_constraints()
        test.discretize_model(method=DiscretizationMethod.OrthogonalCollocation,
                            tstep=10,elems=10,colpoints=2)

        test.set_const_IC("H2O","Unaged","250C",0.001174)
        test.set_const_IC("NH3","Unaged","250C",0)

        test.set_const_IC("q1","Unaged","250C",0)

        test.set_const_BC("H2O","Unaged","250C",0.001174)

        #Read in data tuples to use as BCs
        data_tup = naively_read_data_file("sample_inlet_data.txt",
                                            factor=2,dict_of_tuples=True)

        test.set_time_dependent_BC("NH3","Unaged","250C",
                                    time_value_pairs=data_tup["NH3_inlet"],
                                    initial_value=0)

        assert hasattr(test.model, 'obj')
        assert isinstance(test.model.obj, Objective)

        assert pytest.approx(5.314131789092681e-10, rel=1e-3) == value(test.model.obj)

        assert len(test.model.t) == 11
        assert test.model.t[1] == 0
        assert test.model.t[2] == 1.75
        assert test.model.t[3] == 2.75
        assert test.model.t[4] == 3.75
        assert test.model.t[5] == 5.75
        assert test.model.t[6] == 7.75
        assert test.model.t[7] == 9.75
        assert test.model.t[8] == 11.75
        assert test.model.t[9] == 13.75
        assert test.model.t[10] == 15.75
        assert test.model.t[11] == 17.75

        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,1.75].value, 1e-3) == 2.25E-10
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,2.75].value, 1e-3) == 7.50E-10
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,3.75].value, 1e-3) == 3.00E-09
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,5.75].value, 1e-3) == 6.00E-08
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,7.75].value, 1e-3) == 5.90E-06
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,9.75].value, 1e-3) == 6.60E-06
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,11.75].value, 1e-3) == 6.60E-06

    @pytest.mark.solver
    def test_plot_vs_data(self, isothermal_io_object):
        test = isothermal_io_object

        test.initialize_auto_scaling()

        (stat, cond) = test.initialize_simulator()
        assert cond == TerminationCondition.optimal
        assert stat == SolverStatus.ok

        test.plot_vs_data("NH3", "Unaged", "250C", 5, display_live=False,
                            file_name="plot_v_data_end")
        test.plot_vs_data("NH3", "Unaged", "250C", 2.5, display_live=False,
                            file_name="plot_v_data_mid")

        assert path.exists("output/plot_v_data_endComparisonPlots.png") == True
        assert path.exists("output/plot_v_data_midComparisonPlots.png") == True

    @pytest.mark.unit
    def test_plot_at_locations(self, isothermal_io_object):
        test = isothermal_io_object

        test.plot_at_locations(["NH3"], ["Unaged"], ["250C"], [2.5,5], display_live=False)
        test.plot_at_locations(["q1","S1"], ["Unaged"], ["250C"], [2.5,5], display_live=False)

        assert path.exists("output/NH3_Plots.png") == True
        assert path.exists("output/q1_S1_Plots.png") == True

    @pytest.mark.unit
    def test_plot_at_times(self, isothermal_io_object):
        test = isothermal_io_object

        test.plot_at_times(["NH3"], ["Unaged"], ["250C"],
                            [0,2.75,5.75,9.75,13.75,17.75], display_live=False,
                            file_name="NH3_at_times")
        test.plot_at_times(["q1","S1"], ["Unaged"], ["250C"],
                            [0,2.75,5.75,9.75,13.75,17.75], display_live=False,
                            file_name="q1_at_times")

        assert path.exists("output/NH3_at_timesPlots.png") == True
        assert path.exists("output/q1_at_timesPlots.png") == True

    @pytest.mark.unit
    def test_custom_scaling(self, isothermal_io_object):
        test = isothermal_io_object

        test.auto_select_all_weight_factors()

        assert pytest.approx(151515.15151515152, rel=1e-3) == test.model.w["NH3","Unaged","250C", test.model.t_data.first()].value

    @pytest.mark.solver
    def test_optimization(self, isothermal_io_object):
        test = isothermal_io_object

        test.finalize_auto_scaling()

        (stat, cond) = test.run_solver()
        assert cond == TerminationCondition.optimal
        assert stat == SolverStatus.ok

        test.plot_vs_data("NH3", "Unaged", "250C", 5, display_live=False,
                            file_name="final_result_end")
        test.plot_vs_data("NH3", "Unaged", "250C", 2.5, display_live=False,
                            file_name="final_result_mid")

        assert path.exists("output/final_result_endComparisonPlots.png") == True
        assert path.exists("output/final_result_midComparisonPlots.png") == True

    @pytest.mark.unit
    def test_print_result_files(self, isothermal_io_object):
        test = isothermal_io_object

        test.print_results_all_locations(["NH3","q1","S1"], "Unaged", "250C", file_name="")
        assert path.exists("output/NH3_q1_S1_Unaged_250C_all_loc.txt") == True

        test.print_results_of_breakthrough(["NH3"], "Unaged", "250C", file_name="")
        assert path.exists("output/NH3_Unaged_250C_loc_z_at_5.txt") == True

        test.print_results_of_integral_average(["q1","S1"], "Unaged", "250C", file_name="")
        assert path.exists("output/q1_S1_Unaged_250C_integral_avg.txt") == True

    @pytest.mark.unit
    def test_print_kinetics(self, isothermal_io_object):
        test = isothermal_io_object

        test.print_kinetic_parameter_info(file_name="optimal_params.txt")
        assert path.exists("output/optimal_params.txt") == True

    @pytest.mark.unit
    def test_save_model(self, isothermal_io_object, isothermal_io_object_with_surface_data):
        test = isothermal_io_object

        test.save_model_state(file_name="sample_model.json")
        assert path.exists("output/sample_model.json") == True

        test2 = isothermal_io_object_with_surface_data

        test2.save_model_state(file_name="sample_model_with_surface.json")
        assert path.exists("output/sample_model_with_surface.json") == True

    @pytest.mark.unit
    def test_read_temperature_data(self, isothermal_io_object):
        test = isothermal_io_object

        temp_data = naively_read_data_file("sample_tempinput_data.txt",factor=1)
        assert len(temp_data["time"]) == 14
        assert "T_in" in temp_data.keys()
        assert "T_mid" in temp_data.keys()
        assert "T_out" in temp_data.keys()

        test.set_temperature_from_data("Unaged", "250C", temp_data, {"T_in": 0, "T_mid": 2.5, "T_out": 5})

        assert pytest.approx(523.15, rel=1e-3) == test.model.T["Unaged","250C",0,0].value
        assert pytest.approx(523.15, rel=1e-3) == test.model.T["Unaged","250C",1,0].value
        assert pytest.approx(523.15, rel=1e-3) == test.model.T["Unaged","250C",3,0].value
        assert pytest.approx(523.15, rel=1e-3) == test.model.T["Unaged","250C",5,0].value

        assert pytest.approx(537.15, rel=1e-3) == test.model.T["Unaged","250C",0,9.75].value
        assert pytest.approx(535.9, rel=1e-3) == test.model.T["Unaged","250C",1,9.75].value
        assert pytest.approx(533.9, rel=1e-3) == test.model.T["Unaged","250C",3,9.75].value
        assert pytest.approx(532.15, rel=1e-3) == test.model.T["Unaged","250C",5,9.75].value

        assert pytest.approx(576.9, rel=1e-3) == test.model.T["Unaged","250C",0,17.75].value
        assert pytest.approx(575.9, rel=1e-3) == test.model.T["Unaged","250C",1,17.75].value
        assert pytest.approx(573.9, rel=1e-3) == test.model.T["Unaged","250C",3,17.75].value
        assert pytest.approx(571.9, rel=1e-3) == test.model.T["Unaged","250C",5,17.75].value

    @pytest.mark.unit
    def test_load_full_model(self):
        test = Isothermal_Monolith_Simulator()
        test.load_model_full('output/sample_model.json')

        assert hasattr(test.model, 'z_data')
        assert isinstance(test.model.z_data, Set)
        assert len(test.model.z_data) == 2

        assert pytest.approx(0.0000057, rel=1e-3) == test.model.Cb_data["NH3","Unaged","250C",2.5,12.75].value
        assert pytest.approx(0.000000006, rel=1e-3) == test.model.Cb_data["NH3","Unaged","250C",5,12.75].value

        assert len(test.model.t) == 11
        assert test.model.t[1] == 0
        assert test.model.t[2] == 1.75
        assert test.model.t[3] == 2.75
        assert test.model.t[4] == 3.75
        assert test.model.t[5] == 5.75
        assert test.model.t[6] == 7.75
        assert test.model.t[7] == 9.75
        assert test.model.t[8] == 11.75
        assert test.model.t[9] == 13.75
        assert test.model.t[10] == 15.75
        assert test.model.t[11] == 17.75

        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,1.75].value, 1e-3) == 2.25E-10
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,2.75].value, 1e-3) == 7.50E-10
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,3.75].value, 1e-3) == 3.00E-09
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,5.75].value, 1e-3) == 6.00E-08
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,7.75].value, 1e-3) == 5.90E-06
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,9.75].value, 1e-3) == 6.60E-06
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,11.75].value, 1e-3) == 6.60E-06

        # Loosen tolerance because different solvers may give different results
        assert pytest.approx(test.model.A["r1"].value, 1e-1) == 2499992.910504999
        assert value(test.model.A["r1"].lb) == 25000
        assert value(test.model.A["r1"].ub) == 2500000

        assert test.isBoundarySet["NH3"]["Unaged"]["250C"] == True

        assert test.isInitialSet["q1"]["Unaged"]["250C"] == True

    @pytest.mark.unit
    def test_load_full_model_with_reset_bounds(self):
        test = Isothermal_Monolith_Simulator()
        test.load_model_full('output/sample_model.json',reset_param_bounds=True)

        assert hasattr(test.model, 'z_data')
        assert isinstance(test.model.z_data, Set)
        assert len(test.model.z_data) == 2

        assert pytest.approx(0.0000057, rel=1e-3) == test.model.Cb_data["NH3","Unaged","250C",2.5,12.75].value
        assert pytest.approx(0.000000006, rel=1e-3) == test.model.Cb_data["NH3","Unaged","250C",5,12.75].value

        assert len(test.model.t) == 11
        assert test.model.t[1] == 0
        assert test.model.t[2] == 1.75
        assert test.model.t[3] == 2.75
        assert test.model.t[4] == 3.75
        assert test.model.t[5] == 5.75
        assert test.model.t[6] == 7.75
        assert test.model.t[7] == 9.75
        assert test.model.t[8] == 11.75
        assert test.model.t[9] == 13.75
        assert test.model.t[10] == 15.75
        assert test.model.t[11] == 17.75

        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,1.75].value, 1e-3) == 2.25E-10
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,2.75].value, 1e-3) == 7.50E-10
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,3.75].value, 1e-3) == 3.00E-09
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,5.75].value, 1e-3) == 6.00E-08
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,7.75].value, 1e-3) == 5.90E-06
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,9.75].value, 1e-3) == 6.60E-06
        assert pytest.approx(test.model.Cb["NH3","Unaged","250C",0,11.75].value, 1e-3) == 6.60E-06

        # Loosen tolerance because different solvers may give different results
        assert pytest.approx(test.model.A["r1"].value, 1e-1) == 2499992.910504999
        assert pytest.approx(value(test.model.A["r1"].lb), 1e-3) == test.model.A["r1"].value*0.8
        assert pytest.approx(value(test.model.A["r1"].ub), 1e-3) == test.model.A["r1"].value*1.2

        assert test.isBoundarySet["NH3"]["Unaged"]["250C"] == True

        assert test.isInitialSet["q1"]["Unaged"]["250C"] == True

    @pytest.mark.unit
    def test_load_model_state(self):
        test = Isothermal_Monolith_Simulator()

        # NOTE: When loading a model state, you cannot load a state that doesn't exist
        #       In this case, the previous model ends at time 17.75 and because the user
        #       did not provide a 'state' arg, the method assumes to use the final state.
        #       However, 17.75 does not exist in the window from 60 to 80, thus the model
        #       cannot load.
        with pytest.raises(KeyError):
            test.load_model_state_as_IC('output/sample_model.json', new_time_window=(60,80), tstep=10)

        # NOTE: This attempt will also fail. Although the starting time window is within
        #       the original model set of states, the user has still failed to provide a
        #       'state' arg and thus this option results in a KeyError because the load
        #       function is looking for time 17.75 in the new model, which will not exist.
        test2 = Isothermal_Monolith_Simulator()
        with pytest.raises(KeyError):
            test2.load_model_state_as_IC('output/sample_model.json', new_time_window=(12,30), tstep=10)

        # To properly use this feature, it is recommended that the user provides a 'state'
        # arg when calling the function and that the time window begins at that same
        # state arg value. Alternatively, just provide the final state of the model to
        # load (i.e., 17.75 in this case) as the initial time value in the new time
        # window and the method will take care of the rest.
        test3 = Isothermal_Monolith_Simulator()
        test3.load_model_state_as_IC('output/sample_model.json', new_time_window=(17.75,27.75), tstep=10)

        assert len(test3.model.t) == 11
        assert test3.model.t[1] == 17.75
        assert test3.model.t[2] == 18.75
        assert test3.model.t[3] == 19.75
        assert test3.model.t[4] == 20.75
        assert test3.model.t[5] == 21.75
        assert test3.model.t[6] == 22.75
        assert test3.model.t[7] == 23.75
        assert test3.model.t[8] == 24.75
        assert test3.model.t[9] == 25.75
        assert test3.model.t[10] == 26.75
        assert test3.model.t[11] == 27.75

        # Check to make sure the correct values were put into correct places
        assert pytest.approx(test3.model.Cb["NH3","Unaged","250C",0,17.75].value, 1e-3) == 6.60E-06
        assert pytest.approx(test3.model.C["NH3","Unaged","250C",4.5,17.75].value, 1e-3) == 6.5459e-06
        assert pytest.approx(test3.model.q["q1","Unaged","250C",4,17.75].value, 1e-3) == 0.108787366
        assert pytest.approx(test3.model.S["S1","Unaged","250C",2,17.75].value, 1e-3) == 2.4074412829e-08

        # Now we will test loading a specific state in the middle of the json file
        #       NOTE: The 'state' arg must always match the first item in the time window
        #       ALSO NOTE: when given a list of steps, you DO NOT give 'tstep' as an arg
        test4 = Isothermal_Monolith_Simulator()
        test4.load_model_state_as_IC('output/sample_model.json', new_time_window=[7.75,8.75,9.75,10.75], state=7.75)

        assert len(test4.model.t) == 4
        assert test4.model.t[1] == 7.75
        assert test4.model.t[2] == 8.75
        assert test4.model.t[3] == 9.75
        assert test4.model.t[4] == 10.75

        assert pytest.approx(test4.model.Cb["NH3","Unaged","250C",0,7.75].value, 1e-3) == 5.90E-06
        assert pytest.approx(test4.model.C["NH3","Unaged","250C",4.5,7.75].value, 1e-3) == 5.72817e-13
        assert pytest.approx(test4.model.q["q1","Unaged","250C",4,7.75].value, 1e-3) == 1.99899912e-06
        assert pytest.approx(test4.model.S["S1","Unaged","250C",2,7.75].value, 1e-3) == 0.10655

        # Now we will test loading in another model with surface data
        test5 = Isothermal_Monolith_Simulator()

        test5.load_model_full("output/sample_model_with_surface.json", reset_param_bounds=False)
        test5.plot_vs_data("q1", "Unaged", "250C", 0.05, display_live=False,
                            file_name="surface_plot_v_data_mid")
        assert path.exists("output/surface_plot_v_data_midComparisonPlots.png") == True
        assert pytest.approx(test5.model.q["q1","Unaged","250C",0.05,9].value, 1e-3) == 0.056039725571447034

        # Test loading of a model state
        test6 = Isothermal_Monolith_Simulator()
        test6.load_model_state_as_IC('output/sample_model_with_surface.json', new_time_window=(30,40), tstep=10)

        assert hasattr(test6.model, 'q_data')
        assert isinstance(test6.model.q_data, Param)

        assert hasattr(test6.model, 'q_data_full')
        assert isinstance(test6.model.q_data_full, Param)

        assert hasattr(test6.model, 'wq')
        assert isinstance(test6.model.wq, Param)

        assert pytest.approx(8.440922883914233, rel=1e-3) == test6.model.wq["q1","Unaged","250C", test6.model.t_data.first()].value
        assert pytest.approx(137931.0344827586, rel=1e-3) == test6.model.w["NH3","Unaged","250C", test6.model.t_data.first()].value

    @pytest.mark.build
    def test_remove_select_weight_factors(self, isothermal_io_object_with_surface_data):
        test = isothermal_io_object_with_surface_data

        test.ignore_weight_factor("q1", "Unaged", "250C", time_window=(0,7))

        assert pytest.approx(0, rel=1e-3) == test.model.wq["q1","Unaged","250C", test.model.t_data.first()].value
        assert pytest.approx(0, rel=1e-3) == test.model.wq["q1","Unaged","250C", 5.0].value
        assert pytest.approx(8.440922883914233, rel=1e-3) == test.model.wq["q1","Unaged","250C", 10.0].value
        assert pytest.approx(8.440922883914233, rel=1e-3) == test.model.wq["q1","Unaged","250C", test.model.t_data.last()].value

        test.ignore_all_weight_factors(time_window=(27.5, 31))

        assert pytest.approx(0, rel=1e-3) == test.model.wq["q1","Unaged","250C", test.model.t_data.last()].value
        assert pytest.approx(0, rel=1e-3) == test.model.wq["q1","Unaged","250C", 5.0].value
        assert pytest.approx(8.440922883914233, rel=1e-3) == test.model.wq["q1","Unaged","250C", 10.0].value

        assert pytest.approx(137931.0344827586, rel=1e-3) == test.model.w["NH3","Unaged","250C", test.model.t_data.first()].value
        assert pytest.approx(0, rel=1e-3) == test.model.w["NH3","Unaged","250C", test.model.t_data.last()].value
