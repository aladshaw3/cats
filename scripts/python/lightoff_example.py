# This file is a demo for the 'Isothermal_Monolith_Simulator' object

from isothermal_monolith_catalysis import *

# Test data
data_co = [5048.132494,
        4990.786137,
        4849.85,
        4551.059035,
        3980.648565,
        3143.690365,
        2186.514695,
        1394.79744,
        271.5462783,
        31.34401616,
        7.967678448,
        2.973828219,
        6.831221109,
        17.30586228,
        22.84104744,
        21.91574744,
        21.9410777,
        29.01068192,
        37.18506374,
        42.91591482,
        50.73264931]
data_times = [120,
            360,
            600,
            840,
            1080,
            1320,
            1560,
            1800,
            2040,
            2280,
            2520,
            2760,
            3000,
            3240,
            3480,
            3720,
            3960,
            4200,
            4440,
            4680,
            4920]
# Must add initial time to time set (won't necessarily be in data)
sim_times = [0,
            120,
            360,
            600,
            840,
            1080,
            1320,
            1560,
            1800,
            2040,
            2280,
            2520,
            2760,
            3000,
            3240,
            3480,
            3720,
            3960,
            4200,
            4440,
            4680,
            4920]

# Data dictionary
dict = {"set_1":
            {"location": 5,
            "age": "A0",
            "temp": "T0",
            "data":
                {"CO":
                    {"values": data_co,
                     "times": data_times
                    }
                #add more species
                }
            }
        #add more sets at different locations
        }

# Testing
test = Isothermal_Monolith_Simulator()

# NOTE: Units must be consistent between model and data
test.add_axial_dim(0,5)         #cm
test.add_axial_dataset(5)       # Location of observations (in cm)

test.add_temporal_dim(point_list=sim_times)   #s
test.add_temporal_dataset(data_times)         #Temporal observations (in s)



test.add_age_set("A0")
test.add_data_age_set("A0")             # Data observations can be a sub-set

test.add_temperature_set("T0")
test.add_data_temperature_set("T0")     # Data observations can be a sub-set

test.add_gas_species(["CO","O2","NO","CO2","N2"])
test.add_data_gas_species("CO")         # Data observations can be a sub-set


test.add_reactions({"r1": ReactionType.Arrhenius,
                    "r4": ReactionType.Arrhenius})

# Set data as (spec, age, temp, loc, time_list, value_list)
test.set_data_values_for("CO","A0","T0",5,data_times,data_co)

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.2)
test.set_reactor_radius(1)                  # cm
test.set_space_velocity_all_runs(8.333)     # s^-1
test.set_mass_transfer_coef(0.018667)       # m/s
test.set_surface_to_volume_ratio(5145)      # m^-1

#   Arrhenius
#       Users may specify controls on the upper and lower bounds for each parameter
#       This is optional. The routine will assume bounds of +/- 20% if no option is given
r1 = {"parameters": {"A": 5.00466E+17, "E": 205901.5765,
                    "A_lb": 1.00466E+17, "A_ub": 1.00466E+19,
                    "E_lb": 200000, "E_ub": 210000},
          "mol_reactants": {"CO": 1, "O2": 0.5},
          "mol_products": {"CO2": 1},
          "rxn_orders": {"CO": 1, "O2": 1},
          # The option below is optional and is used to override the value of u_C
          #     (i.e., the molar contribution of this reaction to a given species'
          #     mass balance. This may be useful if user wants to specify some
          #     reaction/species pair as "non-consuming" or "over-consuming")

          #     DO NOT USE UNLESS ABSOLUTELY NECESSARY
         # "override_molar_contribution": {"O2": 0}
        }

r4 = {"parameters": {"A": 1.816252679, "E": 28675.21769},
          "mol_reactants": {"CO": 1, "NO": 1},
          "mol_products": {"CO2": 1, "N2": 0.5},
          "rxn_orders": {"CO": 1, "NO": 1}
        }

test.set_reaction_info("r1", r1)
test.set_reaction_info("r4", r4)

test.set_isothermal_temp("A0","T0",393.15) # K

# Build the constraints then discretize
test.build_constraints()
test.discretize_model(method=DiscretizationMethod.FiniteDifference,
                    tstep=10,elems=5,colpoints=1)

# Initial conditions and Boundary Conditions should be set AFTER discretization
#       Units of concentration here are in ppm
test.set_const_IC("CO","A0","T0",5084)
test.set_const_IC("O2","A0","T0",7080)
test.set_const_IC("NO","A0","T0",1055)
test.set_const_IC("N2","A0","T0",0)
test.set_const_IC("CO2","A0","T0",0)

test.set_const_BC("CO","A0","T0",5084)
test.set_const_BC("O2","A0","T0",7080)
test.set_const_BC("NO","A0","T0",1055)
test.set_const_BC("N2","A0","T0",0)
test.set_const_BC("CO2","A0","T0",0)

# Setup temperature ramp
test.set_temperature_ramp("A0", "T0", 120, 5160, 813.15)

# Fix the kinetics to only run a simulation (leave unfixed for optimization)
#test.fix_all_reactions()
test.initialize_simulator()
test.run_solver()

test.print_results_of_breakthrough(["CO","NO","O2"], "A0", "T0", file_name="", include_temp=True)

test.print_results_all_locations(["CO","NO","O2"], "A0", "T0", file_name="", include_temp=True)

#test.model.obj.pprint()
print(test.interpret_var(test.model.Cb,"CO","A0","T0",4.0,0))
