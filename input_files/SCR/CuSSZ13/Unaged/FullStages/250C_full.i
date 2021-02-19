[GlobalParams]
  dg_scheme = nipg
  sigma = 10
  transfer_rate = 5757.541  #min^-1
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 20
    xmin = 0.0
    xmax = 1.0    #2cm radius
    ymin = 0.0
    ymax = 5.0    #5cm length
[] # END Mesh

[Variables]

## Gas phase variable lists
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.002330029
    [../]

    [./O2w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.002330029
    [../]

    [./H2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.001174
    [../]

    [./H2Ow]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.001174
    [../]

    [./NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NH3w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NOx]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NOxw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NO2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NO2w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./N2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./N2Ow]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

[] #END Variables

[AuxVariables]

  # Z1CuOH
  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.052619
  [../]

  # Z2Cu sites
  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0231257
  [../]

  # ZH sites
  [./w3a]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.01632
  [../]

  # ZH/ZCu sites
  [./w3b]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.003233
  [../]

  # ZH/CuO
  [./w3c]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.006699
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 523.15
  [../]

  [./D]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
  [../]

  # e_b
  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]

  # non_pore = (1 - pore)
  [./non_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.6691
  [../]

  # ew =~ 1/5
  # total_pore = ew* (1 - pore)
  # micro_pore_vol = 0.18 cm^3/g
  # assume ew = 0.2
  [./total_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.13382
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 15110 #cm/min
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
    # =============== Bulk phase O2 ===============
    [./O2_dot]
        type = VariableCoefTimeDerivative
        variable = O2
        coupled_coef = pore
    [../]
    [./O2_gadv]
        type = GPoreConcAdvection
        variable = O2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_gdiff]
        type = GVarPoreDiffusion
        variable = O2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./O2w_trans]
        type = ConstMassTransfer
        variable = O2
        coupled = O2w
    [../]

    # =============== Washcoat phase O2 ===============
    [./O2w_dot]
        type = VariableCoefTimeDerivative
        variable = O2w
        coupled_coef = total_pore
    [../]
    [./O2_trans]
        type = ConstMassTransfer
        variable = O2w
        coupled = O2
    [../]

    # =============== Bulk phase H2O ===============
    [./H2O_dot]
        type = VariableCoefTimeDerivative
        variable = H2O
        coupled_coef = pore
    [../]
    [./H2O_gadv]
        type = GPoreConcAdvection
        variable = H2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_gdiff]
        type = GVarPoreDiffusion
        variable = H2O
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./H2Ow_trans]
        type = ConstMassTransfer
        variable = H2O
        coupled = H2Ow
    [../]

    # =============== Washcoat phase H2O ===============
    [./H2Ow_dot]
        type = VariableCoefTimeDerivative
        variable = H2Ow
        coupled_coef = total_pore
    [../]
    [./H2O_trans]
        type = ConstMassTransfer
        variable = H2Ow
        coupled = H2O
    [../]

    # =============== Bulk phase NH3 ===============
    [./NH3_dot]
        type = VariableCoefTimeDerivative
        variable = NH3
        coupled_coef = pore
    [../]
    [./NH3_gadv]
        type = GPoreConcAdvection
        variable = NH3
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_gdiff]
        type = GVarPoreDiffusion
        variable = NH3
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./NH3w_trans]
        type = ConstMassTransfer
        variable = NH3
        coupled = NH3w
    [../]

    # =============== Washcoat phase NH3 ===============
    [./NH3w_dot]
        type = VariableCoefTimeDerivative
        variable = NH3w
        coupled_coef = total_pore
    [../]
    [./NH3_trans]
        type = ConstMassTransfer
        variable = NH3w
        coupled = NH3
    [../]

    # =============== Bulk phase NO ===============
    [./NOx_dot]
        type = VariableCoefTimeDerivative
        variable = NOx
        coupled_coef = pore
    [../]
    [./NOx_gadv]
        type = GPoreConcAdvection
        variable = NOx
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NOx_gdiff]
        type = GVarPoreDiffusion
        variable = NOx
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./NOxw_trans]
        type = ConstMassTransfer
        variable = NOx
        coupled = NOxw
    [../]

    # =============== Washcoat phase NO ===============
    [./NOxw_dot]
        type = VariableCoefTimeDerivative
        variable = NOxw
        coupled_coef = total_pore
    [../]
    [./NOx_trans]
        type = ConstMassTransfer
        variable = NOxw
        coupled = NOx
    [../]

    # =============== Bulk phase NO2 ===============
    [./NO2_dot]
        type = VariableCoefTimeDerivative
        variable = NO2
        coupled_coef = pore
    [../]
    [./NO2_gadv]
        type = GPoreConcAdvection
        variable = NO2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NO2_gdiff]
        type = GVarPoreDiffusion
        variable = NO2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./NO2w_trans]
        type = ConstMassTransfer
        variable = NO2
        coupled = NO2w
    [../]

    # =============== Washcoat phase NO2 ===============
    [./NO2w_dot]
        type = VariableCoefTimeDerivative
        variable = NO2w
        coupled_coef = total_pore
    [../]
    [./NO2_trans]
        type = ConstMassTransfer
        variable = NO2w
        coupled = NO2
    [../]

    # =============== Bulk phase N2O ===============
    [./N2O_dot]
        type = VariableCoefTimeDerivative
        variable = N2O
        coupled_coef = pore
    [../]
    [./N2O_gadv]
        type = GPoreConcAdvection
        variable = N2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./N2O_gdiff]
        type = GVarPoreDiffusion
        variable = N2O
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./N2Ow_trans]
        type = ConstMassTransfer
        variable = N2O
        coupled = N2Ow
    [../]

    # =============== Washcoat phase N2O ===============
    [./N2Ow_dot]
        type = VariableCoefTimeDerivative
        variable = N2Ow
        coupled_coef = total_pore
    [../]
    [./N2O_trans]
        type = ConstMassTransfer
        variable = N2Ow
        coupled = N2O
    [../]


