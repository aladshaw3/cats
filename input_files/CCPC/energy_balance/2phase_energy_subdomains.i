[GlobalParams]
    dg_scheme = nipg
    sigma = 10

[] #END GlobalParams

[Problem]
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    coord_type = RZ
[] #END Problem

[Mesh]

    [gen] #block = 0
         type = GeneratedMeshGenerator
         dim = 2
         nx = 7
         ny = 10
         xmin = 0.0
         xmax = 0.1015    # m radius
         ymin = 0.0
         ymax = 0.1346    # m length
     []
     #Create a bounding box from the entire domain to span the new subdomain (block = 1)
       [./subdomain1]
         input = gen
         type = SubdomainBoundingBoxGenerator
         bottom_left = '0.0726 0 0'
         top_right = '0.1015 0.1346 0'
         block_id = 1
       [../]
     #Designate a new boundary as the side sets that are shared between block 0 and block 1
     #   The new boundary is now labeled and can be used in boundary conditions or InterfaceKernels
       [./interface]
         type = SideSetsBetweenSubdomainsGenerator
         input = subdomain1
         primary_block = '0'
         paired_block = '1'
         new_boundary = 'master0_interface'
       [../]
     #Break up the original boundaries (left right top bottom) to create separate boundaries for each subdomain
     #new boundary names are (old_name)_to_(block_id)
     # For example, two new left side boundary names:   left_to_0 and left_to_1
     #       left_to_0 is the new left side bounary that is a part of block 0
       [./break_boundary]
         input = interface
         type = BreakBoundaryOnSubdomainGenerator
       [../]
[]

[Variables]
    [./Ef]
        order = FIRST
        family = MONOMIAL
        block = 0
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
        block = 1
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
        family = LAGRANGE
        initial_condition = 298  #K
        block = 0
    [../]

    [./Ts]
        order = FIRST
        family = LAGRANGE
        initial_condition = 298  #K
        block = 1
    [../]

    # Bulk gas concentration for O2
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
        block = 0
    [../]
[]

