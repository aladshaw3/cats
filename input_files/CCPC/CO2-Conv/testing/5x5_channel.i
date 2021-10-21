[GlobalParams]
  # DG Kernel options
  dg_scheme = nipg
  sigma = 10

  # INS options
  gravity = '0 0 0'				#gravity accel for body force
  integrate_p_by_parts = true	#how to include the pressure gradient term (not sure what it does, but solves when true)
  supg = true 					#activates SUPG stabilization (excellent stability, always necessary)
  pspg = true					#activates PSPG stabilization for pressure term (excellent stability, lower accuracy)
  alpha = 0.25 					#stabilization multiplicative correction factor (0.1 < alpha <= 1) [lower value improves accuracy]
  laplace = true				#whether or not viscous term is in laplace form
  convective_term = true		#whether or not to include advective/convective term
  transient_term = true			#whether or not to include time derivative in supg correction (sometimes needed)
[]

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 5by5_test_cell.msh
    #boundary_name = 'inlet outlet solid_exits inner_walls outer_walls'
    #block = 'channel solid'
  []
  [smooth]
    type = SmoothMeshGenerator
    input = file
    iterations = 12
  []
[]

[Materials]
  [./ins_mat]
    type = GenericConstantMaterial
    block = 'channel solid'
    prop_names = 'rho mu'
    #              g/cm^3  g/cm/min
    prop_values = '1.0  0.534'   #VALUES FOR WATER
  [../]
[]

