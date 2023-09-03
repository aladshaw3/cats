[GlobalParams]
    dg_scheme = nipg
    sigma = 10
 
    # Since there is only one reaction, we will put reaction kernel parameters as global
    forward_activation_energy = 5.0E4   #J/mol
    forward_pre_exponential = 25        #m^3/mol/s
    # Reverse components automatically calculated for equilibrium reactions
    #reverse_activation_energy = 0   #J/mol
    #reverse_pre_exponential = 0     #m^3/mol/s
  
[] #END GlobalParams
 
[Mesh]
    type = GeneratedMesh
	#NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    coord_type = RZ
    dim = 2
    nx = 5
    ny = 10
    xmin = 0.0
    xmax = 0.0725    # m radius
    ymin = 0.0
    ymax = 0.1346    # m length
[]

[Functions]
     [./qc_ic]
         type = ParsedFunction
         expression = 4.01E-4*-1.8779*exp(1.8779*y/0.1346)/(1-exp(1.8779))
     [../]
[]

[Variables]
    [./Ef]
        order = FIRST
        family = MONOMIAL
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
        initial_condition = 723.15  #K
    [../]
 
    [./Ts]
        order = FIRST
        family = MONOMIAL
        initial_condition = 723.15  #K
    [../]
 
    # Bulk gas concentration for O2
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]
 
     # Surface Carbon (mol/m^2)
     [./qc]
         order = FIRST
         family = MONOMIAL
#        initial_condition = 4.01E-4        #Avg qc
         [./InitialCondition]
             type = FunctionIC
             function = qc_ic
         [../]
     [../]
 
    # O2 in pore-spaces (mol/m^3)
    [./O2p]
        order = FIRST
        family = MONOMIAL
        initial_condition = 10    #mol/m^3
    [../]
 
    # CO2 in pore-spaces (mol/m^3)
    [./CO2p]
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
        initial_condition = 2.5769 #m/s  - superficial velocity
    [../]

    [./vel_z]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Kg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.07          #W/m/K
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
        initial_condition = 0.45       #kg/m^3
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
        initial_condition = 573.15  #K
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
    
    [./D]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.01
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
    [./Es_rxn] #   qc + O2p <-- --> CO2p
        type = ArrheniusEquilibriumReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E7
        reactants = 'qc O2p'
        reactant_stoich = '1 1'
        products = 'CO2p'
        product_stoich = '1'
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
        Dx = D
        Dy = D
        Dz = D
    [../]
 
    # Kernels for surface reaction
    [./qc_dot]
        type = TimeDerivative
        variable = qc
    [../]
    [./qc_rx]  #   qc + O2p <-- --> CO2p
        type = ArrheniusEquilibriumReaction
        variable = qc
        this_variable = qc
        temperature = Ts
        enthalpy = -3.95E5
        scale = -1.0
        reactants = 'qc O2p'
        reactant_stoich = '1 1'
        products = 'CO2p'
        product_stoich = '1'
    [../]
 
    [./O2p_dot]
        type = VariableCoefTimeDerivative
        variable = O2p
        coupled_coef = 0.333        #s_frac*(1-eps)
    [../]
    [./O2p_rx]  #   qc + O2p <-- --> CO2p
        type = ArrheniusEquilibriumReaction
        variable = O2p
        this_variable = O2p
        temperature = Ts
        enthalpy = -3.95E5
        scale = -48604163       #(1-eps)*As*-1
        reactants = 'qc O2p'
        reactant_stoich = '1 1'
        products = 'CO2p'
        product_stoich = '1'
    [../]
 
    [./CO2p_dot]
        type = VariableCoefTimeDerivative
        variable = CO2p
        coupled_coef = 0.333        #s_frac*(1-eps)
    [../]
    [./CO2p_rx]  #   qc + O2p <-- --> CO2p
        type = ArrheniusEquilibriumReaction
        variable = CO2p
        this_variable = CO2p
        temperature = Ts
        enthalpy = -3.95E5
        scale = 48604163       #(1-eps)*As*1
        reactants = 'qc O2p'
        reactant_stoich = '1 1'
        products = 'CO2p'
        product_stoich = '1'
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
        Dx = D
        Dy = D
        Dz = D
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
        inlet_temp = 723.15
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
 
    [./Ts_avg]
        type = ElementAverageValue
        variable = Ts
        execute_on = 'initial timestep_end'
    [../]
 
    [./qc_avg]
        type = ElementAverageValue
        variable = qc
        execute_on = 'initial timestep_end'
    [../]
 
    [./O2p_avg]
        type = ElementAverageValue
        variable = O2p
        execute_on = 'initial timestep_end'
    [../]
 
    [./CO2p_avg]
        type = ElementAverageValue
        variable = CO2p
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
  end_time = 0.05
  dtmax = 30

  [./TimeStepper]
     type = ConstantDT
     dt = 0.005
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs

