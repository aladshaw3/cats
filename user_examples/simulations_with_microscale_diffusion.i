# Here are a list of all the common parameters to all kernels
[GlobalParams]
    # These are stability options for the DG kernels
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
    is_ideal_gas = false

    # Other Constants (used in kernels, but not declared globally - for book keeping)
    #   dH = -3.95E5 J/mol
    #   As = 8.6346E7   m^-1
    #   Ao = 11797  m^-1
    #   Ao*(1-eps) = 6640.5

    # Microscale common params
    micro_length = 2.545E-4        #Radius of pellet (in m)
    num_nodes = 10
    coord_id = 2

    #Average intraparticle diffusion values
    # Dknudsen = 5.5E-6  m^2/s
    # Dpore = 1.3E-4  m^2/s
    #
    # Dk*eps_s = 3.25E-6
    # Dp*eps_s = 7.7E-5
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
    # Initial distribution function for surface carbon in column
     [./qc_ic]
         type = ParsedFunction
         value = 4.01E-4*-1.8779*exp(1.8779*y/0.1346)/(1-exp(1.8779))
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
    # We use a CONSTANT order here for maximum stability on a coarse mesh
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]

    # Bulk gas concentration for CO2
    [./CO2]
    # We use a CONSTANT order here for maximum stability on a coarse mesh
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]

     # Surface Carbon (mol/m^2)
     [./qc0]
         order = FIRST
         family = MONOMIAL
         [./InitialCondition]
             type = FunctionIC
             function = qc_ic
         [../]
     [../]

    # O2 in pore-spaces (mol/m^3)
    [./O2p0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]

    # CO2 in pore-spaces (mol/m^3)
    [./CO2p0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1e-9    #mol/m^3
    [../]

    # Surface Carbon (mol/m^2)
    [./qc1]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p1]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p1]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

    # Surface Carbon (mol/m^2)
    [./qc2]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p2]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p2]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

    # Surface Carbon (mol/m^2)
    [./qc3]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p3]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p3]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

    # Surface Carbon (mol/m^2)
    [./qc4]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p4]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p4]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

    # Surface Carbon (mol/m^2)
    [./qc5]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p5]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p5]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

    # Surface Carbon (mol/m^2)
    [./qc6]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p6]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p6]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

    # Surface Carbon (mol/m^2)
    [./qc7]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p7]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p7]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

    # Surface Carbon (mol/m^2)
    [./qc8]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p8]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p8]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

    # Surface Carbon (mol/m^2)
    [./qc9]
        order = FIRST
        family = MONOMIAL
        [./InitialCondition]
            type = FunctionIC
            function = qc_ic
        [../]
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p9]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p9]
       order = FIRST
       family = MONOMIAL
       initial_condition = 1e-9    #mol/m^3
   [../]
[]

[AuxVariables]
# Below are the variables for integral averages inside particles
    # Surface Carbon (mol/m^2)
    [./qc]
        order = FIRST
        family = MONOMIAL
    [../]

   # O2 in pore-spaces (mol/m^3)
   [./O2p]
       order = FIRST
       family = MONOMIAL
   [../]

   # CO2 in pore-spaces (mol/m^3)
   [./CO2p]
       order = FIRST
       family = MONOMIAL
   [../]

