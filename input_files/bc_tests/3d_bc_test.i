# Testing a half-cell mesh for BCs
# --------------------------------
# Test demonstrates that even though the
# interfaces were built as a set that ONLY
# identifies with the control volume / block
# that they were first selected from.
#
# Workaround: Build the 'primary' mesh section
# first, then apply the interfaces to that section.
#
# Question: Can an interface set apply to 2 blocks?

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = CO2_electrolyzer_half_cell_plateless_v2_coarse.msh

    ### ========= boundary_name ==========
    # "channel_exit"
    # "channel_enter"
    # "channel_side_walls"
    # "channel_bottom"
    # "channel_interface_cathode"
    # "cathode_interface_membrane"
    # "plate_interface_cathode"
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
    # "cathode"
    # "catex_membrane"
  []

[] # END Mesh

[Variables]
  [./proton]
      order = FIRST
      family = MONOMIAL
      scaling = 1
      initial_condition = 0.0
      block = 'cathode'
  [../]

  [./proton_mem]
      order = FIRST
      family = MONOMIAL
      scaling = 1
      initial_condition = 0.0
      block = 'catex_membrane'
  [../]

  [./proton_channel]
      order = FIRST
      family = MONOMIAL
      scaling = 1
      initial_condition = 0.0
      block = 'channel'
  [../]

[]

[ICs]

[]

[AuxVariables]
  [./D]
      order = CONSTANT
      family = MONOMIAL
      block = 'channel cathode catex_membrane'
      initial_condition = 1.0
  [../]
[]

[Kernels]
  ## ===================== tracer balance ====================
  [./tracer_dot]
      type = VariableCoefTimeDerivative
      variable = proton
      coupled_coef = 1
  [../]
  [./tracer_gdiff]
      type = GVarPoreDiffusion
      variable = proton
      porosity = 1
      Dx = D
      Dy = D
      Dz = D
  [../]

  [./tracer_dot_mem]
      type = VariableCoefTimeDerivative
      variable = proton_mem
      coupled_coef = 1
  [../]
  [./tracer_gdiff_mem]
      type = GVarPoreDiffusion
      variable = proton_mem
      porosity = 1
      Dx = D
      Dy = D
      Dz = D
  [../]

  [./tracer_dot_channel]
      type = VariableCoefTimeDerivative
      variable = proton_channel
      coupled_coef = 1
  [../]
  [./tracer_gdiff_channel]
      type = GVarPoreDiffusion
      variable = proton_channel
      porosity = 1
      Dx = D
      Dy = D
      Dz = D
  [../]


[]

[DGKernels]
  ## ===================== tracer balance ====================
  [./tracer_dgdiff]
      type = DGVarPoreDiffusion
      variable = proton
      porosity = 1
      Dx = D
      Dy = D
      Dz = D
  [../]

  [./tracer_dgdiff_mem]
      type = DGVarPoreDiffusion
      variable = proton_mem
      porosity = 1
      Dx = D
      Dy = D
      Dz = D
  [../]

  [./tracer_dgdiff_channel]
      type = DGVarPoreDiffusion
      variable = proton_channel
      porosity = 1
      Dx = D
      Dy = D
      Dz = D
  [../]
[]

[InterfaceKernels]
[]

[AuxKernels]

[]

[BCs]

  ## =============== tracer fluxes ================
  [./pos_ion_FluxIn_to_cathode_from_membrane]
      type = DGDiffusionFluxBC
      variable = proton
      boundary = 'cathode_interface_membrane'
      Dxx = 1
      Dyy = 1
      Dzz = 1
      u_input = 1e-8
  [../]

  [./pos_ion_FluxIn_to_membrane_from_edge]
      type = DGDiffusionFluxBC
      variable = proton_mem
      boundary = 'catex_mem_interface'
      Dxx = 1
      Dyy = 1
      Dzz = 1
      u_input = 1e-8
  [../]

  [./pos_ion_FluxIn_to_channel_from_bounds]
      type = DGDiffusionFluxBC
      variable = proton_channel
      boundary = 'channel_exit channel_enter channel_side_walls'
      Dxx = 1
      Dyy = 1
      Dzz = 1
      u_input = 1e-8
  [../]


[]

[Postprocessors]

  [./proton_avg]
      type = ElementAverageValue
      block = 'cathode'
      variable = proton
      execute_on = 'initial timestep_end'
  [../]

  [./proton_mem_avg]
      type = ElementAverageValue
      block = 'catex_membrane'
      variable = proton_mem
      execute_on = 'initial timestep_end'
  [../]

  [./proton_channel_avg]
      type = ElementAverageValue
      block = 'channel'
      variable = proton_channel
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

                         1E-8
                         1E-8

                         fgmres
                         lu

                         50
                         50

                         20
                         10

                         1e-8
                         1e-8

                         mumps
                          0.01
                          1e-8
                          4000'


  line_search = l2
  nl_rel_step_tol = 1e-12
  nl_abs_step_tol = 1e-12

  start_time = 0.0
  end_time = 1
  dtmax = 1

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
    interval = 1

[] #END Outputs
