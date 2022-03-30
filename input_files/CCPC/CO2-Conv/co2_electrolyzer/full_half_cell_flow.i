# Testing a half-cell mesh for flow
# -------------------------------
#   Dimensionality and flow rate from
#   literature would result in a hydraulic
#   residence time of ~0.2 seconds

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    #file = CO2_electrolyzer_half_cell_coarse.msh

    # No issue with mesh, just issues with the MUMPS linear solver
    # during preconditioning
    file = CO2_electrolyzer_half_cell_fine.msh

    ### ========= boundary_name ==========
    # "channel_exit"
    # "channel_enter"
    # "channel_side_walls"
    # "plate_end_walls"
    # "channel_bottom"
    # "plate_bottom"
    # "plate_interface_cathode"
    # "channel_interface_cathode"
    # "cathode_interface_membrane"
    # "cathode_left"
    # "cathode_right"
    # "cathode_bottom"
    # "cathode_top"
    # "catex_mem_bottom"
    # "catex_mem_top"
    # "catex_mem_interface"
    # "catex_mem_left"
    # "catex_mem_right"

    ### ====== block ========
    # "channel"
    # "plate"
    # "cathode"
    # "catex_membrane"
  []

[] # END Mesh

[Variables]
  [./dummy]
      order = FIRST
      family = LAGRANGE
      scaling = 1
      block = 'plate'
  [../]

  [./tracer]
      order = FIRST
      family = MONOMIAL
      scaling = 1
      initial_condition = 1.0e-20
      block = 'channel cathode catex_membrane'
  [../]

  # fluid pressure
  [./pressure]
      order = FIRST
      family = LAGRANGE
      scaling = 1
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]

  # velocity in x
  [./vel_x]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]

  # velocity in y
  [./vel_y]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]

  # velocity in z
  [./vel_z]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]
[]

[ICs]

[]

[AuxVariables]
  [./vel_mag]
      order = CONSTANT
      family = MONOMIAL
      block = 'channel cathode catex_membrane'
  [../]

  [./eps]
      order = CONSTANT
      family = MONOMIAL
      block = 'channel cathode catex_membrane'
  [../]

  [./D]
      order = CONSTANT
      family = MONOMIAL
      block = 'channel cathode catex_membrane'
  [../]

  [./density]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.001 # g/mm^3
      block = 'channel cathode catex_membrane'
  [../]
  [./viscosity]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.001 # Pa*s = kg/m/s = g/mm/s
      block = 'channel cathode catex_membrane'
  [../]

  # coefficient for all domains
  [./press_coef]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 1
      block = 'channel cathode catex_membrane'
  [../]

  # Electrolyte temperature
  [./T_e]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 300 #K
      block = 'channel cathode catex_membrane'
  [../]

  # Electrode temperature
  [./T_s]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 300 #K
      block = 'plate cathode catex_membrane'
  [../]

  # velocity inlet
  [./vel_in]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0.1
      block = 'channel cathode catex_membrane'
  [../]
[]

[Kernels]
  ## =============== dummy ========================
  [./dummy]
      type = VariableLaplacian
      variable = dummy
      coupled_coef = 1
  [../]

  ## ===================== tracer balance ====================
  [./tracer_dot]
      type = VariableCoefTimeDerivative
      variable = tracer
      coupled_coef = eps
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
      porosity = eps
      Dx = D
      Dy = D
      Dz = D
  [../]

  ## =============== Pressure ========================
  [./pressure_laplace_channel]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'channel'
  [../]
  [./pressure_laplace_cathode]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'cathode'
  [../]
  [./pressure_laplace_membrane]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'catex_membrane'
  [../]

  ## =================== vel in x ==========================
  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./x_channel]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'channel'
  [../]
  [./x_cathode]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'cathode'
  [../]
  [./x_membrane]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'catex_membrane'
  [../]

  ## =================== vel in y ==========================
  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]
  [./y_channel]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'channel'
  [../]
  [./y_cathode]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'cathode'
  [../]
  [./y_membrane]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'catex_membrane'
  [../]

  ## =================== vel in z ==========================
  [./v_z_equ]
      type = Reaction
      variable = vel_z
  [../]
  [./z_channel]
      type = VariableVectorCoupledGradient
      variable = vel_z
      coupled = pressure
      uz = press_coef
      block = 'channel'
  [../]
  [./z_cathode]
      type = VariableVectorCoupledGradient
      variable = vel_z
      coupled = pressure
      uz = press_coef
      block = 'cathode'
  [../]
  [./z_membrane]
      type = VariableVectorCoupledGradient
      variable = vel_z
      coupled = pressure
      uz = press_coef
      block = 'catex_membrane'
  [../]
[]

[DGKernels]
  ## ===================== tracer balance ====================
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
      porosity = eps
      Dx = D
      Dy = D
      Dz = D
  [../]
[]

[InterfaceKernels]
[]

