import sys
sys.path.append('../..')
from catalyst.isothermal_monolith_catalysis import *

run = "02"
oldrun="01"

readfile = 'output/full_lowtemp_model'+oldrun+'.json'
writefile = "full_lowtemp_model"+run+".json"

sim = Isothermal_Monolith_Simulator()
sim.load_model_full(readfile, reset_param_bounds=True)

sim.unfix_all_reactions()


#  ============= Modify parameter bounds =================
#   Specify modifications to parameter boundaries (default = +/- 20%)
upper = 1+0.05
lower = 1-0.05
for rxn in sim.model.arrhenius_rxns:
    sim.set_reaction_param_bounds(rxn, "A", bounds=(sim.model.A[rxn].value*lower,sim.model.A[rxn].value*upper))
    sim.set_reaction_param_bounds(rxn, "E", bounds=(sim.model.E[rxn].value*lower,sim.model.E[rxn].value*upper))

# Select reactions to fix
sim.fix_reaction("r1")
sim.fix_reaction("r2a")
sim.fix_reaction("r2b")
sim.fix_reaction("r3")
sim.fix_reaction("r4a")
sim.fix_reaction("r4b")
sim.fix_reaction("r5f")
sim.fix_reaction("r5r")
sim.fix_reaction("r6f")
sim.fix_reaction("r6r")
sim.fix_reaction("r7")
sim.fix_reaction("r8")
sim.fix_reaction("r9")
sim.fix_reaction("r10")
sim.fix_reaction("r11")
sim.fix_reaction("r12")
sim.fix_reaction("r13")
sim.fix_reaction("r14")
sim.fix_reaction("r15")
sim.fix_reaction("r16")
sim.fix_reaction("r17")
sim.fix_reaction("r18")
sim.fix_reaction("r19")
sim.fix_reaction("r20")
# Only going to vary the low temp reactions (NH4NO3 forming)
sim.fix_reaction("r34")
sim.fix_reaction("r35")
sim.fix_reaction("r36")
sim.fix_reaction("r37")
sim.fix_reaction("r38")
sim.fix_reaction("r39")

sim.finalize_auto_scaling()
options={'print_user_options': 'yes',
        'linear_solver': LinearSolverMethod.MA27,
        'tol': 1e-6,
        'acceptable_tol': 1e-6,
        'compl_inf_tol': 1e-6,
        'constr_viol_tol': 1e-6,
        'max_iter': 88,
        'obj_scaling_factor': 1,
        'diverging_iterates_tol': 1e50}
sim.run_solver(options=options)



Tstr = "NOSCR"
sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, file_name="Unaged_NOSCR_lowtemp_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, 0, file_name="Unaged_NOSCR_lowtemp_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", Tstr, file_name="Unaged_NOSCR_lowtemp_average_ads.txt")

sim.plot_vs_data("NH3", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("NO", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("NO2", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("N2O", "Unaged", Tstr, 5, display_live=False)


Tstr = "FastSCR"
sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, file_name="Unaged_FastSCR_lowtemp_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, 0, file_name="Unaged_FastSCR_lowtemp_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", Tstr, file_name="Unaged_FastSCR_lowtemp_average_ads.txt")

sim.plot_vs_data("NH3", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("NO", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("NO2", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("N2O", "Unaged", Tstr, 5, display_live=False)


Tstr = "NO2SCR"
sim.print_results_of_breakthrough(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, file_name="Unaged_NO2SCR_lowtemp_breakthrough.txt")
sim.print_results_of_location(["NH3","NO","NO2","N2O","O2","N2","H2O"],
                                        "Unaged", Tstr, 0, file_name="Unaged_NO2SCR_lowtemp_bypass.txt")
sim.print_results_of_integral_average(["Z1CuOH-NH3","Z2Cu-NH3","Z2Cu-(NH3)2","ZNH4",
                                        "Z1CuOH-NH4NO3", "Z2Cu-NH4NO3", "ZH-NH4NO3"],
                                        "Unaged", Tstr, file_name="Unaged_NO2SCR_lowtemp_average_ads.txt")

sim.plot_vs_data("NH3", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("NO", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("NO2", "Unaged", Tstr, 5, display_live=False)

sim.plot_vs_data("N2O", "Unaged", Tstr, 5, display_live=False)


sim.print_kinetic_parameter_info(file_name="full_lowtemp_opt_params"+run+".txt")
sim.save_model_state(file_name=writefile)