# Test intraparticle diffusion constants
    [./Dk]
        order = FIRST
        family = MONOMIAL
        initial_condition = 3.25E-6    #m^2/s  Knudsen Diffusion correction
    [../]

    [./Dp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 7.7E-5    #m^2/s  Pore diffusion (with out Knudsen correction)
    [../]

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

    [./km_O2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./km_CO2]
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

    [./Dmicro_O2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./Dmicro_CO2]
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
    #Invoke for each node in microscale (and scale the specific_area by number of subdivisions)
    [./Es_rxn0] #   qc0 + O2p0 --> CO2p0
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc0 O2p0'
        reactant_stoich = '1 1'
        products = 'CO2p0'
        product_stoich = '1'
    [../]
    [./Es_rxn1] #   qc1 + O2p1 --> CO2p1
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc1 O2p1'
        reactant_stoich = '1 1'
        products = 'CO2p1'
        product_stoich = '1'
    [../]
    [./Es_rxn2] #   qc2 + O2p2 --> CO2p2
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc2 O2p2'
        reactant_stoich = '1 1'
        products = 'CO2p2'
        product_stoich = '1'
    [../]
    [./Es_rxn3] #   qc3 + O2p3 --> CO2p3
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc3 O2p3'
        reactant_stoich = '1 1'
        products = 'CO2p3'
        product_stoich = '1'
    [../]
    [./Es_rxn4] #   qc4 + O2p4 --> CO2p4
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc4 O2p4'
        reactant_stoich = '1 1'
        products = 'CO2p4'
        product_stoich = '1'
    [../]
    [./Es_rxn5] #   qc5 + O2p5 --> CO2p5
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc5 O2p5'
        reactant_stoich = '1 1'
        products = 'CO2p5'
        product_stoich = '1'
    [../]
    [./Es_rxn6] #   qc6 + O2p6 --> CO2p6
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc6 O2p6'
        reactant_stoich = '1 1'
        products = 'CO2p6'
        product_stoich = '1'
    [../]
    [./Es_rxn7] #   qc7 + O2p7 --> CO2p7
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc7 O2p7'
        reactant_stoich = '1 1'
        products = 'CO2p7'
        product_stoich = '1'
    [../]
    [./Es_rxn8] #   qc8 + O2p8 --> CO2p8
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc8 O2p8'
        reactant_stoich = '1 1'
        products = 'CO2p8'
        product_stoich = '1'
    [../]
    [./Es_rxn9] #   qc9 + O2p9 --> CO2p9
        type = ArrheniusReactionEnergyTransfer
        variable = Es
        this_variable = Es
        temperature = Ts
        enthalpy = -3.95E5
        volume_frac = s_frac
        specific_area = 8.6346E6        # = actual_area / num_nodes
        reactants = 'qc9 O2p9'
        reactant_stoich = '1 1'
        products = 'CO2p9'
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

# MACROSCALE for O2
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
        coupled = O2p9          # Couple with the outermost microscale variable here
        rate_variable = km_O2
        av_ratio = 6640.5       #   Ao*(1-eps) = 6640.5
    [../]



    # Kernels for surface reaction @ node 0
    [./qc0_dot]
        type = TimeDerivative
        variable = qc0
    [../]
    [./qc0_rx]  #   qc0 + O2p0 --> CO2p0
        type = ArrheniusReaction
        variable = qc0
        this_variable = qc0
        temperature = Ts
        scale = -1.0
        reactants = 'qc0 O2p0'
        reactant_stoich = '1 1'
        products = 'CO2p0'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 1
    [./qc1_dot]
        type = TimeDerivative
        variable = qc1
    [../]
    [./qc1_rx]  #   qc1 + O2p1 --> CO2p1
        type = ArrheniusReaction
        variable = qc1
        this_variable = qc1
        temperature = Ts
        scale = -1.0
        reactants = 'qc1 O2p1'
        reactant_stoich = '1 1'
        products = 'CO2p1'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 2
    [./qc2_dot]
        type = TimeDerivative
        variable = qc2
    [../]
    [./qc2_rx]  #   qc2 + O2p2 --> CO2p2
        type = ArrheniusReaction
        variable = qc2
        this_variable = qc2
        temperature = Ts
        scale = -1.0
        reactants = 'qc2 O2p2'
        reactant_stoich = '1 1'
        products = 'CO2p2'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 0
    [./qc3_dot]
        type = TimeDerivative
        variable = qc3
    [../]
    [./qc3_rx]  #   qc3 + O2p3 --> CO2p3
        type = ArrheniusReaction
        variable = qc3
        this_variable = qc3
        temperature = Ts
        scale = -1.0
        reactants = 'qc3 O2p3'
        reactant_stoich = '1 1'
        products = 'CO2p3'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 4
    [./qc4_dot]
        type = TimeDerivative
        variable = qc4
    [../]
    [./qc4_rx]  #   qc4 + O2p4 --> CO2p4
        type = ArrheniusReaction
        variable = qc4
        this_variable = qc4
        temperature = Ts
        scale = -1.0
        reactants = 'qc4 O2p4'
        reactant_stoich = '1 1'
        products = 'CO2p4'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 5
    [./qc5_dot]
        type = TimeDerivative
        variable = qc5
    [../]
    [./qc5_rx]  #   qc5 + O2p5 --> CO2p5
        type = ArrheniusReaction
        variable = qc5
        this_variable = qc5
        temperature = Ts
        scale = -1.0
        reactants = 'qc5 O2p5'
        reactant_stoich = '1 1'
        products = 'CO2p5'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 6
    [./qc6_dot]
        type = TimeDerivative
        variable = qc6
    [../]
    [./qc6_rx]  #   qc6 + O2p6 --> CO2p6
        type = ArrheniusReaction
        variable = qc6
        this_variable = qc6
        temperature = Ts
        scale = -1.0
        reactants = 'qc6 O2p6'
        reactant_stoich = '1 1'
        products = 'CO2p6'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 7
    [./qc7_dot]
        type = TimeDerivative
        variable = qc7
    [../]
    [./qc7_rx]  #   qc7 + O2p7 --> CO2p7
        type = ArrheniusReaction
        variable = qc7
        this_variable = qc7
        temperature = Ts
        scale = -1.0
        reactants = 'qc7 O2p7'
        reactant_stoich = '1 1'
        products = 'CO2p7'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 8
    [./qc8_dot]
        type = TimeDerivative
        variable = qc8
    [../]
    [./qc8_rx]  #   qc8 + O2p8 --> CO2p8
        type = ArrheniusReaction
        variable = qc8
        this_variable = qc8
        temperature = Ts
        scale = -1.0
        reactants = 'qc8 O2p8'
        reactant_stoich = '1 1'
        products = 'CO2p8'
        product_stoich = '1'
    [../]
    # Kernels for surface reaction @ node 9
    [./qc9_dot]
        type = TimeDerivative
        variable = qc9
    [../]
    [./qc9_rx]  #   qc9 + O2p9 --> CO2p9
        type = ArrheniusReaction
        variable = qc9
        this_variable = qc9
        temperature = Ts
        scale = -1.0
        reactants = 'qc9 O2p9'
        reactant_stoich = '1 1'
        products = 'CO2p9'
        product_stoich = '1'
    [../]


# MICROSCALE for O2
    # Interior node needs InnerBC
    [./O2p0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p0
        nodal_time_var = eps_s
        node_id = 0
    [../]
    [./O2p0_diff_inner]
        type = MicroscaleVariableDiffusionInnerBC
        variable = O2p0
        node_id = 0
        upper_neighbor = O2p1
        current_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p0_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p0
        coupled_at_node = qc0
        nodal_time_var = -8.6346E7      #As
        node_id = 0
    [../]

    [./O2p1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p1
        nodal_time_var = eps_s
        node_id = 1
    [../]
    [./O2p1_diff]
        type = MicroscaleVariableDiffusion
        variable = O2p1
        node_id = 1
        upper_neighbor = O2p2
        lower_neighbor = O2p0
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p1_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p1
        coupled_at_node = qc1
        nodal_time_var = -8.6346E7      #As
        node_id = 1
    [../]

    [./O2p2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p2
        nodal_time_var = eps_s
        node_id = 2
    [../]
    [./O2p2_diff]
        type = MicroscaleVariableDiffusion
        variable = O2p2
        node_id = 2
        upper_neighbor = O2p3
        lower_neighbor = O2p1
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p2_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p2
        coupled_at_node = qc2
        nodal_time_var = -8.6346E7      #As
        node_id = 2
    [../]

    [./O2p3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p3
        nodal_time_var = eps_s
        node_id = 3
    [../]
    [./O2p3_diff]
        type = MicroscaleVariableDiffusion
        variable = O2p3
        node_id = 3
        upper_neighbor = O2p4
        lower_neighbor = O2p2
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p3_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p3
        coupled_at_node = qc3
        nodal_time_var = -8.6346E7      #As
        node_id = 3
    [../]

    [./O2p4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p4
        nodal_time_var = eps_s
        node_id = 4
    [../]
    [./O2p4_diff]
        type = MicroscaleVariableDiffusion
        variable = O2p4
        node_id = 4
        upper_neighbor = O2p5
        lower_neighbor = O2p3
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p4_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p4
        coupled_at_node = qc4
        nodal_time_var = -8.6346E7      #As
        node_id = 4
    [../]

    [./O2p5_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p5
        nodal_time_var = eps_s
        node_id = 5
    [../]
    [./O2p5_diff]
        type = MicroscaleVariableDiffusion
        variable = O2p5
        node_id = 5
        upper_neighbor = O2p6
        lower_neighbor = O2p4
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p5_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p5
        coupled_at_node = qc5
        nodal_time_var = -8.6346E7      #As
        node_id = 5
    [../]

    [./O2p6_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p6
        nodal_time_var = eps_s
        node_id = 6
    [../]
    [./O2p6_diff]
        type = MicroscaleVariableDiffusion
        variable = O2p6
        node_id = 6
        upper_neighbor = O2p7
        lower_neighbor = O2p5
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p6_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p6
        coupled_at_node = qc6
        nodal_time_var = -8.6346E7      #As
        node_id = 6
    [../]

    [./O2p7_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p7
        nodal_time_var = eps_s
        node_id = 7
    [../]
    [./O2p7_diff]
        type = MicroscaleVariableDiffusion
        variable = O2p7
        node_id = 7
        upper_neighbor = O2p8
        lower_neighbor = O2p6
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p7_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p7
        coupled_at_node = qc7
        nodal_time_var = -8.6346E7      #As
        node_id = 7
    [../]

    [./O2p8_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p8
        nodal_time_var = eps_s
        node_id = 8
    [../]
    [./O2p8_diff]
        type = MicroscaleVariableDiffusion
        variable = O2p8
        node_id = 8
        upper_neighbor = O2p9
        lower_neighbor = O2p7
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./O2p8_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p8
        coupled_at_node = qc8
        nodal_time_var = -8.6346E7      #As
        node_id = 8
    [../]
    # Exterior node needs OuterBC
    [./O2p9_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2p9
        nodal_time_var = eps_s
        node_id = 9
    [../]
    [./O2p9_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = O2p9
        node_id = 9
        macro_variable = O2     #Couple with the macroscale variable here
        lower_neighbor = O2p8
        rate_variable = km_O2
        current_diff = Dk
        lower_diff = Dk
    [../]
    [./O2p9_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = O2p9
        coupled_at_node = qc9
        nodal_time_var = -8.6346E7      #As
        node_id = 9
    [../]

# MACROSCALE for CO2
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
        coupled = CO2p9         # Couple with the outermost microscale variable here
        rate_variable = km_CO2
        av_ratio = 6640.5       #   Ao*(1-eps) = 6640.5
    [../]


# MICROSCALE for CO2
    # Inner most node needs InnerBC here
    [./CO2p0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p0
        nodal_time_var = eps_s
        node_id = 0
    [../]
    [./CO2p0_diff_inner]
        type = MicroscaleVariableDiffusionInnerBC
        variable = CO2p0
        node_id = 0
        upper_neighbor = CO2p1
        current_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p0_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p0
        coupled_at_node = qc0
        nodal_time_var = 8.6346E7      #As
        node_id = 0
    [../]

    [./CO2p1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p1
        nodal_time_var = eps_s
        node_id = 1
    [../]
    [./CO2p1_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2p1
        node_id = 1
        upper_neighbor = CO2p2
        lower_neighbor = CO2p0
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p1_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p1
        coupled_at_node = qc1
        nodal_time_var = 8.6346E7      #As
        node_id = 1
    [../]

    [./CO2p2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p2
        nodal_time_var = eps_s
        node_id = 2
    [../]
    [./CO2p2_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2p2
        node_id = 2
        upper_neighbor = CO2p3
        lower_neighbor = CO2p1
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p2_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p2
        coupled_at_node = qc2
        nodal_time_var = 8.6346E7      #As
        node_id = 2
    [../]

    [./CO2p3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p3
        nodal_time_var = eps_s
        node_id = 3
    [../]
    [./CO2p3_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2p3
        node_id = 3
        upper_neighbor = CO2p4
        lower_neighbor = CO2p2
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p3_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p3
        coupled_at_node = qc3
        nodal_time_var = 8.6346E7      #As
        node_id = 3
    [../]

    [./CO2p4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p4
        nodal_time_var = eps_s
        node_id = 4
    [../]
    [./CO2p4_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2p4
        node_id = 4
        upper_neighbor = CO2p5
        lower_neighbor = CO2p3
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p4_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p4
        coupled_at_node = qc4
        nodal_time_var = 8.6346E7      #As
        node_id = 4
    [../]

    [./CO2p5_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p5
        nodal_time_var = eps_s
        node_id = 5
    [../]
    [./CO2p5_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2p5
        node_id = 5
        upper_neighbor = CO2p6
        lower_neighbor = CO2p4
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p5_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p5
        coupled_at_node = qc5
        nodal_time_var = 8.6346E7      #As
        node_id = 5
    [../]

    [./CO2p6_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p6
        nodal_time_var = eps_s
        node_id = 6
    [../]
    [./CO2p6_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2p6
        node_id = 6
        upper_neighbor = CO2p7
        lower_neighbor = CO2p5
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p6_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p6
        coupled_at_node = qc6
        nodal_time_var = 8.6346E7      #As
        node_id = 6
    [../]

    [./CO2p7_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p7
        nodal_time_var = eps_s
        node_id = 7
    [../]
    [./CO2p7_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2p7
        node_id = 7
        upper_neighbor = CO2p8
        lower_neighbor = CO2p6
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p7_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p7
        coupled_at_node = qc7
        nodal_time_var = 8.6346E7      #As
        node_id = 7
    [../]

    [./CO2p8_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p8
        nodal_time_var = eps_s
        node_id = 8
    [../]
    [./CO2p8_diff]
        type = MicroscaleVariableDiffusion
        variable = CO2p8
        node_id = 8
        upper_neighbor = CO2p9
        lower_neighbor = CO2p7
        current_diff = Dk
        lower_diff = Dk
        upper_diff = Dk
    [../]
    [./CO2p8_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p8
        coupled_at_node = qc8
        nodal_time_var = 8.6346E7      #As
        node_id = 8
    [../]
    # Outer most node needs OuterBC here
    [./CO2p9_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2p9
        nodal_time_var = eps_s
        node_id = 9
    [../]
    [./CO2p9_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = CO2p9
        node_id = 9
        macro_variable = CO2        # Couple with the macroscale variable here
        lower_neighbor = CO2p8
        rate_variable = km_O2
        current_diff = Dk
        lower_diff = Dk
    [../]
    [./CO2p9_trans]
        type = MicroscaleCoupledVariableCoefTimeDerivative
        variable = CO2p9
        coupled_at_node = qc9
        nodal_time_var = 8.6346E7      #As
        node_id = 9
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
   [./CO2p_avg]
       type = MicroscaleIntegralAvg
       variable = CO2p
       space_factor = 1.0
       first_node = 0
       # This list of variables need to be in node order starting from the first node
       micro_vars = 'CO2p0 CO2p1 CO2p2 CO2p3 CO2p4 CO2p5 CO2p6 CO2p7 CO2p8 CO2p9'
       execute_on = 'initial timestep_end'
   [../]

   [./O2p_avg]
       type = MicroscaleIntegralAvg
       variable = O2p
       space_factor = 1.0
       first_node = 0
       # This list of variables need to be in node order starting from the first node
       micro_vars = 'O2p0 O2p1 O2p2 O2p3 O2p4 O2p5 O2p6 O2p7 O2p8 O2p9'
       execute_on = 'initial timestep_end'
   [../]

   [./qc_avg]
       type = MicroscaleIntegralAvg
       variable = qc
       space_factor = 1.0
       first_node = 0
       # This list of variables need to be in node order starting from the first node
       micro_vars = 'qc0 qc1 qc2 qc3 qc4 qc5 qc6 qc7 qc8 qc9'
       execute_on = 'initial timestep_end'
   [../]

    # This auxkernel calculates an average linear velocity based on the flow rate and area
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

    [./km_O2_calc]
        type = GasSpeciesMassTransCoef
        variable = km_O2
        species_index = 1
        temperature = Tf
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

    [./Dmicro_O2_calc]
        type = GasSpeciesKnudsenDiffusionCorrection
        variable = Dmicro_O2
        species_index = 1
        micro_porosity = eps_s
        micro_pore_radius = rp
        temperature = Tf
        pressure = P
        hydraulic_diameter = dp
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    [./Dmicro_CO2_calc]
        type = GasSpeciesKnudsenDiffusionCorrection
        variable = Dmicro_CO2
        species_index = 2
        micro_porosity = eps_s
        micro_pore_radius = rp
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
        area_frac = s_frac
    [../]

# Oxyegen does not begin flowing immediately, instead we introduce is starting around 1250 seconds
# and slowly ramp it up to a maximum inlet concentration of 0.148 mol/m^3 by 2750 seconds
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

    [./Tf_avg]
        type = ElementAverageValue
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
    [../]
[] #END Preconditioning

[Executioner]
    type = Transient
    scheme = implicit-euler
    solve_type = pjfnk
    petsc_options = '-snes_converged_reason'
    petsc_options_iname ='-ksp_type -ksp_gmres_restart -pc_type -sub_pc_type'
    petsc_options_value = 'gmres 300 ilu lu'

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
