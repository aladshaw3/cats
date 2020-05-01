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
 
    # Other Constants
    #   dH = -3.95E5 J/mol
    #   As = 8.6346E7   m^-1
    #   Ao = 11797  m^-1
  
[] #END GlobalParams
 
[Functions]
    [./qc_ic]
        type = ParsedFunction
        value = 4.01E-4*-1.8779*exp(1.8779*y/0.1346)/(1-exp(1.8779))
    [../]
[]

[Problem]
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    coord_type = RZ
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
#    nx = 10
#    ny = 20
    nx = 10
    ny = 20
    xmin = 0.0
    xmax = 0.0725    # m radius
    ymin = 0.0
    ymax = 0.1346    # m length
[] # END Mesh

[Variables]
    # Surface Carbon (mol/m^2)
    [./qc]
        order = FIRST
        family = MONOMIAL
#        initial_condition = 4.01E-4        #Avg qc
#        initial_condition = 8.89E-4     #Max qc
#        initial_condition = 1.359E-4       #Min qc
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
 
    # Gas phase temperature
    [./T]
        order = FIRST
        family = MONOMIAL
        initial_condition = 723.15    #K
    [../]
 
    # Solid phase temperature
    [./Ts]
        order = FIRST
        family = MONOMIAL
        initial_condition = 723.15    #K
    [../]
 
    # Bulk gas concentration for O2
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]
 
    # Bulk gas concentration for CO2
    [./CO2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]

[] #END Variables

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
        initial_condition = 0.018599  #m^3/s
    [../]
 
    [./x_sec]
       order = FIRST
       family = LAGRANGE        #Must be LAGRANGE if vel_y is also LAGRANGE
       initial_condition = 0.016513   #m^2
    [../]
 