[Variables]
  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'channel'
  [../]
  [./vel_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'channel'
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'channel'
  [../]

  # We want this to be first order
  # to get smoother results, but
  # dead zones in meshes lead to
  # negative concentrations in corners
  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'channel'
  [../]

  # This HAS to be first order
  # (unless we use 'advection' in pores)
  [./tracer_p]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
    block = 'solid'
  [../]
[]

[AuxVariables]
    # Approx Diffusion for NaCl in water (0.007827 cm^2/min)
    [./Diff]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.007827
    [../]

    # Approx Pore Diffusion for NaCl in water in the solids
    #   Assume it is roughly Dp = Diff*eps^1.4
    [./Dp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.00217
        block = 'solid'
    [../]
    [./eps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.4
        block = 'solid'
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
    block = 'channel'
  [../]

  #Conservation of momentum equ in x (with time derivative)
  [./x_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    block = 'channel'
  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    pressure = p
    component = 0
    block = 'channel'
  [../]

  #Conservation of momentum equ in y (with time derivative)
  [./y_momentum_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    block = 'channel'
  [../]
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    pressure = p
    component = 1
    block = 'channel'
  [../]

  [./tracer_dot]
      type = VariableCoefTimeDerivative
      variable = tracer
      coupled_coef = 1
      block = 'channel'
  [../]
  [./tracer_gadv]
      type = GPoreConcAdvection
      variable = tracer
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
      block = 'channel'
  [../]
  [./tracer_gdiff]
      type = GVarPoreDiffusion
      variable = tracer
      porosity = 1

      #Dispersion with mechanical mixing may be needed
      #   Helps to clear out material from the wall due
      #   to using the no-slip condition (which causes
      #   a lot of accumulation at the wall)
      Dx = Diff
      Dy = Diff
      Dz = Diff
      block = 'channel'
  [../]

  #tracer in solids
  [./tracer_p_dot]
     type = VariableCoefTimeDerivative
     variable = tracer_p
     coupled_coef = eps
     block = 'solid'
  [../]
  [./tracer_p_gdiff]
      type = GVarPoreDiffusion
      variable = tracer_p
      porosity = eps

      Dx = Dp
      Dy = Dp
      Dz = Dp
      block = 'solid'
  [../]

[]

[DGKernels]
  [./tracer_dgadv]
      type = DGPoreConcAdvection
      variable = tracer
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
      block = 'channel'
  [../]
  [./tracer_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer
      porosity = 1

      #Dispersion with mechanical mixing may be needed
      #   Helps to clear out material from the wall due
      #   to using the no-slip condition (which causes
      #   a lot of accumulation at the wall)
      Dx = Diff
      Dy = Diff
      Dz = Diff
      block = 'channel'
  [../]

  [./tracer_p_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer_p
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
      block = 'solid'
  [../]
[]

# Only need 1 interface kernel per boundary
#     DO NOT duplicate for each coupled variable
[InterfaceKernels]
   [./interface]
     type = InterfaceMassTransfer
     variable = tracer
     neighbor_var = tracer_p
     boundary = 'inner_walls'
     transfer_rate = 200
   [../]
[] #END InterfaceKernels

[BCs]
  #Best BC results are strict no slip at the walls and
  # our custom flux_limited BC that weakly imposes a
  # dirichlet BC given high penalty terms for the
  # 'velocity' and 'diffusive' flux parameters.

  active = 'x_no_slip
            y_no_slip
            x_inlet_flux_limited
            tracer_FluxIn
            tracer_FluxOut'

  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'inner_walls outer_walls'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'inner_walls outer_walls'
    value = 0.0
  [../]

  #Alternative to the strict no slip condition
  # is a weak no slip that enforce a no penetration
  # rule at the boundary. However, this is imposed
  # weakly and is dependent on the penalty term.
  [./x_weak_no_slip]
      type = INSNormalFlowBC
      variable = vel_x
      direction = 0
      boundary = 'inner_walls outer_walls'
      u_dot_n = 0
      ux = vel_x
      uy = vel_y
      uz = 0
      penalty = 1e6
  [../]
  [./y_weak_no_slip]
      type = INSNormalFlowBC
      variable = vel_y
      direction = 1
      boundary = 'inner_walls outer_walls'
      u_dot_n = 0
      ux = vel_x
      uy = vel_y
      uz = 0
      penalty = 1e6
  [../]


  # If I want to have an average inlet velocity
  # of a specific value, then this BC may not work
  # because it conflicts with the 'no slip' conditions
  # at the boundary edge nodes. This may actually be
  # a failing of the mesh element types (which are
  # mostly triangles).
  [./x_inlet_dirchlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'inlet'
    function = 'inlet_func'
  [../]

  # You can try a penalty term for the dirichlet BC,
  # but this still doesn't give the best results.
  [./x_inlet_penalty_dirchlet]
    type = FunctionPenaltyDirichletBC
    variable = vel_x
    boundary = 'inlet'
    function = 'inlet_func'
    penalty = 1e6
  [../]

  # With my DGFluxLimitedBC, I can emulate the
  # BC I want, but must give 'penalty' values
  # for the velocity and diffusion terms.
  [./x_inlet_flux_limited]
      type = DGFluxLimitedStepwiseBC
      variable = vel_x
      boundary = 'inlet'
      u_input = 1

      # For best results, use penalty terms
      # between 1e4 and 1e6. Where 1e4 has
      # very good efficiency, and ok accuracy,
      # but 1e6 has very good accuracy, but
      # worse efficiency.

      # ### NOTE: The size of the penalty term
      #           may also depend on the size
      #           of 'alpha' term in the INS module.
      vx = 1e5
      vy = 1e5
      vz = 1e5
      Dxx = 1e5
      Dyy = 1e5

      input_vals = '50'
      input_times = '10'
      time_spans = '20'
  [../]

  [./tracer_FluxIn]
      type = DGPoreConcFluxStepwiseBC
      variable = tracer
      boundary = 'inlet'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
      u_input = 0

      input_vals = '1 0'
      input_times = '1 30'
      time_spans = '1 5'
  [../]
  [./tracer_FluxOut]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'outlet'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]

  # This BC represents material in the 'solid'
  #   subdomain fluxing out of that domain into
  #   a void (i.e., non-meshed space)
  #
  #  +++++++++++++++ NOTE: This doesn't work well +++++++++++
  [./tracer_p_DiffFluxOut]
      type = NeumannBC
      variable = tracer_p
      boundary = 'solid_exits'
      value = 0
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
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0
  end_time = 80.0
  dtmax = 0.5

  [./TimeStepper]
    type = ConstantDT
    #type = SolutionTimeAdaptiveDT
    dt = 0.25
  [../]
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[]

[Functions]
  [./inlet_func]
    type = ParsedFunction
    value = '1'
  [../]
[]

[Postprocessors]
    [./vel_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_x
        execute_on = 'initial timestep_end'
    [../]
    [./vel_out]
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

    [./tracer_p_avg]
        type = ElementAverageValue
        variable = tracer_p
        execute_on = 'initial timestep_end'
        block = 'solid'
    [../]
    [./tracer_avg]
        type = ElementAverageValue
        variable = tracer
        execute_on = 'initial timestep_end'
        block = 'channel'
    [../]
[]
