''' Testing of building an isothermal model '''
import sys
sys.path.append('../..')

import unittest
import pytest
from catalyst.isothermal_monolith_catalysis import *

import logging

__author__ = "Austin Ladshaw"

_log = logging.getLogger(__name__)

# Start test class
class TestBasicIsothermalCatalystBuild():
    @pytest.fixture(scope="class")
    def isothermal_object(self):
        obj = Isothermal_Monolith_Simulator()
        return obj

    @pytest.fixture(scope="class")
    def isothermal_object_with_lists(self):
        obj = Isothermal_Monolith_Simulator()
        return obj

    @pytest.mark.build
    def test_add_dim(self, isothermal_object):
        obj = isothermal_object
        obj.add_axial_dim(0,5)
        assert hasattr(obj.model, 'z')
        assert isinstance(obj.model.z, ContinuousSet)

    @pytest.mark.build
    def test_add_dim_list(self, isothermal_object_with_lists):
        obj = isothermal_object_with_lists
        obj.add_axial_dim(point_list=[0,1,2,3,4,5])
        assert hasattr(obj.model, 'z')
        assert isinstance(obj.model.z, ContinuousSet)
        assert len(obj.model.z) == 6

    @pytest.mark.build
    def test_add_temporal_dim(self, isothermal_object):
        obj = isothermal_object
        obj.add_temporal_dim(0,20)
        assert hasattr(obj.model, 't')
        assert isinstance(obj.model.t, ContinuousSet)

    @pytest.mark.build
    def test_add_temporal_dim_list(self, isothermal_object_with_lists):
        obj = isothermal_object_with_lists
        obj.add_temporal_dim(point_list=[0,4,8,12,16,20])
        assert hasattr(obj.model, 't')
        assert isinstance(obj.model.t, ContinuousSet)
        assert len(obj.model.t) == 6

    @pytest.mark.build
    def test_add_age_set(self, isothermal_object):
        obj = isothermal_object
        obj.add_age_set("Unaged")
        assert hasattr(obj.model, 'age_set')
        assert isinstance(obj.model.age_set, Set)
        assert len(obj.model.age_set) == 1

    @pytest.mark.build
    def test_add_age_set_list(self, isothermal_object_with_lists):
        obj = isothermal_object_with_lists
        obj.add_age_set(["Unaged", "2hr"])
        assert hasattr(obj.model, 'age_set')
        assert isinstance(obj.model.age_set, Set)
        assert len(obj.model.age_set) == 2

    @pytest.mark.build
    def test_add_temperature_set(self, isothermal_object):
        obj = isothermal_object
        obj.add_temperature_set("250C")
        assert hasattr(obj.model, 'T_set')
        assert isinstance(obj.model.T_set, Set)
        assert len(obj.model.T_set) == 1

        assert hasattr(obj.model, 'T')
        assert isinstance(obj.model.T, Var)

        assert hasattr(obj.model, 'space_velocity')
        assert isinstance(obj.model.space_velocity, Var)

        assert hasattr(obj.model, 'v')
        assert isinstance(obj.model.v, Var)

        assert hasattr(obj.model, 'P')
        assert isinstance(obj.model.P, Var)

        assert hasattr(obj.model, 'Tref')
        assert isinstance(obj.model.Tref, Param)

        assert hasattr(obj.model, 'Pref')
        assert isinstance(obj.model.Pref, Param)

        assert hasattr(obj.model, 'rho')
        assert isinstance(obj.model.rho, Var)

        assert hasattr(obj.model, 'mu')
        assert isinstance(obj.model.mu, Var)

        assert hasattr(obj.model, 'Re')
        assert isinstance(obj.model.Re, Var)

    @pytest.mark.build
    def test_add_temperature_set_list(self, isothermal_object_with_lists):
        obj = isothermal_object_with_lists
        obj.add_temperature_set(["250C","300C"])
        assert hasattr(obj.model, 'T_set')
        assert isinstance(obj.model.T_set, Set)
        assert len(obj.model.T_set) == 2

        assert hasattr(obj.model, 'T')
        assert isinstance(obj.model.T, Var)

        assert hasattr(obj.model, 'space_velocity')
        assert isinstance(obj.model.space_velocity, Var)

        assert hasattr(obj.model, 'v')
        assert isinstance(obj.model.v, Var)

        assert hasattr(obj.model, 'P')
        assert isinstance(obj.model.P, Var)

        assert hasattr(obj.model, 'Tref')
        assert isinstance(obj.model.Tref, Param)

        assert hasattr(obj.model, 'Pref')
        assert isinstance(obj.model.Pref, Param)

        assert hasattr(obj.model, 'rho')
        assert isinstance(obj.model.rho, Var)

        assert hasattr(obj.model, 'mu')
        assert isinstance(obj.model.mu, Var)

        assert hasattr(obj.model, 'Re')
        assert isinstance(obj.model.Re, Var)

    @pytest.mark.build
    def test_add_gas_species(self, isothermal_object):
        obj = isothermal_object
        obj.add_gas_species("NH3")
        assert hasattr(obj.model, 'gas_set')
        assert isinstance(obj.model.gas_set, Set)
        assert len(obj.model.gas_set) == 1

        assert hasattr(obj.model, 'Cb')
        assert isinstance(obj.model.Cb, Var)

        assert hasattr(obj.model, 'C')
        assert isinstance(obj.model.C, Var)

        assert hasattr(obj.model, 'dCb_dz')
        assert isinstance(obj.model.dCb_dz, DerivativeVar)

        assert hasattr(obj.model, 'dCb_dt')
        assert isinstance(obj.model.dCb_dt, DerivativeVar)

        assert hasattr(obj.model, 'dC_dt')
        assert isinstance(obj.model.dC_dt, DerivativeVar)

        assert hasattr(obj.model, 'km')
        assert isinstance(obj.model.km, Var)

        assert hasattr(obj.model, 'Dm')
        assert isinstance(obj.model.Dm, Param)

        assert hasattr(obj.model, 'Sc')
        assert isinstance(obj.model.Sc, Var)

        assert hasattr(obj.model, 'Sh')
        assert isinstance(obj.model.Sh, Var)

    @pytest.mark.build
    def test_add_gas_species_list(self, isothermal_object_with_lists):
        obj = isothermal_object_with_lists
        obj.add_gas_species(["NH3","NO"])
        assert hasattr(obj.model, 'gas_set')
        assert isinstance(obj.model.gas_set, Set)
        assert len(obj.model.gas_set) == 2

        assert hasattr(obj.model, 'Cb')
        assert isinstance(obj.model.Cb, Var)

        assert hasattr(obj.model, 'C')
        assert isinstance(obj.model.C, Var)

        assert hasattr(obj.model, 'dCb_dz')
        assert isinstance(obj.model.dCb_dz, DerivativeVar)

        assert hasattr(obj.model, 'dCb_dt')
        assert isinstance(obj.model.dCb_dt, DerivativeVar)

        assert hasattr(obj.model, 'dC_dt')
        assert isinstance(obj.model.dC_dt, DerivativeVar)

        assert hasattr(obj.model, 'km')
        assert isinstance(obj.model.km, Var)

        assert hasattr(obj.model, 'Dm')
        assert isinstance(obj.model.Dm, Param)

        assert hasattr(obj.model, 'Sc')
        assert isinstance(obj.model.Sc, Var)

        assert hasattr(obj.model, 'Sh')
        assert isinstance(obj.model.Sh, Var)

    @pytest.mark.build
    def test_add_surface_species(self, isothermal_object):
        obj = isothermal_object
        obj.add_surface_species("ZNH4")
        assert hasattr(obj.model, 'surf_set')
        assert isinstance(obj.model.surf_set, Set)
        assert len(obj.model.surf_set) == 1

        assert hasattr(obj.model, 'q')
        assert isinstance(obj.model.q, Var)

        assert hasattr(obj.model, 'dq_dt')
        assert isinstance(obj.model.dq_dt, DerivativeVar)

    @pytest.mark.build
    def test_add_surface_species_list(self, isothermal_object_with_lists):
        obj = isothermal_object_with_lists
        obj.add_surface_species(["ZNH4","ZH"])
        assert hasattr(obj.model, 'surf_set')
        assert isinstance(obj.model.surf_set, Set)
        assert len(obj.model.surf_set) == 2

        assert hasattr(obj.model, 'q')
        assert isinstance(obj.model.q, Var)

        assert hasattr(obj.model, 'dq_dt')
        assert isinstance(obj.model.dq_dt, DerivativeVar)

    @pytest.mark.build
    def test_add_surface_sites(self, isothermal_object):
        obj = isothermal_object
        obj.add_surface_sites("ZH")
        assert hasattr(obj.model, 'site_set')
        assert isinstance(obj.model.site_set, Set)
        assert len(obj.model.site_set) == 1

        assert hasattr(obj.model, 'S')
        assert isinstance(obj.model.S, Var)

        assert hasattr(obj.model, 'Smax')
        assert isinstance(obj.model.Smax, Param)

        assert hasattr(obj.model, 'u_S')
        assert isinstance(obj.model.u_S, Param)

    @pytest.mark.build
    def test_add_surface_sites_list(self):
        obj = Isothermal_Monolith_Simulator()
        obj.add_axial_dim(0,5)
        obj.add_temporal_dim(0,10)
        obj.add_age_set("Unaged")
        obj.add_temperature_set("250C")
        obj.add_gas_species("NH3")
        obj.add_surface_species("ZNH4")
        obj.add_surface_sites(["S1","S2"])
        assert hasattr(obj.model, 'site_set')
        assert isinstance(obj.model.site_set, Set)
        assert len(obj.model.site_set) == 2

        assert hasattr(obj.model, 'S')
        assert isinstance(obj.model.S, Var)

        assert hasattr(obj.model, 'Smax')
        assert isinstance(obj.model.Smax, Param)

        assert hasattr(obj.model, 'u_S')
        assert isinstance(obj.model.u_S, Param)

    @pytest.mark.build
    def test_add_reactions_equ(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists
        rxn_dict = {"r1": ReactionType.EquilibriumArrhenius}
        obj.add_reactions(rxn_dict)
        obj_with_lists.add_reactions(rxn_dict)

        assert hasattr(obj.model, 'all_rxns')
        assert isinstance(obj.model.all_rxns, Set)
        assert len(obj.model.all_rxns) == 1

        assert hasattr(obj_with_lists.model, 'all_rxns')
        assert isinstance(obj_with_lists.model.all_rxns, Set)
        assert len(obj_with_lists.model.all_rxns) == 1

        assert hasattr(obj.model, 'arrhenius_rxns')
        assert isinstance(obj.model.arrhenius_rxns, Set)
        assert len(obj.model.arrhenius_rxns) == 0

        assert hasattr(obj_with_lists.model, 'arrhenius_rxns')
        assert isinstance(obj_with_lists.model.arrhenius_rxns, Set)
        assert len(obj_with_lists.model.arrhenius_rxns) == 0

        assert hasattr(obj.model, 'equ_arrhenius_rxns')
        assert isinstance(obj.model.equ_arrhenius_rxns, Set)
        assert len(obj.model.equ_arrhenius_rxns) == 1

        assert hasattr(obj_with_lists.model, 'equ_arrhenius_rxns')
        assert isinstance(obj_with_lists.model.equ_arrhenius_rxns, Set)
        assert len(obj_with_lists.model.equ_arrhenius_rxns) == 1

        assert hasattr(obj.model, 'u_C')
        assert isinstance(obj.model.u_C, Param)
        assert hasattr(obj.model, 'u_q')
        assert isinstance(obj.model.u_q, Param)

        assert hasattr(obj_with_lists.model, 'u_C')
        assert isinstance(obj_with_lists.model.u_C, Param)
        assert hasattr(obj_with_lists.model, 'u_q')
        assert isinstance(obj_with_lists.model.u_q, Param)

        assert hasattr(obj.model, 'A')
        assert isinstance(obj.model.A, Var)
        assert hasattr(obj.model, 'B')
        assert isinstance(obj.model.B, Var)
        assert hasattr(obj.model, 'E')
        assert isinstance(obj.model.E, Var)
        assert hasattr(obj.model, 'Af')
        assert isinstance(obj.model.Af, Var)
        assert hasattr(obj.model, 'Ef')
        assert isinstance(obj.model.Ef, Var)
        assert hasattr(obj.model, 'dH')
        assert isinstance(obj.model.dH, Var)
        assert hasattr(obj.model, 'dS')
        assert isinstance(obj.model.dS, Var)

        assert hasattr(obj_with_lists.model, 'A')
        assert isinstance(obj_with_lists.model.A, Var)
        assert hasattr(obj_with_lists.model, 'B')
        assert isinstance(obj_with_lists.model.B, Var)
        assert hasattr(obj_with_lists.model, 'E')
        assert isinstance(obj_with_lists.model.E, Var)
        assert hasattr(obj_with_lists.model, 'Af')
        assert isinstance(obj_with_lists.model.Af, Var)
        assert hasattr(obj_with_lists.model, 'Ef')
        assert isinstance(obj_with_lists.model.Ef, Var)
        assert hasattr(obj_with_lists.model, 'dH')
        assert isinstance(obj_with_lists.model.dH, Var)
        assert hasattr(obj_with_lists.model, 'dS')
        assert isinstance(obj_with_lists.model.dS, Var)

        assert hasattr(obj.model, 'all_species_set')
        assert isinstance(obj.model.all_species_set, Set)
        assert len(obj.model.all_species_set) == 3

        assert hasattr(obj_with_lists.model, 'all_species_set')
        assert isinstance(obj_with_lists.model.all_species_set, Set)
        assert len(obj_with_lists.model.all_species_set) == 4

        assert hasattr(obj.model, 'rxn_orders')
        assert isinstance(obj.model.rxn_orders, Param)

        assert hasattr(obj_with_lists.model, 'rxn_orders')
        assert isinstance(obj_with_lists.model.rxn_orders, Param)

    @pytest.mark.unit
    def test_formfactor_calculations(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists
        obj.set_bulk_porosity(0.3309)
        obj.set_cell_density(62)
        obj.set_washcoat_porosity(0.4)
        obj.set_reactor_radius(1)
        obj_with_lists.isMonolith = False
        obj_with_lists.model.dh.set_value(0.1)
        obj_with_lists.set_bulk_porosity(0.3309)
        obj_with_lists.set_cell_density(62)
        obj_with_lists.set_washcoat_porosity(0.4)
        obj_with_lists.set_reactor_radius(1)

        assert value(obj.model.eb) == 0.3309
        assert value(obj.model.cell_density) == 62

        assert value(obj_with_lists.model.eb) == 0.3309
        assert value(obj_with_lists.model.cell_density) == 62

        assert value(obj_with_lists.model.dh) == 0.1
        assert value(obj_with_lists.model.Ga) == 6/0.1

        assert pytest.approx(0.0777448, rel=1e-3) == value(obj.model.dh)
        assert pytest.approx(28.8159, rel=1e-3) == value(obj.model.Ga)

        obj_with_lists.isMonolith = True
        obj_with_lists.model.dh.set_value(value(obj.model.dh))
        obj_with_lists.model.Ga.set_value(value(obj.model.Ga))

        assert pytest.approx(0.0777448, rel=1e-3) == value(obj_with_lists.model.dh)
        assert pytest.approx(28.8159, rel=1e-3) == value(obj_with_lists.model.Ga)

        obj.set_space_velocity_all_runs(1000)
        obj_with_lists.set_space_velocity_all_runs(1000)

    @pytest.mark.unit
    def test_set_site_balance(self, isothermal_object):
        obj = isothermal_object
        obj.set_site_density("ZH","Unaged",0.1152619)
        site_data = {"mol_occupancy": {"ZNH4": 1}}
        obj.set_site_balance("ZH",site_data)

        assert value(obj.model.u_S["ZH","ZNH4"]) == 1

    @pytest.mark.unit
    def test_set_reaction_info(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists
        rxn_dict = {"parameters": {"A": 250000, "E": 0,

                                "A_lb": 2500, "A_ub": 2500000000,
                                "E_lb": -1, "E_ub": 1,

                                "dH": -54000, "dS": 30,

                                "dH_lb": -55000, "dH_ub": -53000,
                                "dS_lb": 20, "dS_ub": 40,
                                },
                  "mol_reactants": {"ZH": 1, "NH3": 1},
                  "mol_products": {"ZNH4": 1},
                  "rxn_orders": {"ZH": 1, "NH3": 1, "ZNH4": 1}
                }
        obj.set_reaction_info("r1", rxn_dict)
        obj_with_lists.set_reaction_info("r1", rxn_dict)

        assert value(obj.model.Af["r1"].lb) == 2500
        assert value(obj.model.Af["r1"].ub) == 2500000000
        assert value(obj.model.Af["r1"]) == 250000

        assert value(obj_with_lists.model.Af["r1"].lb) == 2500
        assert value(obj_with_lists.model.Af["r1"].ub) == 2500000000
        assert value(obj_with_lists.model.Af["r1"]) == 250000

        assert value(obj.model.Ef["r1"].lb) == -1
        assert value(obj.model.Ef["r1"].ub) == 1
        assert value(obj.model.Ef["r1"]) == 0

        assert value(obj_with_lists.model.Ef["r1"].lb) == -1
        assert value(obj_with_lists.model.Ef["r1"].ub) == 1
        assert value(obj_with_lists.model.Ef["r1"]) == 0

        assert value(obj.model.dH["r1"].lb) == -55000
        assert value(obj.model.dH["r1"].ub) == -53000
        assert value(obj.model.dH["r1"]) == -54000

        assert value(obj_with_lists.model.dH["r1"].lb) == -55000
        assert value(obj_with_lists.model.dH["r1"].ub) == -53000
        assert value(obj_with_lists.model.dH["r1"]) == -54000

        assert value(obj.model.dS["r1"].lb) == 20
        assert value(obj.model.dS["r1"].ub) == 40
        assert value(obj.model.dS["r1"]) == 30

        assert value(obj_with_lists.model.dS["r1"].lb) == 20
        assert value(obj_with_lists.model.dS["r1"].ub) == 40
        assert value(obj_with_lists.model.dS["r1"]) == 30

        assert hasattr(obj.model, 'r1_reactants')
        assert isinstance(obj.model.r1_reactants, Set)
        assert len(obj.model.r1_reactants) == 2

        assert hasattr(obj.model, 'r1_products')
        assert isinstance(obj.model.r1_products, Set)
        assert len(obj.model.r1_products) == 1

        assert hasattr(obj_with_lists.model, 'r1_reactants')
        assert isinstance(obj_with_lists.model.r1_reactants, Set)
        assert len(obj_with_lists.model.r1_reactants) == 2

        assert hasattr(obj_with_lists.model, 'r1_products')
        assert isinstance(obj_with_lists.model.r1_products, Set)
        assert len(obj_with_lists.model.r1_products) == 1

        assert value(obj.model.u_C["NH3","r1",obj.model.z.first()]) == -1
        assert value(obj.model.u_q["ZNH4","r1",obj.model.z.first()]) == 1

        assert value(obj_with_lists.model.u_C["NH3","r1",obj_with_lists.model.z.first()]) == -1
        assert value(obj_with_lists.model.u_q["ZNH4","r1",obj_with_lists.model.z.first()]) == 1
        assert value(obj_with_lists.model.u_q["ZH","r1",obj_with_lists.model.z.first()]) == -1

        assert value(obj.model.rxn_orders["r1","NH3"]) == 1
        assert value(obj.model.rxn_orders["r1","ZH"]) == 1
        assert value(obj.model.rxn_orders["r1","ZNH4"]) == 1

        assert value(obj_with_lists.model.rxn_orders["r1","NH3"]) == 1
        assert value(obj_with_lists.model.rxn_orders["r1","ZH"]) == 1
        assert value(obj_with_lists.model.rxn_orders["r1","ZNH4"]) == 1

    @pytest.mark.unit
    def test_set_isothermal_temp(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists
        obj.set_isothermal_temp("Unaged","250C",250+273.15)

        obj_with_lists.set_isothermal_temp("Unaged","250C",250+273.15)
        obj_with_lists.set_isothermal_temp("2hr","250C",250+273.15)
        obj_with_lists.set_isothermal_temp("Unaged","300C",300+273.15)
        obj_with_lists.set_isothermal_temp("2hr","300C",300+273.15)

        assert value(obj.model.T["Unaged","250C",obj.model.z.first(),obj.model.t.first()]) == 250+273.15

        assert value(obj_with_lists.model.T["Unaged","250C",
                    obj_with_lists.model.z.first(),obj_with_lists.model.t.first()]) == 250+273.15
        assert value(obj_with_lists.model.T["2hr","250C",
                    obj_with_lists.model.z.first(),obj_with_lists.model.t.first()]) == 250+273.15

        assert value(obj_with_lists.model.T["Unaged","300C",
                    obj_with_lists.model.z.first(),obj_with_lists.model.t.first()]) == 300+273.15
        assert value(obj_with_lists.model.T["2hr","300C",
                    obj_with_lists.model.z.first(),obj_with_lists.model.t.first()]) == 300+273.15

    @pytest.mark.initialization
    def test_build_constraints(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists
        obj.build_constraints()
        obj_with_lists.build_constraints()

        assert hasattr(obj.model, 'bulk_cons')
        assert isinstance(obj.model.bulk_cons, Constraint)
        assert hasattr(obj.model, 'pore_cons')
        assert isinstance(obj.model.pore_cons, Constraint)
        assert hasattr(obj.model, 'surf_cons')
        assert isinstance(obj.model.surf_cons, Constraint)
        assert hasattr(obj.model, 'site_cons')
        assert isinstance(obj.model.site_cons, Constraint)

        assert hasattr(obj_with_lists.model, 'bulk_cons')
        assert isinstance(obj_with_lists.model.bulk_cons, Constraint)
        assert hasattr(obj_with_lists.model, 'pore_cons')
        assert isinstance(obj_with_lists.model.pore_cons, Constraint)
        assert hasattr(obj_with_lists.model, 'surf_cons')
        assert isinstance(obj_with_lists.model.surf_cons, Constraint)

    @pytest.mark.initialization
    def test_discretization_fd(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists

        obj.discretize_model(method=DiscretizationMethod.FiniteDifference,
                            tstep=5,elems=5,colpoints=2)
        obj_with_lists.discretize_model(method=DiscretizationMethod.FiniteDifference,
                            tstep=5,elems=5,colpoints=2)

        assert hasattr(obj.model, 'dCbdz_edge')
        assert isinstance(obj.model.dCbdz_edge, Constraint)

        assert hasattr(obj_with_lists.model, 'dCbdz_edge')
        assert isinstance(obj_with_lists.model.dCbdz_edge, Constraint)

        assert len(obj.model.t) == len(obj_with_lists.model.t)
        assert len(obj.model.z) == len(obj_with_lists.model.z)

        assert pytest.approx(111.63437198706396, rel=1e-3) == \
            value(obj.model.P["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(
            value(obj_with_lists.model.P["Unaged","250C",obj_with_lists.model.z.first(),
                obj_with_lists.model.t.first()]), rel=1e-3) == \
            value(obj.model.P["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(28882.87336113903, rel=1e-3) == \
            value(obj.model.v["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj_with_lists.model.v["Unaged","250C",obj_with_lists.model.z.first(),
                obj_with_lists.model.t.first()]), rel=1e-3) == \
            value(obj.model.v["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(0.0006748820366629658, rel=1e-3) == \
            value(obj.model.rho["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj_with_lists.model.rho["Unaged","250C",obj_with_lists.model.z.first(),
                obj_with_lists.model.t.first()]), rel=1e-3) == \
            value(obj.model.rho["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(0.0002753695869940695, rel=1e-3) == \
            value(obj.model.mu["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj_with_lists.model.mu["Unaged","250C",obj_with_lists.model.z.first(),
                obj_with_lists.model.t.first()]), rel=1e-3) == \
            value(obj.model.mu["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(91.7218236329034, rel=1e-3) == \
            value(obj.model.Re["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj_with_lists.model.Re["Unaged","250C",obj_with_lists.model.z.first(),
                obj_with_lists.model.t.first()]), rel=1e-3) == \
            value(obj.model.Re["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(0.4129058808030342, rel=1e-3) == \
            value(obj.model.Sc["NH3","Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj_with_lists.model.Sc["NH3","Unaged","250C",obj_with_lists.model.z.first(),
                obj_with_lists.model.t.first()]), rel=1e-3) == \
            value(obj.model.Sc["NH3","Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(4.058710793831378, rel=1e-3) == \
            value(obj.model.Sh["NH3","Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj_with_lists.model.Sh["NH3","Unaged","250C",obj_with_lists.model.z.first(),
                obj_with_lists.model.t.first()]), rel=1e-3) == \
            value(obj.model.Sh["NH3","Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(858.2004564100874, rel=1e-3) == \
            value(obj.model.km["NH3","Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj_with_lists.model.km["NH3","Unaged","250C",
                obj_with_lists.model.z.first(),obj_with_lists.model.t.first()]), rel=1e-3) == \
            value(obj.model.km["NH3","Unaged","250C",obj.model.z.first(),obj.model.t.first()])

    @pytest.mark.unit
    def test_set_initial_conditions(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists

        obj.set_const_IC("NH3","Unaged","250C",0)
        obj.set_const_IC("ZNH4","Unaged","250C",0)

        obj_with_lists.set_const_IC_in_ppm("NH3","Unaged","250C",0)
        obj_with_lists.set_const_IC_in_ppm("NO","Unaged","250C",300)

        obj_with_lists.set_const_IC_in_ppm("NH3","2hr","250C",0)
        obj_with_lists.set_const_IC_in_ppm("NO","2hr","250C",300)

        obj_with_lists.set_const_IC_in_ppm("NH3","Unaged","300C",0)
        obj_with_lists.set_const_IC_in_ppm("NO","Unaged","300C",300)

        obj_with_lists.set_const_IC_in_ppm("NH3","2hr","300C",0)
        obj_with_lists.set_const_IC_in_ppm("NO","2hr","300C",300)

        obj_with_lists.set_const_IC("ZNH4","Unaged","250C",0)
        obj_with_lists.set_const_IC("ZH","Unaged","250C",0.1152619)

        obj_with_lists.set_const_IC("ZNH4","2hr","250C",0)
        obj_with_lists.set_const_IC("ZH","2hr","250C",0.0952619)

        obj_with_lists.set_const_IC("ZNH4","Unaged","300C",0)
        obj_with_lists.set_const_IC("ZH","Unaged","300C",0.1152619)

        obj_with_lists.set_const_IC("ZNH4","2hr","300C",0)
        obj_with_lists.set_const_IC("ZH","2hr","300C",0.0952619)

        assert pytest.approx(6.9762939977887255e-06, rel=1e-3) == \
            value(obj_with_lists.model.Cb["NO","Unaged","250C",
                    obj_with_lists.model.z.first(),obj_with_lists.model.t.first()])

        assert pytest.approx(6.36770165740761e-06, rel=1e-3) == \
            value(obj_with_lists.model.Cb["NO","Unaged","300C",
                    obj_with_lists.model.z.first(),obj_with_lists.model.t.first()])

        assert pytest.approx(6.9762939977887255e-06, rel=1e-3) == \
            value(obj_with_lists.model.C["NO","Unaged","250C",
                    obj_with_lists.model.z.first(),obj_with_lists.model.t.first()])

        assert pytest.approx(6.36770165740761e-06, rel=1e-3) == \
            value(obj_with_lists.model.C["NO","Unaged","300C",
                    obj_with_lists.model.z.first(),obj_with_lists.model.t.first()])

        assert pytest.approx(1e-20, rel=1e-3) == \
            value(obj.model.Cb["NH3","Unaged","250C",
                    obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(1e-20, rel=1e-3) == \
            value(obj.model.C["NH3","Unaged","250C",
                    obj.model.z.first(),obj.model.t.first()])

    @pytest.mark.unit
    def test_set_boundary_conditions(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists

        obj.set_time_dependent_BC("NH3","Unaged","250C",
                                    time_value_pairs=[(4,6.9762939977887255e-06)],
                                    initial_value=0)

        obj_with_lists.set_time_dependent_BC_in_ppm("NH3","Unaged","250C",
                                    time_value_pairs=[(4,300)],
                                    initial_value=0)
        obj_with_lists.set_time_dependent_BC_in_ppm("NH3","2hr","250C",
                                    time_value_pairs=[(4,300)],
                                    initial_value=0)

        obj_with_lists.set_time_dependent_BC_in_ppm("NH3","Unaged","300C",
                                    time_value_pairs=[(4,300)],
                                    initial_value=0)
        obj_with_lists.set_time_dependent_BC_in_ppm("NH3","2hr","300C",
                                    time_value_pairs=[(4,300)],
                                    initial_value=0)

        obj_with_lists.set_const_BC("NO","Unaged","250C",6.9762939977887255e-06)
        obj_with_lists.set_const_BC_in_ppm("NO","2hr","250C",300)

        obj_with_lists.set_const_BC("NO","Unaged","300C",6.36770165740761e-06)
        obj_with_lists.set_const_BC_in_ppm("NO","2hr","300C",300)

        assert pytest.approx(6.9762939977887255e-06, rel=1e-3) == \
            value(obj_with_lists.model.Cb["NH3","Unaged","250C",
                    obj_with_lists.model.z.first(),4.0])

        assert pytest.approx(value(obj.model.Cb["NH3","Unaged","250C",
                                obj.model.z.first(),4.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NH3","Unaged","250C",
                    obj_with_lists.model.z.first(),4.0])

        assert pytest.approx(value(obj_with_lists.model.Cb["NO","Unaged","250C",
                                obj_with_lists.model.z.first(),4.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NO","2hr","250C",
                    obj_with_lists.model.z.first(),4.0])

        assert pytest.approx(value(obj_with_lists.model.Cb["NO","Unaged","300C",
                                obj_with_lists.model.z.first(),4.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NO","2hr","300C",
                    obj_with_lists.model.z.first(),4.0])

    @pytest.mark.initialization
    def test_initialize_auto_scaling(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists
        obj.initialize_auto_scaling()
        obj_with_lists.initialize_auto_scaling()

        assert hasattr(obj.model, 'scaling_factor')
        assert isinstance(obj.model.scaling_factor, Suffix)

        assert hasattr(obj_with_lists.model, 'scaling_factor')
        assert isinstance(obj_with_lists.model.scaling_factor, Suffix)

    @pytest.mark.solver
    def test_initialization_solve(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists

        (stat1, cond1) = obj.initialize_simulator()
        assert cond1 == TerminationCondition.optimal
        assert stat1 == SolverStatus.ok

        (stat2, cond2) = obj_with_lists.initialize_simulator()
        assert cond2 == TerminationCondition.optimal
        assert stat2 == SolverStatus.ok

    @pytest.mark.initialization
    def test_final_auto_scaling(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists

        obj.finalize_auto_scaling()
        obj_with_lists.finalize_auto_scaling()

        assert not hasattr(obj.model, 'obj')
        assert not hasattr(obj_with_lists.model, 'obj')

    @pytest.mark.solver
    def test_full_solve(self, isothermal_object, isothermal_object_with_lists):
        obj = isothermal_object
        obj_with_lists = isothermal_object_with_lists

        (stat1, cond1) = obj.run_solver()
        assert cond1 == TerminationCondition.optimal
        assert stat1 == SolverStatus.ok

        (stat2, cond2) = obj_with_lists.run_solver()
        assert cond2 == TerminationCondition.optimal
        assert stat2 == SolverStatus.ok

        assert pytest.approx(28882.87336113903, rel=1e-3) == \
            value(obj.model.v["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj_with_lists.model.v["Unaged","250C",obj.model.z.first(),obj.model.t.first()]), rel=1e-3) == \
            value(obj.model.v["Unaged","250C",obj.model.z.first(),obj.model.t.first()])

        assert pytest.approx(value(obj.model.Cb["NH3","Unaged","250C",
                                obj.model.z.last(),0.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NH3","Unaged","250C",
                    obj_with_lists.model.z.last(),0.0])

        assert pytest.approx(value(obj.model.Cb["NH3","Unaged","250C",
                                obj.model.z.last(),4.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NH3","Unaged","250C",
                    obj_with_lists.model.z.last(),4.0])

        assert pytest.approx(value(obj.model.Cb["NH3","Unaged","250C",
                                obj.model.z.last(),8.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NH3","Unaged","250C",
                    obj_with_lists.model.z.last(),8.0])

        assert pytest.approx(value(obj.model.Cb["NH3","Unaged","250C",
                                obj.model.z.last(),12.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NH3","Unaged","250C",
                    obj_with_lists.model.z.last(),12.0])

        assert pytest.approx(value(obj.model.Cb["NH3","Unaged","250C",
                                obj.model.z.last(),16.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NH3","Unaged","250C",
                    obj_with_lists.model.z.last(),16.0])

        assert pytest.approx(value(obj.model.Cb["NH3","Unaged","250C",
                                obj.model.z.last(),20.0]), rel=1e-3) == \
            value(obj_with_lists.model.Cb["NH3","Unaged","250C",
                    obj_with_lists.model.z.last(),20.0])


        assert pytest.approx(value(obj.model.q["ZNH4","Unaged","250C",
                                obj.model.z.last(),0.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZNH4","Unaged","250C",
                    obj_with_lists.model.z.last(),0.0])

        assert pytest.approx(value(obj.model.q["ZNH4","Unaged","250C",
                                obj.model.z.last(),4.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZNH4","Unaged","250C",
                    obj_with_lists.model.z.last(),4.0])

        assert pytest.approx(value(obj.model.q["ZNH4","Unaged","250C",
                                obj.model.z.last(),8.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZNH4","Unaged","250C",
                    obj_with_lists.model.z.last(),8.0])

        assert pytest.approx(value(obj.model.q["ZNH4","Unaged","250C",
                                obj.model.z.last(),12.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZNH4","Unaged","250C",
                    obj_with_lists.model.z.last(),12.0])

        assert pytest.approx(value(obj.model.q["ZNH4","Unaged","250C",
                                obj.model.z.last(),16.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZNH4","Unaged","250C",
                    obj_with_lists.model.z.last(),16.0])

        assert pytest.approx(value(obj.model.q["ZNH4","Unaged","250C",
                                obj.model.z.last(),20.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZNH4","Unaged","250C",
                    obj_with_lists.model.z.last(),20.0])



        assert pytest.approx(value(obj.model.S["ZH","Unaged","250C",
                                obj.model.z.last(),0.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZH","Unaged","250C",
                    obj_with_lists.model.z.last(),0.0])

        assert pytest.approx(value(obj.model.S["ZH","Unaged","250C",
                                obj.model.z.last(),4.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZH","Unaged","250C",
                    obj_with_lists.model.z.last(),4.0])

        assert pytest.approx(value(obj.model.S["ZH","Unaged","250C",
                                obj.model.z.last(),8.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZH","Unaged","250C",
                    obj_with_lists.model.z.last(),8.0])

        assert pytest.approx(value(obj.model.S["ZH","Unaged","250C",
                                obj.model.z.last(),12.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZH","Unaged","250C",
                    obj_with_lists.model.z.last(),12.0])

        assert pytest.approx(value(obj.model.S["ZH","Unaged","250C",
                                obj.model.z.last(),16.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZH","Unaged","250C",
                    obj_with_lists.model.z.last(),16.0])

        assert pytest.approx(value(obj.model.S["ZH","Unaged","250C",
                                obj.model.z.last(),20.0]), rel=1e-3) == \
            value(obj_with_lists.model.q["ZH","Unaged","250C",
                    obj_with_lists.model.z.last(),20.0])
