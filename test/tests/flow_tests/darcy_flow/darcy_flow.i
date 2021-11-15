## Example of Darcy's Flow
#     Generally set a BC for inlet and outlet pressure
#
# Use 'elem_type = TRI3' for best stability

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
  		order = FIRST
  		family = LAGRANGE
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
    [./v_x_equ]
        type = Reaction
        variable = vel_x
    [../]
    # -grad(P)_x
    [./x_press]
      type = VectorCoupledGradient
      variable = vel_x
      coupled = pressure

      # These become coefficients in the Darcy Equation
      #     vel_x = -K/eps/mu * grad(P)_x
      #
      #           Thus, vx = K/eps/mu
      vx = 4
    [../]

    ### Conservation of y-momentum ###
    [./v_y_equ]
        type = Reaction
        variable = vel_y
    [../]
    # -grad(P)_y
    [./y_press]
      type = VectorCoupledGradient
      variable = vel_y
      coupled = pressure

      # These become coefficients in the Darcy Equation
      #     vel_y = -K/eps/mu * grad(P)_y
      #
      #           Thus, vy = K/eps/mu
      vy = 4
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

  # Non-zero pressure at inlet
  [./press_x_inlet]
      type = FunctionDirichletBC
      variable = pressure
      boundary = 'left'
      function = '2.6*t'
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
                         ksp

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
