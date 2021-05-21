''' Testing of building an non-isothermal model '''
import sys
sys.path.append('../..')

import unittest
import pytest
from catalyst.nonisothermal_monolith_catalysis import *

import logging

__author__ = "Austin Ladshaw"

_log = logging.getLogger(__name__)

# Start test class
class TestBasicNonisothermalCatalystBuild():
    @pytest.fixture(scope="class")
    def nonisothermal_object(self):
        obj = Nonisothermal_Monolith_Simulator()
        return obj

    @pytest.fixture(scope="class")
    def nonisothermal_object_no_rxns(self):
        obj = Nonisothermal_Monolith_Simulator()
        return obj

    @pytest.mark.build
    def test_add_dim(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        obj.add_axial_dim(0,5)
        assert hasattr(obj.model, 'z')
        assert isinstance(obj.model.z, ContinuousSet)

        obj_inert.add_axial_dim(0,5)
        assert hasattr(obj_inert.model, 'z')
        assert isinstance(obj_inert.model.z, ContinuousSet)

    @pytest.mark.build
    def test_add_temporal_dim(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        obj.add_temporal_dim(0,20)
        assert hasattr(obj.model, 't')
        assert isinstance(obj.model.t, ContinuousSet)

        obj_inert.add_temporal_dim(0,20)
        assert hasattr(obj_inert.model, 't')
        assert isinstance(obj_inert.model.t, ContinuousSet)

    @pytest.mark.build
    def test_add_age_set(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        obj.add_age_set("Unaged")
        assert hasattr(obj.model, 'age_set')
        assert isinstance(obj.model.age_set, Set)
        assert len(obj.model.age_set) == 1

        obj_inert.add_age_set("Unaged")
        assert hasattr(obj_inert.model, 'age_set')
        assert isinstance(obj_inert.model.age_set, Set)
        assert len(obj_inert.model.age_set) == 1

    @pytest.mark.build
    def test_add_temperature_set(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        obj.add_temperature_set("250C")
        assert hasattr(obj.model, 'T_set')
        assert isinstance(obj.model.T_set, Set)
        assert len(obj.model.T_set) == 1

        # new add-ons
        assert hasattr(obj.model, 'Tc')
        assert isinstance(obj.model.Tc, Var)

        assert hasattr(obj.model, 'Tw')
        assert isinstance(obj.model.Tw, Var)

        assert hasattr(obj.model, 'Ta')
        assert isinstance(obj.model.Ta, Var)

        assert hasattr(obj.model, 'dT_dt')
        assert isinstance(obj.model.dT_dt, DerivativeVar)

        assert hasattr(obj.model, 'dT_dz')
        assert isinstance(obj.model.dT_dz, DerivativeVar)

        assert hasattr(obj.model, 'dTc_dt')
        assert isinstance(obj.model.dTc_dt, DerivativeVar)

        assert hasattr(obj.model, 'dTw_dt')
        assert isinstance(obj.model.dTw_dt, DerivativeVar)

        assert hasattr(obj.model, 'd2Tc_dz2')
        assert isinstance(obj.model.d2Tc_dz2, DerivativeVar)

        assert hasattr(obj.model, 'd2Tw_dz2')
        assert isinstance(obj.model.d2Tw_dz2, DerivativeVar)

        assert hasattr(obj.model, 'cpg')
        assert isinstance(obj.model.cpg, Var)

        obj_inert.add_temperature_set("250C")
        assert hasattr(obj_inert.model, 'T_set')
        assert isinstance(obj_inert.model.T_set, Set)
        assert len(obj_inert.model.T_set) == 1

        # new add-ons
        assert hasattr(obj_inert.model, 'Tc')
        assert isinstance(obj_inert.model.Tc, Var)

        assert hasattr(obj_inert.model, 'Tw')
        assert isinstance(obj_inert.model.Tw, Var)

        assert hasattr(obj_inert.model, 'Ta')
        assert isinstance(obj_inert.model.Ta, Var)

        assert hasattr(obj_inert.model, 'dT_dt')
        assert isinstance(obj_inert.model.dT_dt, DerivativeVar)

        assert hasattr(obj_inert.model, 'dT_dz')
        assert isinstance(obj_inert.model.dT_dz, DerivativeVar)

        assert hasattr(obj_inert.model, 'dTc_dt')
        assert isinstance(obj_inert.model.dTc_dt, DerivativeVar)

        assert hasattr(obj_inert.model, 'dTw_dt')
        assert isinstance(obj_inert.model.dTw_dt, DerivativeVar)

        assert hasattr(obj_inert.model, 'd2Tc_dz2')
        assert isinstance(obj_inert.model.d2Tc_dz2, DerivativeVar)

        assert hasattr(obj_inert.model, 'd2Tw_dz2')
        assert isinstance(obj_inert.model.d2Tw_dz2, DerivativeVar)

        assert hasattr(obj_inert.model, 'cpg')
        assert isinstance(obj_inert.model.cpg, Var)

    @pytest.mark.build
    def test_add_gas_species(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        obj.add_gas_species("NH3")
        assert hasattr(obj.model, 'gas_set')
        assert isinstance(obj.model.gas_set, Set)
        assert len(obj.model.gas_set) == 1

        obj_inert.add_gas_species("N2")
        assert hasattr(obj_inert.model, 'gas_set')
        assert isinstance(obj_inert.model.gas_set, Set)
        assert len(obj_inert.model.gas_set) == 1

    @pytest.mark.build
    def test_add_surface_species(self, nonisothermal_object):
        obj = nonisothermal_object
        obj.add_surface_species("ZNH4")
        assert hasattr(obj.model, 'surf_set')
        assert isinstance(obj.model.surf_set, Set)
        assert len(obj.model.surf_set) == 1

        obj.add_surface_sites("ZH")
        assert hasattr(obj.model, 'site_set')
        assert isinstance(obj.model.site_set, Set)
        assert len(obj.model.site_set) == 1

    @pytest.mark.build
    def test_add_reactions_equ(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        rxn_dict = {"r1": ReactionType.EquilibriumArrhenius}
        obj.add_reactions(rxn_dict)
        obj_inert.add_reactions({})

        assert hasattr(obj.model, 'dHrxn')
        assert isinstance(obj.model.dHrxn, Var)
        assert hasattr(obj.model, 'd_rxn')
        assert isinstance(obj.model.d_rxn, Var)

        assert hasattr(obj_inert.model, 'dHrxn')
        assert isinstance(obj_inert.model.dHrxn, Var)
        assert hasattr(obj_inert.model, 'd_rxn')
        assert isinstance(obj_inert.model.d_rxn, Var)

        assert len(obj.model.all_rxns) == 1
        assert len(obj_inert.model.all_rxns) == 0

    @pytest.mark.unit
    def test_finish_setup_params(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        obj.set_bulk_porosity(0.3309)
        obj.set_washcoat_porosity(0.4)
        obj.set_reactor_radius(1)
        obj.set_wall_thickness(0.3)
        obj.set_space_velocity_all_runs(1000)
        obj.set_cell_density(62)

        obj_inert.set_bulk_porosity(0.3309)
        obj_inert.set_washcoat_porosity(0.4)
        obj_inert.set_reactor_radius(1)
        obj_inert.set_wall_thickness(0.3)
        obj_inert.set_space_velocity_all_runs(1000)
        obj_inert.set_cell_density(62)

        s1_data = {"mol_occupancy": {"ZNH4": 1}}
        obj.set_site_balance("ZH",s1_data)

        r1_equ = {"parameters": {"A": 250000, "E": 0,
                                "dH": -54000, "dS": 30},
                  "mol_reactants": {"ZH": 1, "NH3": 1},
                  "mol_products": {"ZNH4": 1},
                  "rxn_orders": {"ZH": 1, "NH3": 1, "ZNH4": 1}
                }
        obj.set_reaction_info("r1", r1_equ)
        obj.set_site_density("ZH","Unaged",0.1152619)
        obj.model.dHrxn["r1"].set_value(-54000)

        assert hasattr(obj.model, 'a')
        assert isinstance(obj.model.a, Param)
        assert value(obj.model.a) == 2.0/1

        assert hasattr(obj.model, 'aw')
        assert isinstance(obj.model.aw, Param)
        assert value(obj.model.aw) == 2*(1 + 0.3)/0.3**2

        assert hasattr(obj_inert.model, 'a')
        assert isinstance(obj_inert.model.a, Param)
        assert value(obj_inert.model.a) == 2.0/1

        assert hasattr(obj_inert.model, 'aw')
        assert isinstance(obj_inert.model.aw, Param)
        assert value(obj_inert.model.aw) == 2*(1 + 0.3)/0.3**2

    @pytest.mark.initialization
    def test_build_constraints(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        obj.build_constraints()
        obj_inert.build_constraints()

        assert hasattr(obj.model, 'bulk_cons')
        assert isinstance(obj.model.bulk_cons, Constraint)
        assert hasattr(obj.model, 'pore_cons')
        assert isinstance(obj.model.pore_cons, Constraint)
        assert hasattr(obj.model, 'surf_cons')
        assert isinstance(obj.model.surf_cons, Constraint)
        assert hasattr(obj.model, 'site_cons')
        assert isinstance(obj.model.site_cons, Constraint)

        assert hasattr(obj_inert.model, 'bulk_cons')
        assert isinstance(obj_inert.model.bulk_cons, Constraint)
        assert hasattr(obj_inert.model, 'pore_cons')
        assert isinstance(obj_inert.model.pore_cons, Constraint)

        assert hasattr(obj.model, 'gas_energy')
        assert isinstance(obj.model.gas_energy, Constraint)
        assert hasattr(obj.model, 'solid_energy')
        assert isinstance(obj.model.solid_energy, Constraint)
        assert hasattr(obj.model, 'wall_energy')
        assert isinstance(obj.model.wall_energy, Constraint)

        assert hasattr(obj_inert.model, 'gas_energy')
        assert isinstance(obj_inert.model.gas_energy, Constraint)
        assert hasattr(obj_inert.model, 'solid_energy')
        assert isinstance(obj_inert.model.solid_energy, Constraint)
        assert hasattr(obj_inert.model, 'wall_energy')
        assert isinstance(obj_inert.model.wall_energy, Constraint)

    @pytest.mark.initialization
    def test_discretization(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns

        obj.discretize_model(method=DiscretizationMethod.OrthogonalCollocation,
                            tstep=10,elems=5,colpoints=2)
        obj_inert.discretize_model(method=DiscretizationMethod.FiniteDifference,
                            tstep=10,elems=5,colpoints=2)

        assert hasattr(obj_inert.model, 'dTdz_edge')
        assert isinstance(obj_inert.model.dTdz_edge, Constraint)
        assert hasattr(obj_inert.model, 'd2Tcdz2_back')
        assert isinstance(obj_inert.model.d2Tcdz2_back, Constraint)
        assert hasattr(obj_inert.model, 'd2Twdz2_back')
        assert isinstance(obj_inert.model.d2Twdz2_back, Constraint)

        assert hasattr(obj.model, 'd2Tcdz2_front')
        assert isinstance(obj.model.d2Tcdz2_front, Constraint)
        assert hasattr(obj.model, 'd2Twdz2_front')
        assert isinstance(obj.model.d2Twdz2_front, Constraint)

        assert hasattr(obj_inert.model, 'd2Tcdz2_front')
        assert isinstance(obj_inert.model.d2Tcdz2_front, Constraint)
        assert hasattr(obj_inert.model, 'd2Twdz2_front')
        assert isinstance(obj_inert.model.d2Twdz2_front, Constraint)

        assert value(obj.model.d_rxn["r1",obj.model.z.first()]) == 1

    @pytest.mark.unit
    def test_set_initial_conditions(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns

        obj.set_const_temperature_IC("Unaged","250C",250+273.15)
        obj.set_const_ambient_temperature("Unaged","250C",250+273.15)

        obj.set_const_IC_in_ppm("NH3","Unaged","250C",0)
        obj.set_const_IC("ZNH4","Unaged","250C",0)

        obj_inert.set_const_temperature_IC("Unaged","250C",250+273.15)
        obj_inert.set_const_ambient_temperature("Unaged","250C",25+273.15)
        obj_inert.set_const_IC_in_ppm("N2","Unaged","250C",7900000)

        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj.model.T["Unaged","250C",
                    obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj.model.Tc["Unaged","250C",
                    obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj.model.Tw["Unaged","250C",
                    obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj.model.Ta["Unaged","250C",
                    obj.model.z.first(),obj.model.t.first()])


        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj_inert.model.T["Unaged","250C",
                    obj_inert.model.z.first(),obj_inert.model.t.first()])

        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj_inert.model.Tc["Unaged","250C",
                    obj_inert.model.z.first(),obj_inert.model.t.first()])

        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj_inert.model.Tw["Unaged","250C",
                    obj_inert.model.z.first(),obj_inert.model.t.first()])

        assert pytest.approx(298.15, rel=1e-3) == \
            value(obj_inert.model.Ta["Unaged","250C",
                    obj_inert.model.z.first(),obj_inert.model.t.first()])

    @pytest.mark.unit
    def test_set_boundary_conditions(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns

        obj.set_const_temperature_BC("Unaged","250C",250+273.15)
        obj.set_time_dependent_BC_in_ppm("NH3","Unaged","250C",
                                    time_value_pairs=[(2,300), (10,0)],
                                    initial_value=0)

        obj_inert.set_const_temperature_BC("Unaged","250C",250+273.15)
        obj_inert.set_const_BC_in_ppm("N2","Unaged","250C",7900000)

        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj.model.T["Unaged","250C",
                    obj.model.z.first(),obj.model.t.first()])
        assert pytest.approx(523.15, rel=1e-3) == \
            value(obj_inert.model.T["Unaged","250C",
                    obj_inert.model.z.first(),obj_inert.model.t.first()])

        assert pytest.approx(6.9762939977887255e-06, rel=1e-3) == \
            value(obj.model.Cb["NH3","Unaged","250C",
                    obj.model.z.first(),2.0])
        assert pytest.approx(0.1837090752751031, rel=1e-3) == \
            value(obj_inert.model.Cb["N2","Unaged","250C",
                    obj_inert.model.z.first(),2.0])

    @pytest.mark.initialization
    def test_initialize_auto_scaling(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns
        obj.initialize_auto_scaling()
        obj_inert.initialize_auto_scaling()

        assert hasattr(obj.model, 'scaling_factor')
        assert isinstance(obj.model.scaling_factor, Suffix)

        assert hasattr(obj_inert.model, 'scaling_factor')
        assert isinstance(obj_inert.model.scaling_factor, Suffix)

    @pytest.mark.solver
    def test_initialization_solve(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns

        (stat1, cond1) = obj.initialize_simulator()
        assert cond1 == TerminationCondition.optimal
        assert stat1 == SolverStatus.ok

        (stat2, cond2) = obj_inert.initialize_simulator()
        assert cond2 == TerminationCondition.optimal
        assert stat2 == SolverStatus.ok

    @pytest.mark.initialization
    def test_final_auto_scaling(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns

        obj.finalize_auto_scaling()
        obj_inert.finalize_auto_scaling()

        assert not hasattr(obj.model, 'obj')
        assert not hasattr(obj_inert.model, 'obj')

    @pytest.mark.solver
    def test_full_solve(self, nonisothermal_object, nonisothermal_object_no_rxns):
        obj = nonisothermal_object
        obj_inert = nonisothermal_object_no_rxns

        (stat1, cond1) = obj.run_solver()
        assert cond1 == TerminationCondition.optimal
        assert stat1 == SolverStatus.ok

        (stat2, cond2) = obj_inert.run_solver()
        assert cond2 == TerminationCondition.optimal
        assert stat2 == SolverStatus.ok
