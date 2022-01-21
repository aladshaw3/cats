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
  # DG Kernel options
  dg_scheme = nipg
  sigma = 10

  # INS options
  gravity = '0 0 0'				#gravity accel for body force (cm/s/s)
  integrate_p_by_parts = true	#how to include the pressure gradient term (not sure what it does, but solves when true)
  supg = true 					#activates SUPG stabilization (excellent stability, always necessary)
  pspg = true					#activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
  alpha = 0.1 					#stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
  laplace = true				#whether or not viscous term is in laplace form
  convective_term = true		#whether or not to include advective/convective term
  transient_term = true			#whether or not to include time derivative in supg correction (sometimes needed)

  order = FIRST
  family = LAGRANGE
  scaling = 1.0      #factor to multiple by the residual for a non-linear variable (can be different for each variable)
[]

[Mesh]
  file = Perf-Cylinder-Converted.unv
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
    initial_condition = 0
  [../]
  [./p]
    initial_condition = 0
  [../]

  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]
[]

[AuxVariables]
  [./D]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
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

      #Dispersion with mechanical mixing is needed
      #   Helps to clear out material from the wall due
      #   to using the no-slip condition (which causes
      #   a lot of accumulation at the wall)
      Dx = D
      Dy = D
      Dz = D
  [../]
[]

[BCs]
  # List of currently active BCs
  active = 'x_no_slip y_no_slip z_no_slip
            z_inlet z_outlet
            tracer_FluxIn
            tracer_FluxOut'

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

  # NOTE: we apply same constraint to inlet and outlet
  #       to FORCE the total flow to be conserved.
  [./z_inlet]
    type = FunctionDirichletBC
    variable = vel_z
    boundary = 'inlet outlet'
    function = 'inlet_func'
  [../]
  [./z_outlet]
    type = FunctionDirichletBC
    variable = vel_z
    boundary = 'outlet'
    function = 'inlet_func'
  [../]

  # An alternative set of inlet/outlet BCs are to use the
  #   INSNormalFlowBC and specify an amount of flux at the
  #   inlet and outlet. If we want to conserve total flow
  #   rate, then the inlet and outlet boundaries should
  #   have the same magnitude of flux (but opposite directions
  #   normal to the boundary).
  #
  #   NOTE: This BC is relatively weak and must be imposed with
  #         a penalty term. If the term is too low or too high,
  #         then convergence and accuracy can get poor.
  [./z_inlet_flux]
      type = INSNormalFlowBC
      boundary = 'inlet'
      variable = vel_z

      # Inlet boundaries have negative flux
      u_dot_n = -1
      direction = 2
      penalty = 1e4
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./z_outlet_flux]
      type = INSNormalFlowBC
      boundary = 'outlet'
      variable = vel_z

      # Outlet boundaries have positive flux
      u_dot_n = 1
      direction = 2
      penalty = 1e4
      ux = vel_x
      uy = vel_y
      uz = vel_z
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
    #prop_values = '1.0  0.01'

    prop_values = '1.0  0.01'  #Add some 'false' viscosity for stability
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
  scheme = implicit-euler
  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
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

                         gmres
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
  end_time = 20.0
  dtmax = 0.5

  [./TimeStepper]
	   type = ConstantDT
     dt = 0.5
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
    #vz = a*x^2 + b*y^2 + c	solve for a, b, and c
    #value = '(-(1/25) * x^2 - (1/25) * y^2 + 1)*1.0*(1-exp(-10*t))'   #in cm/s

    # Constant with time (slow ramp up)
    #     This is better to use because it is more generally applicable
    value = '1.0*(1-exp(-1*t))'   #in cm/s
  [../]
[]

[Postprocessors]
    [./vel_z_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_z
        execute_on = 'initial timestep_end'
    [../]
    [./vel_z_out]
        type = SideAverageValue
        boundary = 'outlet'
        variable = vel_z
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
