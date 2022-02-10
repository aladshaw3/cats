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

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 5
    ny = 10
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
      initial_condition = 0
  [../]

  # electrode potential (in V or J/C)
  [./phi_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
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
[]

[AuxVariables]
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
      coupled_list = 'J_H2 J_CO'
      weights = '1 1'
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
      coupled_list = 'J_H2 J_CO'
      weights = '-1 -1'
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
      function = '-1.4'
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
  [./J_CO_avg]
      type = ElementAverageValue
      variable = J_CO
      execute_on = 'initial timestep_end'
  [../]

  [./r_CO_avg]
      type = ElementAverageValue
      variable = r_CO
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

  [./phi_diff]
      type = ElementAverageValue
      variable = phi_diff
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
  type = Steady
  #scheme = implicit-euler

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

                         10

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
