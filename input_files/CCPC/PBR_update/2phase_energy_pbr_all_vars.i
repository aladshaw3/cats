#NOTE: This result qualitatively works well, updating the parameters might fix remaining issues
#       Then, depreciate the old heat kernels. 

[GlobalParams]
    dg_scheme = nipg
    sigma = 10
 
    # Since there is only one reaction, we will put reaction kernel parameters as global
    forward_activation_energy = 5.0E4   #J/mol
    forward_pre_exponential = 25        #m^3/mol/s
    reverse_activation_energy = 0   #J/mol
    reverse_pre_exponential = 0     #m^3/mol/s

    # All AuxKernels for GasProperties use same gases
    gases = 'N2 O2 CO2'
    molar_weights = '28 32 44'
    sutherland_temp = '300.55 292.25 293.15'
    sutherland_const = '111 127 240'
    sutherland_vis = '0.0001781 0.0002018 0.000148'
    spec_heat = '1.04 0.919 0.846'
    execute_on = 'initial timestep_end'

    # newer options
#    carrier_gas = N2
#    carrier_gas_mw = 28
    is_ideal_gas = true
#NOTE: We get an error if ideal gas == false and no carrier given
 
    # Other Constants
    #   dH = -3.95E5 J/mol
    #   As = 8.6346E7   m^-1
    #   Ao = 11797  m^-1
    #   Ao*(1-eps) = 6640.5
  
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

[Functions]
     [./qc_ic]
         type = ParsedFunction
        value = 4.01E-4*-1.8779*exp(1.8779*y/0.1346)/(1-exp(1.8779))
#        value = 4.01E-4        #Avg qc
#        value = 8.89E-4     #Max qc
#        value = 1.359E-4       #Min qc
     [../]

    [./v_ic]
#m/s  avg - superficial velocity (low 2.334 - high 2.4925) ?
        type = ParsedFunction
#value = '2.334 + 0.1585*(y/0.1346)'
#value = '2.334 + 0.1585*(1/2)'
#value = '2.334'
        value = '2.5'
    [../]
[]

[Variables]
    [./Ef]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = InitialPhaseEnergy
            specific_heat = cpg
            volume_frac = eps
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
            volume_frac = s_frac
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
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]
 
    # Bulk gas concentration for CO2
    [./CO2]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]
 
     # Surface Carbon (mol/m^2)
     [./qc]
         order = FIRST
         family = MONOMIAL
         [./InitialCondition]
             type = FunctionIC
             function = qc_ic
         [../]
     [../]
 
    # O2 in pore-spaces (mol/m^3)
    [./O2p]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]
 
    # CO2 in pore-spaces (mol/m^3)
    [./CO2p]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]
[]
 
