# This input file tests various options for the incompressible NS equations in a column with perforations.

# CONVERGES WELL

# NOTES
# -------
# There are multiple types of stabilization possible in incompressible
# Navier Stokes. The user can specify supg = true to apply streamline
# upwind petrov-galerkin stabilization to the momentum equations. This
# is most useful for high Reynolds numbers, e.g. when inertial effects
# dominate over viscous effects. The user can also specify pspg = true
# to apply pressure stabilized petrov-galerkin stabilization to the mass
# equation. PSPG is a form of Galerkin Least Squares. This stabilization
# allows equal order interpolations to be used for pressure and velocity.
# Finally, the alpha parameter controls the amount of stabilization.
# For PSPG, decreasing alpha leads to increased accuracy but may induce
# spurious oscillations in the pressure field. Some numerical experiments
# suggest that alpha between .1 and 1 may be optimal for accuracy and
# robustness.

# Parameters given below provide the best tested compromise of stability and accuracy

# NOTE: If you want an approximate steady-state flow profile, use MAXIMUM STABILITY options (alpha = 1.0 and all set to true)
#       and simulate for many time steps.

[GlobalParams]
  gravity = '0 0 0'				#gravity accel for body force
  integrate_p_by_parts = true	#how to include the pressure gradient term (not sure what it does, but solves when true)
  supg = true 					#activates SUPG stabilization (excellent stability, always necessary)
  pspg = true					#activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
  alpha = 0.5 					#stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
  laplace = true				#whether or not viscous term is in laplace form
  convective_term = true		#whether or not to include advective/convective term
  transient_term = true			#whether or not to include time derivative in supg correction (sometimes needed)

  order = FIRST
  family = LAGRANGE
[]

[Mesh]
  file = Perf-Cylinder-Min-Converted.unv
  boundary_name = 'inlet outlet wall'
[]


[Variables]
  [./vel_x]
    initial_condition = 0
  [../]
  [./vel_y]
    initial_condition = 0
  [../]
  [./vel_z]
    initial_condition = 0.0
  [../]
  [./p]
    initial_condition = 0
  [../]
  [./conc]
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
    w = vel_z
    pressure = p
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
    w = vel_z
    pressure = p
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
    w = vel_z
    pressure = p
    component = 1
  [../]

  #Conservation of momentum equ in z (with time derivative)
  [./z_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_z
  [../]
  [./z_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_z
    u = vel_x
    v = vel_y
    w = vel_z
    pressure = p
    component = 2
  [../]

  #Concentration time derivative
  [./time]
    type = TimeDerivative
    variable = conc
  [../]
#  [./time_supg]
#    type = LevelSetTimeDerivativeSUPG   #velocity can't be zero for this to work
#    variable = conc
#    velocity_x = vel_x
#    velocity_y = vel_y
#    velocity_z = vel_z
# [../]
 #Concentration advection
  [./phi_advection]
    type = LevelSetAdvection
    variable = conc
    velocity_x = vel_x
    velocity_y = vel_y
    velocity_z = vel_z
  [../]
#  [./phi_advection_supg]
#    type = LevelSetAdvectionSUPG    #velocity can't be zero for this to work
#    variable = conc
#    velocity_x = vel_x
#    velocity_y = vel_y
#    velocity_z = vel_z
#  [../]
  [./diff]
    type = Diffusion
    variable = conc
  [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'wall inlet'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'wall inlet'
    value = 0.0
  [../]
  [./z_no_slip]
    type = DirichletBC
    variable = vel_z
    boundary = 'wall'
    value = 0.0
  [../]
  [./z_inlet]
    type = FunctionDirichletBC
    variable = vel_z
    boundary = 'inlet'
    function = 'inlet_func'
  [../]
  [./conc_inlet]
    type = DirichletBC
    variable = conc
    boundary = 'inlet'
    value = 1.0
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'rho mu'
    #              g/cm^3  g/cm/s    #VALUES FOR WATER
    prop_values = '1.0  0.01'
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = newton   #newton solver works faster when using very good preconditioner
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = basic
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 100.0
  dtmax = 0.5

  [./TimeStepper]
	type = SolutionTimeAdaptiveDT
#    type = ConstantDT
    dt = 0.1
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
    #vz = a*x^2 + b*y^2 + c	solve for a, b, and c
    value = '(-(1/25) * x^2 - (1/25) * y^2 + 1)*5.0'   #in cm/s
  [../]
[]

[Adaptivity]
  marker = errorfrac
  [./Indicators]
    [./error]
    type = GradientJumpIndicator
    variable = conc
    [../]
  [../]

  [./Markers]
    [./errorfrac]
    type = ErrorFractionMarker
    refine = 0.0
    coarsen = 0.0
    indicator = error
    [../]
  [../]

[] #END Adaptivity
