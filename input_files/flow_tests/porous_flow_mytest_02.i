# Darcy flow
[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 10
    ny = 10
    xmin = 0.0
    xmax = 10.0
    ymin = 0.0
    ymax = 10.0
[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[Variables]
  [porepressure]
  []

  [./tracer]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]
[]

# Won't work, can't couple with darcy_vel_x values
[Kernels]
  [./tracer_dot]
      type = VariableCoefTimeDerivative
      variable = tracer
      coupled_coef = 0.4
  [../]
  [./tracer_gadv]
      type = GPoreConcAdvection
      variable = tracer
      porosity = 0.4
      ux = darcy_vel_x
      uy = darcy_vel_y
      uz = 0
  [../]
  [./tracer_gdiff]
      type = GVarPoreDiffusion
      variable = tracer
      porosity = 0.4

      #Dispersion with mechanical mixing may be needed
      #   Helps to clear out material from the wall due
      #   to using the no-slip condition (which causes
      #   a lot of accumulation at the wall)
      Dx = 0.1
      Dy = 0.1
      Dz = 0.1
  [../]
[]

[DGKernels]
  [./tracer_dgadv]
      type = DGPoreConcAdvection
      variable = tracer
      porosity = 0.4
      ux = darcy_vel_x
      uy = darcy_vel_y
      uz = 0
  [../]
  [./tracer_dgdiff]
      type = DGVarPoreDiffusion
      variable = tracer
      porosity = 0.4

      #Dispersion with mechanical mixing may be needed
      #   Helps to clear out material from the wall due
      #   to using the no-slip condition (which causes
      #   a lot of accumulation at the wall)
      Dx = 0.1
      Dy = 0.1
      Dz = 0.1
  [../]
[]

[PorousFlowBasicTHM]
  porepressure = porepressure
  coupling_type = Hydro
  gravity = '0 0 0'
  fp = the_simple_fluid
[]

[BCs]
  [constant_injection_porepressure]
    type = DirichletBC
    variable = porepressure
    value = 100
    boundary = 'left'
  []
  [constant_exit_porepressure]
    type = DirichletBC
    variable = porepressure
    value = 90
    boundary = 'right'
  []
[]

[Modules]
  [FluidProperties]
    [the_simple_fluid]
      type = SimpleFluidProperties
      bulk_modulus = 2E4
      viscosity = 1.0E-3
      density0 = 1000.0
    []
  []
[]

[Materials]
  [porosity]
    type = PorousFlowPorosity
    porosity_zero = 0.4
  []
  [biot_modulus]
    type = PorousFlowConstantBiotModulus
    biot_coefficient = 0.8
    solid_bulk_compliance = 2E-6
    fluid_bulk_modulus = 1E6
  []
  [permeability_aquifer]
    type = PorousFlowPermeabilityConst
    permeability = '1E-3 0 0
                    0 1E-3 0
                    0 0 1E-3'
  []
[]

[Preconditioning]
  active = basic
  [basic]
    type = SMP
    full = true
    solve_type = Newton
  []
[]

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
                         1E-8
                         1E-10

                         fgmres
                         lu'
  end_time = 10
  dt = 0.1
[]

[Outputs]
  exodus = true
[]

[Postprocessors]

    [./pressure_right]
        type = SideAverageValue
        boundary = 'right'
        variable = porepressure
        execute_on = 'initial timestep_end'
    [../]

    [./ux_right]
        type = SideAverageValue
        boundary = 'right'
        variable = darcy_vel_x
        execute_on = 'initial timestep_end'
    [../]

    [./uy_right]
        type = SideAverageValue
        boundary = 'right'
        variable = darcy_vel_y
        execute_on = 'initial timestep_end'
    [../]
[]
