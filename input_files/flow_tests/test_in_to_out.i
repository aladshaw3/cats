[GlobalParams]
  sigma = 10
  dg_scheme = nipg
[]

[Problem]
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 10
  xmin = 0.0
  xmax = 7.0
  ymin = 0.0
  ymax = 4.0
  elem_type = TRI3
[]

[Variables]
  [./pressure]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./vel_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./tracer]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
  [../]

[]

[AuxVariables]
  [./mu]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.2
  [../]

  [./rho]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1
  [../]

  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./D]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.1
  [../]

[]

[ICs]
[]

[Kernels]
  [./cons_fluid_flow]
    type = DivergenceFreeCondition
    variable = pressure
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./v_x_equ]
    type = Reaction
    variable = vel_x
  [../]

  [./x_press]
    type = VectorCoupledGradient
    variable = vel_x
    coupled = pressure
    vx = 4
  [../]

  [./v_y_equ]
    type = Reaction
    variable = vel_y
  [../]

  [./y_press]
    type = VectorCoupledGradient
    variable = vel_y
    coupled = pressure
    vy = 4
  [../]

  [./tracer_dot]
    type = VariableCoefTimeDerivative
    variable = tracer
    coupled_coef = 1
  [../]

  [./tracer_gadv]
    type = GPoreConcAdvection
    variable = tracer
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./tracer_gdiff]
    type = GVarPoreDiffusion
    variable = tracer
    porosity = 1
    Dx = D
    Dy = D
    Dz = D
  [../]

[]

[DGKernels]
  [./tracer_dgadv]
    type = DGPoreConcAdvection
    variable = tracer
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./tracer_dgdiff]
    type = DGVarPoreDiffusion
    variable = tracer
    porosity = 1
    Dx = D
    Dy = D
    Dz = D
  [../]

[]

[BCs]
  [./press_at_exit]
    type = DirichletBC
    variable = pressure
    boundary = 'right'
    value = 0.0
  [../]

  [./press_x_inlet]
    type = FunctionDirichletBC
    variable = pressure
    boundary = 'left'
    function = '2.6*t'
  [../]

  [./vel_x_obj]
    type = INSNormalFlowBC
    variable = vel_x
    boundary = 'top bottom'
    direction = 0
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./vel_y_obj]
    type = INSNormalFlowBC
    variable = vel_y
    boundary = 'top bottom'
    direction = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./tracer_FluxIn]
    type = DGPoreConcFluxBC
    variable = tracer
    boundary = 'left'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    u_input = 1
  [../]

  [./tracer_FluxOut]
    type = DGPoreConcFluxBC
    variable = tracer
    boundary = 'right'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

[]

[Materials]
[]

[Postprocessors]
  [./pressure_inlet]
    type = SideAverageValue
    boundary = 'left'
    variable = pressure
    execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
    type = SideAverageValue
    boundary = 'right'
    variable = pressure
    execute_on = 'initial timestep_end'
  [../]

  [./pressure_avg]
    type = ElementAverageValue
    variable = pressure
    execute_on = 'initial timestep_end'
  [../]

  [./tracer_inlet]
    type = SideAverageValue
    boundary = 'left'
    variable = tracer
    execute_on = 'initial timestep_end'
  [../]

  [./tracer_outlet]
    type = SideAverageValue
    boundary = 'right'
    variable = tracer
    execute_on = 'initial timestep_end'
  [../]

  [./vel_x_inlet]
    type = SideAverageValue
    boundary = 'left'
    variable = vel_x
    execute_on = 'initial timestep_end'
  [../]

  [./vel_x_outlet]
    type = SideAverageValue
    boundary = 'right'
    variable = vel_x
    execute_on = 'initial timestep_end'
  [../]

[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason -ksp_gmres_modifiedgramschmidt'
  petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_max_it
                     -sub_pc_factor_shift_type -pc_factor_shift_type -ksp_pc_factor_shift_type -pc_asm_overlap
                     -snes_atol -snes_rtol -ksp_ksp_type -ksp_pc_type'
  petsc_options_value = 'fgmres ksp lu 20
                     NONZERO NONZERO NONZERO 10
                     1e-06 1e-08 fgmres lu'
  line_search = none
  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-06
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-06
  l_max_its = 300
  start_time = 0.0
  end_time = 20.0
  dtmax = 0.5
  [./TimeStepper]
    type = ConstantDT
    dt = 0.5
  [../]

[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = True
    solve_type = pjfnk
  [../]

[]

[Outputs]
  exodus = True
  csv = True
  print_linear_residuals = True
[]

