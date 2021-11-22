# Test validates that the kernel works as intended compared to
# a standard reaction kernel developed previously. It does not
# couple directly with potential or temperature yet.

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

  [./Abv]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
  [../]
  [./Bbv]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
  [./rbv]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
[]

[AuxVariables]

[]

[Kernels]
  [./A_dot]
     type = TimeDerivative
     variable = A
  [../]
  [./A_decay]  #   2A <--> B
    type = ScaledWeightedCoupledSumFunction
    variable = A
    coupled_list = 'r'
    weights = '-2'
    scale = 1.0
  [../]

  [./B_dot]
    type = TimeDerivative
    variable = B
  [../]
  [./B_gain]  #   2A <--> B
    type = ScaledWeightedCoupledSumFunction
    variable = B
    coupled_list = 'r'
    weights = '1'
    scale = 1.0
  [../]

  [./r_equ]
    type = Reaction
    variable = r
  [../]
  [./r_rxn]  #   2A <--> B
    type = ConstReaction
    variable = r
    this_variable = r
    forward_rate = 1.0
    reverse_rate = 1.0
    scale = 1.0
    reactants = 'A'
    reactant_stoich = '2'
    products = 'B'
    product_stoich = '1'
  [../]

  [./Abv_dot]
     type = TimeDerivative
     variable = Abv
  [../]
  [./Abv_decay]  #   2A <--> B
    type = ScaledWeightedCoupledSumFunction
    variable = Abv
    coupled_list = 'rbv'
    weights = '-2'
    scale = 1.0
  [../]

  [./Bbv_dot]
    type = TimeDerivative
    variable = Bbv
  [../]
  [./Bbv_gain]  #   2A <--> B
    type = ScaledWeightedCoupledSumFunction
    variable = Bbv
    coupled_list = 'rbv'
    weights = '1'
    scale = 1.0
  [../]

  [./rbv_equ]
    type = Reaction
    variable = rbv
  [../]
  [./rbv_rxn]  #   2A <--> B
    type = ModifiedButlerVolmerReaction
    variable = rbv

    use_equilibrium_potential = true

    reaction_rate_const = 1.0
    equilibrium_potential = 0

    scale = 1.0
    reduced_state_vars = 'Abv'
    reduced_state_stoich = '2'

    oxidized_state_vars = 'Bbv'
    oxidized_state_stoich = '1'

    electric_potential_difference = 0
    temperature = 298
    number_of_electrons = 1
    electron_transfer_coef = 0.5
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

    [./Abv]
        type = ElementAverageValue
        variable = Abv
        execute_on = 'initial timestep_end'
    [../]
    [./Bbv]
       type = ElementAverageValue
       variable = Bbv
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
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 2.0
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
