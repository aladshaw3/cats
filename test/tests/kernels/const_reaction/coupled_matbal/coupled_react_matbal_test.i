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
  [./C]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]
[]
 
[AuxVariables]
  [./total]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
  [../]
[]

[Kernels]
  [./mat_bal]
    type = MaterialBalance
    variable = A
    this_variable = A
    coupled_list = 'A B C'
    weights = '1 1 2'
    total_material = total
  [../]
 
  [./B_dot]
    type = TimeDerivative
    variable = B
  [../]
  [./B_gain]  #   A --> B
    type = ConstReaction
    variable = B
    this_variable = B
    forward_rate = 1.0
    reverse_rate = 0.0
    scale = 1.0
    reactants = 'A'
    reactant_stoich = '1'
    products = ''
    product_stoich = ''
  [../]
  [./B_loss]  #   2B --> C
    type = ConstReaction
    variable = B
    this_variable = B
    forward_rate = 1.0
    reverse_rate = 0.0
    scale = -2.0
    reactants = 'B'
    reactant_stoich = '2'
    products = ''
    product_stoich = ''
  [../]
 
  [./C_dot]
    type = TimeDerivative
    variable = C
  [../]
  [./C_gain]  #   2B --> C
    type = ConstReaction
    variable = C
    this_variable = C
    forward_rate = 1.0
    reverse_rate = 0.0
    scale = 1.0
    reactants = 'B'
    reactant_stoich = '2'
    products = ''
    product_stoich = ''
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
    [./C]
       type = ElementAverageValue
       variable = C
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

