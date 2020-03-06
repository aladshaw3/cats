# This input file tests various options for the incompressible NS equations in a channel.

[GlobalParams]
  gravity = '0 0 0'				#gravity accel for body force
  integrate_p_by_parts = true	#how to include the pressure gradient term (not sure what it does, but solves when true)
  supg = true 					#activates SUPG stabilization
  alpha = 1.0 					#stabilization multiplicative correction factor (0 < alpha <= 1)
  laplace = true				#whether or not viscous term is in laplace form
  convective_term = true		#whether or not to include advective/convective term
  transient_term = true			#whether or not to include time derivative in supg correction (must be true if simulation is transient)
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = -2.0
  xmax = 5.0
  ymin = -2.0
  ymax = 2.0
  nx = 30
  ny = 10
  elem_type = QUAD9
[]


[Variables]
  [./vel_x]
    order = SECOND
    family = LAGRANGE
    initial_condition = 0
  [../]
  [./vel_y]
    order = SECOND
    family = LAGRANGE
    initial_condition = 0
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  [../]
[]

[Kernels]
  #Continuity Equ
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
  [../]

  #Conservation of momentum equ in x (with time derivative)
  [./x_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
  [../]

  #Conservation of momentum equ in y (with time derivative)
  [./y_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
  [../]
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
  [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'top bottom'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'left top bottom'
    value = 0.0
  [../]
  [./x_inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'left'
    function = 'inlet_func'
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'rho mu'
    #              kg/m^3  kg/m/s
    prop_values = '1000.0  0.001'
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
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
  dtmax = 1.0

  [./TimeStepper]
	type = SolutionTimeAdaptiveDT
#    type = ConstantDT
    dt = 0.01
  [../]
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]

[Functions]
  [./inlet_func]
    type = ParsedFunction
    #Parabola that has velocity of zero at y=top and=bot, with maximum at y=middle
    #value = a*y^2 + b*y + c	solve for a, b, and c
    value = '-0.25 * y^2 + 1'
  [../]
[]
