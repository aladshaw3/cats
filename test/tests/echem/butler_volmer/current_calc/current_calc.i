# Test validates that current calculation comes
# out correct based on given inputs.

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 1
  ny = 1
[]

[Variables]
  [./A]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
  [../]
  [./B]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
  [./r]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
  [./J]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./phi_e]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
  [./phi_s]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
  [./phi_diff]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
[]

[AuxVariables]

  [./As]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.5
  [../]

  [./eps_e]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.5
  [../]

  [./eps_s]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.5
  [../]

[]

[Kernels]

  [./A_dot]
     type = VariableCoefTimeDerivative
     variable = A
     coupled_coef = eps_s
  [../]
  [./A_decay]  #   A <--> B + e-
    type = ScaledWeightedCoupledSumFunction
    variable = A
    coupled_list = 'r'
    weights = '-1'
    scale = As
  [../]

  [./B_dot]
    type = VariableCoefTimeDerivative
    variable = B
    coupled_coef = eps_e
  [../]
  [./B_gain]  #   A <--> B + e-
    type = ScaledWeightedCoupledSumFunction
    variable = B
    coupled_list = 'r'
    weights = '1'
    scale = As
  [../]

  [./r_equ]
    type = Reaction
    variable = r
  [../]
  [./r_rxn]  #   A <--> B + e-
    type = ModifiedButlerVolmerReaction
    variable = r

    oxidation_rate_const = 0.25
    reduction_rate_const = 0.025

    scale = 1.0
    reduced_state_vars = 'A'
    reduced_state_stoich = '1'

    oxidized_state_vars = 'B'
    oxidized_state_stoich = '1'

    electric_potential_difference = phi_diff
    temperature = 298
    number_of_electrons = 1
    electron_transfer_coef = 0.5
  [../]

  [./J_equ]
    type = Reaction
    variable = J
  [../]
  [./J_rxn]  #   A <--> B + e-
    type = ButlerVolmerCurrentDensity
    variable = J

    number_of_electrons = 1
    specific_area = As
    rate_var = r
  [../]


  # NOTE: These relationships for phi_e and phi_s are NOT real!
  #       This is just for testing purposes.
  [./phi_e_dot]
    type = VariableCoefTimeDerivative
    variable = phi_e
    coupled_coef = 5e5
  [../]
  [./phi_e_J]
    type = ScaledWeightedCoupledSumFunction
    variable = phi_e
    coupled_list = 'J'
    weights = '-1'
    scale = 1
  [../]

  [./phi_s_dot]
    type = VariableCoefTimeDerivative
    variable = phi_s
    coupled_coef = 5e5
  [../]
  [./phi_s_J]
    type = ScaledWeightedCoupledSumFunction
    variable = phi_s
    coupled_list = 'J'
    weights = '1'
    scale = 1
  [../]

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
[]

[BCs]

[]

[Postprocessors]
    [./A]
        type = ElementAverageValue
        variable = A
        execute_on = 'initial timestep_end'
    [../]
    [./B]
       type = ElementAverageValue
       variable = B
       execute_on = 'initial timestep_end'
    [../]
    [./r]
       type = ElementAverageValue
       variable = r
       execute_on = 'initial timestep_end'
    [../]
    [./J]
       type = ElementAverageValue
       variable = J
       execute_on = 'initial timestep_end'
    [../]

    [./phi_e]
        type = ElementAverageValue
        variable = phi_e
        execute_on = 'initial timestep_end'
    [../]
    [./phi_s]
       type = ElementAverageValue
       variable = phi_s
       execute_on = 'initial timestep_end'
    [../]
    [./phi_diff]
       type = ElementAverageValue
       variable = phi_diff
       execute_on = 'initial timestep_end'
    [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
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

  petsc_options_value = 'gmres
                         ksp

                         lu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-10
                         1E-10

                         gmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = bt
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 0.1
  dtmax = 0.0125

  [./TimeStepper]
     type = ConstantDT
     dt = 0.0125
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