[AuxVariables]
 #Reverved for Temporary AuxVariables
    [./N2p]
        order = FIRST
        family = MONOMIAL
        initial_condition = 16.497    #mol/m^3
    [../]
 
    [./N2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 16.497    #mol/m^3
    [../]

# Reference or inlet/outlet terms (vary in time, but not in space)
   [./P_o]     # Reference pressure (and inlet/outlet pressure) for average constant density
       order = FIRST
       family = MONOMIAL
       initial_condition = 90000    #Pa
   [../]

   [./flow_rate]
       order = FIRST
       family = LAGRANGE       #Must be LAGRANGE if vel_y is also LAGRANGE
       initial_condition = 0.02025  #m^3/s  AVG FLOW RATE
   [../]

   [./x_sec]
      order = FIRST
      family = LAGRANGE        #Must be LAGRANGE if vel_y is also LAGRANGE
      initial_condition = 0.016513   #m^2
   [../]
 
    [./vel_x]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

# ---------- TO BE CALCULATED --------------
    [./vel_y]
        order = FIRST
        family = LAGRANGE
#        initial_condition = 2.806 #m/s  avg - superficial velocity (low 2.5769 - high 3.17)
        [./InitialCondition]
            type = FunctionIC
            function = v_ic
        [../]
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
        initial_condition = 4.9       #W/m/K   (  should be 4.9 = eps_s*0.07 + (1-eps_s)*11.9  )
    [../]
 
    # MUST BE LAGRANGE IF USED TO CALCULATE vel_y (which is also LAGRANGE)
    [./eps]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0.4371          #volume bulk voids / total volumes
    [../]
 
    [./s_frac]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.5629          #volume of bulk solids / total volumes
    [../]

    [./eps_s]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.5916          #volume of solid pores / solid volume
    [../]

    [./vol_ss]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.667         #volume of skel. solid  / total volume
    [../]

    [./vol_pores]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.333         #volume of pores  / total volume
    [../]

    [./rho]
        order = FIRST
        family = MONOMIAL
initial_condition = 0.45       #kg/m^3  ( double check comsol calculations )
    [../]
 
    [./rho_s]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1599       #kg/m^3
    [../]
 
    [./cpg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1100       #J/kg/K
    [../]
 
    [./cps]
        order = FIRST
        family = MONOMIAL
        initial_condition = 928       #J/kg/K    (  should be 928 = eps_s*1100 + (1-eps_s)*680  )
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
        initial_condition = 288       #W/m^2/K
    [../]
 
    [./Ao]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11797       #m^-1
    [../]

    [./dp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 5.09E-4    #m
    [../]

    [./d_bed]
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.1450   #m
    [../]

    [./rp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.37E-8       #m
    [../]

# ---- USE AUXKERNELS TO CALCULATE -------
   [./P]
       order = FIRST
       family = MONOMIAL
   [../]

   [./mu]
       order = FIRST
       family = MONOMIAL
   [../]

   [./kme_O2]
       order = FIRST
       family = MONOMIAL
   [../]

   [./kme_CO2]
       order = FIRST
       family = MONOMIAL
   [../]

   [./De_O2]
       order = FIRST
       family = MONOMIAL
   [../]

   [./De_CO2]
       order = FIRST
       family = MONOMIAL
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
        volume_frac = s_frac  #s_frac = (1-eps)  ==>  s_frac*eps_s = 0.333
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
    [./Es_rxn] #   qc + O2p --> CO2p
        type = ArrheniusReactionEnergyTransfer
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
        volume_frac = eps
        density = rho
    [../]
 
    [./Ts_calc]
        type = PhaseTemperature
        variable = Ts
        energy = Es
        specific_heat = cps
        volume_frac = s_frac
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
        Dx = De_O2
        Dy = De_O2
        Dz = De_O2
    [../]
    [./O2p_trans]
        type = FilmMassTransfer
        variable = O2
        coupled = O2p
        rate_variable = kme_O2
        av_ratio = 6640.5
    [../]
 
    # Kernels for surface reaction
    [./qc_dot]
        type = TimeDerivative
        variable = qc
    [../]
    [./qc_rx]  #   qc + O2p --> CO2p
        type = ArrheniusReaction
        variable = qc
        this_variable = qc
        temperature = Ts
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
    [./O2_trans]
        type = FilmMassTransfer
        variable = O2p
        coupled = O2
        rate_variable = kme_O2
        av_ratio = 6640.5
    [../]
    [./O2p_rx]  #   qc + O2p --> CO2p
        type = ArrheniusReaction
        variable = O2p
        this_variable = O2p
        temperature = Ts
        scale = -48604163       #(1-eps)*As*-1
        reactants = 'qc O2p'
        reactant_stoich = '1 1'
        products = 'CO2p'
        product_stoich = '1'
    [../]
 
    [./CO2_dot]
        type = VariableCoefTimeDerivative
        variable = CO2
        coupled_coef = eps
    [../]
    [./CO2_gadv]
        type = GPoreConcAdvection
        variable = CO2
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO2_gdiff]
        type = GVarPoreDiffusion
        variable = CO2
        porosity = eps
        Dx = De_CO2
        Dy = De_CO2
        Dz = De_CO2
    [../]
    [./CO2p_trans]
        type = FilmMassTransfer
        variable = CO2
        coupled = CO2p
        rate_variable = kme_CO2
        av_ratio = 6640.5
    [../]
 
    [./CO2p_dot]
        type = VariableCoefTimeDerivative
        variable = CO2p
        coupled_coef = 0.333        #s_frac*(1-eps)
    [../]
    [./CO2_trans]
        type = FilmMassTransfer
        variable = CO2p
        coupled = CO2
        rate_variable = kme_CO2
        av_ratio = 6640.5
    [../]
    [./CO2p_rx]  #   qc + O2p --> CO2p
        type = ArrheniusReaction
        variable = CO2p
        this_variable = CO2p
        temperature = Ts
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
        volume_frac = s_frac  #s_frac = (1-eps)  ==>  s_frac*eps_s = 0.333
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
        Dx = De_O2
        Dy = De_O2
        Dz = De_O2
    [../]
 
    [./CO2_dgadv]
        type = DGPoreConcAdvection
        variable = CO2
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO2_dgdiff]
        type = DGVarPoreDiffusion
        variable = CO2
        porosity = eps
        Dx = De_CO2
        Dy = De_CO2
        Dz = De_CO2
    [../]
 
[]


[AuxKernels]
#    [./vel_y_calc]
#        type = AuxAvgLinearVelocity
#        variable = vel_y
#        porosity = eps
#        flow_rate = flow_rate
#        xsec_area = x_sec
#    [../]
 
    [./P_ergun]
        type = AuxErgunPressure
        variable = P
        direction = 1
        porosity = eps
        temperature = Tf
        # NOTE: Use inlet/outlet pressure for pressure variable in aux pressure kernel
        pressure = P_o
        is_inlet_press = false
        start_point = 0
        end_point = 0.1346
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./dens_calc]
        type = GasDensity
        variable = rho
        temperature = Tf
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./Kg_calc]
        type = GasThermalConductivity
        variable = Kg
        temperature = Tf
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./vis_calc]
        type = GasViscosity
        variable = mu
        temperature = Tf
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./cp_calc]
        type = GasSpecHeat
        variable = cpg
        temperature = Tf
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./kme_O2_calc]
        type = GasSpeciesEffectiveTransferCoef
        variable = kme_O2
        species_index = 1
        micro_porosity = eps_s
        temperature = Tf
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./kme_CO2_calc]
        type = GasSpeciesEffectiveTransferCoef
        variable = kme_CO2
        species_index = 2
        micro_porosity = eps_s
        temperature = Tf
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

   [./De_O2_calc]
       type = GasSpeciesAxialDispersion
       variable = De_O2
       species_index = 1
       macroscale_diameter = d_bed
       temperature = Tf
       pressure = P
       hydraulic_diameter = dp
       ux = vel_x
       uy = vel_y
       uz = vel_z
   [../]

   [./De_CO2_calc]
       type = GasSpeciesAxialDispersion
       variable = De_CO2
       species_index = 2
       macroscale_diameter = d_bed
       temperature = Tf
       pressure = P
       hydraulic_diameter = dp
       ux = vel_x
       uy = vel_y
       uz = vel_z
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
        area_frac = s_frac   #s_frac = (1-eps)  ==>  s_frac*eps_s = 0.333
    [../]
 
    [./O2_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = O2
        boundary = 'bottom'
        u_input = 1e-9
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '0.148'
        input_times = '2000'
        time_spans = '1500'
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
 
    [./CO2_FluxIn]
        type = DGPoreConcFluxBC
        variable = CO2
        boundary = 'bottom'
        u_input = 1e-9
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO2_FluxOut]
        type = DGPoreConcFluxBC
        variable = CO2
        boundary = 'top'
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[]

