# This input file tests outflow boundary conditions for the incompressible NS equations.

[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = true
[]

[Mesh]
	file = 2D-Flow-Converted.unv
	boundary_name = 'inlet outlet top bottom object'
[]


[Variables]
  [./vel_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./vel_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
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
    boundary = 'top bottom object'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'inlet top bottom object'
    value = 0.0
  [../]
  [./x_inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'inlet'
    function = 'inlet_func'
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'rho mu'
    prop_values = '1  1'
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
  type = Steady
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300
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
