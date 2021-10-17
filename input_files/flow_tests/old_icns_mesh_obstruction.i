# This input file tests various options for the incompressible NS equations in a channel.

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
  alpha = 1 					#stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
  laplace = true				#whether or not viscous term is in laplace form
  convective_term = true		#whether or not to include advective/convective term
  transient_term = true			#whether or not to include time derivative in supg correction (sometimes needed)
[]

[Mesh]
  [./obstruct_file]
    type = FileMeshGenerator
    file = 2D-obstruction-Converted.unv
  [../]
  #The above file contains the following block and boundary names
  #boundary_name = 'inlet outlet top bottom object'
  #block_name = 'conduit obstruction'
[]


[Variables]
  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 10000
    block = 'conduit'
  [../]
  [./vel_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'conduit'
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'conduit'
  [../]

  [./inner]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
    block = 'obstruction'
  [../]

  [CO2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
    block = 'conduit'
  []
[]

[AuxVariables]
    [./vel_in]
        order = FIRST
        family = MONOMIAL
        initial_condition = 10000
    [../]
[]

[Kernels]
#Place holder variable and kernel needed to satisfy moose
  [./inner_dot]
    type = CoefTimeDerivative
    variable = inner
    Coefficient = 1.0
    block = 'obstruction'
  [../]
  [./body_force]
    type = BodyForce
    variable = inner
    block = 'obstruction'
    value = 1
  [../]

  # Transport of conc
  [./CO2_dot]
      type = VariableCoefTimeDerivative
      variable = CO2
      coupled_coef = 1
      block = 'conduit'
  [../]
  [./CO2_gadv]
      type = GPoreConcAdvection
      variable = CO2
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
      block = 'conduit'
  [../]
  [./CO2_gdiff]
      type = GVarPoreDiffusion
      variable = CO2
      porosity = 1
      Dx = 2400
      Dy = 2400
      Dz = 2400
      block = 'conduit'
  [../]

  #Continuity Equ
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    pressure = p
    block = 'conduit'
  [../]

  #Conservation of momentum equ in x (with time derivative)
  [./x_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    block = 'conduit'
  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    pressure = p
    component = 0
    block = 'conduit'
  [../]

  #Conservation of momentum equ in y (with time derivative)
  [./y_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    block = 'conduit'
  [../]
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    pressure = p
    component = 1
    block = 'conduit'
  [../]
[]

[DGKernels]
  [./CO2_dgadv]
      type = DGPoreConcAdvection
      variable = CO2
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
      block = 'conduit'
  [../]
  [./CO2_dgdiff]
      type = DGVarPoreDiffusion
      variable = CO2
      porosity = 1
      Dx = 2400
      Dy = 2400
      Dz = 2400
      block = 'conduit'
  [../]
[]

[AuxKernels]
    # NOTE: YOU MUST setup up calculation on
    #     'initial timestep_begin timestep_end'
    #     in order to have the coupling aligned
    #     correctly in time.
    [./vel_in_increase]
        type = LinearChangeInTime
        variable = vel_in
        start_time = 0
        end_time = 5
        end_value = 50000
        execute_on = 'initial timestep_begin timestep_end'
    [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = vel_x

    # For all walls
    boundary = 'top bottom object'

    # If we want to allow free slip, then remove
    #   the DirichletBC at the walls, only put
    #   at the obstruction.
    #boundary = 'object'

    value = 0.0

  [../]

  # Less strict no slip condition
  #   Good for walls, maybe less so
  #   for obstructions
  #[./x_alt_penalty_wall]
  #    type = PenaltyDirichletBC
  #    boundary = 'top bottom'
  #    variable = vel_x
  #    value = 0
  #    penalty = 100
  #[../]

  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'inlet top bottom object'
    value = 0.0
  [../]
  [./x_inlet]
    #type = FunctionDirichletBC
    #function = 'inlet_func'

    type = PostprocessorDirichletBC
    postprocessor = vel_in


    variable = vel_x
    boundary = 'inlet'
  [../]

  # Is this needed?  NO!!! DO NOT SET
  #[./p_out]
  #  type = DirichletBC
  #  variable = p
  #  boundary = 'outlet'
  #  # Should always set outlet p to zero
  #  value = 0.0
  #[../]

  [./CO2_FluxIn]
      type = DGPoreConcFluxBC_ppm
      variable = CO2
      boundary = 'inlet'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
      pressure = 101.35
      temperature = 273
      inlet_ppm = 130000
  [../]
  [./CO2_FluxOut]
      type = DGPoreConcFluxBC
      variable = CO2
      boundary = 'outlet'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    block = 'conduit obstruction'
    prop_names = 'rho mu'
    #              g/cm^3  g/cm/min
    #prop_values = '1.225e-3  108.6E-4'   #VALUES FOR AIR

    # NOTE: Adding 'artifical' viscosity can aid in stabilization
    #     Addition of artificial viscosity should be a function
    #     of the inlet flowrate (or inlet velocity)
    prop_values = '1.225e-3  108.6E-1'   #VALUES FOR AIR (artifical vis)
  [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #newton solver works faster when using very good preconditioner
  [../]
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'

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
  end_time = 5.0
  dtmax = 0.5

  [./TimeStepper]
    type = ConstantDT
    dt = 0.5
  [../]
[]

[Postprocessors]
    [./u_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_x
        execute_on = 'initial timestep_end'
    [../]
    [./u_out]
        type = SideAverageValue
        boundary = 'outlet'
        variable = vel_x
        execute_on = 'initial timestep_end'
    [../]

    [./C_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]
    [./C_out]
        type = SideAverageValue
        boundary = 'outlet'
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]

    [./P_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = p
        execute_on = 'initial timestep_end'
    [../]

    # NOTE: YOU MUST setup up calculation on
    #     'initial timestep_begin timestep_end'
    #     in order to have the coupling aligned
    #     correctly in time.
    [./vel_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_in
        execute_on = 'initial timestep_begin timestep_end'
    [../]
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
[]

[Functions]
  [./inlet_func]
    type = ParsedFunction
    #Parabola that has velocity of zero at y=top and=bot, with maximum at y=middle
    #value = a*y^2 + b*y + c	solve for a, b, and c
    #value = '-0.25 * y^2 + 1'
    value = 1
  [../]
[]
