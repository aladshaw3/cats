[GlobalParams]

[] #END GlobalParams

[Problem]

    coord_type = RZ

[] #END Problem

[Mesh]

    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 1
    xmin = 0.0
    xmax = 2.0    #2cm radius
    ymin = 0.0
    ymax = 5.0    #5cm length

[] # END Mesh

[Variables]

    [./q1]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q2]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q3]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]
 
    [./qH2O]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]
 
    [./S1]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./S2]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./S3]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./qT]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]

[] #END Variables

[AuxVariables]
 
  [./NH3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.78862977563539E-05
  [../]

  [./O2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5.35186739166803E-05
  [../]

  #MOVED water to AuxVariables because we don't want to consider mass transfer right now
  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001337966847917
  [../]

  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.05016
  [../]

  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.03534
  [../]

  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.03963
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 423.15
  [../]

  [./Diff]
    order = FIRST
    family = MONOMIAL
    initial_condition = 75.0
  [../]
 
  [./Dz]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
  [../]

  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 7555.15
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]

    [./qT_calc]
      type = MaterialBalance
      variable = qT
      this_variable = qT
      coupled_list = 'q1 q2 q3'
      weights = '1 1 1'
      total_material = qT
    [../]
 
    [./S1_bal]
      type = MaterialBalance
      variable = S1
      this_variable = S1
      coupled_list = 'q1 S1 qH2O'
      weights = '1 1 1'
      total_material = w1
    [../]
 
    [./S2_bal]
      type = MaterialBalance
      variable = S2
      this_variable = S2
      coupled_list = 'q2 S2'
      weights = '1 1'
      total_material = w2
    [../]
 
    [./S3_bal]
      type = MaterialBalance
      variable = S3
      this_variable = S3
      coupled_list = 'q3 S3'
      weights = '1 1'
      total_material = w3
    [../]
 
    [./q1_rx]  #   NH3 + S1 <-- --> q1
      type = ConstReaction
      variable = q1
      this_variable = q1
      forward_rate = 157554.199
      reverse_rate = 1.0
      scale = 1.0
      reactants = 'NH3 S1'
      reactant_stoich = '1 1'
      products = 'q1'
      product_stoich = '1'
    [../]
 
    [./q2_rx]  #   NH3 + S2 <-- --> q2
      type = ConstReaction
      variable = q2
      this_variable = q2
      forward_rate = 21541444.4
      reverse_rate = 1.0
      scale = 1.0
      reactants = 'NH3 S2'
      reactant_stoich = '1 1'
      products = 'q2'
      product_stoich = '1'
    [../]
 
    [./q3_rx]  #   NH3 + S3 <-- --> q3
      type = ConstReaction
      variable = q3
      this_variable = q3
      forward_rate = 1044803109.0
      reverse_rate = 1.0
      scale = 1.0
      reactants = 'NH3 S3'
      reactant_stoich = '1 1'
      products = 'q3'
      product_stoich = '1'
    [../]
 
    [./qH2O_rx]  #   H2O + S1 <-- --> qH2O
      type = ConstReaction
      variable = qH2O
      this_variable = qH2O
      forward_rate = 790.93684
      reverse_rate = 1.0
      scale = 1.0
      reactants = 'H2O S1'
      reactant_stoich = '1 1'
      products = 'qH2O'
      product_stoich = '1'
    [../]
 

[] #END Kernels

[DGKernels]

[] #END DGKernels

[AuxKernels]

[] #END AuxKernels

[BCs]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./NH3_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]
 
    [./NH3_enter]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./q1_avg]
        type = ElementAverageValue
        variable = q1
        execute_on = 'initial timestep_end'
    [../]

    [./q2_avg]
        type = ElementAverageValue
        variable = q2
        execute_on = 'initial timestep_end'
    [../]

    [./q3_avg]
        type = ElementAverageValue
        variable = q3
        execute_on = 'initial timestep_end'
    [../]

   [./qT_avg]
        type = ElementAverageValue
        variable = qT
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Steady
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
