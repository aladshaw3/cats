# Testing a partial mesh for flow
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
    file = CO2_electrolyzer_half_cell_partial.msh

    ### ========= boundary_name ==========
    # "channel_exit"
    # "channel_enter"
    # "channel_side_walls"
    # "plate_end_walls"
    # "channel_bottom"
    # "plate_bottom"
    # "plate_interface_cathode"
    # "channel_interface_cathode"

    ### ====== block ========
    # "channel"
    # "plate"
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
      block = 'channel'
  [../]

  # fluid pressure
  [./pressure]
      order = FIRST
      family = LAGRANGE
      scaling = 1
      block = 'channel'
      initial_condition = 1.0e5
  [../]


[]

[ICs]
[]

[AuxVariables]
  [./vel_mag]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.0
  [../]

  [./D]
      order = FIRST
      family = MONOMIAL
      initial_condition = 100.0
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
      Dx = D
      Dy = D
      Dz = D
  [../]

  ## =============== Pressure ========================
  [./pressure_laplace_channels]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = 1
      block = 'channel'
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
      ux = 1
      block = 'channel'
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
      uy = 1
      block = 'channel'
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
      uz = 1
      block = 'channel'
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
      porosity = 1
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

  # exit pressure
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'channel_exit'
      value = 0
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = NeumannBC
      variable = pressure
      boundary = 'channel_enter'
      value = 963.33   # mm/s
  [../]

  [./no_slip_x]
      type = DirichletBC
      variable = vel_x
      boundary = 'channel_side_walls channel_bottom'
      value = 0
  [../]
  [./no_slip_y]
      type = DirichletBC
      variable = vel_y
      boundary = 'channel_side_walls channel_bottom'
      value = 0
  [../]
  [./no_slip_z]
      type = DirichletBC
      variable = vel_z
      boundary = 'channel_side_walls channel_bottom'
      value = 0
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

                         50
                         50

                         1e-16
                         1e-6

                         mumps

                          0.01
                          0.
                          500'


  line_search = l2
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10

  start_time = 0.0
  end_time = 0.4
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
