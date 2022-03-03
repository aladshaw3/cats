# Test the pressure driven flow in the domain

[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = 2D_Electrolyzer_mm.msh

    ### ========= boundary_name ==========
    # "cathode_fluid_channel_left"
    # "cathode_fluid_channel_bottom"
    # "cathode_fluid_channel_top"
    # "cathode_fluid_channel_interface_cathode"
    # "cathode_bottom"
    # "cathode_top"
    # "cathode_interface_membrane"
    # "membrane_bottom"
    # "membrane_top"
    # "membrane_interface_anode"
    # "anode_bottom"
    # "anode_top"
    # "anode_interface_anode_fluid_channel"
    # "anode_fluid_channel_bottom"
    # "anode_fluid_channel_top"
    # "anode_fluid_channel_right"

    ### ====== block ========
    # "cathode_fluid_channel"
    # "cathode"
    # "membrane"
    # "anode"
    # "anode_fluid_channel"
  []

[] # END Mesh

[Variables]
  # relative pressure
  [./pressure]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # velocity in x
  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
  [../]

  # velocity in y
  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
  [../]

  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.2E-6 #mol/mm^3
      scaling = 1e3
  [../]
[]

[AuxVariables]
  # velocity in z
  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]

  [./Dp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1
  [../]
[]

[Kernels]
  [./pressure_laplace_electrodes]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = 1
  [../]

  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./x_darcy]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = 1
  [../]

  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]
  [./y_darcy]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = 1
  [../]

  [./H2O_dot]
      type = VariableCoefTimeDerivative
      variable = H2O
      coupled_coef = 1
  [../]
  [./H2O_gadv]
      type = GPoreConcAdvection
      variable = H2O
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H2O_gdiff]
      type = GVarPoreDiffusion
      variable = H2O
      porosity = 1
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]
[]

[DGKernels]
  [./H2O_dgadv]
      type = DGPoreConcAdvection
      variable = H2O
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H2O_dgdiff]
      type = DGVarPoreDiffusion
      variable = H2O
      porosity = 1
      Dx = Dp
      Dy = Dp
      Dz = Dp
  [../]
[]

[InterfaceKernels]
[] #END InterfaceKernels

[AuxKernels]
[]

[BCs]
  # exit pressure
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      value = 0
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = NeumannBC
      variable = pressure
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      value = 66   # vel in mm/min
  [../]

  # zero pressure grad at non-exits
  [./press_grad_at_non_exits]
      type = NeumannBC
      variable = pressure
      boundary = 'cathode_bottom cathode_top anode_bottom anode_top membrane_bottom membrane_top'
      value = 0   # vel in mm/min
  [../]


  [./H2O_FluxIn_pos]
      type = DGPoreConcFluxBC
      variable = H2O
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 2.4E-6
  [../]
  [./H2O_FluxIn_neg]
      type = DGPoreConcFluxBC
      variable = H2O
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      u_input = 1.2E-6
  [../]
  [./H2O_FluxOut]
      type = DGPoreConcFluxBC
      variable = H2O
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top cathode_top membrane_top anode_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
[]

[Postprocessors]
  [./pressure_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./H2O_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = H2O
      execute_on = 'initial timestep_end'
  [../]

  [./H2O_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = H2O
      execute_on = 'initial timestep_end'
  [../]
[]


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

  petsc_options_value = 'fgmres
                         ksp

                         lu

                         20

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-10
                         1E-10

                         fgmres
                         lu'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 20

  start_time = 0.0
  end_time = 1.0
  dtmax = 0.025

  [./TimeStepper]
		  type = ConstantDT
      dt = 0.025
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
