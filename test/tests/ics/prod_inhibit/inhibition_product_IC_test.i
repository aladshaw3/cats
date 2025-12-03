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
#Inhibition variable to be made as the product of inhibition from A and B (R = RA*RB)
  [./R]
    order = FIRST
    family = MONOMIAL
    [./InitialCondition]
        type = InitialInhibitionProducts
        coupled_list = 'RA RB'
        power_list = '1 1'
    [../]
  [../]
 
#Individual inhibition terms for A and B
  [./RA]
    order = FIRST
    family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'A'
        pre_exponentials = '1'
    [../]
  [../]
 
  [./RB]
    order = FIRST
    family = MONOMIAL
    [./InitialCondition]
        type = InitialLangmuirInhibition
        temperature = temp
        coupled_list = 'B'
        pre_exponentials = '1'
    [../]
  [../]
 
[]
 
[AuxVariables]
  [./total]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
  [../]
  [./temp]
    order = FIRST
    family = MONOMIAL
    initial_condition = 298.15  #K
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
    type = InhibitedArrheniusReaction
    variable = B
    this_variable = B
    temperature = temp
 
    forward_pre_exponential = 1.0
    forward_activation_energy = 0.0
    forward_inhibition = R
 
    reverse_pre_exponential = 0.0
    reverse_activation_energy = 0.0
    reverse_inhibition = 1   #NOTE: When there is NO inhibition, the variable will be 1
 
    scale = 1.0
    reactants = 'A'
    reactant_stoich = '1'
    products = 'B'
    product_stoich = '1'
  [../]
  [./B_loss]  #   2B --> C
    type = InhibitedArrheniusReaction
    variable = B
    this_variable = B
    temperature = temp
 
    forward_pre_exponential = 1.0
    forward_activation_energy = 0.0
    forward_inhibition = R

    reverse_pre_exponential = 0.0
    reverse_activation_energy = 0.0
    reverse_inhibition = 1   #NOTE: When there is NO inhibition, the variable will be 1
 
    scale = -2.0
    reactants = 'B'
    reactant_stoich = '2'
    products = 'C'
    product_stoich = '1'
  [../]
 
  [./C_dot]
    type = TimeDerivative
    variable = C
  [../]
  [./C_gain]  #   2B --> C
    type = InhibitedArrheniusReaction
    variable = C
    this_variable = C
    temperature = temp
 
    forward_pre_exponential = 1.0
    forward_activation_energy = 0.0
    forward_inhibition = R

    reverse_pre_exponential = 0.0
    reverse_activation_energy = 0.0
    reverse_inhibition = 1   #NOTE: When there is NO inhibition, the variable will be 1
 
    scale = 1.0
    reactants = 'B'
    reactant_stoich = '2'
    products = 'C'
    product_stoich = '1'
  [../]
 
#NOTE: The inhibition residual is the sum of a "Reaction" kernel and any other inhibition model kernel
  [./RA_eq]
    type = Reaction
    variable = RA
  [../]
  [./RA_lang]
    type = LangmuirInhibition
    variable = RA
    temperature = temp
    coupled_list = 'A'
    pre_exponentials = '1'
  [../]
 
  [./RB_eq]
    type = Reaction
    variable = RB
  [../]
  [./RB_lang]
    type = LangmuirInhibition
    variable = RB
    temperature = temp
    coupled_list = 'B'
    pre_exponentials = '1'
  [../]
 
  [./R_eq]
    type = Reaction
    variable = R
  [../]
  [./R_lang]
    type = InhibitionProducts
    variable = R
    coupled_list = 'RA RB'
    power_list = '1 1'
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
    [./R]
        type = ElementAverageValue
        variable = R
        execute_on = 'initial timestep_end'
    [../]
    [./RA]
        type = ElementAverageValue
        variable = RA
        execute_on = 'initial timestep_end'
    [../]
    [./RB]
        type = ElementAverageValue
        variable = RB
        execute_on = 'initial timestep_end'
    [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
  solve_type = pjfnk
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
  petsc_options_value = 'gmres 300 asm lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
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
time_step_interval = 1
[] #END Outputs


