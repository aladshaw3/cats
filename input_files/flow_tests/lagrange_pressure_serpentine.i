# NOTE: This example seems to only run under the Darcy flow assumption

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 5by5_test_cell.msh
    #boundary_name = 'inlet outlet solid_exits inner_walls outer_walls'
    #block = 'channel solid'
  []

[] # END Mesh

[Variables]
	[./pressure]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
    block = 'channel'
	[../]

  [./vel_x]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
    block = 'channel'
	[../]

  [./vel_y]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
    block = 'channel'
	[../]

  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'channel'
  [../]

  [./dummy]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'solid'
  [../]

[] #END Variables

[AuxVariables]
  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'channel'
  [../]

  [./D]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.1
    block = 'solid channel'
  [../]
[] #END AuxVariables

[ICs]


[] #END ICs

[Kernels]
    # This is a demo of pure Darcy Flow
    active = 'press_diff

              x_equ
              x_press
              y_equ
              y_press
              tracer_dot tracer_gadv tracer_gdiff

              dummy_dot'


    # Enfore Linear/Planar Pressure
    #   Good for Darcy flow, but not much else.
    #   Do not use this form unless doing pressure
    #   driven darcy flow.
    #
    # What this does is force the second derivative of
    #   pressure to be zero (when no other kernel is
    #   active for pressure). Thus, pressure is linear
    #   in the domain, which is true for Darcy flow.
    [./press_diff]
      type = Diffusion
      variable = pressure
      block = 'channel'
    [../]

    # Enforce Div*vel = 0
    [./vx_press]
      type = VectorCoupledGradient
      variable = pressure
      coupled = vel_x
      vx = 1
      block = 'channel'
    [../]
    [./vy_press]
      type = VectorCoupledGradient
      variable = pressure
      coupled = vel_y
      vy = 1
      block = 'channel'
    [../]

    # Use this kernel with VectorCoupledGradient
    # ONLY if doing darcy flow
    #   This + x_press, gives an expression by
    #   which velocity is calculated purely from
    #   the pressure gradient. The magnitude of
    #   velocity is a scalar multiple of this,
    #   thus we need a vector coefficient to
    #   add such that we get the correct flow rate
    #   for a specific pressure gradient in a porous
    #   media.
    [./x_equ]
      type = Reaction
      variable = vel_x
      block = 'channel'
    [../]

    [./x_press]
      type = VectorCoupledGradient
      variable = vel_x
      coupled = pressure
      vx = 1
      block = 'channel'
    [../]
    [./x_diff]
      type = Diffusion
      variable = vel_x
      block = 'channel'
    [../]

    # Use this kernel with VectorCoupledGradient
    # ONLY if doing darcy flow
    #   This + y_press, gives an expression by
    #   which velocity is calculated purely from
    #   the pressure gradient. The magnitude of
    #   velocity is a scalar multiple of this,
    #   thus we need a vector coefficient to
    #   add such that we get the correct flow rate
    #   for a specific pressure gradient in a porous
    #   media.
    [./y_equ]
      type = Reaction
      variable = vel_y
      block = 'channel'
    [../]

    [./y_press]
      type = VectorCoupledGradient
      variable = vel_y
      coupled = pressure
      vy = 1
      block = 'channel'
    [../]
    [./y_diff]
      type = Diffusion
      variable = vel_y
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
        uz = vel_z
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
        Dx = D
        Dy = D
        Dz = D
        block = 'channel'
    [../]

    [./dummy_dot]
        type = VariableCoefTimeDerivative
        variable = dummy
        coupled_coef = 1
        block = 'solid'
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
      Dx = D
      Dy = D
      Dz = D
      block = 'channel'
  [../]
[]

[AuxKernels]


[] #END AuxKernels

[BCs]
  # Darcy Flow requires you to know pressure at the inlet and outlet
  # of the domain. This is needed to establish the pressure gradient.
  # Any expression for pressure differential should suffice, including
  # the Ergun equation. This equation equates fluid properties and porosity
  # to a pressure drop over a distance. The issue with this relationship,
  # however, is that it presumes a constant porosity. Alternatively, instead
  # of using the Ergun relationship to set a pressure at the boundary, you
  # could have the Ergun relationship coded as a kernel, but that has not
  # been tested.
  active = 'press_at_exit
            press_at_enter

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
		    value = 100.0
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

  [./vel_x_obj]
        type = DirichletBC
        variable = vel_x
        boundary = 'inner_walls outer_walls'
		    value = 0.0
  [../]

  [./vel_y_obj]
        type = DirichletBC
        variable = vel_y
        boundary = 'inner_walls outer_walls inlet outlet'
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
        block = 'channel'
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
                         1E-10
                         1E-10

                         fgmres
                         lu'

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