[AuxKernels]
  [./vel_calc]
      type = VectorMagnitude
      variable = vel_mag
      ux = vel_x
      uy = vel_y
      uz = vel_z
      execute_on = 'timestep_end'
  [../]

  [./eps_calc_one]
      type = ConstantAux
      variable = eps
      value = 0.999

      execute_on = 'initial timestep_end'
      block = 'channel catex_membrane'
  [../]
  [./eps_calc_two]
      type = ConstantAux
      variable = eps
      value = 0.85

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  ## ============================ D calc ===========================
  [./D_calc_channels]
      type = SimpleFluidDispersion
      variable = D
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'channel'
  [../]

  [./D_calc_elec]
      type = SimpleFluidDispersion
      variable = D
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  [./D_calc_mem]
      type = SimpleFluidDispersion
      variable = D
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'catex_membrane'
  [../]

  [./dens_calc]
      type = SimpleFluidDensity
      variable = density
      temperature = T_e

      output_volume_unit = "mm^3"
      output_mass_unit = "g"

      execute_on = 'initial timestep_end'
  [../]

  [./visc_calc]
      type = SimpleFluidViscosity
      variable = viscosity
      temperature = T_e

      output_length_unit = "mm"
      output_mass_unit = "g"
      output_time_unit = "s"

      unit_basis = "mass"

      execute_on = 'initial timestep_end'
  [../]

  [./coef_calc_channels]
      type = DarcyWeisbachCoefficient
      variable = press_coef

      friction_factor = 0.05       # ~64/Re
      density = density            #g/mm^3
      velocity = vel_in           #mm/s
      hydraulic_diameter = 1.315   #mm

      execute_on = 'initial timestep_end'
      block = 'channel'
  [../]

  [./coef_calc_elec]
      type = KozenyCarmanDarcyCoefficient
      variable = press_coef

      porosity = eps
      viscosity = viscosity   #g/mm/s
      particle_diameter = 0.01 #mm
      kozeny_carman_const = 150 #for spheres

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  [./coef_calc_mem]
      type = SchloeglDarcyCoefficient
      variable = press_coef

      hydraulic_permeability = 1.58E-12  #mm^2
      viscosity = viscosity  #g/mm/s

      execute_on = 'initial timestep_end'
      block = 'catex_membrane'
  [../]

  [./vel_step_input]
      type = TemporalStepFunction
      variable = vel_in

      start_value = 963.33
      aux_vals = '963.33'
      aux_times = '15'
      time_spans = '30'

      execute_on = 'initial timestep_begin nonlinear'
  [../]
[]

[BCs]

  ## =============== tracer fluxes ================
  [./tracer_FluxIn]
      type = DGFlowMassFluxBC
      variable = tracer
      boundary = 'channel_enter'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1.0
  [../]
  [./tracer_FluxOut]
      type = DGFlowMassFluxBC
      variable = tracer
      boundary = 'channel_exit'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]

  ## NOTE: If we want to consider losses at boundary edges
  #[./tracer_leaking]
  #    type = DGFlowMassFluxBC
  #    variable = tracer
  #    boundary = 'catex_mem_left catex_mem_right
  #                catex_mem_top catex_mem_bottom
  #                cathode_left cathode_right
  #                cathode_top cathode_bottom'
  #    porosity = 1
  #    ux = vel_x
  #    uy = vel_y
  #    uz = vel_z
  #[../]
  #[./tracer_membrane_trans]
  #    type = DGFlowMassFluxBC
  #    variable = tracer
  #    boundary = 'catex_mem_interface'
  #    porosity = 1
  #    ux = vel_x
  #    uy = vel_y
  #    uz = vel_z
  #[../]

  # exit pressure
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'channel_exit'
      value = 0
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = CoupledNeumannBC
      variable = pressure
      boundary = 'channel_enter'
      coupled = vel_in  # mm/s
  [../]

[]

[Postprocessors]
  [./pressure_inlet]
      type = SideAverageValue
      boundary = 'channel_enter'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
      type = SideAverageValue
      boundary = 'channel_exit'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./tracer_inlet]
      type = SideAverageValue
      boundary = 'channel_enter'
      variable = tracer
      execute_on = 'initial timestep_end'
  [../]

  [./tracer_outlet]
      type = SideAverageValue
      boundary = 'channel_exit'
      variable = tracer
      execute_on = 'initial timestep_end'
  [../]

  [./vy_inlet]
      type = SideAverageValue
      boundary = 'channel_enter'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vy_outlet]
      type = SideAverageValue
      boundary = 'channel_exit'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]
[]

[Executioner]
  type = Transient
  scheme = implicit-euler

  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason
                    -snes_linesearch_monitor

                    -ksp_gmres_modifiedgramschmidt
                    -ksp_ksp_gmres_modifiedgramschmidt'

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

                        -pc_gasm_overlap

                        -snes_atol
                        -snes_rtol

                        -ksp_ksp_type
                        -ksp_pc_type

                        -ksp_gmres_restart
                        -ksp_ksp_gmres_restart

                        -ksp_max_it
                        -ksp_ksp_max_it

                        -ksp_rtol
                        -ksp_atol

                         -ksp_pc_factor_mat_solver_type
                        	-mat_mumps_cntl_1
                          -mat_mumps_cntl_3
                          -mat_mumps_icntl_23'

  ## NOTE: May be best to just use lu as pc_type instead of ksp
  petsc_options_value = 'fgmres
                         ksp

                         lu

                         50

                         NONZERO
                         NONZERO
                         NONZERO

                         20

                         1E-6
                         1E-8

                         fgmres
                         lu

                         50
                         50

                         20
                         10

                         1e-16
                         1e-6

                         mumps
                          0.01
                          1e-10
                          2000'


  line_search = l2
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10

  start_time = 0.0
  end_time = 0.5
  dtmax = 1

  [./TimeStepper]
		  type = SolutionTimeAdaptiveDT
      dt = 0.01
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
    interval = 1

[] #END Outputs
