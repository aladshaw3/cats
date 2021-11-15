## NOTE: Darcy's Law is derivable from Stokes Flow equations
#
# Use 'elem_type = TRI3' for best stability
#

[GlobalParams]
  # Default DG methods
  sigma = 10
  dg_scheme = nipg

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 20
    ny = 10
    xmin = 0.0
    xmax = 7.0
    ymin = 0.0
    ymax = 4.0
    elem_type = TRI3
[] # END Mesh

[Variables]
  ### Pressure variable should always be 'FIRST' order 'LAGRANGE' functions
	[./pressure]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
	[../]

  ### For optimal stability: Use 'SECOND' order 'MONOMIAL' functions for velocities
  ###     HOWEVER:  For very smally viscosity (relative to density), you are better
  #                 off using 'FIRST' order functions.
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

  ### Other variables for mass and energy can be any order 'MONOMIAL' functions
  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

[] #END Variables

[AuxVariables]
    # NOTE: Viscosity (mu) controls how laminar the flow is. Very low viscosity,
    #       relative to density (rho) can be difficult to converge due to extreme
    #       jumps in velocity magnitudes near boundaries. You can stabilize the
    #       flow by artificially increasing viscosity, but this will lower accuracy.
    [./mu]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.2
    [../]

    [./rho]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
    [../]

    [./vel_z]
  		order = SECOND
  		family = MONOMIAL
  		initial_condition = 0.0
  	[../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]

    ####  Enforce Div*vel = 0 ###
    [./cons_fluid_flow]
        type = DivergenceFreeCondition
        variable = pressure
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    ### Conservation of x-momentum ###
    # rho* d(vel_x)/dt
    [./x_dot]
      type = VariableCoefTimeDerivative
      variable = vel_x
      coupled_coef = rho
    [../]
    # -grad(P)_x
    [./x_press]
      type = VectorCoupledGradient
      variable = vel_x
      coupled = pressure
      vx = 1
    [../]
    # Div*(mu*grad(vel_x))
    [./x_gdiff]
      type = GVariableDiffusion
      variable = vel_x
      Dx = mu
      Dy = mu
      Dz = mu
    [../]

    ### Conservation of y-momentum ###
    # rho* d(vel_y)/dt
    [./y_dot]
      type = VariableCoefTimeDerivative
      variable = vel_y
      coupled_coef = rho
    [../]
    # -grad(P)_y
    [./y_press]
      type = VectorCoupledGradient
      variable = vel_y
      coupled = pressure
      vy = 1
    [../]
    # Div*(mu*grad(vel_y))
    [./y_gdiff]
      type = GVariableDiffusion
      variable = vel_y
      Dx = mu
      Dy = mu
      Dz = mu
    [../]

    ### Conservation of mass for a dilute tracer ###
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
        Dx = 0.1
        Dy = 0.1
        Dz = 0.1
    [../]

[] #END Kernels

# NOTE: All'G' prefixed kernels from above MUST have a
#       corresponding 'DG' kernel down here.
[DGKernels]
  ### Conservation of mass for a dilute tracer ###
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
      Dx = 0.1
      Dy = 0.1
      Dz = 0.1
  [../]

  # Div*(mu*grad(vel_x))
  [./x_dgdiff]
    type = DGVariableDiffusion
    variable = vel_x
    Dx = mu
    Dy = mu
    Dz = mu
  [../]

  # Div*(mu*grad(vel_y))
  [./y_dgdiff]
    type = DGVariableDiffusion
    variable = vel_y
    Dx = mu
    Dy = mu
    Dz = mu
  [../]
[]

[AuxKernels]

[] #END AuxKernels

[BCs]

  # Zero pressure at exit
	[./press_at_exit]
        type = DirichletBC
        variable = pressure
        boundary = 'right'
		    value = 0.0
  [../]

  # Inlet velocity at boundary
  [./vel_x_inlet]
        type = FunctionPenaltyDirichletBC
        variable = vel_x
        boundary = 'left'
        penalty = 3e2
        function = '1.485*t'
  [../]

  ### No Slip Conditions at the Walls ###
  # in x-direction
  [./vel_x_obj]
        type = PenaltyDirichletBC
        variable = vel_x
        boundary = 'top bottom'
		    value = 0.0
        penalty = 3e2
  [../]
  # in y-direction
  [./vel_y_obj]
        type = PenaltyDirichletBC
        variable = vel_y
        boundary = 'top bottom'
		    value = 0.0
        penalty = 3e2
  [../]

  ### Fluxes for Conservative Tracer ###
  [./tracer_FluxIn]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'left'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 1
  [../]
  [./tracer_FluxOut]
      type = DGPoreConcFluxBC
      variable = tracer
      boundary = 'right'
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
        boundary = 'left'
        variable = pressure
        execute_on = 'initial timestep_end'
    [../]

    [./pressure_outlet]
        type = SideAverageValue
        boundary = 'right'
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
        boundary = 'left'
        variable = tracer
        execute_on = 'initial timestep_end'
    [../]

    [./tracer_outlet]
        type = SideAverageValue
        boundary = 'right'
        variable = tracer
        execute_on = 'initial timestep_end'
    [../]

    [./vel_x_inlet]
        type = SideAverageValue
        boundary = 'left'
        variable = vel_x
        execute_on = 'initial timestep_end'
    [../]

    [./vel_x_outlet]
        type = SideAverageValue
        boundary = 'right'
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
                        -pc_factor_shift_type
                        -ksp_pc_factor_shift_type

                        -pc_asm_overlap

                        -snes_atol
                        -snes_rtol

                        -ksp_ksp_type
                        -ksp_pc_type'

  # snes_max_it = maximum non-linear steps
  petsc_options_value = 'fgmres
                         asm

                         lu

                         20

                         NONZERO
                         NONZERO
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
  end_time = 1.0
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
