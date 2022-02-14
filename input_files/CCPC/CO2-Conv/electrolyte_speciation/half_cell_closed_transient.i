# +++++++++ Simulation Case +++++++++++
# -------------------------------------
#   Simulated conversion of CO2 to other
#   products in a closed box with no
#   transport kernels active for concentration
#   species. The concentrations will simply
#   vary in time according to their reaction
#   rates and the applied potential/current
#   into the box.
#
#
# Literature reference for parameters:
# ------------------------------------
# J.C. Bui, C. Kim, A.Z. Weber, A.T. Bell, ACS Energy Lett.,
#   6 (2021) 1181 - 1188. doi: 10.1021/acsenergylett.1c00364
#
# ------------------------------------
#
# NOTE: Literature discusses BCs of applied potentials
#       rather than any specific current.
#
# NOTE 2: Literature shows current densities varying between
#         0 to 60 mA/cm^2 (1 mA = 0.001 C/s = 0.06 C/min).
#         Thus, a 'current flux' BC would be on the order
#         of 0 to 3.6 C/min/cm^2.
#

[GlobalParams]
    # In the literature, it is not clear what the conductivity of the solution
    # is, so I am providing a 'background' level based on different water sources.
    # Ultimately, the only one that has any appreciable effect is the conductivity
    # of seawater, which is also probably the least realistic for this what-if case.

    #min_conductivity = 3.0E-6  # C/V/cm/min (typical background of DI water)
    min_conductivity = 0.03    # C/V/cm/min (typical background of tap water)
    #min_conductivity = 3       # C/V/cm/min (typical background of seawater)

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 5
    ny = 25
    xmin = 0.0
    xmax = 0.4   # cm
    ymin = 0.0
    ymax = 5     # cm
[] # END Mesh

