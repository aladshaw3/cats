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
  # DG Kernel options
  dg_scheme = nipg
  sigma = 10

  # INS options
  gravity = '-0.098 0 0'				#gravity accel for body force (cm/s^2) [Gravity has negative accel]
  integrate_p_by_parts = true	#how to include the pressure gradient term (not sure what it does, but solves when true)
  supg = true 					#activates SUPG stabilization (excellent stability, always necessary)
  pspg = true					#activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
  alpha = 1 					#stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
  laplace = true				#whether or not viscous term is in laplace form
  convective_term = true		#whether or not to include advective/convective term
  transient_term = true			#whether or not to include time derivative in supg correction (sometimes needed)
[]

[Mesh]
  file = 2D-Flow-Step-Converted.unv
  boundary_name = 'inlet outlet wall'
[]


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

  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]
[]

[AuxVariables]
  [./vel_z]
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
    pressure = p
    component = 1
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

      #Dispersion with mechanical mixing is needed
      #   Helps to clear out material from the wall due
      #   to using the no-slip condition (which causes
      #   a lot of accumulation at the wall)
      Dx = 1
      Dy = 1
      Dz = 1
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

      #Dispersion with mechanical mixing is needed
      #   Helps to clear out material from the wall due
      #   to using the no-slip condition (which causes
      #   a lot of accumulation at the wall)
      Dx = 1
      Dy = 1
      Dz = 1
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

  [./tracer_FluxIn]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'inlet'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 1

  [../]
  [./tracer_FluxOut]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'outlet'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
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
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason

                    -ksp_gmres_modifiedgramschmidt'

  # NOTE: The sub_pc_type arg not used if pc_type is ksp,
  #       Instead, set the ksp_ksp_type to the pc method
  #       you want. Then, also set the ksp_pc_type to be
  #       the terminal preconditioner.
  #
  # Good terminal precon options: lu, ilu, asm, gasm, pbjacobi
  #                               bjacobi, redundant, telescope
  petsc_options_iname ='-ksp_type
                        -pc_type

                        -sub_pc_type

                        -snes_max_it

                        -sub_pc_factor_shift_type
                        -pc_asm_overlap

                        -snes_atol
                        -snes_rtol

                        -ksp_ksp_type
                        -ksp_pc_type'

  # snes_max_it = maximum non-linear steps
  petsc_options_value = 'fgmres
                         ksp

                         lu

                         10
                         NONZERO
                         20
                         1E-8
                         1E-10

                         fgmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 10.0
  dtmax = 0.5

  [./TimeStepper]
    type = ConstantDT
    dt = 0.5
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
    value = '10.0*(1-exp(-1*t))'   #in cm/s
    # Velocities in cm/s
  [../]
[]

[Postprocessors]
    [./vel_x_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_x
        execute_on = 'initial timestep_end'
    [../]
    [./vel_x_out]
        type = SideAverageValue
        boundary = 'outlet'
        variable = vel_x
        execute_on = 'initial timestep_end'
    [../]

    [./tracer_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = tracer
        execute_on = 'initial timestep_end'
    [../]
    [./tracer_out]
        type = SideAverageValue
        boundary = 'outlet'
        variable = tracer
        execute_on = 'initial timestep_end'
    [../]
[]
