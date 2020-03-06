# This input file tests various options for the incompressible NS equations in a channel with a step.

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
  gravity = '0 0 0'				#gravity accel for body force (cm/s^2) [Gravity has negative accel]
  integrate_p_by_parts = true	#how to include the pressure gradient term (not sure what it does, but solves when true)
  supg = true 					#activates SUPG stabilization (excellent stability, always necessary)
  pspg = true					#activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
  alpha = 0.5 					#stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
  laplace = true				#whether or not viscous term is in laplace form
  convective_term = true		#whether or not to include advective/convective term
  transient_term = true			#whether or not to include time derivative in supg correction (sometimes needed)
[]

[Mesh]
  file = 2D-Flow-Step-Converted.unv
  boundary_name = 'inlet outlet wall'
[]

#[MeshModifiers]
#  [./corner_node]
#    # Pin is on the top left corner of the domain
#    type = AddExtraNodeset
#    new_boundary = pinned_node
#    coord = '-2 2'
#   [../]
#[]


[Variables]
  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  [../]
  [./vel_y]
    order = FIRST
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
    boundary = 'wall'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'inlet wall'
    value = 0.0
  [../]
  [./x_inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'inlet'
    function = 'inlet_func'
  [../]

#  [./p_corner]
#    # Since the pressure is not integrated by parts in this example,
#    # it is only specified up to a constant by the natural outflow BC.
#    # Therefore, we need to pin its value at a single location.
#    type = DirichletBC
#    boundary = pinned_node
#    value = 0
#    variable = p
#  [../]
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
  scheme = implicit-euler
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
  end_time = 200.0
  dtmax = 0.5

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
    value = '(-0.25 * y^2 + 1)*10'
    # Velocities in cm/s
  [../]
[]
