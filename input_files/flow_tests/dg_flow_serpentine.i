# File demos Incompressible Navier-Stokes flow with DG methods

# Equations:
# ----------
#       vel = < vel_x, vel_y, vel_z>
#
# (1) continuity:   [resolves pressure gradient]
#
#       Div * vel = 0
#
# (2) conservation of momentum: [integration by parts]
#
#       rho* d(vel_i)/dt + Div*(rho*vel*vel_i) = -grad(P)_i + Div*(mu*grad(vel_i))
#
#           where i = x, y, or z
#
#       Div * vel = grad(vel_x)_x + grad(vel_y)_y + grad(vel_z)_z
#
#
# Custom DGINS (and GINS) kernels were developed to handle the momentum advection
# and the outflow BCs. Divergence of velocity is computed piecewise, as well as
# the piecewise resolution of the gradients of pressure.
#
# BCs at the inlet and walls for velocity are done using a PenaltyDirichletBC
# (and derivatives of that BC type) since we cannot directly enforce a DirichletBC
# on DG shape functions and variables.
#
#     NOTE: A good penalty term for inlet velocity and 'No Slip' conditions has
#           been found to be '3e2' (or 300) for most cases tested. It is unclear
#           why this number is good, but a range of values from 1 to 1e6 were
#           tested for convergence and conservation. 
#
# BCs for pressure enforce a 0 pressure at the boundary outlet. As such, the pressure
# gradients coupled to in the functions are representative of 'gage pressure' and
# not 'absolute pressure'. The units of pressure are fully dependent on the units
# used for 'rho' (density) and 'mu' (viscosity).
#
# NOTE: Because we do integration by parts, this formulation is only valid in
#       Cartesian coordinates. For RZ cylindrical coordinates, the divergence
#       of velocity has an additional term not included here.
#
#       For RZ cylindrical:
#             Div * vel == (vel_x/x) + grad(vel_x)_x + grad(vel_y)_y
#
#             where x = r and y = z
#
#       Thus, the only thing that would change is to add 1 additional term
#           to the residuals acting on pressure. There is currently no term
#           or kernel coded for this.

##### SOLVER NOTE #######
# ======================
#
# These methods create very difficult to solve
# matrices due to a high degree of non-linear coupling.
# In order to get it to solve in a reasonable amount of
# time, it is HIGHLY recommended to use 'fgmres' as the
# 'ksp' method with 'ksp' preconditioning to call another
# instance of 'fgmres' with an 'ilu' or 'lu' terminal
# preconditioner. This has been found to give very good
# convergence over a wide array of problems.

