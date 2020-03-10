[GlobalParams]
  dg_scheme = nipg
  sigma = 10
  Coefficient = 1.0
[] #END GlobalParams

[Problem]

    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)

[] #END Problem

[Mesh]

    type = GeneratedMesh
    dim = 2
    nx = 3
    ny = 40
    xmin = 0.0
    xmax = 2.0    #2cm radius
    ymin = 0.0
    ymax = 5.0    #5cm length

[] # END Mesh

[Variables]

    [./q1]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./q2]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./q3]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./qT]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

[] #END Variables

[AuxVariables]

  [./NH3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.78862977563539E-05
  [../]

  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001337966847917
  [../]

  [./O2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5.35186739166803E-05
  [../]

  [./w1]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.050158034226165
  [../]

  [./w2]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.035551848023962
  [../]

  [./w3]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.03941211725362
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 423.15
  [../]

  [./Diff]
    order = FIRST
    family = LAGRANGE
    initial_condition = 10
  [../]

  [./pore]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.3309
  [../]

  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 10000
  [../]

  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]

    [./q1_dot]
        type = CoefTimeDerivative
        variable = q1
    [../]
    [./q1_rxn]
      type = Reaction
      variable = q1
    [../]
    [./q1_lang] #site 1
      type = VarSiteDensityExtLangModel
      variable = q1
      coupled_site_density = w1
      main_coupled = NH3
      coupled_list = 'NH3 H2O'
      enthalpies = '-83080.8 -30428.7'
      entropies = '71.7 157.4'
      coupled_temp = temp
    [../]

    [./q2_dot]
        type = CoefTimeDerivative
        variable = q2
    [../]
    [./q2_rxn]
      type = Reaction
      variable = q2
    [../]
    [./q2_lang] #site 2
      type = VarSiteDensityExtLangModel
      variable = q2
      coupled_site_density = w2
      main_coupled = NH3
      coupled_list = 'NH3'
      enthalpies = '-75602.7'
      entropies = '-39.4'
      coupled_temp = temp
    [../]

    [./q3_dot]
        type = CoefTimeDerivative
        variable = q3
    [../]
    [./q3_rxn]
      type = Reaction
      variable = q3
    [../]
    [./q3_lang] #site 3
      type = VarSiteDensityExtLangModel
      variable = q3
      coupled_site_density = w3
      main_coupled = NH3
      coupled_list = 'NH3'
      enthalpies = '-84693.9'
      entropies = '-23.3'
      coupled_temp = temp
    [../]

    [./qT_res]
      type = Reaction
      variable = qT
    [../]
    [./qT_sum]
      type = CoupledSumFunction
      variable = qT
      coupled_list = 'q1 q2 q3'
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
    solve_type = newton   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 10.0
  dtmax = 0.5

  [./TimeStepper]
	   type = SolutionTimeAdaptiveDT
     #type = ConstantDT
     dt = 0.1
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = false
  exodus = true
  csv = true
[] #END Outputs