[Variables]
  # electrolyte potential (in V or J/C)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.4
  [../]

  # electrode potential (in V or J/C)
  [./phi_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.4
  [../]

  # -------- Butler-Volmer reaction rates ------------
  # reduced_state <----> oxidized_state
  # H2 + OH- <----> 2 H2O + 2 e-
  [./r_H2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 3.955E-8    # mol/cm^2/min
          equilibrium_potential = 0         # V

          reduced_state_vars = 'a_H2'       # assumed
          reduced_state_stoich = '1'        # assumed

          oxidized_state_vars = 'a_H'
          oxidized_state_stoich = '0.1737'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.14   # fitted param
      [../]
  [../]
  # CO + 2 OH- <----> CO2 + H2O + 2 e-
  [./r_CO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 1.250E-9    # mol/cm^2/min
          equilibrium_potential = -0.11         # V

          reduced_state_vars = 'a_CO'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'a_H a_CO2'
          oxidized_state_stoich = '0.6774 1.5'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.35   # fitted param
      [../]
  [../]
  # HCOO- + OH- <----> CO2 + H2O + 2 e-
  [./r_HCOO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 2.226E-12    # mol/cm^2/min
          equilibrium_potential = -0.02         # V

          reduced_state_vars = 'a_HCOO'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'a_H a_CO2'
          oxidized_state_stoich = '0.6774 2'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.43   # fitted param
      [../]
  [../]
  # C2H4 + 8 OH- <----> CO2 + 6 H2O + 8 e-
  [./r_C2H4]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 3.203E-18    # mol/cm^2/min
          equilibrium_potential = 0.07         # V

          reduced_state_vars = 'a_C2H4'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'a_CO2'
          oxidized_state_stoich = '1.36'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.41   # fitted param
      [../]
  [../]
  # C2H5OH + 12 OH- <----> 2 CO2 + 9 H2O + 12 e-
  [./r_C2H5OH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 5.267E-19    # mol/cm^2/min
          equilibrium_potential = 0.08         # V

          reduced_state_vars = 'a_C2H5OH'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'a_CO2'
          oxidized_state_stoich = '0.96'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.43   # fitted param
      [../]
  [../]
  # C3H7OH + 18 OH- <----> 3 CO2 + 13 H2O + 18 e-
  [./r_C3H7OH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 6.048E-19    # mol/cm^2/min
          equilibrium_potential = 0.09         # V

          reduced_state_vars = 'a_C3H7OH'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'a_CO2'
          oxidized_state_stoich = '0.96'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.40   # fitted param
      [../]
  [../]
  # C3H6O + 16 OH- <----> 3 CO2 + 11 H2O + 16 e-
  [./r_C3H6O]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 2.089E-21    # mol/cm^2/min
          equilibrium_potential = 0.05         # V

          reduced_state_vars = 'a_C3H6O'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'a_CO2'
          oxidized_state_stoich = '0.96'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.49   # fitted param
      [../]
  [../]
  # CH4 + 8 OH- <----> CO2 + 6 H2O + 8 e-
  [./r_CH4]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 2.519E-24    # mol/cm^2/min
          equilibrium_potential = 0.17         # V

          reduced_state_vars = 'a_CH4'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'a_H a_CO2'
          oxidized_state_stoich = '0.6774 0.84'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.84   # fitted param
      [../]
  [../]

  # ------------- Butler-Volmer current densities ---------
  [./J_H2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_H2
      [../]
  [../]
  [./J_CO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_CO
      [../]
  [../]
  [./J_HCOO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_HCOO
      [../]
  [../]
  [./J_C2H4]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_C2H4
      [../]
  [../]
  [./J_C2H5OH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_C2H5OH
      [../]
  [../]
  [./J_C3H7OH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_C3H7OH
      [../]
  [../]
  [./J_C3H6O]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_C3H6O
      [../]
  [../]
  [./J_CH4]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_CH4
      [../]
  [../]

  # Variable for potential difference
  [./phi_diff]
      order = FIRST
      family = LAGRANGE
      [./InitialCondition]
          type = InitialPotentialDifference
          electrode_potential = phi_s
          electrolyte_potential = phi_e
      [../]
  [../]

  # Speciation reaction rates
  # rate of water reaction
  # 1/min ==> convert to mol/cm^3/min via scale = C_ref
  [./r_w]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of CO2 -> HCO3 reaction
  # 1/min ==> convert to mol/cm^3/min via scale = C_ref
  [./r_1]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of HCO3 -> CO3 reaction
  # 1/min ==> convert to mol/cm^3/min via scale = C_ref
  [./r_2]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of alt CO2 -> HCO3 reaction
  # 1/min ==> convert to mol/cm^3/min via scale = C_ref
  [./r_3]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of alt HCO3 -> CO3 reaction
  # 1/min ==> convert to mol/cm^3/min via scale = C_ref
  [./r_4]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of alt HCOOH -> HCOO reaction
  # 1/min ==> convert to mol/cm^3/min via scale = C_ref
  [./r_5]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Ions/species
  [./C_H]
      order = FIRST
      family = MONOMIAL
      initial_condition = 4.5E-12 # mol/cm^3
  [../]
  [./C_H2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]
  [./C_Cs]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.0E-4 # mol/cm^3
  [../]
  [./C_OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.1E-9 # mol/cm^3
  [../]
  [./C_HCOO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]
  [./C_HCOOH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]
  [./C_HCO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 9.8E-5 # mol/cm^3
  [../]
  [./C_CO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 9.9E-7 # mol/cm^3
  [../]
  [./C_CO2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.0E-6 # mol/cm^3
  [../]
  [./C_CO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]
  [./C_CH4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]
  [./C_C2H4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]
  [./C_C2H5OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]
  [./C_C3H7OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]
  [./C_C3H6O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]

  # activities
  [./a_H]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_H
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
  [../]
  [./a_H2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_H2
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]
  [./a_Cs]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_Cs
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
  [../]
  [./a_OH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_OH
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
  [../]
  [./a_HCOO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_HCOO
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
  [../]
  [./a_HCOOH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_HCOOH
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]
  [./a_HCO3]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_HCO3
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
  [../]
  [./a_CO3]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_CO3
          activity_coeff = gamma2
          ref_conc = C_ref
      [../]
  [../]
  [./a_CO2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_CO2
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]
  [./a_CO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_CO
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]
  [./a_CH4]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_CH4
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]
  [./a_C2H4]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_C2H4
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]
  [./a_C2H5OH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_C2H5OH
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]
  [./a_C3H7OH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_C3H7OH
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]
  [./a_C3H6O]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = C_C3H6O
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
  [../]

[]

[AuxVariables]

  # Diffusivities
  [./D_H]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00417 #cm^2/min
  [../]
  [./D_H2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00417 #cm^2/min
  [../]
  [./D_Cs]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001302 #cm^2/min
  [../]
  [./D_OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.002958 #cm^2/min
  [../]
  [./D_HCOO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.000876 #cm^2/min
  [../]
  [./D_HCOOH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.000876 #cm^2/min
  [../]
  [./D_HCO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.000660 #cm^2/min
  [../]
  [./D_CO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0004806 #cm^2/min
  [../]
  [./D_CO2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001146 #cm^2/min
  [../]
  # ---------- below are all assumed ----------
  [./D_CO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001146 #cm^2/min
  [../]
  [./D_CH4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001146 #cm^2/min
  [../]
  [./D_C2H4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001146 #cm^2/min
  [../]
  [./D_C2H5OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001146 #cm^2/min
  [../]
  [./D_C3H7OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001146 #cm^2/min
  [../]
  [./D_C3H6O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001146 #cm^2/min
  [../]

  # reference conc
  [./C_ref]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001 # mol/cm^3
  [../]

  # ideal activity coeff
  [./gamma0]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 1
  [../]
  [./gamma1]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 1
  [../]
  [./gamma2]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 1
  [../]

  # Electrolyte current density in x (C/cm^2/min)
  [./ie_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Electrolyte current density in y (C/cm^2/min)
  [./ie_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # electrode current density in x (C/cm^2/min)
  [./is_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # electrode current density in y (C/cm^2/min)
  [./is_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # electrolyte temperature
  [./T_e]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300 # K
  [../]

  # electrode temperature
  [./T_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300 # K
  [../]

  #Specific surface area
  [./As]
    order = FIRST
    family = MONOMIAL
    initial_condition = 2E4  # cm^-1
  [../]

  # electrode porosity
  [./eps]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.68
  [../]

  # effective solid volume (1-eps)
  [./sol_vol_frac]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.32
  [../]

  # electrode conductivity (C/V/cm/min)
  [./sigma_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300     # 500 S/m  : 1 S = 1 A/V = 1 C/V/s
  [../]

  # Just to check calculation of electrolyte conductivity
  #   Not actually used in kernels
  [./Keff]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # C/V/cm/min
  [../]
[]

[Kernels]

  ## =============== Butler-Volmer Current ================
  [./J_H2_equ]
      type = Reaction
      variable = J_H2
  [../]
  [./J_H2_rxn]  # H2 + OH- <----> 2 H2O + 2 e-
      type = ButlerVolmerCurrentDensity
      variable = J_H2

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_H2
  [../]

  [./J_CO_equ]
      type = Reaction
      variable = J_CO
  [../]
  [./J_CO_rxn]  # CO + 2 OH- <----> CO2 + H2O + 2 e-
      type = ButlerVolmerCurrentDensity
      variable = J_CO

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_CO
  [../]

  [./J_HCOO_equ]
      type = Reaction
      variable = J_HCOO
  [../]
  [./J_HCOO_rxn]  # HCOO- + OH- <----> CO2 + H2O + 2 e-
      type = ButlerVolmerCurrentDensity
      variable = J_HCOO

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_HCOO
  [../]

  [./J_C2H4_equ]
      type = Reaction
      variable = J_C2H4
  [../]
  [./J_C2H4_rxn]  # C2H4 + 8 OH- <----> CO2 + 6 H2O + 8 e-
      type = ButlerVolmerCurrentDensity
      variable = J_C2H4

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_C2H4
  [../]

  [./J_C2H5OH_equ]
      type = Reaction
      variable = J_C2H5OH
  [../]
  [./J_C2H5OH_rxn]  # C2H5OH + 12 OH- <----> 2 CO2 + 9 H2O + 12 e-
      type = ButlerVolmerCurrentDensity
      variable = J_C2H5OH

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_C2H5OH
  [../]

  [./J_C3H7OH_equ]
      type = Reaction
      variable = J_C3H7OH
  [../]
  [./J_C3H7OH_rxn]  # C3H7OH + 18 OH- <----> 3 CO2 + 13 H2O + 18 e-
      type = ButlerVolmerCurrentDensity
      variable = J_C3H7OH

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_C3H7OH
  [../]

  [./J_C3H6O_equ]
      type = Reaction
      variable = J_C3H6O
  [../]
  [./J_C3H6O_rxn]  # C3H6O + 16 OH- <----> 3 CO2 + 11 H2O + 16 e-
      type = ButlerVolmerCurrentDensity
      variable = J_C3H6O

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_C3H6O
  [../]

  [./J_CH4_equ]
      type = Reaction
      variable = J_CH4
  [../]
  [./J_CH4_rxn]  # CH4 + 8 OH- <----> CO2 + 6 H2O + 8 e-
      type = ButlerVolmerCurrentDensity
      variable = J_CH4

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_CH4
  [../]

  ## =============== Potential Difference ==================
  [./phi_diff_equ]
      type = Reaction
      variable = phi_diff
  [../]
  [./phi_diff_sum]
      type = WeightedCoupledSumFunction
      variable = phi_diff
      coupled_list = 'phi_s phi_e'
      weights = '1 -1'
  [../]

  ### ==================== Electrolyte Potentials ==========================
  # Calculate potential from gradients in system
  [./phi_e_potential_conductivity]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'C_H C_Cs'
      diffusion = 'D_H D_Cs'
      ion_valence = '1 1'
  [../]
  [./phi_e_ionic_conductivity]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = eps
      ion_conc = 'C_H C_Cs'
      diffusion = 'D_H D_Cs'
      ion_valence = '1 1'
  [../]
  [./phi_e_J_H2]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = 'J_H2 J_CO J_HCOO J_C2H4 J_C2H5OH J_C3H7OH J_C3H6O J_CH4'
      weights = '1 1 1 1 1 1 1 1'
  [../]

  ### ==================== Electrode Potentials ==========================
  # Calculate potential from conductivity
  [./phi_s_pot_cond]
      type = ElectrodePotentialConductivity
      variable = phi_s
      solid_frac = sol_vol_frac
      conductivity = sigma_s
  [../]
  [./phi_s_J_H2]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_s
      coupled_list = 'J_H2 J_CO J_HCOO J_C2H4 J_C2H5OH J_C3H7OH J_C3H6O J_CH4'
      weights = '-1 -1 -1 -1 -1 -1 -1 -1'
  [../]

  ## =============== Butler-Volmer Kinetics ================
  [./r_H2_equ]
      type = Reaction
      variable = r_H2
  [../]
  [./r_H2_rxn]  # H2 + OH- <----> 2 H2O + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_H2

      reaction_rate_const = 3.955E-8    # mol/cm^2/min
      equilibrium_potential = 0         # V

      reduced_state_vars = 'a_H2'       # assumed
      reduced_state_stoich = '1'        # assumed

      oxidized_state_vars = 'a_H'
      oxidized_state_stoich = '0.1737'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.14   # fitted param
  [../]

  [./r_CO_equ]
      type = Reaction
      variable = r_CO
  [../]
  [./r_CO_rxn]  # CO + 2 OH- <----> CO2 + H2O + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_CO

      reaction_rate_const = 1.250E-9    # mol/cm^2/min
      equilibrium_potential = -0.11         # V

      reduced_state_vars = 'a_CO'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'a_H a_CO2'
      oxidized_state_stoich = '0.6774 1.5'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.35   # fitted param
  [../]

  [./r_HCOO_equ]
      type = Reaction
      variable = r_HCOO
  [../]
  [./r_HCOO_rxn]  # HCOO- + OH- <----> CO2 + H2O + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_HCOO

      reaction_rate_const = 2.226E-12    # mol/cm^2/min
      equilibrium_potential = -0.02         # V

      reduced_state_vars = 'a_HCOO'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'a_H a_CO2'
      oxidized_state_stoich = '0.6774 2'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.43   # fitted param
  [../]

  [./r_C2H4_equ]
      type = Reaction
      variable = r_C2H4
  [../]
  [./r_C2H4_rxn]  # C2H4 + 8 OH- <----> CO2 + 6 H2O + 8 e-
      type = ModifiedButlerVolmerReaction
      variable = r_C2H4

      reaction_rate_const = 3.203E-18    # mol/cm^2/min
      equilibrium_potential = 0.07         # V

      reduced_state_vars = 'a_C2H4'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'a_CO2'
      oxidized_state_stoich = '1.36'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.41   # fitted param
  [../]

  [./r_C2H5OH_equ]
      type = Reaction
      variable = r_C2H5OH
  [../]
  [./r_C2H5OH_rxn]  # C2H5OH + 12 OH- <----> 2 CO2 + 9 H2O + 12 e-
      type = ModifiedButlerVolmerReaction
      variable = r_C2H5OH

      reaction_rate_const = 5.267E-19    # mol/cm^2/min
      equilibrium_potential = 0.08         # V

      reduced_state_vars = 'a_C2H5OH'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'a_CO2'
      oxidized_state_stoich = '0.96'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.43   # fitted param
  [../]

  [./r_C3H7OH_equ]
      type = Reaction
      variable = r_C3H7OH
  [../]
  [./r_C3H7OH_rxn]  # C3H7OH + 18 OH- <----> 3 CO2 + 13 H2O + 18 e-
      type = ModifiedButlerVolmerReaction
      variable = r_C3H7OH

      reaction_rate_const = 6.048E-19    # mol/cm^2/min
      equilibrium_potential = 0.09         # V

      reduced_state_vars = 'a_C3H7OH'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'a_CO2'
      oxidized_state_stoich = '0.96'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.40   # fitted param
  [../]

  [./r_C3H6O_equ]
      type = Reaction
      variable = r_C3H6O
  [../]
  [./r_C3H6O_rxn]  # C3H6O + 16 OH- <----> 3 CO2 + 11 H2O + 16 e-
      type = ModifiedButlerVolmerReaction
      variable = r_C3H6O

      reaction_rate_const = 2.089E-21    # mol/cm^2/min
      equilibrium_potential = 0.05         # V

      reduced_state_vars = 'a_C3H6O'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'a_CO2'
      oxidized_state_stoich = '0.96'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.49   # fitted param
  [../]

  [./r_CH4_equ]
      type = Reaction
      variable = r_CH4
  [../]
  [./r_CH4_rxn]  # CH4 + 8 OH- <----> CO2 + 6 H2O + 8 e-
      type = ModifiedButlerVolmerReaction
      variable = r_CH4

      reaction_rate_const = 2.519E-24    # mol/cm^2/min
      equilibrium_potential = 0.17         # V

      reduced_state_vars = 'a_CH4'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'a_H a_CO2'
      oxidized_state_stoich = '0.6774 0.84'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.84   # fitted param
  [../]

  ## =============== Speciation Reactions ================

  ## =============== water reaction ================
  [./r_w_equ]
      type = Reaction
      variable = r_w
  [../]
  [./r_w_rxn]  #   H2O <--> H+ + OH-
      type = ConstReaction
      variable = r_w
      this_variable = r_w

      forward_rate = 9.6E-2
      reverse_rate = 9.6E12

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 0.001 # mol/cm^3

      reactants = '1'
      reactant_stoich = '1'
      products = 'a_H a_OH'
      product_stoich = '1 1'
  [../]

  ## =============== r1 reaction ================
  [./r_1_equ]
      type = Reaction
      variable = r_1
  [../]
  [./r_1_rxn]  #   CO2 + H2O <--> H+ + HCO3-
      type = ConstReaction
      variable = r_1
      this_variable = r_1

      forward_rate = 2.4E-0
      reverse_rate = 5.621E6

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 0.001 # mol/cm^3

      reactants = 'a_CO2'
      reactant_stoich = '1'
      products = 'a_H a_HCO3'
      product_stoich = '1 1'
  [../]

  ## =============== r2 reaction ================
  [./r_2_equ]
      type = Reaction
      variable = r_2
  [../]
  [./r_2_rxn]  #   HCO3- <--> H+ + CO3--
      type = ConstReaction
      variable = r_2
      this_variable = r_2

      forward_rate = 3.377E3
      reverse_rate = 7.3728E13

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 0.001 # mol/cm^3

      reactants = 'a_HCO3'
      reactant_stoich = '1'
      products = 'a_H a_CO3'
      product_stoich = '1 1'
  [../]

  ## =============== r3 reaction ================
  [./r_3_equ]
      type = Reaction
      variable = r_3
  [../]
  [./r_3_rxn]  #   CO2 + OH- <--> HCO3-
      type = ConstReaction
      variable = r_3
      this_variable = r_3

      forward_rate = 1.26E5
      reverse_rate = 2.951E-3

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 0.001 # mol/cm^3

      reactants = 'a_CO2 a_OH'
      reactant_stoich = '1 1'
      products = 'a_HCO3'
      product_stoich = '1'
  [../]

  ## =============== r4 reaction ================
  [./r_4_equ]
      type = Reaction
      variable = r_4
  [../]
  [./r_4_rxn]  #   HCO3- + OH- <--> CO3-- + H2O
      type = ConstReaction
      variable = r_4
      this_variable = r_4

      forward_rate = 3.9E11
      reverse_rate = 8.022E7

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 0.001 # mol/cm^3

      reactants = 'a_HCO3 a_OH'
      reactant_stoich = '1 1'
      products = 'a_CO3'
      product_stoich = '1'
  [../]

  ## =============== r5 reaction ================
  [./r_5_equ]
      type = Reaction
      variable = r_5
  [../]
  [./r_5_rxn]  #   HCOOH <--> H+ + HCOO-
      type = ConstReaction
      variable = r_5
      this_variable = r_5

      forward_rate = 2.424E7
      reverse_rate = 1.183E11

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 0.001 # mol/cm^3

      reactants = 'a_HCOOH'
      reactant_stoich = '1'
      products = 'a_H a_HCOO'
      product_stoich = '1 1'
  [../]


  ## =============== Mass Balances for Ions ================

  ## ============= H+ balance ==============
  [./H_dot]
      type = TimeDerivative
      variable = C_H
  [../]
  [./H_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_H
      coupled_list = 'r_w r_1 r_2 r_5'
      weights = '1 1 1 1'
      scale = 1
  [../]

  ## ============= OH- balance ==============
  [./OH_dot]
      type = TimeDerivative
      variable = C_OH
  [../]
  [./OH_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_OH
      coupled_list = 'r_w r_3 r_4'
      weights = '1 -1 -1'
      scale = 1
  [../]
  [./OH_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_OH
      coupled_list = 'r_H2 r_CO r_HCOO r_CH4 r_C2H4 r_C2H5OH r_C3H7OH r_C3H6O'
      weights = '-1 -2 -1 -8 -12 -12 -18 -16'
      scale = As
  [../]

  ## ============= CO2 balance ==============
  [./CO2_dot]
      type = TimeDerivative
      variable = C_CO2
  [../]
  [./CO2_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CO2
      coupled_list = 'r_1 r_3'
      weights = '-1 -1'
      scale = 1
  [../]
  [./CO2_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CO2
      coupled_list = 'r_CO r_HCOO r_CH4 r_C2H4 r_C2H5OH r_C3H7OH r_C3H6O'
      weights = '1 1 1 2 2 3 3'
      scale = As
  [../]

  ## ============= HCO3 balance ==============
  [./HCO3_dot]
      type = TimeDerivative
      variable = C_HCO3
  [../]
  [./HCO3_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_HCO3
      coupled_list = 'r_1 r_2 r_3 r_4'
      weights = '1 -1 1 -1'
      scale = 1
  [../]

  ## ============= CO3 balance ==============
  [./CO3_dot]
      type = TimeDerivative
      variable = C_CO3
  [../]
  [./CO3_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CO3
      coupled_list = 'r_2 r_4'
      weights = '1 1'
      scale = 1
  [../]

  ## ============= HCOOH balance ==============
  [./HCOOH_dot]
      type = TimeDerivative
      variable = C_HCOOH
  [../]
  [./HCOOH_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_HCOOH
      coupled_list = 'r_5'
      weights = '-1'
      scale = 1
  [../]

  ## ============= HCOO balance ==============
  [./HCOO_dot]
      type = TimeDerivative
      variable = C_HCOO
  [../]
  [./HCOO_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_HCOO
      coupled_list = 'r_5'
      weights = '1'
      scale = 1
  [../]
  [./HCOO_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_HCOO
      coupled_list = 'r_HCOO'
      weights = '-1'
      scale = As
  [../]

  ## ============= Cs balance ==============
  [./Cs_dot]
      type = TimeDerivative
      variable = C_Cs
  [../]
  [./Cs_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_Cs
      coupled_list = ''
      weights = ''
      scale = 1
  [../]

  ## ============= H2 balance ==============
  [./H2_dot]
      type = TimeDerivative
      variable = C_H2
  [../]
  [./H2_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_H2
      coupled_list = ''
      weights = ''
      scale = 1
  [../]
  [./H2_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_H2
      coupled_list = 'r_H2'
      weights = '-1'
      scale = As
  [../]

  ## ============= CO balance ==============
  [./CO_dot]
      type = TimeDerivative
      variable = C_CO
  [../]
  [./CO_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CO
      coupled_list = ''
      weights = ''
      scale = 1
  [../]
  [./CO_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CO
      coupled_list = 'r_CO'
      weights = '-1'
      scale = As
  [../]

  ## ============= CH4 balance ==============
  [./CH4_dot]
      type = TimeDerivative
      variable = C_CH4
  [../]
  [./CH4_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CH4
      coupled_list = ''
      weights = ''
      scale = 1
  [../]
  [./CH4_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_CH4
      coupled_list = 'r_CH4'
      weights = '-1'
      scale = As
  [../]

  ## ============= C2H4 balance ==============
  [./C2H4_dot]
      type = TimeDerivative
      variable = C_C2H4
  [../]
  [./C2H4_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_C2H4
      coupled_list = ''
      weights = ''
      scale = 1
  [../]
  [./C2H4_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_C2H4
      coupled_list = 'r_C2H4'
      weights = '-1'
      scale = As
  [../]

  ## ============= C2H5OH balance ==============
  [./C2H5OH_dot]
      type = TimeDerivative
      variable = C_C2H5OH
  [../]
  [./C2H5OH_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_C2H5OH
      coupled_list = ''
      weights = ''
      scale = 1
  [../]
  [./C2H5OH_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_C2H5OH
      coupled_list = 'r_C2H5OH'
      weights = '-1'
      scale = As
  [../]

  ## ============= C3H7OH balance ==============
  [./C3H7OH_dot]
      type = TimeDerivative
      variable = C_C3H7OH
  [../]
  [./C3H7OH_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_C3H7OH
      coupled_list = ''
      weights = ''
      scale = 1
  [../]
  [./C3H7OH_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_C3H7OH
      coupled_list = 'r_C3H7OH'
      weights = '-1'
      scale = As
  [../]

  ## ============= C3H6O balance ==============
  [./C3H6O_dot]
      type = TimeDerivative
      variable = C_C3H6O
  [../]
  [./C3H6O_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_C3H6O
      coupled_list = ''
      weights = ''
      scale = 1
  [../]
  [./C3H6O_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_C3H6O
      coupled_list = 'r_C3H6O'
      weights = '-1'
      scale = As
  [../]

  ## =============== Activity Constraints ==================

  ## =============== H+ activity constraint ================
  [./a_H_equ]
      type = Reaction
      variable = a_H
  [../]
  [./a_H_cons]
      type = ActivityConstraint
      variable = a_H
      concentration = C_H
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== OH- activity constraint ================
  [./a_OH_equ]
      type = Reaction
      variable = a_OH
  [../]
  [./a_OH_cons]
      type = ActivityConstraint
      variable = a_OH
      concentration = C_OH
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== CO2 activity constraint ================
  [./a_CO2_equ]
      type = Reaction
      variable = a_CO2
  [../]
  [./a_CO2_cons]
      type = ActivityConstraint
      variable = a_CO2
      concentration = C_CO2
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== HCO3 activity constraint ================
  [./a_HCO3_equ]
      type = Reaction
      variable = a_HCO3
  [../]
  [./a_HCO3_cons]
      type = ActivityConstraint
      variable = a_HCO3
      concentration = C_HCO3
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== CO3 activity constraint ================
  [./a_CO3_equ]
      type = Reaction
      variable = a_CO3
  [../]
  [./a_CO3_cons]
      type = ActivityConstraint
      variable = a_CO3
      concentration = C_CO3
      activity_coeff = gamma2
      ref_conc = C_ref
  [../]

  ## =============== HCOOH activity constraint ================
  [./a_HCOOH_equ]
      type = Reaction
      variable = a_HCOOH
  [../]
  [./a_HCOOH_cons]
      type = ActivityConstraint
      variable = a_HCOOH
      concentration = C_HCOOH
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== HCOO activity constraint ================
  [./a_HCOO_equ]
      type = Reaction
      variable = a_HCOO
  [../]
  [./a_HCOO_cons]
      type = ActivityConstraint
      variable = a_HCOO
      concentration = C_HCOO
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== Cs+ activity constraint ================
  [./a_Cs_equ]
      type = Reaction
      variable = a_Cs
  [../]
  [./a_Cs_cons]
      type = ActivityConstraint
      variable = a_Cs
      concentration = C_Cs
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== H2 activity constraint ================
  [./a_H2_equ]
      type = Reaction
      variable = a_H2
  [../]
  [./a_H2_cons]
      type = ActivityConstraint
      variable = a_H2
      concentration = C_H2
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== CO activity constraint ================
  [./a_CO_equ]
      type = Reaction
      variable = a_CO
  [../]
  [./a_CO_cons]
      type = ActivityConstraint
      variable = a_CO
      concentration = C_CO
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== CH4 activity constraint ================
  [./a_CH4_equ]
      type = Reaction
      variable = a_CH4
  [../]
  [./a_CH4_cons]
      type = ActivityConstraint
      variable = a_CH4
      concentration = C_CH4
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== C2H4 activity constraint ================
  [./a_C2H4_equ]
      type = Reaction
      variable = a_C2H4
  [../]
  [./a_C2H4_cons]
      type = ActivityConstraint
      variable = a_C2H4
      concentration = C_C2H4
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== C2H5OH activity constraint ================
  [./a_C2H5OH_equ]
      type = Reaction
      variable = a_C2H5OH
  [../]
  [./a_C2H5OH_cons]
      type = ActivityConstraint
      variable = a_C2H5OH
      concentration = C_C2H5OH
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== C3H7OH activity constraint ================
  [./a_C3H7OH_equ]
      type = Reaction
      variable = a_C3H7OH
  [../]
  [./a_C3H7OH_cons]
      type = ActivityConstraint
      variable = a_C3H7OH
      concentration = C_C3H7OH
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== C3H6O activity constraint ================
  [./a_C3H6O_equ]
      type = Reaction
      variable = a_C3H6O
  [../]
  [./a_C3H6O_cons]
      type = ActivityConstraint
      variable = a_C3H6O
      concentration = C_C3H6O
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

[]

[DGKernels]
[]

[AuxKernels]
    [./Keff_calc]
        type = ElectrolyteConductivity
        variable = Keff
        temperature = T_e
        ion_conc = 'C_H C_Cs'
        diffusion = 'D_H D_Cs'
        ion_valence = '1 1'
        execute_on = 'initial timestep_end'
    [../]

    [./non_pore_calc]
        type = SolidsVolumeFraction
        variable = sol_vol_frac
        porosity = eps
        execute_on = 'initial timestep_end'
    [../]

    [./ie_x_calc]
        type = AuxElectrolyteCurrent
        variable = ie_x
        direction = 0         # 0=x
        electric_potential = phi_e
        porosity = eps
        temperature = T_e
        ion_conc = 'C_H C_Cs'
        diffusion = 'D_H D_Cs'
        ion_valence = '1 1'
        execute_on = 'initial timestep_end'
    [../]
    [./ie_y_calc]
        type = AuxElectrolyteCurrent
        variable = ie_y
        direction = 1         # 0=x
        electric_potential = phi_e
        porosity = eps
        temperature = T_e
        ion_conc = 'C_H C_Cs'
        diffusion = 'D_H D_Cs'
        ion_valence = '1 1'
        execute_on = 'initial timestep_end'
    [../]

    [./is_x_calc]
        type = AuxElectrodeCurrent
        variable = is_x
        direction = 0         # 0=x
        electric_potential = phi_s
        solid_frac = sol_vol_frac
        conductivity = sigma_s
        execute_on = 'initial timestep_end'
    [../]
    [./is_y_calc]
        type = AuxElectrodeCurrent
        variable = is_y
        direction = 1         # 0=x
        electric_potential = phi_s
        solid_frac = sol_vol_frac
        conductivity = sigma_s
        execute_on = 'initial timestep_end'
    [../]
[]

[BCs]

  ### BCs for phi_e ###
  # 'ground side'
  [./phi_e_left]
      type = FunctionNeumannBC
      variable = phi_e
      boundary = 'left'
      function = '0'
  [../]
  # 'membrane side'
  [./phi_e_right]
      type = FunctionNeumannBC
      variable = phi_e
      boundary = 'right'
      function = '0.36'     # correspond to 6 mA/cm^2
  [../]

  ### BCs for phi_s ###
  # 'ground side'
  [./phi_s_left]
      type = FunctionDirichletBC
      variable = phi_s
      boundary = 'left'
      function = '1.4'
  [../]
  # 'membrane side'
  [./phi_s_right]
      type = FunctionNeumannBC
      variable = phi_s
      boundary = 'right'
      function = '0'
  [../]
[]

[Postprocessors]

  [./C_H_avg]
      type = ElementAverageValue
      variable = C_H
      execute_on = 'initial timestep_end'
  [../]

  [./C_OH_avg]
      type = ElementAverageValue
      variable = C_OH
      execute_on = 'initial timestep_end'
  [../]

  [./C_HCO3_avg]
      type = ElementAverageValue
      variable = C_HCO3
      execute_on = 'initial timestep_end'
  [../]

  [./C_CO3_avg]
      type = ElementAverageValue
      variable = C_CO3
      execute_on = 'initial timestep_end'
  [../]

  [./C_CO2_avg]
      type = ElementAverageValue
      variable = C_CO2
      execute_on = 'initial timestep_end'
  [../]

  [./C_HCOOH_avg]
      type = ElementAverageValue
      variable = C_HCOOH
      execute_on = 'initial timestep_end'
  [../]

  [./C_HCOO_avg]
      type = ElementAverageValue
      variable = C_HCOO
      execute_on = 'initial timestep_end'
  [../]

  [./C_CO_avg]
      type = ElementAverageValue
      variable = C_CO
      execute_on = 'initial timestep_end'
  [../]

  [./C_H2_avg]
      type = ElementAverageValue
      variable = C_H2
      execute_on = 'initial timestep_end'
  [../]

  [./C_CH4_avg]
      type = ElementAverageValue
      variable = C_CH4
      execute_on = 'initial timestep_end'
  [../]

  [./C_C2H4_avg]
      type = ElementAverageValue
      variable = C_C2H4
      execute_on = 'initial timestep_end'
  [../]

  [./C_C2H5OH_avg]
      type = ElementAverageValue
      variable = C_C2H5OH
      execute_on = 'initial timestep_end'
  [../]

  [./C_C3H7OH_avg]
      type = ElementAverageValue
      variable = C_C3H7OH
      execute_on = 'initial timestep_end'
  [../]

  [./C_C3H6O_avg]
      type = ElementAverageValue
      variable = C_C3H6O
      execute_on = 'initial timestep_end'
  [../]

  [./phi_e_left]
      type = SideAverageValue
      boundary = 'left'
      variable = phi_e
      execute_on = 'initial timestep_end'
  [../]

  [./phi_e_right]
      type = SideAverageValue
      boundary = 'right'
      variable = phi_e
      execute_on = 'initial timestep_end'
  [../]

  [./phi_s_left]
      type = SideAverageValue
      boundary = 'left'
      variable = phi_s
      execute_on = 'initial timestep_end'
  [../]

  [./phi_s_right]
      type = SideAverageValue
      boundary = 'right'
      variable = phi_s
      execute_on = 'initial timestep_end'
  [../]

  [./is_left]
      type = SideAverageValue
      boundary = 'left'
      variable = is_x
      execute_on = 'initial timestep_end'
  [../]

  [./is_right]
      type = SideAverageValue
      boundary = 'right'
      variable = is_x
      execute_on = 'initial timestep_end'
  [../]

  [./ie_left]
      type = SideAverageValue
      boundary = 'left'
      variable = ie_x
      execute_on = 'initial timestep_end'
  [../]

  [./ie_right]
      type = SideAverageValue
      boundary = 'right'
      variable = ie_x
      execute_on = 'initial timestep_end'
  [../]
[]

[Executioner]
  type = Transient
  scheme = implicit-euler

  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason

                    -ksp_gmres_modifiedgramschmidt
                    -ksp_ksp_gmres_modifiedgramschmidt'

  # NOTE: The sub_pc_type arg not used if pc_type is ksp,
  #       Instead, set the ksp_ksp_type to the pc method
  #       you want. Then, also set the ksp_pc_type to be
  #       the terminal preconditioner.
  #
  # Good terminal precon options: lu, ilu, asm, gasm, pbjacobi
  #                               bjacobi, redundant, telescope
  #
  # NOTE: -ksp_pc_factor_mat_solver_type == (mumps or superlu_dist)
  petsc_options_iname ='-ksp_type
                        -pc_type

                        -sub_pc_type

                        -snes_max_it

                        -sub_pc_factor_shift_type
                        -pc_factor_shift_type
                        -ksp_pc_factor_shift_type

                        -pc_asm_overlap

                        -snes_atol
                        -snes_rtol

                        -ksp_ksp_type
                        -ksp_pc_type

                        -ksp_gmres_restart
                        -ksp_ksp_gmres_restart

                        -ksp_max_it
                        -ksp_ksp_max_it'

  ## NOTE: May be best to just use lu as pc_type instead of ksp
  petsc_options_value = 'fgmres
                         ksp

                         ilu

                         50

                         NONZERO
                         NONZERO
                         NONZERO

                         20

                         1E-12
                         1E-12

                         fgmres
                         ilu

                         30
                         30

                         30
                         30'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 20

  # Time in min
  start_time = 0.0
  end_time = 10
  dtmax = 2

  # NOTE: Maximum step size to start is 0.01
  [./TimeStepper]
     type = SolutionTimeAdaptiveDT
     dt = 0.01
     cutback_factor_at_failure = 0.5
     percent_change = 0.7
  [../]

[] #END Executioner

[Preconditioning]
    [./SMP_PJFNK]
      type = SMP
      full = true
      solve_type = pjfnk
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = true

[] #END Outputs
