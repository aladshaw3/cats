# File demos Navier-Stokes flow with DG methods
# This example shows how to properly add BCs
# since that is the most difficult part.
# It is important to add a flux out for each
# velocity/momentum term. This becomes extremely
# important if your inlet momentum flux is
# increasing with time.

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
		order = SECOND
		family = MONOMIAL
		initial_condition = 0.0
	[../]

  [./vel_y]
		order = SECOND
		family = MONOMIAL
		initial_condition = 0.0
	[../]

  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

[] #END Variables

[AuxVariables]
    [./mu]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.1
    [../]

    [./rho]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
    [../]

[] #END AuxVariables

[ICs]


[] #END ICs

[Kernels]

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

    [./x_dot]
      type = VariableCoefTimeDerivative
      variable = vel_x
      coupled_coef = rho
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
      Dx = mu
      Dy = mu
      Dz = mu
    [../]
    [./x_gadv]
        type = GINSMomentumAdvection
        variable = vel_x
        this_variable = vel_x
        density = rho
        ux = vel_x
        uy = vel_y
        uz = 0
    [../]

    [./y_dot]
      type = VariableCoefTimeDerivative
      variable = vel_y
      coupled_coef = rho
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
      Dx = mu
      Dy = mu
      Dz = mu
    [../]
    [./y_gadv]
        type = GINSMomentumAdvection
        variable = vel_y
        this_variable = vel_y
        density = rho
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
    Dx = mu
    Dy = mu
    Dz = mu

    sigma = 10
    dg_scheme = nipg
  [../]
  [./x_dgadv]
      type = DGINSMomentumAdvection
      variable = vel_x
      this_variable = vel_x
      density = rho
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]

  [./y_dgdiff]
    type = DGVariableDiffusion
    variable = vel_y
    Dx = mu
    Dy = mu
    Dz = mu

    sigma = 10
    dg_scheme = nipg
  [../]
  [./y_dgadv]
      type = DGINSMomentumAdvection
      variable = vel_y
      this_variable = vel_y
      density = rho
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]
[]

[AuxKernels]


[] #END AuxKernels

[BCs]

  # Zero pressure at exit
	[./press_at_exit]
        type = DirichletBC
        variable = pressure
        boundary = 'outlet'
		    value = 0.0
  [../]

  [./vel_x_inlet]
        type = FunctionPenaltyDirichletBC
        variable = vel_x
        boundary = 'inlet'
        penalty = 1e4
        function = '0+1*t'
  [../]
  [./vel_x_outlet]
      type = DGINSMomentumOutflowBC
      variable = vel_x
      this_variable = vel_x
      boundary = 'outlet'
      density = rho
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]
  [./vel_y_outlet]
      type = DGINSMomentumOutflowBC
      variable = vel_y
      this_variable = vel_y
      boundary = 'outlet'
      density = rho
      ux = vel_x
      uy = vel_y
      uz = 0
  [../]

  [./vel_x_obj]
        type = PenaltyDirichletBC
        variable = vel_x
        boundary = 'top bottom object'
		    value = 0.0
        penalty = 1e4
  [../]

  [./vel_y_obj]
        type = PenaltyDirichletBC
        variable = vel_y
        boundary = 'top bottom object inlet'
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

                         20

                         NONZERO
                         10
                         1E-6
                         1E-8

                         fgmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
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
      solve_type = pjfnk
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = true

[] #END Outputs