[AuxVariables]
    [./vel_x]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
        block = 0
    [../]

    [./vel_y]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0.01 #m/s  - superficial velocity
        block = 0
    [../]

    [./vel_z]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
        block = 0
    [../]

    [./Kg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.1          #W/m/K
        block = 0
    [../]

    [./Ks]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.9       #W/m/K
        block = 1
    [../]

    [./eps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.4371          #W/m/K
        block = 0
    [../]

    [./s_frac]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.5629          #W/m/K
        block = '0 1'
    [../]

    [./rho]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1       #kg/m^3
        block = 0
    [../]

    [./rho_s]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1599       #kg/m^3
        block = 1
    [../]

    [./cpg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1000       #J/kg/K
        block = 0
    [../]

    [./cps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 680       #J/kg/K
        block = 1
    [../]

    [./hw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 50       #W/m^2/K
        block = '0 1'
    [../]

    [./Tw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 253  #K
        block = '0 1'
    [../]

    [./hs]
        order = FIRST
        family = MONOMIAL
        initial_condition = 50       #W/m^2/K
        block = '0 1'
    [../]

    [./Ao]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11797       #m^-1
        block = '0 1'
    [../]

    [./D]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.1
        block = '0 1'
    [../]

[]

[Kernels]
     [./Ef_dot]
         type = VariableCoefTimeDerivative
         variable = Ef
         coupled_coef = 1
         block = 0
     [../]
     [./Ef_gadv]
         type = GPoreConcAdvection
         variable = Ef
         porosity = 1
         ux = vel_x
         uy = vel_y
         uz = vel_z
         block = 0
     [../]
     [./Ef_gdiff]
         type = GPhaseThermalConductivity
         variable = Ef
         temperature = Tf
         volume_frac = 1
         Dx = Kg
         Dy = Kg
         Dz = Kg
         block = 0
     [../]

    [./Es_dot]
        type = VariableCoefTimeDerivative
        variable = Es
        coupled_coef = 1
        block = 1
    [../]
    [./Es_gdiff]
        type = GPhaseThermalConductivity
        variable = Es
        temperature = Ts
        volume_frac = 1
        Dx = Ks
        Dy = Ks
        Dz = Ks
        block = 1
    [../]

    [./Tf_calc]
        type = PhaseTemperature
        variable = Tf
        energy = Ef
        specific_heat = cpg
        density = rho
        block = 0
    [../]

    [./Ts_calc]
        type = PhaseTemperature
        variable = Ts
        energy = Es
        specific_heat = cps
        density = rho_s
        block = 1
    [../]

    [./O2_dot]
        type = VariableCoefTimeDerivative
        variable = O2
        coupled_coef = 1
        block = 0
    [../]
    [./O2_gadv]
        type = GPoreConcAdvection
        variable = O2
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 0
    [../]
    [./O2_gdiff]
        type = GVarPoreDiffusion
        variable = O2
        porosity = 1
        Dx = D
        Dy = D
        Dz = D
        block = 0
    [../]
[]

[DGKernels]
    [./Ef_dgadv]
        type = DGPoreConcAdvection
        variable = Ef
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 0
    [../]
    [./Ef_dgdiff]
        type = DGPhaseThermalConductivity
        variable = Ef
        temperature = Tf
        volume_frac = 1
        Dx = Kg
        Dy = Kg
        Dz = Kg
        block = 0
    [../]

    [./Es_dgdiff]
        type = DGPhaseThermalConductivity
        variable = Es
        temperature = Ts
        volume_frac = 1
        Dx = Ks
        Dy = Ks
        Dz = Ks
        block = 1
    [../]

    [./O2_dgadv]
        type = DGPoreConcAdvection
        variable = O2
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 0
    [../]
    [./O2_dgdiff]
        type = DGVarPoreDiffusion
        variable = O2
        porosity = 1
        Dx = D
        Dy = D
        Dz = D
        block = 0
    [../]
[]

[InterfaceKernels]
    [./interface]
        type = InterfaceEnergyTransfer
        variable = Ef        #variable must be the variable in the master block
        neighbor_var = Es    #neighbor_var must the the variable in the paired block
        boundary = master0_interface
        master_temp = Tf
        neighbor_temp = Ts
        transfer_coef = hs
        area_frac = 1
    [../]
[] #END InterfaceKernels

[BCs]
    [./Ef_Flux_OpenBounds]
        type = DGFlowEnergyFluxBC
        variable = Ef
        boundary = 'bottom_to_0 top_to_0'
        porosity = 1
        specific_heat = cpg
        density = rho
        inlet_temp = 348
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./Es_WallFluxIn]
        type = DGWallEnergyFluxBC
        variable = Es
        boundary = 'right'
        transfer_coef = hw
        wall_temp = Tw
        temperature = Ts
        area_frac = 1
    [../]

    [./O2_FluxIn]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'bottom_to_0'
        u_input = 1e-6
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_FluxOut]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'top_to_0'
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[]

[Postprocessors]
    [./Ef_out]
        type = SideAverageValue
        boundary = 'top_to_0'
        variable = Ef
        execute_on = 'initial timestep_end'
    [../]

    [./Ef_in]
        type = SideAverageValue
        boundary = 'bottom_to_0'
        variable = Ef
        execute_on = 'initial timestep_end'
    [../]

    [./Es_avg]
        type = ElementAverageValue
        variable = Es
        execute_on = 'initial timestep_end'
        block = 1
    [../]

    [./T_out]
        type = SideAverageValue
        boundary = 'top_to_0'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]

    [./T_in]
        type = SideAverageValue
        boundary = 'bottom_to_0'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]

    [./Ts_avg]
        type = ElementAverageValue
        variable = Ts
        execute_on = 'initial timestep_end'
        block = 1
    [../]

    [./O2_out]
        type = SideAverageValue
        boundary = 'top_to_0'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./O2_in]
        type = SideAverageValue
        boundary = 'bottom_to_0'
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
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 500
  dtmax = 100

  [./TimeStepper]
     type = ConstantDT
     dt = 100
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
