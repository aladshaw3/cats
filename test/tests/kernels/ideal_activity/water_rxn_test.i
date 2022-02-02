# NOTE: Be aware that when doing the reactions in this manner, we are
#       needing to solve for concentrations in a very dilute system.
#       Updating and tightening tolerances may be necessary for accuracy.

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 1
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
[] # END Mesh

[Variables]
  # H+ concentration
  [./C_H]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]

  # OH- concentration
  [./C_OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
  [../]

  # H+ activity (unitless)
  [./a_H]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # OH- activity (unitless)
  [./a_OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # rate of water reaction
  # 1/s ==> convert to mol/cm^3/s via scale = C_ref
  [./r_w]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]
[]

[AuxVariables]
  # ideal activity coeff
  [./gamma]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1
  [../]

  # ref conc
  [./C_ref]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001 # mol/cm^3
  [../]
[]

[Kernels]

  ## =============== water reaction ================
  [./r_w_equ]
    type = Reaction
    variable = r_w
  [../]
  [./r_w_rxn]  #   H2O <--> H+ + OH-
    type = ConstReaction
    variable = r_w
    this_variable = r_w

    forward_rate = 1.6E-3
    reverse_rate = 1.6E11

    reactants = '1'
    reactant_stoich = '1'
    products = 'a_H a_OH'
    product_stoich = '1 1'
  [../]

  ## ============= H+ balance ==============
  [./H_dot]
      type = TimeDerivative
      variable = C_H
  [../]
  [./H_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_H
      coupled_list = 'r_w'
      weights = '1'
      scale = C_ref
  [../]

  ## ============= OH- balance ==============
  [./OH_dot]
      type = TimeDerivative
      variable = C_OH
  [../]
  [./OH_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = C_OH
      coupled_list = 'r_w'
      weights = '1'
      scale = C_ref
  [../]

  ## =============== H+ activity constraint ================
  [./a_H_equ]
    type = Reaction
    variable = a_H
  [../]
  [./a_H_cons]
    type = ActivityConstraint
    variable = a_H
    concentration = C_H
    activity_coeff = gamma
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
    activity_coeff = gamma
    ref_conc = C_ref
  [../]
[]

[DGKernels]
[]

[AuxKernels]
[]

[BCs]
[]

[Postprocessors]
  [./C_H]
      type = ElementAverageValue
      variable = C_H
      execute_on = 'initial timestep_end'
  [../]
  [./C_OH]
      type = ElementAverageValue
      variable = C_OH
      execute_on = 'initial timestep_end'
  [../]
  [./a_H]
      type = ElementAverageValue
      variable = a_H
      execute_on = 'initial timestep_end'
  [../]
  [./a_OH]
      type = ElementAverageValue
      variable = a_OH
      execute_on = 'initial timestep_end'
  [../]
[]

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

  petsc_options_value = 'fgmres
                         ksp

                         ilu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-12
                         1E-12

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

  start_time = 0.0
  end_time = 0.0005
  dtmax = 1

  [./TimeStepper]
     type = ConstantDT
     dt = 0.0001
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
