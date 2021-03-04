# This file is a demo for the 'Isothermal_Monolith_Simulator' object

from isothermal_monolith_catalysis import *

# Testing
test = Isothermal_Monolith_Simulator()
test.add_axial_dim(0,5)
test.add_temporal_dim(0,20)

test.add_age_set("Unaged")
test.add_temperature_set("250C")

test.add_gas_species("NH3")
test.add_surface_species("q1")
test.add_surface_sites("S1")
test.add_reactions({"r1": ReactionType.EquilibriumArrhenius})

test.set_bulk_porosity(0.3309)
test.set_washcoat_porosity(0.2)
test.set_linear_velocity(15110)
test.set_mass_transfer_coef(1.12)
test.set_surface_to_volume_ratio(5757.541)

# Setting up site balances using dicts
s1_data = {"mol_occupancy": {"q1": 1}}
test.set_site_balance("S1",s1_data)

# Reaction specification information (must correspond to correct reaction type)

#   EquilibriumArrhenius
r1_equ = {"parameters": {"A": 250000, "E": 0, "dH": -54000, "dS": 30},
          "mol_reactants": {"S1": 1, "NH3": 1},
          "mol_products": {"q1": 1},
          "rxn_orders": {"S1": 1, "NH3": 1, "q1": 1}
        }

test.set_reaction_info("r1", r1_equ)

# TODO: NOTE: May have to set after discretization?
test.set_site_density("S1","Unaged",0.1152619)

#test.model.dCb_dz = DerivativeVar(test.model.Cb, wrt=test.model.z, units=units.mol/units.L/units.min)

test.build_constraints()
test.discretize_model(tstep=20,elems=20)

test.set_isothermal_temp("Unaged","250C",250+273.15)
#test.set_site_density("S1","Unaged",0.1152619)

#test.model.v.pprint()
#print(value(test.model.v))
test.set_const_IC("NH3","Unaged","250C",1e-20)
test.set_const_IC("q1","Unaged","250C",1e-20)
test.set_const_BC("NH3","Unaged","250C",6.94E-6)
test.fix_all_reactions()

#test.model.pprint()
print()
print(test.isInitialSet)
print(test.isBoundarySet)

from pyomo.environ import *

# TODO: Create a lower bound that is non-zero
solver = SolverFactory('ipopt')
results = solver.solve(test.model, tee=True)

def print_breakthrough_results(model, spec, age, temp, file):
    # TODO: Update this to use a list of vars

    #Print header first
    file.write('Results for '+str(spec)+' at system exit in table below'+'\n')
    file.write('Time\t'+str(spec)+' @ z=' + str(model.z.last()) + '\n')
    for time in model.t:
        file.write(str(time) + '\t' + str(value(model.Cb[spec,age,temp,model.z.last(),time])) + '\n')
    file.write('\n')

file = open("1D_Sorption_Breakthrough.txt","w")
print_breakthrough_results(test.model, "NH3", "Unaged", "250C", file)
file.close()
#print(test.rxn_list)

#a = test.arrhenius_rate_func("r1",test.model,"Unaged",250+273.15,0,0)
#print(a)

#b = test.equilibrium_arrhenius_rate_func("r2",test.model,"Unaged",250+273.15,0,0)
#print(b)

#c = test.reaction_sum_gas("NH3",test.model,"Unaged",250+273.15,0,0)
#print(c)

#d = test.reaction_sum_surf("q1",test.model,"Unaged",250+273.15,0,0)
#print(d)

#e = test.site_sum("S1",test.model,"Unaged",250+273.15,0,0)
#print(e)