#Actual AuxVariables
    [./vel_x]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]

    [./vel_y]
        order = FIRST
        family = LAGRANGE
        # This is now being calculated from AuxAvgLinearVelocity
        #initial_condition = 2.5769 #m/s
    [../]

    [./vel_z]
        order = FIRST
        family = LAGRANGE
        initial_condition = 0
    [../]
 
    [./Tw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 573.15    #K
    [../]
 
    [./dp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 5.09E-4    #m
    [../]
 
    [./eps]
        order = FIRST
        family = LAGRANGE       #Must be LAGRANGE if vel_y is also LAGRANGE
        initial_condition = 0.4371
    [../]
 
    [./eps_s]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.5916
    [../]
 
    [./d_bed]
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.1450   #m
    [../]
 
    [./Ks]
        order = FIRST
        family = MONOMIAL
        initial_condition = 11.9       #W/m/K
    [../]
 
    [./rho_s]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1599       #kg/m^3
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
 
    [./rp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.37E-8       #m
    [../]
 
# Calculated from GasProperties
    [./rho]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.45       #kg/m^3
    [../]
 
    [./P]
        order = FIRST
        family = MONOMIAL
    [../]
 
    [./mu]
        order = FIRST
        family = MONOMIAL
    [../]
 
    [./Ke]
        order = FIRST
        family = MONOMIAL
 initial_condition = 6.7          #W/m/K
    [../]
 
    [./cpg]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1040       #J/kg/K
    [../]
 
    [./km_O2]
        order = FIRST
        family = MONOMIAL
    [../]
 
    [./km_CO2]
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
 
    [./hs]
        order = FIRST
        family = MONOMIAL
    [../]
 
[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
# Kernels for gas-phase temperature
# Important: If we do not vary velocity due to density variations, then we cannot couple with
#               a density variable that has a density gradient!!! Instead, you must couple
#               with an average column density. Alternatively, you can vary or scale the
#               the column velocities by changes in density. However, then you may also run
#               into conservation of mass issues unless you scale concentrations with density.
    [./T_dot]
        type = HeatAccumulation
        variable = T
#        specific_heat = cpg
#        porosity = eps
#        density = rho
 
        specific_heat = 612257
       porosity = 1
       density = 1
    [../]
    [./T_gadv]
        type = GHeatAdvection
        variable = T
        specific_heat = cpg
        porosity = eps
        density = rho
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./T_gdiff]
        type = GVariableDiffusion
        variable = T
        Dx = Ke
        Dy = Ke
        Dz = Ke
    [../]
#    [./Ts_trans]
#        type = FilmMassTransfer
#        variable = T
#        coupled = Ts
#        rate_variable = hs
#        av_ratio = 11797
#    [../]
    [./T_rx]  #   qc + O2p --> CO2p
        type = ArrheniusReaction
        variable = T
        this_variable = T
        temperature = T
 scale = 1.92E13  #As*DH*(1-eps)
        reactants = 'qc O2p'
        reactant_stoich = '1 1'
        products = 'CO2p'
        product_stoich = '1'
    [../]
 
# Kernels for solid-phase temperature
    [./Ts_dot]
        type = HeatAccumulation
        variable = Ts
        specific_heat = cps
        porosity = 1.0
        density = rho_s
    [../]
#    [./Ts_gdiff]
#        type = GVariableDiffusion
#        variable = Ts
#        # Ks*(1-eps)
#        Dx = 6.7
#        Dy = 6.7
#        Dz = 6.7
#    [../]
#    [./T_trans]
#        type = FilmMassTransfer
#        variable = Ts
#        coupled = T
#        rate_variable = hs
#        av_ratio = 11797
#    [../]
# Placeholder for heat of reaction kernel (do mass balances first - Coupling impacts the heat up)
#    [./Ts_rxn]
#        type = CoupledCoeffTimeDerivative
#        variable = Ts
#        coupled = qc
#        time_coeff = 3.41E13 #3.41E13     #8.6346E7*-3.95E5*-1
#    [../]
#    [./Ts_rx]  #   qc + O2p --> CO2p
#        type = ArrheniusReaction
#        variable = Ts
#        this_variable = Ts
#        temperature = Ts
#        scale = 3.41E13
#        reactants = 'qc O2p'
#        reactant_stoich = '1 1'
#        products = 'CO2p'
#        product_stoich = '1'
#    [../]
    
 
# Kernels for surface reaction
    [./qc_dot]
        type = TimeDerivative
        variable = qc
    [../]
    [./qc_rx]  #   qc + O2p --> CO2p
        type = ArrheniusReaction
        variable = qc
        this_variable = qc
        temperature = T
        scale = -1.0
        reactants = 'qc O2p'
        reactant_stoich = '1 1'
        products = 'CO2p'
        product_stoich = '1'
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
        av_ratio = 11797
    [../]
 
    [./O2p_dot]
        type = VariableCoefTimeDerivative
        variable = O2p
        coupled_coef = 0.333        #eps_s*(1-eps)
    [../]
    [./O2_trans]
        type = FilmMassTransfer
        variable = O2p
        coupled = O2
        rate_variable = kme_O2
        av_ratio = 11797
    [../]
    [./O2p_rx]  #   qc + O2p --> CO2p
        type = ArrheniusReaction
        variable = O2p
        this_variable = O2p
        temperature = T
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
        av_ratio = 11797
    [../]
 
    [./CO2p_dot]
        type = VariableCoefTimeDerivative
        variable = CO2p
        coupled_coef = 0.333        #eps_s*(1-eps)
    [../]
    [./CO2_trans]
        type = FilmMassTransfer
        variable = CO2p
        coupled = CO2
        rate_variable = kme_CO2
        av_ratio = 11797
    [../]
    [./CO2p_rx]  #   qc + O2p --> CO2p
        type = ArrheniusReaction
        variable = CO2p
        this_variable = CO2p
        temperature = T
        scale = 48604163       #(1-eps)*As*1
        reactants = 'qc O2p'
        reactant_stoich = '1 1'
        products = 'CO2p'
        product_stoich = '1'
    [../]
 
[] #END Kernels

[DGKernels]
    [./T_dgadv]
        type = DGHeatAdvection
        variable = T
        specific_heat = cpg
        porosity = eps
        density = rho
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./T_dgdiff]
        type = DGVariableDiffusion
        variable = T
        Dx = Ke
        Dy = Ke
        Dz = Ke
    [../]
 
#    [./Ts_dgdiff]
#        type = DGVariableDiffusion
#        variable = Ts
#        # Ks*(1-eps)
#        Dx = 6.7
#        Dy = 6.7
#        Dz = 6.7
#    [../]
 
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
[] #END DGKernels

[AuxKernels]
    [./vel_y_calc]
        type = AuxAvgLinearVelocity
        variable = vel_y
        porosity = eps
        flow_rate = flow_rate
        xsec_area = x_sec
    [../]
 
    [./P_ergun]
        type = AuxErgunPressure
        variable = P
        direction = 1
        porosity = eps
        temperature = T
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
# NOTE: Should change the density calculation to use ErgunPressure (inlet) with system T and concentrations
#       Alternatively, just use AuxAvgGasDensity with reference pressure and system T with concentrations
#       OR, just use this function, but provide the reference/inlet/outlet pressure variable
#    [./dens_calc]
#        type = GasDensity
#        variable = rho
#        temperature = T
#        pressure = P          #Provide the reference pressure here (maybe not when all physics are in place?)
#        hydraulic_diameter = dp
#        ux = vel_x
#        uy = vel_y
#        uz = vel_z
#    [../]
 
    [./vis_calc]
        type = GasViscosity
        variable = mu
        temperature = T
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
 
#    [./Keff_calc]
#        type = GasEffectiveThermalConductivity
#        variable = Ke
#        temperature = T
#        pressure = P
#        hydraulic_diameter = dp
#        macroscale_diameter = d_bed
#        porosity = eps
#        ux = vel_x
#        uy = vel_y
#        uz = vel_z
#    [../]
 
#    [./cp_calc]
#        type = GasSpecHeat
#        variable = cpg
#        temperature = T
#        pressure = P
#        hydraulic_diameter = dp
#        ux = vel_x
#        uy = vel_y
#        uz = vel_z
#    [../]
 
    [./km_O2_calc]
        type = GasSpeciesMassTransCoef
        variable = km_O2
        species_index = 1
        temperature = T
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
        temperature = T
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
 
    [./km_CO2_calc]
        type = GasSpeciesMassTransCoef
        variable = km_CO2
        species_index = 2
        temperature = T
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
        temperature = T
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
        temperature = T
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
        temperature = T
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
 
    [./hs_calc]
        type = GasSolidHeatTransCoef
        variable = hs
        temperature = T
        pressure = P
        hydraulic_diameter = dp
        solid_conductivity = Ks
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[] #END AuxKernels

[BCs]
    [./T_FluxIn]
        type = DGHeatFluxBC
        variable = T
        u_input = 723.15
        boundary = 'bottom'
        specific_heat = cpg
        porosity = eps
        density = rho
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./T_FluxOut]
        type = DGHeatFluxBC
        variable = T
        boundary = 'top'
        specific_heat = cpg
        porosity = eps
        density = rho
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
 
# Need to add same kernel with variable wall temperature
    [./T_WallFluxIn]
        type = DGWallHeatFluxBC
        variable = T
        u_input = 573.15
        boundary = 'right'
        hw = hw
        Kx = Ke
        Ky = Ke
        Kz = Ke
    [../]
 
# Need to add same kernel with variable wall temperature
#    [./Ts_WallFluxIn]
#        type = DGWallHeatFluxBC
#        variable = Ts
#        u_input = 573.15
#        boundary = 'right'
#        hw = hw
#        # Ks*(1-eps)
#        Kx = 6.7
#        Ky = 6.7
#        Kz = 6.7
#    [../]
 
    [./O2_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = O2
        boundary = 'bottom'
        u_input = 1e-9
        porosity = eps
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '0.13433'
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

[] #END BCs

[Materials]

[] #END Materials

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
        variable = T
        execute_on = 'initial timestep_end'
    [../]
 
    [./T_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = T
        execute_on = 'initial timestep_end'
    [../]
 
    [./T_avg]
        type = ElementAverageValue
        variable = T
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
 
    [./O2_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]
 
    [./CO2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]
 
    [./CO2_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CO2
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
    line_search = none
    nl_rel_tol = 1e-6
    nl_abs_tol = 1e-4
    nl_rel_step_tol = 1e-10
    nl_abs_step_tol = 1e-10
    nl_max_its = 10
    l_tol = 1e-6
    l_max_its = 300

    start_time = 0.0
    end_time = 35000
    dtmax = 10

    [./TimeStepper]
#        type = ConstantDT
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

