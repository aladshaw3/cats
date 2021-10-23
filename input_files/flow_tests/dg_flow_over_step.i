# File demos Navier-Stokes flow with DG methods
# This establishes the first working example of
# an implementation of Navier-Stokes equations
# using DG kernels. Pressure variable stablization
# is aided using DG methods with high order (second
# or higher).

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 2D-Flow-Step-Converted.unv
    #boundary_name = 'inlet outlet wall'
  []

[] # END Mesh

[Variables]
	[./pressure]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
	[../]

  [./vel_x]
		order = SECOND
		family = L2_LAGRANGE
		initial_condition = 0.0
	[../]

  [./vel_y]
		order = SECOND
		family = L2_LAGRANGE
		initial_condition = 0.0
	[../]

  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

[] #END Variables

[AuxVariables]

[] #END AuxVariables

[ICs]


[] #END ICs

[Kernels]
    active = 'vx_press vy_press
              x_press
              y_press
              tracer_dot tracer_gadv tracer_gdiff
              x_gdiff y_gdiff'

    # Enforce Div*vel = 0
    [./vx_press]
      type = VectorCoupledGradient
      variable = pressure
      coupled = vel_x
      vx = 1
    [../]
    [./vy_press]
      type = VectorCoupledGradient
      variable = pressure
      coupled = vel_y
      vy = 1
    [../]

    [./x_press]
      type = VectorCoupledGradient
      variable = vel_x
      coupled = pressure
      vx = 1
    [../]
    [./x_gdiff]
      type = GVariableDiffusion
      variable = vel_x
      Dx = 1
      Dy = 1
      Dz = 1
    [../]
    [./x_gadv]
        type = GPoreConcAdvection
        variable = vel_x
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = 0
    [../]

    [./y_press]
      type = VectorCoupledGradient
      variable = vel_y
      coupled = pressure
      vy = 1
    [../]
    [./y_gdiff]
      type = GVariableDiffusion
      variable = vel_y
      Dx = 1
      Dy = 1
      Dz = 1
    [../]
    [./y_gadv]
        type = GPoreConcAdvection
        variable = vel_y
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = 0
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
        uz = 0
    [../]
    [./tracer_gdiff]
        type = GVarPoreDiffusion
        variable = tracer
        porosity = 1
        Dx = 0.1
        Dy = 0.1
        Dz = 0.1
    [../]

[] #END Kernels

[DGKernels]
  [./tracer_dgadv]
      type = DGPoreConcAdvection
      variable = tracer
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]
  [./tracer_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer
      porosity = 1
      Dx = 0.1
      Dy = 0.1
      Dz = 0.1
  [../]

  [./x_dgdiff]
    type = DGVariableDiffusion
    variable = vel_x
    Dx = 1
    Dy = 1
    Dz = 1

    sigma = 1e2
    dg_scheme = nipg
  [../]
  [./x_dgadv]
      type = DGPoreConcAdvection
      variable = vel_x
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]

  [./y_dgdiff]
    type = DGVariableDiffusion
    variable = vel_y
    Dx = 1
    Dy = 1
    Dz = 1

    sigma = 1e2
    dg_scheme = nipg
  [../]
  [./y_dgadv]
      type = DGPoreConcAdvection
      variable = vel_y
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]
[]

[AuxKernels]


[] #END AuxKernels

[BCs]

  # Zero pressure at exit (mandatory)
	[./press_at_exit]
        type = DirichletBC
        variable = pressure
        boundary = 'outlet'
		    value = 0.0
  [../]

  [./vel_x_inlet]
        type = INSNormalFlowBC
        variable = vel_x
        boundary = 'inlet'
        u_dot_n = -1
        direction = 0
        penalty = 1e4
        ux = vel_x
        uy = vel_y
        uz = 0
  [../]

  [./vel_x_obj]
        type = PenaltyDirichletBC
        variable = vel_x
        boundary = 'wall'
		    value = 0.0
        penalty = 1e4
  [../]

  [./vel_y_obj]
        type = PenaltyDirichletBC
        variable = vel_y
        boundary = 'wall'
		    value = 0.0
        penalty = 1e4
  [../]

  [./tracer_FluxIn]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'inlet'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = 0
      u_input = 1
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

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./pressure_inlet]
        type = SideAverageValue
        boundary = 'inlet'
        variable = pressure
        execute_on = 'initial timestep_end'
    [../]

    [./pressure_outlet]
        type = SideAverageValue
        boundary = 'outlet'
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
        boundary = 'inlet'
        variable = tracer
        execute_on = 'initial timestep_end'
    [../]

    [./tracer_outlet]
        type = SideAverageValue
        boundary = 'outlet'
        variable = tracer
        execute_on = 'initial timestep_end'
    [../]

    [./vel_x_inlet]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_x
        execute_on = 'initial timestep_end'
    [../]

    [./vel_x_outlet]
        type = SideAverageValue
        boundary = 'outlet'
        variable = vel_x
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-10 1E-12'

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
  end_time = 20.0
  dtmax = 0.5

    [./TimeStepper]
		  type = ConstantDT
      dt = 0.5
    [../]

[] #END Executioner

[Preconditioning]
    [./SMP_PJFNK]
      type = SMP
      full = true
      solve_type = pjfnk   #newton solver works faster when using very good preconditioner
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = true

[] #END Outputs
