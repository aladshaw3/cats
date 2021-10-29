# This example is to demonstrate how we can simulate Darcy Flow through
# a porous media using our own custom kernels and methods. This was necessary
# to start exploring because the MOOSE PorousFlow module cannot be linked/coupled
# to our own methods based on how that module was constructed.

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

  # Dummy variable is needed on the other block
  #   We are not using this variable in this example
  [./dummy]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'solid'
  [../]

[] #END Variables

[AuxVariables]

    # Variable coefficients for Darcy Flux
    [./Kx]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
        block = 'channel'
    [../]
    [./Ky]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1
        block = 'channel'
    [../]

[] #END AuxVariables

[ICs]


[] #END ICs

[Kernels]
    # Enfore Linear/Planar Pressure
    # What this does is force the second derivative of
    #   pressure to be zero (when no other kernel is
    #   active for pressure). Thus, pressure is linear
    #   in the domain, which is true for Darcy flow.
    [./press_diff]
      type = Diffusion
      variable = pressure
      block = 'channel'
    [../]


    # NOTE: In this example, the permeability coefficent
    #       for each velocity component is just 1. This
    #       is done by setting 'vx' to 1 for the x component
    #       of velocity and 'vy' to 1 for the y component
    #       of velocity.

    # Use this kernel with VariableVectorCoupledGradient
    #   This + x_press, gives an expression by
    #   which velocity is calculated purely from
    #   the pressure gradient. The magnitude of
    #   velocity is a scalar multiple of this,
    #   thus we need a variable coefficient (in x-direction) to
    #   add such that we get the correct flow rate
    #   for a specific pressure gradient in a porous
    #   media.
    [./x_equ]
      type = Reaction
      variable = vel_x
      block = 'channel'
    [../]
    [./x_press]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = Kx
      block = 'channel'
    [../]

    # Use this kernel with VariableVectorCoupledGradient
    #   This + y_press, gives an expression by
    #   which velocity is calculated purely from
    #   the pressure gradient. The magnitude of
    #   velocity is a scalar multiple of this,
    #   thus we need a variable coefficient (in y-direction) to
    #   add such that we get the correct flow rate
    #   for a specific pressure gradient in a porous
    #   media.
    [./y_equ]
      type = Reaction
      variable = vel_y
      block = 'channel'
    [../]
    [./y_press]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = Ky
      block = 'channel'
    [../]

    # Tracer function using DG methods
    [./tracer_dot]
        type = VariableCoefTimeDerivative
        variable = tracer
        coupled_coef = 0.5
        block = 'channel'
    [../]
    # vel_x and vel_y are 'Darcy Velocity' and
    # not average linear velocity in this case.
    # Thus, they inherently carry the porosity
    # term with them. (i.e., Darcy Velocity =
    # average linear velocity * porosity)
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
        porosity = 0.5
        Dx = 0.1
        Dy = 0.1
        Dz = 0.1
        block = 'channel'
    [../]

    [./dummy_dot]
        type = VariableCoefTimeDerivative
        variable = dummy
        coupled_coef = 0.5
        block = 'solid'
    [../]

[] #END Kernels

[DGKernels]
  # vel_x and vel_y are 'Darcy Velocity' and
  # not average linear velocity in this case.
  # Thus, they inherently carry the porosity
  # term with them. (i.e., Darcy Velocity =
  # average linear velocity * porosity)
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
      porosity = 0.5
      Dx = 0.1
      Dy = 0.1
      Dz = 0.1
      block = 'channel'
  [../]
[]

[AuxKernels]


[] #END AuxKernels

[BCs]
  # Darcy Flow requires you to know pressure at the inlet and outlet
  # of the domain. This is needed to establish the pressure gradient.

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

  # NOTE: The 'No Slip' condition is not necessary in Darcy Flow

  #Add tracer and inlet and let it leave only through the exit
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