[] #END Kernels

[DGKernels]

    # =========== O2 DG kernels ===========
    [./O2_dgadv]
        type = DGPoreConcAdvection
        variable = O2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_dgdiff]
        type = DGVarPoreDiffusion
        variable = O2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== H2O DG kernels ===========
    [./H2O_dgadv]
        type = DGPoreConcAdvection
        variable = H2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_dgdiff]
        type = DGVarPoreDiffusion
        variable = H2O
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== NH3 DG kernels ===========
    [./NH3_dgadv]
        type = DGPoreConcAdvection
        variable = NH3
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_dgdiff]
        type = DGVarPoreDiffusion
        variable = NH3
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== NO DG kernels ===========
    [./NOx_dgadv]
        type = DGPoreConcAdvection
        variable = NOx
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NOx_dgdiff]
        type = DGVarPoreDiffusion
        variable = NOx
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== NO2 DG kernels ===========
    [./NO2_dgadv]
        type = DGPoreConcAdvection
        variable = NO2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NO2_dgdiff]
        type = DGVarPoreDiffusion
        variable = NO2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== N2O DG kernels ===========
    [./N2O_dgadv]
        type = DGPoreConcAdvection
        variable = N2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./N2O_dgdiff]
        type = DGVarPoreDiffusion
        variable = N2O
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

[] #END DGKernels

[AuxKernels]

[] #END AuxKernels

[BCs]

    # ============== O2 BCs ================
    [./O2_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = O2
        boundary = 'bottom'
        u_input = 0.002330029
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '4.66006E-5 0.002330029'
        input_times = '2.0917 29.758'
        time_spans = '0.25 0.25'
    [../]
    [./O2_FluxOut]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== H2O BCs ================
    [./H2O_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = H2O
        boundary = 'bottom'
        u_input = 0.001174
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '0.00115689 0.001144255    0.00113886'
        input_times = '3.5917   31.5    203.5'
        time_spans = '0.25  0.25  0.25'
    [../]
    [./H2O_FluxOut]
        type = DGPoreConcFluxBC
        variable = H2O
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NH3 BCs ================
    [./NH3_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = NH3
        boundary = 'bottom'
        u_input = 1E-9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '6.9499E-6   1E-9   6.9499E-6  1E-9    6.9499E-6   1E-9'
        input_times = '2.0917   40.75    56.2583    101.425    130.425    190.7583'
        time_spans = '0.25      0.25    0.25    0.25    0.25    0.25'
    [../]
    [./NH3_FluxOut]
        type = DGPoreConcFluxBC
        variable = NH3
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NO BCs ================
    [./NOx_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = NOx
        boundary = 'bottom'
        u_input = 1E-9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '6.9239E-6   3.44803E-6   6.9239E-6'
        input_times = '40.75    116.925    203.7583'
        time_spans = '0.25      0.25    0.25'
    [../]
    [./NOx_FluxOut]
        type = DGPoreConcFluxBC
        variable = NOx
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NO2 BCs ================
    [./NO2_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = NO2
        boundary = 'bottom'
        u_input = 1E-9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '3.37554E-6   1E-9'
        input_times = '116.925    203.7583'
        time_spans = '0.25      0.25    0.25'
    [../]
    [./NO2_FluxOut]
        type = DGPoreConcFluxBC
        variable = NO2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== N2O BCs ================
    [./N2O_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = N2O
        boundary = 'bottom'
        u_input = 1E-9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '1E-9'
        input_times = '1'
        time_spans = '0.25'
    [../]
    [./N2O_FluxOut]
        type = DGPoreConcFluxBC
        variable = N2O
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./O2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./O2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./H2O_out]
        type = SideAverageValue
        boundary = 'top'
        variable = H2O
        execute_on = 'initial timestep_end'
    [../]

    [./H2O_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2O
        execute_on = 'initial timestep_end'
    [../]

    [./NH3_out]
        type = SideAverageValue
        boundary = 'top'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./NH3_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./NO_out]
        type = SideAverageValue
        boundary = 'top'
        variable = NOx
        execute_on = 'initial timestep_end'
    [../]

    [./NO_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NOx
        execute_on = 'initial timestep_end'
    [../]

    [./NO2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = NO2
        execute_on = 'initial timestep_end'
    [../]

    [./NO2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NO2
        execute_on = 'initial timestep_end'
    [../]

    [./N2O_out]
        type = SideAverageValue
        boundary = 'top'
        variable = N2O
        execute_on = 'initial timestep_end'
    [../]

    [./N2O_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = N2O
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 212.0
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = false
  exodus = true
  csv = true
[] #END Outputs
