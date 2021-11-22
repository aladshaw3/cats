
[GlobalParams]
  # Default DG methods
  sigma = 10
  dg_scheme = nipg

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  #FileMeshGenerator automatically assigns boundary names from the .msh file
  #   .msh file MUST HAVE specific boundary names in it (use msh format 4.1)
    [./mesh_file]
        type = FileMeshGenerator
        file = Monolith_Composite_Updated.msh
    [../]
  #The above file contains the following boundary names
  #boundary_name = 'inlet outlet washcoat_walls interface wash_in wash_out'
  #block_name = 'washcoat channel'

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
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]

  [./vel_y]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]

  [./vel_z]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
  [../]

  ### Other variables for mass and energy can be any order 'MONOMIAL' functions
  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'channel'
  [../]

  [./tracer_w]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'washcoat'
  [../]

[] #END Variables

[AuxVariables]
    # NOTE: Viscosity (mu) controls how laminar the flow is. Very low viscosity,
    #       relative to density (rho) can be difficult to converge due to extreme
    #       jumps in velocity magnitudes near boundaries. You can stabilize the
    #       flow by artificially increasing viscosity, but this will lower accuracy.
    [./mu]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0.2
    [../]

    [./rho]
        order = FIRST
        family = LAGRANGE
        initial_condition = 1
    [../]

    [./eps]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0.5
    [../]

    [./Dp]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0.5
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
    # Div*(rho*vel*vel_x)
    [./x_gadv]
        type = GNSMomentumAdvection
        variable = vel_x
        this_variable = vel_x
        density = rho
        ux = vel_x
        uy = vel_y
        uz = vel_z
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
    # Div*(rho*vel*vel_y)
    [./y_gadv]
        type = GNSMomentumAdvection
        variable = vel_y
        this_variable = vel_y
        density = rho
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    ### Conservation of z-momentum ###
    # rho* d(vel_z)/dt
    [./z_dot]
      type = VariableCoefTimeDerivative
      variable = vel_z
      coupled_coef = rho
    [../]
    # -grad(P)_z
    [./z_press]
      type = VectorCoupledGradient
      variable = vel_z
      coupled = pressure
      vz = 1
    [../]
    # Div*(mu*grad(vel_z))
    [./z_gdiff]
      type = GVariableDiffusion
      variable = vel_z
      Dx = mu
      Dy = mu
      Dz = mu
    [../]
    # Div*(rho*vel*vel_z)
    [./z_gadv]
        type = GNSMomentumAdvection
        variable = vel_z
        this_variable = vel_z
        density = rho
        ux = vel_x
        uy = vel_y
        uz = vel_z
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


    [./tracer_w_dot]
        type = VariableCoefTimeDerivative
        variable = tracer_w
        coupled_coef = eps
    [../]
    [./tracer_w_gdiff]
        type = GVarPoreDiffusion
        variable = tracer_w
        porosity = eps
        Dx = Dp
        Dy = Dp
        Dz = Dp
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

  ### Conservation of mass for dilute tracer in washcoat ###
  [./tracer_w_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer_w
      porosity = eps
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]

  # Div*(mu*grad(vel_x))
  [./x_dgdiff]
    type = DGVariableDiffusion
    variable = vel_x
    Dx = mu
    Dy = mu
    Dz = mu
  [../]
  # Div*(rho*vel*vel_x)
  [./x_dgadv]
      type = DGNSMomentumAdvection
      variable = vel_x
      this_variable = vel_x
      density = rho
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]

  # Div*(mu*grad(vel_y))
  [./y_dgdiff]
    type = DGVariableDiffusion
    variable = vel_y
    Dx = mu
    Dy = mu
    Dz = mu
  [../]
  # Div*(rho*vel*vel_y)
  [./y_dgadv]
      type = DGNSMomentumAdvection
      variable = vel_y
      this_variable = vel_y
      density = rho
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]

  # Div*(mu*grad(vel_z))
  [./z_dgdiff]
    type = DGVariableDiffusion
    variable = vel_z
    Dx = mu
    Dy = mu
    Dz = mu
  [../]
  # Div*(rho*vel*vel_z)
  [./z_dgadv]
      type = DGNSMomentumAdvection
      variable = vel_z
      this_variable = vel_z
      density = rho
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
[]

[InterfaceKernels]
   [./interface_kernel]
       type = InterfaceMassTransfer
       variable = tracer        #variable must be the variable in the master block
       neighbor_var = tracer_w    #neighbor_var must the the variable in the paired block
       boundary = 'interface'
       transfer_rate = 2
   [../]
[] #END InterfaceKernels

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

  # Inlet velocity at boundary
  [./vel_y_inlet]
        type = FunctionPenaltyDirichletBC
        variable = vel_y
        boundary = 'inlet outlet'
        penalty = 3e4
        function = '100*t'
  [../]

  ### Momentum Flux Out of Domain ###
  # in x-direction
  [./vel_x_outlet]
      type = DGNSMomentumOutflowBC
      variable = vel_x
      this_variable = vel_x
      boundary = 'outlet'
      density = rho
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  # in y-direction
  [./vel_y_outlet]
      type = DGNSMomentumOutflowBC
      variable = vel_y
      this_variable = vel_y
      boundary = 'outlet'
      density = rho
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  # in z-direction
  [./vel_z_outlet]
      type = DGNSMomentumOutflowBC
      variable = vel_z
      this_variable = vel_z
      boundary = 'outlet'
      density = rho
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]

  ### No Slip Conditions at the Walls ###
  # in x-direction
  [./vel_x_obj]
        type = PenaltyDirichletBC
        variable = vel_x
        boundary = 'washcoat_walls'
		    value = 0.0
        penalty = 3e4
  [../]
  # in y-direction
  [./vel_y_obj]
        type = PenaltyDirichletBC
        variable = vel_y
        boundary = 'washcoat_walls'
		    value = 0.0
        penalty = 3e4
  [../]
  # in z-direction
  [./vel_z_obj]
        type = PenaltyDirichletBC
        variable = vel_z
        boundary = 'washcoat_walls'
		    value = 0.0
        penalty = 3e4
  [../]

  ### Fluxes for Conservative Tracer ###
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

    [./vel_y_inlet]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]

    [./vel_y_outlet]
        type = SideAverageValue
        boundary = 'outlet'
        variable = vel_y
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
                         lu

                         lu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         100

                         1E-10
                         1E-10

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
