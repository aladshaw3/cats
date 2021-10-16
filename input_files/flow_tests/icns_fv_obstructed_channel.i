# NOTE: This will only work when flow is incompressible
#       and when density is constant.

#mu=60.0E-2    #g/cm/min
#rho=1.0      #g/cm^3 (water)

mu=108.6E-4   # g/cm/min
rho=1.225E-3 # g/cm^3 (air)

advected_interp_method='average'
velocity_interp_method='rc'

[Mesh]
  [file]
    type = FileMeshGenerator
    # NOTE: This mesh doesn't work like we want
    #       because the velocities exist inside the
    #       object subdomain. To fix this, you can
    #       either remove the subdomain (below) or
    #       you can place velocity variable ONLY
    #       on a subdomain of the mesh (in this
    #       case, only on block = '2')
    file = 2D-obstruction-Converted.unv

    # This is the same mesh, but without
    #   the subdomain, just a hole.
    #file = 2D-Flow-Converted.unv

    ### boundary_name = 'inlet outlet top bottom object'
    ### block = '1' <-- object
    ### block = '2' <-- open channel
  []
[]

[Problem]
  fv_bcs_integrity_check = false
[]

[Variables]
  [u]
    type = INSFVVelocityVariable
    initial_condition = 0
    block = '2'
  []
  [v]
    type = INSFVVelocityVariable
    initial_condition = 0
    block = '2'
  []
  [pressure]
    type = INSFVPressureVariable
    block = '2'
  []
  [CO2]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0
    block = '1 2'
  []
[]

[AuxVariables]
    [./vel_in]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]
[]

# Here is where the regular kernels go
[Kernels]
    [./CO2_dot]
        type = VariableCoefTimeDerivative
        variable = CO2
        coupled_coef = 1
        block = '1 2'
    [../]
    [./CO2_gadv]
        type = GPoreConcAdvection
        variable = CO2
        porosity = 1
        ux = 1
        uy = 0
        uz = 0
        block = '2'
    [../]
    [./CO2_gdiff]
        type = GVarPoreDiffusion
        variable = CO2
        porosity = 1
        Dx = 1
        Dy = 1
        Dz = 1
        block = '1 2'
    [../]
[]

# MAJOR PROBLEM:  Cannot use DG kernels with FV flow???
#       We cannot use FV kernels with anything we do...
[DGKernels]
#  [./CO2_dgadv]
#      type = DGPoreConcAdvection
#      variable = CO2
#      porosity = 1
#      ux = 0
#      uy = 0
#      uz = 0
#      block = '2'
#  [../]
#  [./CO2_dgdiff]
#      type = DGVarPoreDiffusion
#      variable = CO2
#      porosity = 1
#      Dx = 1
#      Dy = 1
#      Dz = 1
#      block = '1 2'
#  [../]
[]

[BCs]
  [./CO2_FluxIn]
      type = DGPoreConcFluxBC_ppm
      variable = CO2
      boundary = 'inlet'
      porosity = 1
      ux = 1
      uy = 0
      uz = 0
      pressure = 101.35
      temperature = 273
      inlet_ppm = 130000
  [../]
  [./CO2_FluxOut]
      type = DGPoreConcFluxBC
      variable = CO2
      boundary = 'outlet'
      porosity = 1
      ux = 1
      uy = 0
      uz = 0
  [../]
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
        end_value = 5
        execute_on = 'initial timestep_begin timestep_end'
    [../]
[]

# Make it such that these kernels only act on
#   block = '2' (i.e., open channel).
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
    block = '2'
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    variable = 'u'
    rho = ${rho}
    block = '2'
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
    block = '2'
  []
  [u_viscosity]
    type = FVDiffusion
    variable = u
    coeff = ${mu}
    block = '2'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    momentum_component = 'x'
    pressure = pressure
    block = '2'
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    variable = 'v'
    rho = ${rho}
    block = '2'
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
    block = '2'
  []
  [v_viscosity]
    type = FVDiffusion
    variable = v
    coeff = ${mu}
    block = '2'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = v
    momentum_component = 'y'
    pressure = pressure
    block = '2'
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
    #type = INSFVInletVelocityBC
    #function = '1*t'

    boundary = 'inlet'
    variable = u

    # Can just use basic FV BCs from MOOSE framework
    #type = FVDirichletBC
    #value = 1

    # HERE, we can use the postprocessor BC
    #   to loosely couple with an aux variable
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
    boundary = 'top bottom'
    variable = u
    function = 0
  []
  [obj-u]
    type = INSFVNoSlipWallBC
    boundary = 'object'
    variable = u
    function = 0
  []
  [walls-v]
    type = INSFVNoSlipWallBC
    boundary = 'top bottom object'
    variable = v
    function = 0
  []
  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'outlet'
    variable = pressure
    function = '0'
  []
[]

[Materials]
  [ins_fv]
    type = INSFVMaterial
    u = 'u'
    v = 'v'
    pressure = 'pressure'
    rho = ${rho}
    block = '2'
  []

  # NOTE: If any block has a material, then all blocks
  #     must have a material. Here, we invoke an instance
  #     of CATS INSFluid material and provide dummy args.
  [dummy_mat]
    type = INSFluid
    density = CO2
    viscosity = CO2
    block = '1 2'
  []
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
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      200                lu           NONZERO'
  line_search = 'none'
  nl_rel_tol = 1e-12
  nl_abs_tol = 1e-8

  end_time = 5
  # If there is high Re, then need smaller dt
  #     helps to rescale problem by choosing
  #     different unit basis that is more
  #     appropriate for time scale and length.
  dt = 0.5
[]

[Outputs]
  exodus = true
  csv = true
[]
