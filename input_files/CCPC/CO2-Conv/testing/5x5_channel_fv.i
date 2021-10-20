# NOTE: This will only work when flow is incompressible
#       and when density is constant.
#
# Also includes transport of a tracer

# Water parameters
mu=0.534   # g/cm/min
rho=1.0 # g/cm^3

advected_interp_method='average'
velocity_interp_method='rc'

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 5by5_test_cell.msh
    #boundary_name = 'inlet outlet solid_exits inner_walls outer_walls'
    #block = 'channel solid'
  []
[]

[Problem]
  fv_bcs_integrity_check = true
[]

[Variables]
  [u]
    type = INSFVVelocityVariable
    initial_condition = 0
    block = 'channel'
  []
  [v]
    type = INSFVVelocityVariable
    initial_condition = 0
    block = 'channel'
  []
  [pressure]
    type = INSFVPressureVariable
    block = 'channel'
  []

  [./tracer_p]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
    block = 'solid'
    fv = true
  [../]

  [./tracer]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
    fv = true
    block = 'channel'
  [../]

[]

[AuxVariables]
    [./vel_in]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./tracer_in]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 1
    [../]
[]

[BCs]

[]

[AuxKernels]
    # NOTE: YOU MUST setup up calculation on
    #     'initial timestep_begin timestep_end'
    #     in order to have the coupling aligned
    #     correctly in time.
    [./vel_in_increase]
        type = LinearChangeInTime
        variable = vel_in
        start_time = 0
        end_time = 5
        end_value = 10
        execute_on = 'initial timestep_begin timestep_end'
    [../]

    # NOTE: YOU MUST setup up calculation on
    #     'initial timestep_begin timestep_end'
    #     in order to have the coupling aligned
    #     correctly in time.
    [./tracer_in_increase]
        type = LinearChangeInTime
        variable = tracer_in
        start_time = 25
        end_time = 30
        end_value = 0
        execute_on = 'initial timestep_begin timestep_end'
    [../]
[]

# Make it such that these kernels only act on
#   block = 'channel' (i.e., open channel).
[FVKernels]

  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    vel = 'velocity'
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
    block = 'channel'
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    variable = 'u'
    rho = ${rho}
    block = 'channel'
  []
  [u_advection]
    type = INSFVMomentumAdvection
    variable = u
    advected_quantity = 'rhou'
    vel = 'velocity'
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
    block = 'channel'
  []
  [u_viscosity]
    type = FVDiffusion
    variable = u
    coeff = ${mu}
    block = 'channel'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    momentum_component = 'x'
    pressure = pressure
    block = 'channel'
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    variable = 'v'
    rho = ${rho}
    block = 'channel'
  []
  [v_advection]
    type = INSFVMomentumAdvection
    variable = v
    advected_quantity = 'rhov'
    vel = 'velocity'
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
    block = 'channel'
  []
  [v_viscosity]
    type = FVDiffusion
    variable = v
    coeff = ${mu}
    block = 'channel'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = v
    momentum_component = 'y'
    pressure = pressure
    block = 'channel'
  []


  # Conservative Advection Diffusion
  [./tracer_dot]
     type = FVTimeKernel
     variable = tracer
     block = 'channel'
  [../]
  [./diff]
    type = FVDiffusion
    variable = tracer
    coeff = 0.01
    block = 'channel'
  [../]
  [adv_rho]
    type = FVMatAdvection
    variable = tracer
    vel = 'velocity'
  []

  [./tracer_p_dot]
     type = FVPorosityTimeDerivative
     variable = tracer_p
     porosity = 0.4
     block = 'solid'
  [../]
  [./diff_p]
    type = FVDiffusion
    variable = tracer_p
    coeff = 0.001
    block = 'solid'
  [../]

[]

# HERE I am borrowing from the navier-stokes module an
# interface kernel for mass transfer that takes the same
# form as the heat transfer kernel.
[FVInterfaceKernels]
  [convection]
    type = FVConvectionCorrelationInterface
    variable1 = tracer
    variable2 = tracer_p
    boundary = 'inner_walls'
    h = 200
    temp_solid = tracer_p
    temp_fluid = tracer
    subdomain1 = 'channel'
    subdomain2 = 'solid'
    wall_cell_is_bulk = true
  []
[]

# I may be able to make this work
# if I override the BCs to set an
# inlet velocity value...
#   Can input a function with time
#   may need own BC kernel
[FVBCs]
  [inlet-u]
    # This BC is specific to NS modules
    boundary = 'inlet'
    variable = u

    type = FVPostprocessorDirichletBC
    postprocessor = vel_in
  []
  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'inlet'
    variable = v
    function = '0'
  []
  [walls-u]
    type = INSFVNoSlipWallBC
    boundary = 'inner_walls outer_walls'
    variable = u
    function = 0
  []
  [walls-v]
    type = INSFVNoSlipWallBC
    boundary = 'inner_walls outer_walls'
    variable = v
    function = 0
  []
  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'outlet'
    variable = pressure
    function = '0'
  []

  # Inlet and outlet BCs for tracer
  [./tracer_in]
      # This BC is specific to NS modules
      boundary = 'inlet'
      variable = tracer

      type = FVPostprocessorDirichletBC
      postprocessor = tracer_in
  [../]
  [./tracer_outlet]
    type = FVMatAdvectionOutflowBC
    variable = tracer
    boundary = 'outlet'
    vel = 'velocity'
  [../]
[]

[Materials]
  [ins_fv]
    type = INSFVMaterial
    u = 'u'
    v = 'v'
    pressure = 'pressure'
    rho = ${rho}
    block = 'channel'
  []

  [./ins_dummy]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    #              g/cm^3  g/cm/min
    prop_values = '1.0  0.534'   #VALUES FOR WATER
    block = 'solid'
  [../]
[]

[Postprocessors]
    [./u_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = u
        execute_on = 'initial timestep_end'
    [../]
    [./u_out]
        type = SideAverageValue
        boundary = 'outlet'
        variable = u
        execute_on = 'initial timestep_end'
    [../]

    # NOTE: YOU MUST setup up calculation on
    #     'initial timestep_begin timestep_end'
    #     in order to have the coupling aligned
    #     correctly in time.
    [./vel_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = vel_in
        execute_on = 'initial timestep_begin timestep_end'
    [../]
    [./tracer_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = tracer_in
        execute_on = 'initial timestep_begin timestep_end'
    [../]

    [./P_in]
        type = SideAverageValue
        boundary = 'inlet'
        variable = pressure
        execute_on = 'initial timestep_end'
    [../]

    [./tracer_inlet]
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
    [./tracer_avg]
        type = ElementAverageValue
        block = 'channel'
        variable = tracer
        execute_on = 'initial timestep_end'
    [../]

    [./tracer_avg_p]
        type = ElementAverageValue
        block = 'solid'
        variable = tracer_p
        execute_on = 'initial timestep_end'
    [../]
[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
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
  line_search = 'none'
  nl_rel_tol = 1e-12
  nl_abs_tol = 1e-8

  end_time = 50
  # If there is high Re, then need smaller dt
  #     helps to rescale problem by choosing
  #     different unit basis that is more
  #     appropriate for time scale and length.
  dt = 0.25
[]

[Outputs]
  exodus = true
  csv = true
[]