[GlobalParams]
  # Default DG methods
  sigma = 10
  dg_scheme = nipg

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
  ### Pressure variable should always be 'FIRST' order 'LAGRANGE' functions
	[./pressure]
		order = FIRST
		family = LAGRANGE
		initial_condition = 0.0
    block = 'channel'
	[../]

  ### For optimal stability: Use 'SECOND' order 'MONOMIAL' functions for velocities
  ###     HOWEVER:  For very smally viscosity (relative to density), you are better
  #                 off using 'FIRST' order functions.
  [./vel_x]
		order = SECOND
		family = MONOMIAL
		initial_condition = 0.0
    block = 'channel'
	[../]

  [./vel_y]
		order = SECOND
		family = MONOMIAL
		initial_condition = 0.0
    block = 'channel'
	[../]

  ### Other variables for mass and energy can be any order 'MONOMIAL' functions
  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'channel'
  [../]

  ### dummy variable to satisfy MOOSE framework
  [./dummy]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'solid'
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
        initial_condition = 1
        block = 'solid channel'
    [../]

    [./rho]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
        block = 'solid channel'
    [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]

    ####  Enforce Div*vel = 0 ###
    # grad(vel_x)_x   --> give 'vx=1' to only grab the gradient in x
    [./vx_press]
      type = VectorCoupledGradient
      variable = pressure
      coupled = vel_x
      vx = 1
      block = 'channel'
    [../]
    # grad(vel_y)_y   --> give 'vy=1' to only grab the gradient in y
    [./vy_press]
      type = VectorCoupledGradient
      variable = pressure
      coupled = vel_y
      vy = 1
      block = 'channel'
    [../]

    ### Conservation of x-momentum ###
    # rho* d(vel_x)/dt
    [./x_dot]
      type = VariableCoefTimeDerivative
      variable = vel_x
      coupled_coef = rho
      block = 'channel'
    [../]
    # -grad(P)_x
    [./x_press]
      type = VectorCoupledGradient
      variable = vel_x
      coupled = pressure
      vx = 1
      block = 'channel'
    [../]
    # Div*(mu*grad(vel_x))
    [./x_gdiff]
      type = GVariableDiffusion
      variable = vel_x
      Dx = mu
      Dy = mu
      Dz = mu
      block = 'channel'
    [../]
    # Div*(rho*vel*vel_x)
    [./x_gadv]
        type = GINSMomentumAdvection
        variable = vel_x
        this_variable = vel_x
        density = rho
        ux = vel_x
        uy = vel_y
        uz = 0
        block = 'channel'
    [../]

    ### Conservation of y-momentum ###
    # rho* d(vel_y)/dt
    [./y_dot]
      type = VariableCoefTimeDerivative
      variable = vel_y
      coupled_coef = rho
      block = 'channel'
    [../]
    # -grad(P)_y
    [./y_press]
      type = VectorCoupledGradient
      variable = vel_y
      coupled = pressure
      vy = 1
      block = 'channel'
    [../]
    # Div*(mu*grad(vel_y))
    [./y_gdiff]
      type = GVariableDiffusion
      variable = vel_y
      Dx = mu
      Dy = mu
      Dz = mu
      block = 'channel'
    [../]
    # Div*(rho*vel*vel_y)
    [./y_gadv]
        type = GINSMomentumAdvection
        variable = vel_y
        this_variable = vel_y
        density = rho
        ux = vel_x
        uy = vel_y
        uz = 0
        block = 'channel'
    [../]

    ### Conservation of mass for a dilute tracer ###
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
        Dx = 0.1
        Dy = 0.1
        Dz = 0.1
        block = 'channel'
    [../]

    ### dummy kernel to satisfy MOOSE ###
    [./dummy_dot]
        type = VariableCoefTimeDerivative
        variable = dummy
        coupled_coef = 1
        block = 'solid'
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
      uz = 0
      block = 'channel'
  [../]
  [./tracer_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer
      porosity = 1
      Dx = 0.1
      Dy = 0.1
      Dz = 0.1
      block = 'channel'
  [../]

  # Div*(mu*grad(vel_x))
  [./x_dgdiff]
    type = DGVariableDiffusion
    variable = vel_x
    Dx = mu
    Dy = mu
    Dz = mu
    block = 'channel'
  [../]
  # Div*(rho*vel*vel_x)
  [./x_dgadv]
      type = DGINSMomentumAdvection
      variable = vel_x
      this_variable = vel_x
      density = rho
      ux = vel_x
      uy = vel_y
      uz = 0
      block = 'channel'
  [../]

  # Div*(mu*grad(vel_y))
  [./y_dgdiff]
    type = DGVariableDiffusion
    variable = vel_y
    Dx = mu
    Dy = mu
    Dz = mu
    block = 'channel'
  [../]
  # Div*(rho*vel*vel_y)
  [./y_dgadv]
      type = DGINSMomentumAdvection
      variable = vel_y
      this_variable = vel_y
      density = rho
      ux = vel_x
      uy = vel_y
      uz = 0
      block = 'channel'
  [../]
[]

[AuxKernels]

[] #END AuxKernels


#boundary_name = 'inlet outlet solid_exits inner_walls outer_walls'
[BCs]

  # Zero pressure at exit (mandatory)
	[./press_at_exit]
        type = DirichletBC
        variable = pressure
        boundary = 'outlet'
		    value = 0.0
  [../]

  # Inlet velocity at boundary
  [./vel_x_inlet]
        type = FunctionPenaltyDirichletBC
        variable = vel_x
        boundary = 'inlet'
        penalty = 3e2
        function = '1'
  [../]

  ### Momentum Flux Out of Domain ###
  # in x-direction
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
  # in y-direction
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

  # No Slip BCs
  [./vel_x_obj]
        type = PenaltyDirichletBC
        variable = vel_x
        boundary = 'inner_walls outer_walls'
		    value = 0.0
        penalty = 3e2
  [../]
  [./vel_y_obj]
        type = PenaltyDirichletBC
        variable = vel_y
        boundary = 'inner_walls outer_walls'
		    value = 0.0
        penalty = 3e2
  [../]

  ## Conservative Tracer fluxes
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
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 50.0
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
