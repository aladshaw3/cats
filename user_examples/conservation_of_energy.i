[Problem]
    coord_type = RZ
[] #END Problem

[Mesh]
    [./my_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 5
        ny = 20
        xmin = 0.0
        xmax = 0.05
        ymin = 0.0
        ymax = 0.1
    [../]
[] # END Mesh

[Variables]
    [./Ef]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = InitialPhaseEnergy
            specific_heat = cpf
            density = rho
            temperature = Tf
        [../]
    [../]

    [./Es]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = InitialPhaseEnergy
            specific_heat = cps
            density = rhop
            temperature = Ts
        [../]
    [../]

    [./Tf]
        order = FIRST
        family = LAGRANGE
        initial_condition = 400
    [../]

    [./Ts]
        order = FIRST
        family = LAGRANGE
        initial_condition = 400
    [../]
[] #END Variables

[AuxVariables]
  [./eps]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.5
  [../]
 
  [./s_frac]
    # Solids fraction: (1 - eps)
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.5
  [../]
 
  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 3
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]
 
  [./Kf]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.1
  [../]
 
  [./Ks]
    order = FIRST
    family = LAGRANGE
    initial_condition = 20
  [../]
 
  [./h]
    order = FIRST
    family = LAGRANGE
    initial_condition = 600
  [../]
 
  [./Ao]
    order = FIRST
    family = LAGRANGE
    initial_condition = 5000
  [../]
 
  [./rho]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1.2
  [../]
 
  [./cpf]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1100
  [../]
 
  [./rhop]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1500
  [../]
 
  [./cps]
    order = FIRST
    family = LAGRANGE
    initial_condition = 900
  [../]
 
  [./Tw]
      order = FIRST
      family = LAGRANGE
      initial_condition = 300
  [../]
 
  [./hw]
     order = FIRST
     family = LAGRANGE
     initial_condition = 100
  [../]
[] #END AuxVariables

[Kernels]
# Conservation of energy for fluid
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
        Dx = Kf
        Dy = Kf
        Dz = Kf
    [../]
    [./Ef_trans]
        type = PhaseEnergyTransfer
        variable = Ef
        this_phase_temp = Tf
        other_phase_temp = Ts
        transfer_coef = h
        specific_area = Ao
        volume_frac = s_frac
    [../]
 
 # Conservation of energy for solid
    [./Es_dot]
        type = TimeDerivative
        variable = Es
    [../]
    [./Es_gdiff]
        type = GPhaseThermalConductivity
        variable = Es
        temperature = Ts
        volume_frac = 1
        Dx = Ks
        Dy = Ks
        Dz = Ks
    [../]
    [./Es_trans]
        type = PhaseEnergyTransfer
        variable = Es
        this_phase_temp = Ts
        other_phase_temp = Tf
        transfer_coef = h
        specific_area = Ao
        volume_frac = 1
    [../]
 
# Temperature of fluid
    [./Tf_calc]
        type = PhaseTemperature
        variable = Tf
        energy = Ef
        specific_heat = cpf
        density = rho
    [../]
 
# Temperature of solid
    [./Ts_calc]
        type = PhaseTemperature
        variable = Ts
        energy = Es
        specific_heat = cps
        density = rhop
    [../]

[] #END Kernels

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
        Dx = Kf
        Dy = Kf
        Dz = Kf
    [../]
    
    [./Es_dgdiff]
        type = DGPhaseThermalConductivity
        variable = Es
        temperature = Ts
        volume_frac = 1
        Dx = Ks
        Dy = Ks
        Dz = Ks
    [../]

[] #END DGKernels


[BCs]

    [./Ef_Flux_OpenBounds]
        type = DGFlowEnergyFluxBC
        variable = Ef
        boundary = 'bottom top'
        porosity = eps
        specific_heat = cpf
        density = rho
        inlet_temp = 400
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
    
[] #END BCs


[Postprocessors]
    [./T_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]
    [./Ts_avg]
        type = ElementAverageValue
        variable = Ts
        execute_on = 'initial timestep_end'
    [../]
[] #END Postprocessors

[Preconditioning]
    [./SMP_PJFNK]
        type = SMP
        full = true
    [../]
[] #END Preconditioning

[Executioner]
    type = Transient
    scheme = bdf2
    solve_type = pjfnk
    petsc_options = '-snes_converged_reason'
    petsc_options_iname ='-ksp_type -pc_type -sub_pc_type'
    petsc_options_value = 'bcgs bjacobi lu'

    line_search = none
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-8
    nl_rel_step_tol = 1e-12
    nl_abs_step_tol = 1e-12
    nl_max_its = 10
    l_tol = 1e-6
    l_max_its = 300

    start_time = 0.0
    end_time = 80.0
    dtmax = 0.5

    [./TimeStepper]
        type = ConstantDT
        dt = 0.2
    [../]
 
[] #END Executioner

[Outputs]
    print_linear_residuals = true
    exodus = true
    csv = true
    interval = 10
[] #END Outputs
