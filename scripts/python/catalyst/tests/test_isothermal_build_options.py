''' Testing of building an isothermal model  with various options '''
import sys
sys.path.append('../..')

import unittest
import pytest
from catalyst.isothermal_monolith_catalysis import *

import logging

__author__ = "Austin Ladshaw"

_log = logging.getLogger(__name__)

# Start test class
class TestIsothermalCatalystBuildOptions():
    @pytest.fixture(scope="class")
    def temperature_ramp(self):
        obj = Isothermal_Monolith_Simulator()
        return obj

    @pytest.fixture(scope="class")
    def stair_inputs(self):
        obj = Isothermal_Monolith_Simulator()
        return obj

    @pytest.fixture(scope="class")
    def mixed_reactions(self):
        obj = Isothermal_Monolith_Simulator()
        return obj

    @pytest.fixture(scope="class")
    def ppm_BCs_with_temp_ramp(self):
        obj = Isothermal_Monolith_Simulator()
        return obj

    @pytest.fixture(scope="class")
    def catalyst_zoning(self):
        obj = Isothermal_Monolith_Simulator()
        return obj

    @pytest.fixture(scope="class")
    def packed_bed(self):
        obj = Isothermal_Monolith_Simulator()
        return obj

    @pytest.mark.build
    def test_temperature_ramping(self, temperature_ramp):
        test = temperature_ramp
        test.add_axial_dim(0,5)
        test.add_temporal_dim(0,306)

        test.add_age_set("Unaged")
        test.add_temperature_set("150C")
        test.add_gas_species(["NH3"])

        test.set_bulk_porosity(0.3309)
        test.set_washcoat_porosity(0.4)
        test.set_reactor_radius(1)
        test.set_space_velocity_all_runs(500)
        test.set_cell_density(62)

        test.add_reactions({})

        # NOTE: Still need to establish baseline temperature
        #           Can be done AFTER calling discretizer
        test.set_isothermal_temp("Unaged","150C",150+273.15)

        test.build_constraints()
        test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                            tstep=100,elems=5,colpoints=2)

        test.set_const_IC("NH3","Unaged","150C",0)
        test.set_const_BC("NH3","Unaged","150C",0.001)

        test.set_temperature_ramp("Unaged", "150C", 225.425, 305.3, 809.5651714)

        assert pytest.approx(423.15, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.first(), 223.38])

        assert pytest.approx(531.6848903957308, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.first(), 247.86])

        assert pytest.approx(664.9164875206884, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.first(), 275.4])

        assert pytest.approx(738.9340414789983, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.first(), 290.7])

        assert pytest.approx(809.5651714, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.first(), 306])


        assert pytest.approx(423.15, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.last(), 223.38])

        assert pytest.approx(531.6848903957308, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.last(), 247.86])

        assert pytest.approx(664.9164875206884, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.last(), 275.4])

        assert pytest.approx(738.9340414789983, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.last(), 290.7])

        assert pytest.approx(809.5651714, rel=1e-3) == \
            value(test.model.T["Unaged","150C", test.model.z.last(), 306])

    @pytest.mark.build
    def test_stair_inputs(self, stair_inputs):
        test = stair_inputs
        test.add_axial_dim(0,5)
        test.add_temporal_dim(0,306)

        test.add_age_set("Unaged")
        test.add_temperature_set("150C")
        test.add_gas_species(["NH3"])

        test.set_bulk_porosity(0.3309)
        test.set_washcoat_porosity(0.4)
        test.set_reactor_radius(1)
        test.set_space_velocity_all_runs(500)
        test.set_cell_density(62)

        test.add_reactions({})

        # NOTE: Still need to establish baseline temperature
        test.set_isothermal_temp("Unaged","150C",150+273.15)

        test.build_constraints()
        test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                            tstep=100,elems=5,colpoints=2)

        test.set_const_IC("NH3","Unaged","150C",0)

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

        assert pytest.approx(1e-20, rel=1e-3) == \
            value(test.model.Cb["NH3","Unaged","150C", test.model.z.first(), 0])

        assert pytest.approx(2.88105E-05, rel=1e-3) == \
            value(test.model.Cb["NH3","Unaged","150C", test.model.z.first(), 3.06])

        assert pytest.approx(1.70674E-05, rel=1e-3) == \
            value(test.model.Cb["NH3","Unaged","150C", test.model.z.first(), 24.48])

        assert pytest.approx(1.13344E-05, rel=1e-3) == \
            value(test.model.Cb["NH3","Unaged","150C", test.model.z.first(), 33.66])

        assert pytest.approx(5.76691E-06, rel=1e-3) == \
            value(test.model.Cb["NH3","Unaged","150C", test.model.z.first(), 42.84])

        assert pytest.approx(2.87521E-06, rel=1e-3) == \
            value(test.model.Cb["NH3","Unaged","150C", test.model.z.first(), 67.32])

        assert pytest.approx(3.67254E-07, rel=1e-3) == \
            value(test.model.Cb["NH3","Unaged","150C", test.model.z.first(), 201.96])

    @pytest.mark.build
    def test_mixing_reactions(self, mixed_reactions):
        test = mixed_reactions
        test.add_axial_dim(0,5)
        test.add_temporal_dim(0,10)

        test.add_age_set("Unaged")
        test.add_temperature_set("150C")
        test.add_gas_species(["A","B","C"])
        test.add_surface_species(["x","y","z"])
        test.add_surface_sites(["i","j","k"])

        test.add_reactions({"r1": ReactionType.EquilibriumArrhenius,
                            "r2": ReactionType.Arrhenius,

                            "r3": ReactionType.EquilibriumArrhenius,
                            "r4": ReactionType.Arrhenius,

                            "r5": ReactionType.EquilibriumArrhenius,
                            "r6": ReactionType.Arrhenius
                            })

        assert hasattr(test.model, 'all_rxns')
        assert isinstance(test.model.all_rxns, Set)
        assert len(test.model.all_rxns) == 6

        assert hasattr(test.model, 'arrhenius_rxns')
        assert isinstance(test.model.arrhenius_rxns, Set)
        assert len(test.model.arrhenius_rxns) == 3

        assert hasattr(test.model, 'equ_arrhenius_rxns')
        assert isinstance(test.model.equ_arrhenius_rxns, Set)
        assert len(test.model.equ_arrhenius_rxns) == 3

        s1_data = {"mol_occupancy": {"x": 1, "y": 2}}
        # NOTE: line below is not an accurate way to model site balances,
        #       the A and j species will be ignored because they are not
        #       members of the 'surface_species' set
        s2_data = {"mol_occupancy": {"x": 1, "A": 1, "j": 1}}
        s3a_data = {"mol_occupancy": {"z": 1}}

        test.set_site_balance("i",s1_data)
        test.set_site_balance("j",s2_data)
        test.set_site_balance("k",s3a_data)

        assert pytest.approx(1, rel=1e-3) == value(test.model.u_S["i","x"])
        assert pytest.approx(2, rel=1e-3) == value(test.model.u_S["i","y"])
        assert pytest.approx(0, rel=1e-3) == value(test.model.u_S["i","z"])

        assert pytest.approx(1, rel=1e-3) == value(test.model.u_S["j","x"])
        assert pytest.approx(0, rel=1e-3) == value(test.model.u_S["j","y"])
        assert pytest.approx(0, rel=1e-3) == value(test.model.u_S["j","z"])

        assert pytest.approx(0, rel=1e-3) == value(test.model.u_S["k","x"])
        assert pytest.approx(0, rel=1e-3) == value(test.model.u_S["k","y"])
        assert pytest.approx(1, rel=1e-3) == value(test.model.u_S["k","z"])

        r1_equ = {"parameters": {"A": 250000, "E": 0, "dH": -55373.27775, "dS": -9.890904876},
                  "mol_reactants": {"A": 1, "B": 1},
                  "mol_products": {"C": 1},
                  "rxn_orders": {"A": 1, "B": 1, "C": 1}
                }
        test.set_reaction_info("r1", r1_equ)

        assert value(test.model.u_C["A","r1",test.model.z.first()]) == -1
        assert value(test.model.u_C["B","r1",test.model.z.first()]) == -1
        assert value(test.model.u_C["C","r1",test.model.z.first()]) == 1

        assert value(test.model.rxn_orders["r1","A"]) == 1
        assert value(test.model.rxn_orders["r1","B"]) == 1
        assert value(test.model.rxn_orders["r1","C"]) == 1

        r2_arr = {"parameters": {"A": 250000, "E": 0},
                  "mol_reactants": {"A": 1, "x": 1},
                  "mol_products": {"i": 1},
                  "rxn_orders": {"A": 2, "x": 1}
                }
        test.set_reaction_info("r2", r2_arr)

        assert value(test.model.u_C["A","r2",test.model.z.first()]) == -1
        assert value(test.model.u_q["x","r2",test.model.z.first()]) == -1

        assert value(test.model.rxn_orders["r2","A"]) == 2
        assert value(test.model.rxn_orders["r2","x"]) == 1

        r3_equ = {"parameters": {"A": 250000, "E": 0, "dH": -55373.27775, "dS": -9.890904876},
                  "mol_reactants": {"i": 1, "j": 1},
                  "mol_products": {"z": 2},
                  "rxn_orders": {"i": 1, "j": 0, "z": 2}
                }
        test.set_reaction_info("r3", r3_equ)

        assert value(test.model.u_q["z","r3",test.model.z.first()]) == 2

        assert value(test.model.rxn_orders["r3","i"]) == 1
        assert value(test.model.rxn_orders["r3","j"]) == 0
        assert value(test.model.rxn_orders["r3","z"]) == 2

        r4_arr = {"parameters": {"A": 250000, "E": 0},
                  "mol_reactants": {"A": 1, "x": 1},
                  "mol_products": {"i": 1},
                  "rxn_orders": {"A": 2, "x": 1},
                  "override_molar_contribution": {"A": -2, "x": 1}
                }
        test.set_reaction_info("r4", r4_arr)

        assert value(test.model.u_C["A","r4",test.model.z.first()]) == -2
        assert value(test.model.u_q["x","r4",test.model.z.first()]) == 1

        assert value(test.model.rxn_orders["r4","A"]) == 2
        assert value(test.model.rxn_orders["r4","x"]) == 1

    @pytest.mark.build
    def test_ppm_BCs_with_ramp(self, ppm_BCs_with_temp_ramp):
        test = ppm_BCs_with_temp_ramp
        test.add_axial_dim(0,5)
        test.add_temporal_dim(0,82)

        test.add_age_set("A0")
        test.add_temperature_set("T0")
        test.add_gas_species(["CO","O2","NO","CO2","N2"])

        test.add_reactions({"r1": ReactionType.Arrhenius,
                            "r4": ReactionType.Arrhenius})

        test.set_bulk_porosity(0.3309)
        test.set_washcoat_porosity(0.4)
        test.set_reactor_radius(1)
        test.set_space_velocity_all_runs(500)
        test.set_cell_density(62)

        r1 = {"parameters": {"A": 3.002796E19, "E": 205901.5765},
                  "mol_reactants": {"CO": 1, "O2": 0.5},
                  "mol_products": {"CO2": 1},
                  "rxn_orders": {"CO": 1, "O2": 1},
                }

        r4 = {"parameters": {"A": 108.975, "E": 28675.21769},
                  "mol_reactants": {"CO": 1, "NO": 1},
                  "mol_products": {"CO2": 1, "N2": 0.5},
                  "rxn_orders": {"CO": 1, "NO": 1}
                }

        test.set_reaction_info("r1", r1)
        test.set_reaction_info("r4", r4)

        test.build_constraints()
        test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                            tstep=10,elems=5,colpoints=2)

        test.set_isothermal_temp("A0","T0",393.15)
        test.set_temperature_ramp("A0", "T0", 2, 86, 813.15)

        test.set_const_IC_in_ppm("CO","A0","T0",5084)
        test.set_const_IC_in_ppm("O2","A0","T0",7080)
        test.set_const_IC_in_ppm("NO","A0","T0",1055)
        test.set_const_IC_in_ppm("N2","A0","T0",0)
        test.set_const_IC_in_ppm("CO2","A0","T0",0)

        test.set_const_BC_in_ppm("CO","A0","T0",5084)
        test.set_const_BC_in_ppm("O2","A0","T0",7080)
        test.set_const_BC_in_ppm("NO","A0","T0",1055)
        test.set_const_BC_in_ppm("N2","A0","T0",0)
        test.set_const_BC_in_ppm("CO2","A0","T0",0)

        test.recalculate_linear_velocities() #Manually called for testing

        assert pytest.approx(0.00015731749098250102, rel=1e-3) == \
            value(test.model.Cb["CO","A0","T0", test.model.z.first(), test.model.t.first()])

        assert pytest.approx(7.79794132002399e-05, rel=1e-3) == \
            value(test.model.Cb["CO","A0","T0", test.model.z.first(), test.model.t.last()])

        assert pytest.approx(3.264554543401625e-05, rel=1e-3) == \
            value(test.model.Cb["NO","A0","T0", test.model.z.first(), test.model.t.first()])

        assert pytest.approx(1.6181801913110364e-05, rel=1e-3) == \
            value(test.model.Cb["NO","A0","T0", test.model.z.first(), test.model.t.last()])

        assert pytest.approx(7005.664099711817, rel=1e-3) == \
            value(test.model.v["A0","T0", test.model.t.first()])

        assert pytest.approx(14133.390514272996, rel=1e-3) == \
            value(test.model.v["A0","T0", test.model.t.last()])


        # NOTE: When doing a temperature ramp at a constant inlet ppm, the values of
        #       velocity and concentration in mol/L should vary with the temperature
        #       according to ideal gas law. However, the product of these two values
        #       should be approximately equal to ensure the total mass flow does not
        #       change during the temperature ramp.
        assert pytest.approx(value(test.model.v["A0","T0", test.model.t.first()]) * \
            value(test.model.Cb["NO","A0","T0", test.model.z.first(), test.model.t.first()]), rel=1e-3) == \
            value(test.model.v["A0","T0", test.model.t.last()]) * \
            value(test.model.Cb["NO","A0","T0", test.model.z.first(), test.model.t.last()])

        assert pytest.approx(value(test.model.v["A0","T0", test.model.t.first()]) * \
            value(test.model.Cb["CO","A0","T0", test.model.z.first(), test.model.t.first()]), rel=1e-3) == \
            value(test.model.v["A0","T0", test.model.t.last()]) * \
            value(test.model.Cb["CO","A0","T0", test.model.z.first(), test.model.t.last()])

    @pytest.mark.build
    def test_catalyst_zones(self, catalyst_zoning):
        test = catalyst_zoning
        test.add_axial_dim(0,5)
        test.add_temporal_dim(0,82)

        test.add_age_set("A0")
        test.add_temperature_set("T0")
        test.add_gas_species(["CO","O2","NO","CO2","N2"])

        test.add_reactions({"r1": ReactionType.Arrhenius,
                            "r4": ReactionType.Arrhenius})

        test.set_bulk_porosity(0.3309)
        test.set_washcoat_porosity(0.4)
        test.set_reactor_radius(1)
        test.set_space_velocity_all_runs(500)
        test.set_cell_density(62)

        r1 = {"parameters": {"A": 3.002796E19, "E": 205901.5765},
                  "mol_reactants": {"CO": 1, "O2": 0.5},
                  "mol_products": {"CO2": 1},
                  "rxn_orders": {"CO": 1, "O2": 1},
                }

        r4 = {"parameters": {"A": 108.975, "E": 28675.21769},
                  "mol_reactants": {"CO": 1, "NO": 1},
                  "mol_products": {"CO2": 1, "N2": 0.5},
                  "rxn_orders": {"CO": 1, "NO": 1}
                }

        test.set_reaction_info("r1", r1)
        test.set_reaction_info("r4", r4)

        test.build_constraints()
        test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                            tstep=10,elems=10,colpoints=2)

        test.set_isothermal_temp("A0","T0",393.15)
        test.set_temperature_ramp("A0", "T0", 2, 86, 813.15)

        test.set_const_IC_in_ppm("CO","A0","T0",5084)
        test.set_const_IC_in_ppm("O2","A0","T0",7080)
        test.set_const_IC_in_ppm("NO","A0","T0",1055)
        test.set_const_IC_in_ppm("N2","A0","T0",0)
        test.set_const_IC_in_ppm("CO2","A0","T0",0)

        test.set_const_BC_in_ppm("CO","A0","T0",5084)
        test.set_const_BC_in_ppm("O2","A0","T0",7080)
        test.set_const_BC_in_ppm("NO","A0","T0",1055)
        test.set_const_BC_in_ppm("N2","A0","T0",0)
        test.set_const_BC_in_ppm("CO2","A0","T0",0)

        # Specify a reaction zone
        #   Zone is specified as a tuple: (start_zone, end_zone)
        test.set_reaction_zone("r4", (2.5, 5))
        #   NOTE: If you have multiple zones where a reaction may be active, then
        #           you should use the function below to specify sets of zones where
        #           the reaction is NOT active. This is because only the 'NOT' version
        #           of this function is additive (whereas the standard function would
        #           override susequent zoning information)
        test.set_reaction_zone("r1", (0, 1.5), isNotActive=True)
        test.set_reaction_zone("r1", (3, 4), isNotActive=True)

        # Result: r4 will occur in 1 zone (2.5, 5)
        #         r1 will occur in 2 zones (1.5, 3) & (4, 5)
        #
        #         NOTE: Zones listed are "inclusive" for each bound
        #
        #               Full length (0, 5)
        #
        # model.z = Set ( [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5] )
        assert value(test.model.u_C["CO","r1",0]) == 0
        assert value(test.model.u_C["O2","r1",0]) == 0
        assert value(test.model.u_C["CO2","r1",0]) == 0

        assert value(test.model.u_C["CO","r1",0.5]) == 0
        assert value(test.model.u_C["O2","r1",0.5]) == 0
        assert value(test.model.u_C["CO2","r1",0.5]) == 0

        assert value(test.model.u_C["CO","r1",1.0]) == 0
        assert value(test.model.u_C["O2","r1",1.0]) == 0
        assert value(test.model.u_C["CO2","r1",1.0]) == 0

        assert value(test.model.u_C["CO","r1",1.5]) == 0
        assert value(test.model.u_C["O2","r1",1.5]) == 0
        assert value(test.model.u_C["CO2","r1",1.5]) == 0

        assert value(test.model.u_C["CO","r1",2.0]) == -1
        assert value(test.model.u_C["O2","r1",2.0]) == -0.5
        assert value(test.model.u_C["CO2","r1",2.0]) == 1

        assert value(test.model.u_C["CO","r1",2.5]) == -1
        assert value(test.model.u_C["O2","r1",2.5]) == -0.5
        assert value(test.model.u_C["CO2","r1",2.5]) == 1

        assert value(test.model.u_C["CO","r1",3.0]) == 0
        assert value(test.model.u_C["O2","r1",3.0]) == 0
        assert value(test.model.u_C["CO2","r1",3.0]) == 0

        assert value(test.model.u_C["CO","r1",3.5]) == 0
        assert value(test.model.u_C["O2","r1",3.5]) == 0
        assert value(test.model.u_C["CO2","r1",3.5]) == 0

        assert value(test.model.u_C["CO","r1",4.0]) == 0
        assert value(test.model.u_C["O2","r1",4.0]) == 0
        assert value(test.model.u_C["CO2","r1",4.0]) == 0

        assert value(test.model.u_C["CO","r1",4.5]) == -1
        assert value(test.model.u_C["O2","r1",4.5]) == -0.5
        assert value(test.model.u_C["CO2","r1",4.5]) == 1

        assert value(test.model.u_C["CO","r1",5.0]) == -1
        assert value(test.model.u_C["O2","r1",5.0]) == -0.5
        assert value(test.model.u_C["CO2","r1",5.0]) == 1


        assert value(test.model.u_C["CO","r4",0]) == 0
        assert value(test.model.u_C["NO","r4",0]) == 0
        assert value(test.model.u_C["CO2","r4",0]) == 0
        assert value(test.model.u_C["N2","r4",0]) == 0

        assert value(test.model.u_C["CO","r4",0.5]) == 0
        assert value(test.model.u_C["NO","r4",0.5]) == 0
        assert value(test.model.u_C["CO2","r4",0.5]) == 0
        assert value(test.model.u_C["N2","r4",0.5]) == 0

        assert value(test.model.u_C["CO","r4",1.0]) == 0
        assert value(test.model.u_C["NO","r4",1.0]) == 0
        assert value(test.model.u_C["CO2","r4",1.0]) == 0
        assert value(test.model.u_C["N2","r4",1.0]) == 0

        assert value(test.model.u_C["CO","r4",1.5]) == 0
        assert value(test.model.u_C["NO","r4",1.5]) == 0
        assert value(test.model.u_C["CO2","r4",1.5]) == 0
        assert value(test.model.u_C["N2","r4",1.5]) == 0

        assert value(test.model.u_C["CO","r4",2.0]) == 0
        assert value(test.model.u_C["NO","r4",2.0]) == 0
        assert value(test.model.u_C["CO2","r4",2.0]) == 0
        assert value(test.model.u_C["N2","r4",2.0]) == 0

        assert value(test.model.u_C["CO","r4",2.5]) == -1
        assert value(test.model.u_C["NO","r4",2.5]) == -1
        assert value(test.model.u_C["CO2","r4",2.5]) == 1
        assert value(test.model.u_C["N2","r4",2.5]) == 0.5

        assert value(test.model.u_C["CO","r4",3.0]) == -1
        assert value(test.model.u_C["NO","r4",3.0]) == -1
        assert value(test.model.u_C["CO2","r4",3.0]) == 1
        assert value(test.model.u_C["N2","r4",3.0]) == 0.5

        assert value(test.model.u_C["CO","r4",3.5]) == -1
        assert value(test.model.u_C["NO","r4",3.5]) == -1
        assert value(test.model.u_C["CO2","r4",3.5]) == 1
        assert value(test.model.u_C["N2","r4",3.5]) == 0.5

        assert value(test.model.u_C["CO","r4",4.0]) == -1
        assert value(test.model.u_C["NO","r4",4.0]) == -1
        assert value(test.model.u_C["CO2","r4",4.0]) == 1
        assert value(test.model.u_C["N2","r4",4.0]) == 0.5

        assert value(test.model.u_C["CO","r4",4.5]) == -1
        assert value(test.model.u_C["NO","r4",4.5]) == -1
        assert value(test.model.u_C["CO2","r4",4.5]) == 1
        assert value(test.model.u_C["N2","r4",4.5]) == 0.5

        assert value(test.model.u_C["CO","r4",5.0]) == -1
        assert value(test.model.u_C["NO","r4",5.0]) == -1
        assert value(test.model.u_C["CO2","r4",5.0]) == 1
        assert value(test.model.u_C["N2","r4",5.0]) == 0.5


    @pytest.mark.build
    def test_packed_bed(self, packed_bed):
        test = packed_bed
        test.add_axial_dim(0,5)
        test.add_temporal_dim(0,10)

        test.add_age_set("Unaged")
        test.add_temperature_set("150C")
        test.add_gas_species(["NH3"])

        test.set_bulk_porosity(0.3309)
        test.set_washcoat_porosity(0.4)
        test.set_reactor_radius(1)
        test.set_space_velocity_all_runs(500)

        # Intead of calling 'set_cell_density()',
        #   you call 'set_packed_bed_particle_diameter()'
        test.set_packed_bed_particle_diameter(0.07)

        assert test.isMonolith == False
        assert value(test.model.dh) == 0.07
        assert value(test.model.Ga) == 6/0.07

        test.add_reactions({})

        test.set_isothermal_temp("Unaged","150C",298.15)

        test.build_constraints()
        test.discretize_model(method=DiscretizationMethod.OrthogonalCollocation,
                            tstep=10,elems=5,colpoints=2)

        assert pytest.approx(4.577827237450853, rel=1e-3) == \
            value(test.model.Sh["NH3","Unaged","150C",test.model.t.first()])

        assert pytest.approx(431.02267281890863, rel=1e-3) == \
            value(test.model.km["NH3","Unaged","150C",test.model.z.first(),test.model.t.first()])
