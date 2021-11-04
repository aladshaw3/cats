[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 2D-Flow-Converted.unv
  []

[] # END Mesh

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

[] #END Variables

[AuxVariables]
  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

[] #END AuxVariables

[ICs]


[] #END ICs

[Kernels]
    active = 'vx_press vy_press
              x_press
              y_press
              tracer_dot tracer_gadv tracer_gdiff
              x_diff y_diff'


    # Enfore Linear/Planar Pressure
    #   Good for Darcy flow, but not much else.
    #   Do not use this form unless doing pressure
    #   driven darcy flow.
    [./press_diff]
      type = Diffusion
      variable = pressure
    [../]

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

    # Use this kernel with VectorCoupledGradient
    # ONLY if doing darcy flow
    [./x_equ]
      type = Reaction
      variable = vel_x
    [../]

    [./x_press]
      type = VectorCoupledGradient
      variable = vel_x
      coupled = pressure
      vx = 1
    [../]
    [./x_diff]
      type = Diffusion
      variable = vel_x
    [../]

    # Use this kernel with VectorCoupledGradient
    # ONLY if doing darcy flow
    [./y_equ]
      type = Reaction
      variable = vel_y
    [../]

    [./y_press]
      type = VectorCoupledGradient
      variable = vel_y
      coupled = pressure
      vy = 1
    [../]
    [./y_diff]
      type = Diffusion
      variable = vel_y
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

        #Dispersion with mechanical mixing may be needed
        #   Helps to clear out material from the wall due
        #   to using the no-slip condition (which causes
        #   a lot of accumulation at the wall)
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
      uz = vel_z
  [../]
  [./tracer_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer
      porosity = 1

      #Dispersion with mechanical mixing may be needed
      #   Helps to clear out material from the wall due
      #   to using the no-slip condition (which causes
      #   a lot of accumulation at the wall)
      Dx = 0.1
      Dy = 0.1
      Dz = 0.1
  [../]
[]

[AuxKernels]


[] #END AuxKernels

[BCs]
  active = 'press_at_exit

            vel_x_inlet
            vel_x_obj vel_y_obj
            tracer_FluxIn tracer_FluxOut'

  # Zero pressure at exit (mandatory)
	[./press_at_exit]
        type = DirichletBC
        variable = pressure
        boundary = 'outlet'
		    value = 0.0
  [../]

  # 100 kPa pressure at enter
	[./press_at_enter]
        type = DirichletBC
        variable = pressure
        boundary = 'inlet'
		    value = 10.0
  [../]

  # Both types of BCs work to give the
  # correct flow field, but the DirichletBC
  # gives slightly 'off' velocity at the inlet
  [./vel_x_inlet]
        type = DirichletBC
        variable = vel_x
        boundary = 'inlet outlet'
		    value = 1.0
  [../]
  # NOTE: Setting the velocity at the inlet and
  #       outlet can make sure that flow is conserved

  # No slip conditions
  [./vel_x_obj]
        type = DirichletBC
        variable = vel_x
        boundary = 'object top bottom'
		    value = 0.0
  [../]
  [./vel_y_obj]
        type = DirichletBC
        variable = vel_y
        boundary = 'object top bottom inlet outlet'
		    value = 0.0
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
