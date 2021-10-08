[GlobalParams]
    dg_scheme = nipg
    sigma = 10

[] #END GlobalParams

[Problem]
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    coord_type = RZ
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 5
    ny = 10
    xmin = 0.0
    xmax = 0.0725    # m radius
    ymin = 0.0
    ymax = 0.1346    # m length
[]

[Variables]
    [./Ef]
        order = FIRST
        family = MONOMIAL
        # Ef = rho*cp*T     (1 kg/m^3) * (1000 J/kg/K) * (298 K)
        [./InitialCondition]
            type = InitialPhaseEnergy
            specific_heat = cpg
            density = rho
            temperature = Tf
        [../]
    [../]

    [./Es]
        order = FIRST
        family = MONOMIAL
        # Ef = rho*cp*T     (1 kg/m^3) * (1000 J/kg/K) * (298 K)
        [./InitialCondition]
            type = InitialPhaseEnergy
            specific_heat = cps
            density = rho_s
            temperature = Ts
        [../]
    [../]

    [./Tf]
        order = FIRST
        family = MONOMIAL
        initial_condition = 298  #K
    [../]

    [./Ts]
        order = FIRST
        family = MONOMIAL
        initial_condition = 298  #K
    [../]

    # Bulk gas concentration for O2
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]
[]

[AuxVariables]
    [./vel_x]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./vel_y]
        order = FIRST
        family = LAGRANGE
        initial_condition = 2.5769 #m/s  - avg linear velocity
    [../]

    [./vel_z]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./Kg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.1          #W/m/K
    [../]

    [./Ks]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.9       #W/m/K
    [../]

    [./eps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.4371          #W/m/K
    [../]

    [./s_frac]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.5629          #W/m/K
    [../]

    [./rho]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1       #kg/m^3
    [../]

    [./rho_s]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1599       #kg/m^3
    [../]

    [./cpg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1000       #J/kg/K
    [../]

    [./cps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 680       #J/kg/K
    [../]

    [./hw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 50       #W/m^2/K
    [../]

    [./Tw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 298  #K
    [../]

    [./hs]
        order = FIRST
        family = MONOMIAL
        initial_condition = 25       #W/m^2/K
    [../]

    [./Ao]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11797       #m^-1
    [../]

[]

[Kernels]
     [./Ef_dot]
         type = VariableCoefTimeDerivative
         variable = Ef
         coupled_coef = eps
     [../]
     [./Ef_gadv]
         type = GPoreConcAdvection
         variable = Ef
         porosity = eps
         ux = vel_x
         uy = vel_y
         uz = vel_z
     [../]
     [./Ef_gdiff]
         type = GPhaseThermalConductivity
         variable = Ef
         temperature = Tf
         volume_frac = eps
         Dx = Kg
         Dy = Kg
         Dz = Kg
     [../]
     [./Ef_trans]
         type = PhaseEnergyTransfer
         variable = Ef
         this_phase_temp = Tf
         other_phase_temp = Ts
         transfer_coef = hs
         specific_area = Ao
         volume_frac = s_frac
     [../]

    [./Es_dot]
        type = VariableCoefTimeDerivative
        variable = Es
        coupled_coef = s_frac
    [../]
    [./Es_gdiff]
        type = GPhaseThermalConductivity
        variable = Es
        temperature = Ts
        volume_frac = s_frac
        Dx = Ks
        Dy = Ks
        Dz = Ks
    [../]
    [./Es_trans]
        type = PhaseEnergyTransfer
        variable = Es
        this_phase_temp = Ts
        other_phase_temp = Tf
        transfer_coef = hs
        specific_area = Ao
        volume_frac = s_frac
    [../]

    [./Tf_calc]
        type = PhaseTemperature
        variable = Tf
        energy = Ef
        specific_heat = cpg
        density = rho
    [../]

    [./Ts_calc]
        type = PhaseTemperature
        variable = Ts
        energy = Es
        specific_heat = cps
        density = rho_s
    [../]

    [./O2_dot]
        type = VariableCoefTimeDerivative
        variable = O2
        coupled_coef = eps
    [../]
    [./O2_gadv]
        type = GPoreConcAdvection
        variable = O2
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_gdiff]
        type = GVarPoreDiffusion
        variable = O2
        porosity = eps
        Dx = 0.01
        Dy = 0.01
        Dz = 0.01
    [../]
[]

[DGKernels]
    [./Ef_dgadv]
        type = DGPoreConcAdvection
        variable = Ef
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./Ef_dgdiff]
        type = DGPhaseThermalConductivity
        variable = Ef
        temperature = Tf
        volume_frac = eps
        Dx = Kg
        Dy = Kg
        Dz = Kg
    [../]

    [./Es_dgdiff]
        type = DGPhaseThermalConductivity
        variable = Es
        temperature = Ts
        volume_frac = s_frac
        Dx = Ks
        Dy = Ks
        Dz = Ks
    [../]

    [./O2_dgadv]
        type = DGPoreConcAdvection
        variable = O2
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_dgdiff]
        type = DGVarPoreDiffusion
        variable = O2
        porosity = eps
        Dx = 0.01
        Dy = 0.01
        Dz = 0.01
    [../]
[]

[BCs]
    [./Ef_Flux_OpenBounds]
        type = DGFlowEnergyFluxBC
        variable = Ef
        boundary = 'bottom top'
        porosity = eps
        specific_heat = cpg
        density = rho
        inlet_temp = 348
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./Ef_WallFluxIn]
        type = DGWallEnergyFluxBC
        variable = Ef
        boundary = 'right'
        transfer_coef = hw
        wall_temp = Tw
        temperature = Tf
        area_frac = eps
    [../]

    [./Es_WallFluxIn]
        type = DGWallEnergyFluxBC
        variable = Es
        boundary = 'right'
        transfer_coef = hw
        wall_temp = Tw
        temperature = Ts
        area_frac = s_frac
    [../]

    [./O2_FluxIn]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'bottom'
        u_input = 1e-6
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_FluxOut]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'top'
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[]

[Postprocessors]
    [./Ef_out]
        type = SideAverageValue
        boundary = 'top'
        variable = Ef
        execute_on = 'initial timestep_end'
    [../]

    [./Ef_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = Ef
        execute_on = 'initial timestep_end'
    [../]

    [./Es_out]
        type = SideAverageValue
        boundary = 'top'
        variable = Es
        execute_on = 'initial timestep_end'
    [../]

    [./Es_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = Es
        execute_on = 'initial timestep_end'
    [../]

    [./T_out]
        type = SideAverageValue
        boundary = 'top'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]

    [./T_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]

    [./Ts_out]
        type = SideAverageValue
        boundary = 'top'
        variable = Ts
        execute_on = 'initial timestep_end'
    [../]

    [./Ts_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = Ts
        execute_on = 'initial timestep_end'
    [../]

    [./O2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./O2_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = O2
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
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm lu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 300
  dtmax = 30

  [./TimeStepper]
     type = ConstantDT
     dt = 30
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
