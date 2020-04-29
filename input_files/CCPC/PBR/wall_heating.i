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

[Problem]
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
    coord_type = RZ
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 10
    ny = 2
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
        initial_condition = 4.01E-4
    [../]
 
    # CO2 in pore-spaces (mol/m^3)
    [./CO2p]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0    #mol/m^3
    [../]
 
    # Gas phase temperature
    [./T]
        order = FIRST
        family = MONOMIAL
        initial_condition = 723.15    #K
    [../]
 
    # Bulk gas concentration for O2
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0    #mol/m^3
    [../]

[] #END Variables

[AuxVariables]
#Reverved for Temporary AuxVariables
    [./O2p]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.13433    #mol/m^3
    [../]
 
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
 
    [./CO2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0    #mol/m^3
    [../]
 
    [./Ts]
        order = FIRST
        family = MONOMIAL
        initial_condition = 723.15    #K
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
        initial_condition = 0  #m^3/s
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
        #initial_condition = 2.5769 #m/s        # This is now being calculated from AuxAvgLinearVelocity
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
 initial_condition = .5
    [../]
 
    [./cpg]
        order = FIRST
        family = MONOMIAL
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
 initial_condition = 0.001
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
        specific_heat = cpg
        porosity = eps
        density = rho
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
 
# Place-holder kernels for CO2p generation
    [./CO2p_dot]
        type = TimeDerivative
        variable = CO2p
    [../]
    [./CO2p_rx]  #   qc + O2p --> CO2p
        type = ArrheniusReaction
        variable = CO2p
        this_variable = CO2p
        temperature = Ts
        scale = 1.0
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
    [./dens_calc]
        type = GasDensity
        variable = rho
        temperature = T
        pressure = P_o          #Provide the reference pressure here
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
 
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
 
    [./cp_calc]
        type = GasSpecHeat
        variable = cpg
        temperature = T
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
 
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
 
#    [./De_O2_calc]
#        type = GasSpeciesAxialDispersion
#        variable = De_O2
#        species_index = 1
#        macroscale_diameter = d_bed
#        temperature = T
#        pressure = P
#        hydraulic_diameter = dp
#        ux = vel_x
#        uy = vel_y
#        uz = vel_z
#    [../]
 
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
 
    [./T_WallFluxIn]
        type = DGFluxLimitedBC
        variable = T
        u_input = 573.15
        boundary = 'right'
        vx = 0
        vy = 0
        vz = 0
 Dxx = .5
 Dyy = .5
    [../]
 
#    [./O2_FluxIn]
#        type = DGPoreConcFluxBC
#        variable = O2
#        boundary = 'bottom'
#        u_input = 0.13433
#        porosity = eps
#        ux = vel_x
#        uy = vel_y
#        uz = vel_z
#    [../]
#    [./O2_FluxOut]
#        type = DGPoreConcFluxBC
#        variable = O2
#        boundary = 'top'
#        porosity = eps
#        ux = vel_x
#        uy = vel_y
#        uz = vel_z
#    [../]
 
     [./O2_FluxIn]
         type = DGFluxLimitedBC
         variable = O2
         boundary = 'right left'
         u_input = 0.13433
        vx = 0
         vy = 0
         vz = 0
        Dxx = 0.001
        Dyy = 0.001
     [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]
 
    [./T_avg]
        type = ElementAverageValue
        variable = T
        execute_on = 'initial timestep_end'
    [../]
 
    [./T_wall]
        type = SideAverageValue
        boundary = 'right'
        variable = T
        execute_on = 'initial timestep_end'
    [../]
 
    [./O2_avg]
        type = ElementAverageValue
        variable = O2
        execute_on = 'initial timestep_end'
    [../]
 
    [./O2_in]
        type = SideAverageValue
        boundary = 'right'
        variable = O2
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
    end_time = 6
    dtmax = 0.06

    [./TimeStepper]
        type = ConstantDT
        dt = 0.06
    [../]
[] #END Executioner

[Outputs]
    print_linear_residuals = true
    exodus = true
    csv = true
[] #END Outputs