[Postprocessors]
   [./P_out]
       type = SideAverageValue
       boundary = 'top'
       variable = P
       execute_on = 'initial timestep_end'
   [../]

   [./P_in]
       type = SideAverageValue
       boundary = 'bottom'
       variable = P
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

    [./T_wall_f]
        type = SideAverageValue
        boundary = 'right'
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]

    [./T_wall_s]
        type = SideAverageValue
        boundary = 'right'
        variable = Ts
        execute_on = 'initial timestep_end'
    [../]

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

    [./Ef_wall]
        type = SideAverageValue
        boundary = 'right'
        variable = Ef
        execute_on = 'initial timestep_end'
    [../]

    [./T_avg]
        type = ElementAverageValue
        variable = Tf
        execute_on = 'initial timestep_end'
    [../]

    [./Ef_avg]
        type = ElementAverageValue
        variable = Ef
        execute_on = 'initial timestep_end'
    [../]
 
    [./Ts_avg]
        type = ElementAverageValue
        variable = Ts
        execute_on = 'initial timestep_end'
    [../]

    [./Es_avg]
        type = ElementAverageValue
        variable = Es
        execute_on = 'initial timestep_end'
    [../]

    [./Es_wall]
        type = SideAverageValue
        boundary = 'right'
        variable = Es
        execute_on = 'initial timestep_end'
    [../]

   [./rho_out]
       type = SideAverageValue
       boundary = 'top'
       variable = rho
       execute_on = 'initial timestep_end'
   [../]

   [./rho_in]
       type = SideAverageValue
       boundary = 'bottom'
       variable = rho
       execute_on = 'initial timestep_end'
   [../]

    [./v_out]
        type = SideAverageValue
        boundary = 'top'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]

    [./v_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = vel_y
        execute_on = 'initial timestep_end'
    [../]

    [./cpg_out]
        type = SideAverageValue
        boundary = 'top'
        variable = cpg
        execute_on = 'initial timestep_end'
    [../]

    [./cpg_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = cpg
        execute_on = 'initial timestep_end'
    [../]
 
    [./qc_avg]
        type = ElementAverageValue
        variable = qc
        execute_on = 'initial timestep_end'
    [../]

    [./O2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]
 
    [./O2_inside]
        type = ElementAverageValue
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./O2p_avg]
        type = ElementAverageValue
        variable = O2p
        execute_on = 'initial timestep_end'
    [../]
 
    [./CO2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]
 
    [./CO2_inside]
        type = ElementAverageValue
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]

    [./CO2p_avg]
        type = ElementAverageValue
        variable = CO2p
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
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 30000
  dtmax = 30

  [./TimeStepper]
     type = SolutionTimeAdaptiveDT
     dt = 2
  [../]
[] #END Executioner

[Outputs]
    print_linear_residuals = true
    exodus = true
    csv = true
    interval = 10   #Number of time steps to wait before writing output
[] #END Outputs

