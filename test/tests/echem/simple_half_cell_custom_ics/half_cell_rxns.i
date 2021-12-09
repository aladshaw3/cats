# Validation Test: Compute potentials assuming
# constant, uniform concentration profiles.
# Includes Butler-Volmer kinetics to validate
# that portion of the physics, since others
# were independently validated already.

# NOTE: The Keff calculation does not match what
# is reported in literature given the values they
# state in there problem. We correct this in our example.

# NOTE 2: Literature conveniently left off some
# computation details, forcing me to 'guess' some
# values. The 'equilibrium_potential' is has been
# determined to be -0.3497 V (to give constant U of -0.255 V)
#
# Reaction rate should be 1.75E-7 m/s.

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 20
    ny = 1
    xmin = 0.0
    xmax = 0.004   # m
    ymin = 0.0
    ymax = 0.0004  # m
[] # END Mesh

[Variables]
  # electrolyte potential (in V or J/C)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.2595
  [../]

  # electrode potential (in V or J/C)
  [./phi_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # H+ concentration (solved from electroneutrality)
  [./C_H]
      order = FIRST
      family = MONOMIAL
      initial_condition = 4413 # mol/m^3
  [../]

  # Butler-Volmer reaction rate
  [./r]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 1.75E-7  # m/s
          equilibrium_potential = -0.3497 # V  (gives U = -0.255 V)

          reduced_state_vars = 'C_V_II'
          reduced_state_stoich = '1'

          oxidized_state_vars = 'C_V_III'
          oxidized_state_stoich = '1'

          electric_potential_difference = phi_diff

          temperature = Te
          number_of_electrons = 1
          electron_transfer_coef = 0.5
      [../]
  [../]

  # Butler-Volmer current density
  [./J]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1
          specific_area = As
          rate_var = r
      [../]
  [../]

  # Variable for potential difference
  [./phi_diff]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialPotentialDifference
          electrode_potential = phi_s
          electrolyte_potential = phi_e
      [../]
  [../]

  # Electrolyte current density in x (C/m^2/s)
  [./ie_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # electrode current density in x (C/m^2/s)
  [./is_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]
[]

[AuxVariables]
  # Ions/metals
  [./C_V_II]
      order = FIRST
      family = MONOMIAL
      initial_condition = 27 # mol/m^3
  [../]
  [./C_V_III]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1053 # mol/m^3
  [../]
  [./C_HSO4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1200 # mol/m^3
  [../]
  [./C_SO4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1606.5 # mol/m^3
  [../]

  # Filler concentration to get Keff correct
  [./C_f]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1200 # mol/m^3
  [../]

  # Diff Coeffs
  [./D_V_II]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.4E-10 # m^2/s
  [../]
  [./D_V_III]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.4E-10 # m^2/s
  [../]
  [./D_HSO4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.23E-9 # m^2/s
  [../]
  [./D_SO4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.2E-10 # m^2/s
  [../]
  [./D_H]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.4E-9 # m^2/s
  [../]

  # Filler to get Keff correct
  [./D_f]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.55369e-6 # m^2/s
  [../]

  # temperature in K
  [./Te]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300
  [../]

  # Keff
  [./Keff]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # C/V/m/s  (or S/m)
  [../]

  # sigma_s
  [./sigma_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 90.5 # C/V/m/s  (or S/m)
  [../]

  #Specific surface area (adjusted)
  [./As]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1.359301E6  # m^-1
  [../]

  # eps_e
  [./eps_e]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.68
  [../]
  # eps_s
  [./eps_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.32
  [../]
[]

[Kernels]

  ## =============== Butler-Volmer Current ================
  [./J_equ]
    type = Reaction
    variable = J
  [../]
  [./J_rxn]  #   C_V_II <--> C_V_III + e-
    type = ButlerVolmerCurrentDensity
    variable = J

    number_of_electrons = 1
    specific_area = As
    rate_var = r
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
  [./phi_e_pot_cond]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = 1
      temperature = Te
      ion_conc = 'C_V_II C_V_III C_HSO4 C_SO4 C_H C_f'
      diffusion = 'D_V_II D_V_III D_HSO4 D_SO4 D_H D_f'
      ion_valence = '2 3 -1 -2 1 -1'
  [../]
  [./phi_e_J]
    type = ScaledWeightedCoupledSumFunction
    variable = phi_e
    coupled_list = 'J'
    weights = '1'
  [../]

  ### ==================== Electrode Potentials ==========================
  # Calculate potential from conductivity
  [./phi_s_pot_cond]
      type = ElectrodePotentialConductivity
      variable = phi_s
      solid_frac = 1
      conductivity = sigma_s
  [../]
  [./phi_s_J]
    type = ScaledWeightedCoupledSumFunction
    variable = phi_s
    coupled_list = 'J'
    weights = '-1'
  [../]

  ## electroneutrality
  [./ENE]
      type = MaterialBalance
      variable = C_H
      this_variable = C_H
      total_material = 0
      coupled_list = 'C_H C_HSO4 C_SO4'
      weights = '1 -1 -2'
  [../]

  ## =============== Butler-Volmer Kinetics ================
  [./r_equ]
    type = Reaction
    variable = r
  [../]
  [./r_rxn]  #   C_V_II <--> C_V_III + e-
    type = ModifiedButlerVolmerReaction
    variable = r

    reaction_rate_const = 1.75E-7  # m/s
    equilibrium_potential = -0.3497 # V  (gives U = -0.255 V)

    reduced_state_vars = 'C_V_II'
    reduced_state_stoich = '1'

    oxidized_state_vars = 'C_V_III'
    oxidized_state_stoich = '1'

    electric_potential_difference = phi_diff

    temperature = Te
    number_of_electrons = 1
    electron_transfer_coef = 0.5
  [../]

  # Current density in x-dir from potential gradient
  #  ie_x
  [./ie_x_equ]
      type = Reaction
      variable = ie_x
  [../]
  #  -K*grad(phi_e)_x   where K=f(ions, diff, etc....)
  [./ie_x_phigrad]
      type = ElectrolyteCurrentFromPotentialGradient
      variable = ie_x
      direction = 0         # 0=x
      electric_potential = phi_e
      porosity = 1
      temperature = Te
      ion_conc = 'C_V_II C_V_III C_HSO4 C_SO4 C_H C_f'
      diffusion = 'D_V_II D_V_III D_HSO4 D_SO4 D_H D_f'
      ion_valence = '2 3 -1 -2 1 -1'
  [../]

  # Current density in x-dir from potential gradient
  #  is_x
  [./is_x_equ]
      type = Reaction
      variable = is_x
  [../]
  #  -sigma*(1-eps)*grad(phi_s)_x
  [./is_x_phigrad]
      type = ElectrodeCurrentFromPotentialGradient
      variable = is_x
      direction = 0         # 0=x
      electric_potential = phi_s
      solid_frac = 1
      conductivity = sigma_s
  [../]

[]

[DGKernels]
[]

[AuxKernels]

    [./Keff_calc]
        type = ElectrolyteConductivity
        variable = Keff
        temperature = Te
        ion_conc = 'C_V_II C_V_III C_HSO4 C_SO4 C_H C_f'
        diffusion = 'D_V_II D_V_III D_HSO4 D_SO4 D_H D_f'
        ion_valence = '2 3 -1 -2 1 -1'
        execute_on = 'initial timestep_end'
    [../]

    [./non_pore_calc]
        type = SolidsVolumeFraction
        variable = eps_s
        porosity = eps_e
        execute_on = 'initial timestep_end'
    [../]
[]

[BCs]
  active = 'phi_e_left
            phi_e_right
            phi_s_left
            phi_s_right'

  ### BCs for phi_e ###
  [./phi_e_left]
      type = FunctionNeumannBC
      variable = phi_e
      boundary = 'left'
      function = '0'
  [../]
  [./phi_e_right]
      type = FunctionNeumannBC
      variable = phi_e
      boundary = 'right'
      function = '1000'
  [../]

  ### BCs for phi_s ###
  [./phi_s_left]
      type = FunctionDirichletBC
      variable = phi_s
      boundary = 'left'
      function = '0'
  [../]
  [./phi_s_right]
      type = FunctionNeumannBC
      variable = phi_s
      boundary = 'right'
      function = '0'
  [../]
[]

[Postprocessors]
  [./is_left]
      type = SideAverageValue
      boundary = 'left'
      variable = is_x
      execute_on = 'initial timestep_end'
  [../]

  [./ie_left]
      type = SideAverageValue
      boundary = 'left'
      variable = ie_x
      execute_on = 'initial timestep_end'
  [../]

  [./J_avg]
      type = ElementAverageValue
      variable = J
      execute_on = 'initial timestep_end'
  [../]

  [./r_avg]
      type = ElementAverageValue
      variable = r
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
[]

[Executioner]
  type = Steady
  #scheme = implicit-euler

  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason

                    -ksp_gmres_modifiedgramschmidt'

  # NOTE: The sub_pc_type arg not used if pc_type is ksp,
  #       Instead, set the ksp_ksp_type to the pc method
  #       you want. Then, also set the ksp_pc_type to be
  #       the terminal preconditioner.
  #
  # Good terminal precon options: lu, ilu, asm, gasm, pbjacobi
  #                               bjacobi, redundant, telescope
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
                        -ksp_pc_type'

  # snes_max_it = maximum non-linear steps


  ######## NOTE: Best convergence results with asm pc and lu sub-pc ##############
  ##      Issue may be caused by the terminal pc of the ksp pc method
  #       using MUMPS as the linear solver (which is an inefficient method)

  petsc_options_value = 'fgmres
                         ksp

                         ilu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-10
                         1E-10

                         fgmres
                         ilu'

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
