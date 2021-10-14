#fitting data from 2016-ORNL report

# General Comments: Pay very close attention to units and conversion factors. Make sure you are calling the right kernels with the right variables and coupling.
#			Avoid using 'LAGRANGE' family for DG variables. Add in axial dispersion for numerical stabilization or changed 'order' to 'CONSTANT'

# update 9/20: convert all units to cm, s, gram; integrated Aux kernels

[Problem]
    coord_type=RZ
[]


# I went ahead and updated your lengths to a cm basis. You can change this back if you want, but it seems more stable here.
#		NOTE: Your units will still work out this way because the

[GlobalParams]
    # DG Scheme args
    dg_scheme = nipg
    sigma = 10

    #### Params below are all autocalculated ###
    #Dx = 0
    #Dy = 10 #axial dispersion cm^2/s (mostly for stabilization - need to check to see if valid. Otherwise, use 'order = CONSTANT' for stabilization)
    #Dz = 0
    #diffusion_const = 0.152   #D_CH3I,air (cm^2/s) from SU calculation, D_pCH3I estimated based on CATS manual
    #transfer_const = 2.71      #k_CH3I (cm/s) from SU calculation
    #rate_variable = 2.71         #film mass transfer coefficient

    micro_length = 0.1        #Radius of pellet Based on the Ao = 3000 cm^-1
    num_nodes = 10
    coord_id = 2

    # All AuxKernels for GasProperties use same gases
#    gases = 'N2 O2 CH3I'
#    molar_weights = '28 32 141.939'
#    sutherland_temp = '300.55 292.25 293.15'
#    sutherland_const = '111 127 93'
#    sutherland_vis = '0.0001781 0.0002018 0.00011'
#    spec_heat = '1.04 0.919 2.232'
#    execute_on = 'initial timestep_end'
#    is_ideal_gas = false

    ### These are being set locally now ###
    #order = CONSTANT
    #order = FIRST
    #family = MONOMIAL     #Setting these as global and removing overwites in Variables block
[]


# Another thing to consider, since your bed length is the size of 1 particle, you really don't need to discretize the column lengthwise
#		and you can easily get away with just using 'order=CONSTANT'. Thus, your domain basically acts as a CSTR rather than a PFR
# For thicker beds, add the discretization back in and update the order to FIRST

[Mesh]
    [./my_mesh]
	      type=GeneratedMeshGenerator
        dim=2
        xmin=0
        xmax=1.725   #radius in cm
        ymin=0
        ymax=11  #length in cm
        nx=1
        ny=55
    [../]
[]


[Variables]

# NOTE: Several variables had listed 'LAGRANGE' as the family. Should use 'MONOMIAL' for DG variables

    [./CH3I] #in mol/cm^3 (C, concentration of CH3I in bulk phase)
       order = FIRST
       family = MONOMIAL
       initial_condition=1e-20
    [../]

    [./CH3Iw0] #in mol/cm^3 (Cw, concentration of CH3I within the pore)
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw1] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw2] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw3] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw4] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw5] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw6] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw7] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw8] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./CH3Iw9] #in mol/cm^3
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]


    [./AgI0] #in mol/g (q, adsorbed)
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI1] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI2] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI3] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI4] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI5] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI6] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI7] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI8] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]

    [./AgI9] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=1e-20
    [../]


	# These values should be initially set to the Ag_Max if we assume all Ag is initally in this state
    [./Ag0] #in mol/g (S, site)
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag1] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag2] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag3] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag4] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag5] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag6] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag7] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag8] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]

    [./Ag9] #in mol/g
       order = FIRST
       family = MONOMIAL

       initial_condition=0.00328
    [../]
[]


[AuxVariables]

    [./eps_b] #Bed porosity
       order=FIRST
       family=MONOMIAL
       initial_condition=0.395 #estimated value; recalculated in Aux Kernel
    [../]

    [./eps_p] #pore porosity
       order=FIRST
       family=MONOMIAL
       initial_condition=0.88
    [../]

    [./eps_total] #total porosity
       order=FIRST
       family=MONOMIAL
    [../]

    [./k_CH3I] #mass transfer coefficient for macroscale MT; calculated in Aux Kernel
       order=FIRST
       family=MONOMIAL
    [../]

    [./A_0] #Area per volume coeff for macroscale mass transfer
       order=FIRST
       family=MONOMIAL
    [../]

    [./Disp] #axial dispersion cm^2/s
       order=FIRST
       family=MONOMIAL
    [../]

    [./D_CH3I] #pore diffusivity of micropore diffusion
       order=FIRST
       family=MONOMIAL
       #initial_condition=6.7E-4
    [../]

    [./CH3IwAvg] #Average of washing concentration within the pellet
        order=FIRST
        family=MONOMIAL
       initial_condition=0
    [../]

    [./AgIAvg] #Average of adsorbed mass within the pellet
        order=FIRST
        family=MONOMIAL
       initial_condition=0
    [../]

    [./AgAvg] # Average of adsorbed mass within the pellet; in mol/g
        order=FIRST
        family=MONOMIAL
       initial_condition=0.00328
    [../]

    [./Ag_max] # in mol/g
       order=FIRST
       family=MONOMIAL
       initial_condition=0.00328
    [../]


# Changing velocity to MONOMIAL funtions. You don't need these
#   to be LAGRANGE unless you are doing Navier-Stokes in MOOSE
    [./vel_x]
       order=FIRST
       family=MONOMIAL
       initial_condition=0
    [../]

# lin_vel = Q/A/eps_b
    [./vel_y] #superficial velocity 10m/min
       order=FIRST
       family=MONOMIAL
       initial_condition=42.28 #in cm/s   #####calculated linear velocity######
    [../]

    [./vel_z]
       order=FIRST
       family=MONOMIAL
       initial_condition=0
    [../]


[]

[Kernels]
    # macroscale conservation of mass on CH3I
    [./CH3IAccum]
       type=VariableCoefTimeDerivative
       variable=CH3I
       coupled_coef=eps_b
    [../]
    [./CH3IAdv]
       type=GPoreConcAdvection
       variable=CH3I
       porosity=eps_b
       ux=vel_x
       uy=vel_y
       uz=vel_z
    [../]
    [./CH3IDiff]
        type = GVarPoreDiffusion
        variable = CH3I
        porosity = eps_b
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]
    [./CH3I_trans]
       type=FilmMassTransfer						#### NOTE: Your major mistake was here where you referenced the wrong variable ####
       variable=CH3I
       coupled=CH3Iw9
       rate_variable=k_CH3I   ###calculated in Aux Kernel
       av_ratio=A_0 #calculated in Aux_kernel, area per total volume
       #av_ratio=18.15 ############ to be confirmed , area-to-volume ratio (m-1)#############   ### NOTE: This needs units of cm^-1 if you using cm units on km ###
                     ##converted from 1815 m-1 to 18.15 cm-1##
    [../]



    ######## NOTE: The nodal_time_coef for the MicroscaleCoupledCoefTimeDerivative should be your density of the aerogel
    #				This is because you need to convert from mol/kg (in AgI units) to mol/m^3 (in CH3I units)
    #				Thus, this parameter should be material density in kg/m^3


    # inner BC
    [./CH3Iw0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw0
        nodal_time_var = eps_total ############ to be confirmed , is it pellet porosity?#############
        node_id = 0
    [../]
    [./CH3Iw0_diff_inner]
        type = MicroscaleVariableDiffusionInnerBC
        variable = CH3Iw0
        node_id = 0
        upper_neighbor = CH3Iw1
        current_diff=D_CH3I
        upper_diff=D_CH3I
    [../]
    [./AgI0_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw0
        coupled_at_node = AgI0
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
				#density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 0
    [../]

    [./CH3Iw1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw1
        nodal_time_var = eps_total
        node_id = 1
    [../]
    [./CH3Iw1_diff]
        type = MicroscaleVariableDiffusion
        variable = CH3Iw1
        node_id = 1
        current_diff=D_CH3I
        upper_diff=D_CH3I
        lower_diff=D_CH3I
        upper_neighbor = CH3Iw2
        lower_neighbor = CH3Iw0
    [../]
    [./AgI1_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw1
        coupled_at_node = AgI1
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 1
    [../]

    [./CH3Iw2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw2
        nodal_time_var = eps_total
        node_id = 2
    [../]
    [./CH3Iw2_diff]
        type = MicroscaleVariableDiffusion
        variable = CH3Iw2
        node_id = 2
        current_diff=D_CH3I
        upper_diff=D_CH3I
        lower_diff=D_CH3I
        upper_neighbor = CH3Iw3
        lower_neighbor = CH3Iw1
    [../]
    [./AgI2_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw2
        coupled_at_node = AgI2
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 2
    [../]

    [./CH3Iw3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw3
        nodal_time_var = eps_total
        node_id = 3
    [../]
    [./CH3Iw3_diff]
        type = MicroscaleVariableDiffusion
        variable = CH3Iw3
        node_id = 3
        current_diff=D_CH3I
        upper_diff=D_CH3I
        lower_diff=D_CH3I
        upper_neighbor = CH3Iw4
        lower_neighbor = CH3Iw2
    [../]
    [./AgI3_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw3
        coupled_at_node = AgI3
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 3
    [../]

    [./CH3Iw4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw4
        nodal_time_var = eps_total
        node_id = 4
    [../]
    [./CH3Iw4_diff]
        type = MicroscaleVariableDiffusion
        variable = CH3Iw4
        node_id = 4
        current_diff=D_CH3I
        upper_diff=D_CH3I
        lower_diff=D_CH3I
        upper_neighbor = CH3Iw5
        lower_neighbor = CH3Iw3
    [../]
    [./AgI4_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw4
        coupled_at_node = AgI4
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 4
    [../]


    [./CH3Iw5_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw5
        nodal_time_var = eps_total
        node_id = 5
    [../]
    [./CH3Iw5_diff]
        type = MicroscaleVariableDiffusion
        variable = CH3Iw5
        node_id = 5
        current_diff=D_CH3I
        upper_diff=D_CH3I
        lower_diff=D_CH3I
        upper_neighbor = CH3Iw6
        lower_neighbor = CH3Iw4
    [../]
    [./AgI5_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw5
        coupled_at_node = AgI5
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 5
    [../]

    [./CH3Iw6_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw6
        nodal_time_var = eps_total
        node_id = 6
    [../]
    [./CH3Iw6_diff]
        type = MicroscaleVariableDiffusion
        variable = CH3Iw6
        node_id = 6
        current_diff=D_CH3I
        upper_diff=D_CH3I
        lower_diff=D_CH3I
        upper_neighbor = CH3Iw7
        lower_neighbor = CH3Iw5
    [../]
    [./AgI6_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw6
        coupled_at_node = AgI6
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 6
    [../]

    [./CH3Iw7_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw7
        nodal_time_var = eps_total
        node_id = 7
    [../]
    [./CH3Iw7_diff]
        type = MicroscaleVariableDiffusion
        variable = CH3Iw7
        node_id = 7
        current_diff=D_CH3I
        upper_diff=D_CH3I
        lower_diff=D_CH3I
        upper_neighbor = CH3Iw8
        lower_neighbor = CH3Iw6
    [../]
    [./AgI7_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw7
        coupled_at_node = AgI7
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 7
    [../]

    [./CH3Iw8_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw8
        nodal_time_var = eps_total
        node_id = 8
    [../]
    [./CH3Iw8_diff]
        type = MicroscaleVariableDiffusion
        variable = CH3Iw8
        node_id = 8
        current_diff=D_CH3I
        upper_diff=D_CH3I
        lower_diff=D_CH3I
        upper_neighbor = CH3Iw9
        lower_neighbor = CH3Iw7
    [../]
    [./AgI8_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw8
        coupled_at_node = AgI8
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 8
    [../]


    #outer BC
    [./CH3Iw9_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CH3Iw9
        nodal_time_var = eps_total
        node_id = 9
    [../]
    [./CH3Iw9_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        macro_variable=CH3I
        variable = CH3Iw9
        node_id = 9
        current_diff=D_CH3I
        lower_diff=D_CH3I
        lower_neighbor = CH3Iw8
        rate_variable = k_CH3I
    [../]
    [./AgI9_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = CH3Iw9
        coupled_at_node = AgI9
        nodal_time_coef = 0.62  #density = 0.62g/cm^3=620kg/m^3=0.00062kg/cm^3
        node_id = 9
    [../]


############## NOTE: There may be a better way to do the coupling of AgI and Ag instead of using material balance. If you have more trouble let me know. ####################
##################      Current configuration may result in large negative values. If you see these, let me know and we will reformulate ##############


    [./AgI0_dot]
        type = TimeDerivative
        variable = AgI0
    [../]
    [./AgI0_rxn]  #   CH3Iw0 + Ag0 <-- --> AgI0 + CH3*
        type = ConstReaction
        variable = AgI0
        this_variable = AgI0
        forward_rate = 20000       ######to be determined, does not affect the current calculation results#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw0 Ag0'
        reactant_stoich = '1 1'
        products = 'AgI0'
        product_stoich = '1'
    [../]
    [./mat_bal0]
      type = MaterialBalance
      variable = Ag0
      this_variable = Ag0
      coupled_list = 'Ag0 AgI0'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI1_dot]
        type = TimeDerivative
        variable = AgI1
    [../]
    [./AgI1_rxn]  #   CH3Iw1 + Ag1 <-- --> AgI1 + CH3*
        type = ConstReaction
        variable = AgI1
        this_variable = AgI1
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw1 Ag1'
        reactant_stoich = '1 1'
        products = 'AgI1'
        product_stoich = '1'
    [../]
    [./mat_bal1]
      type = MaterialBalance
      variable = Ag1
      this_variable = Ag1
      coupled_list = 'Ag1 AgI1'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI2_dot]
        type = TimeDerivative
        variable = AgI2
    [../]
    [./AgI2_rxn]  #   CH3Iw2 + Ag2 <-- --> AgI2 + CH3*
        type = ConstReaction
        variable = AgI2
        this_variable = AgI2
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw2 Ag2'
        reactant_stoich = '1 1'
        products = 'AgI2'
        product_stoich = '1'
    [../]
    [./mat_bal2]
      type = MaterialBalance
      variable = Ag2
      this_variable = Ag2
      coupled_list = 'Ag2 AgI2'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI3_dot]
        type = TimeDerivative
        variable = AgI3
    [../]
    [./AgI3_rxn]  #   CH3Iw3 + Ag3 <-- --> AgI3 + CH3*
        type = ConstReaction
        variable = AgI3
        this_variable = AgI3
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw3 Ag3'
        reactant_stoich = '1 1'
        products = 'AgI3'
        product_stoich = '1'
    [../]
    [./mat_bal3]
      type = MaterialBalance
      variable = Ag3
      this_variable = Ag3
      coupled_list = 'Ag3 AgI3'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI4_dot]
        type = TimeDerivative
        variable = AgI4
    [../]
    [./AgI4_rxn]  #   CH3Iw4 + Ag4 <-- --> AgI4 + CH3*
        type = ConstReaction
        variable = AgI4
        this_variable = AgI4
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw4 Ag4'
        reactant_stoich = '1 1'
        products = 'AgI4'
        product_stoich = '1'
    [../]
    [./mat_bal4]
      type = MaterialBalance
      variable = Ag4
      this_variable = Ag4
      coupled_list = 'Ag4 AgI4'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI5_dot]
        type = TimeDerivative
        variable = AgI5
    [../]
    [./AgI5_rxn]  #   CH3Iw5 + Ag5 <-- --> AgI5 + CH3*
        type = ConstReaction
        variable = AgI5
        this_variable = AgI5
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw5 Ag5'
        reactant_stoich = '1 1'
        products = 'AgI5'
        product_stoich = '1'
    [../]
    [./mat_bal5]
      type = MaterialBalance
      variable = Ag5
      this_variable = Ag5
      coupled_list = 'Ag5 AgI5'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI6_dot]
        type = TimeDerivative
        variable = AgI6			########### NOTE: You were referencing the wrong variable here ############
    [../]
    [./AgI6_rxn]  #   CH3Iw6 + Ag6 <-- --> AgI6 + CH3*
        type = ConstReaction
        variable = AgI6
        this_variable = AgI6
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw6 Ag6'
        reactant_stoich = '1 1'
        products = 'AgI6'
        product_stoich = '1'
    [../]
    [./mat_bal6]
      type = MaterialBalance
      variable = Ag6
      this_variable = Ag6
      coupled_list = 'Ag6 AgI6'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI7_dot]
        type = TimeDerivative
        variable = AgI7
    [../]
    [./AgI7_rxn]  #   CH3Iw7 + Ag7 <-- --> AgI7 + CH3*
        type = ConstReaction
        variable = AgI7
        this_variable = AgI7
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw7 Ag7'
        reactant_stoich = '1 1'
        products = 'AgI7'
        product_stoich = '1'
    [../]
    [./mat_bal7]
      type = MaterialBalance
      variable = Ag7
      this_variable = Ag7
      coupled_list = 'Ag7 AgI7'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI8_dot]
        type = TimeDerivative
        variable = AgI8
    [../]
    [./AgI8_rxn]  #   CH3Iw8 + Ag8 <-- --> AgI8 + CH3*
        type = ConstReaction
        variable = AgI8
        this_variable = AgI8
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw8 Ag8'
        reactant_stoich = '1 1'
        products = 'AgI8'
        product_stoich = '1'
    [../]
    [./mat_bal8]
      type = MaterialBalance
      variable = Ag8
      this_variable = Ag8
      coupled_list = 'Ag8 AgI8'
      weights = '1 1'
      total_material = Ag_max
    [../]

    [./AgI9_dot]
        type = TimeDerivative
        variable = AgI9
    [../]
    [./AgI9_rxn]  #   CH3Iw9 + Ag9 <-- --> AgI9 + CH3*
        type = ConstReaction
        variable = AgI9
        this_variable = AgI9
        forward_rate = 20000       ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'CH3Iw9 Ag9'
        reactant_stoich = '1 1'
        products = 'AgI9'
        product_stoich = '1'
    [../]
    [./mat_bal9]
      type = MaterialBalance
      variable = Ag9
      this_variable = Ag9
      coupled_list = 'Ag9 AgI9'
      weights = '1 1'
      total_material = Ag_max
    [../]

 []

[DGKernels]
    [./CH3IDGAdv]
       type=DGPoreConcAdvection
       variable=CH3I
       porosity=eps_b
       ux=vel_x
       uy=vel_y
       uz=vel_z
    [../]
    [./CH3IDGdiff]
        type = DGVarPoreDiffusion
        variable = CH3I
        porosity = eps_b
        Dx = Disp
        Dy = Disp
        Dz = Disp
    [../]
[]

[AuxKernels]

#    [./bulk_eps_calc]
#        type = VoidsVolumeFraction
#        variable = eps_b
#        particle_diameter = 0.2    #cm
#        particle_mass = 0.015      #g ?????
#        packing_density = 0.62       #g/cm^3
#        execute_on = 'initial timestep_end'
#   [../]

    [./total_eps_calc]
        type = MicroscalePoreVolumePerTotalVolume
        variable = eps_total
        porosity = eps_b
        microscale_porosity = eps_p
        execute_on = 'initial timestep_end'
    [../]

    [./Disp_calc]
        type = SimpleGasDispersion
        variable = Disp

        pressure = 101.35
        temperature = 423.15
        micro_porosity = eps_p
        macro_porosity = eps_b

        characteristic_length = 0.2
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "s"

        # molecular diffusivity of CH3I in air
        # obtained from SU (0.196) and Jubin's (0.1764) calculation
        ref_diffusivity = 0.1764
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 423.15

        output_length_unit = "cm"
        output_time_unit = "s"

        execute_on = 'initial timestep_end'
    [../]

    [./kCH3I_calc]
        type = SimpleGasSphericalMassTransCoef
        variable = k_CH3I

        pressure = 101.35
        temperature = 423.15
        micro_porosity = eps_p
        macro_porosity = eps_b


        characteristic_length = 0.2  # characteristic_length is particle diameter for this case
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "s"

        # molecular diffusivity of CH3I in air
        # obtained from SU (0.196) and Jubin's (0.1764) calculation
        ref_diffusivity = 0.1764
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 423.15

        output_length_unit = "cm"
        output_time_unit = "s"

        execute_on = 'initial timestep_end'
    [../]

    [./A0_calc]
        type = SphericalAreaVolumeRatio
        variable = A_0
        particle_diameter = 0.2    #cm
        porosity = eps_b
        per_solids_volume = false  #calculate per total volume
        execute_on = 'initial timestep_end'
    [../]

    [./DCH3I_calc]
        type = SimpleGasEffectiveKnudsenDiffusivity ##KnudsenDiffusivity
        variable = D_CH3I

        pressure = 101.35
        temperature = 423.15
        micro_porosity = eps_p
        macro_porosity = eps_b

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "s"

        # molecular diffusivity of CH3I in air
        # obtained from SU (0.196) and Jubin's (0.1764) calculation
        ref_diffusivity = 0.1764
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 423.15

        characteristic_length = 1E-5 #100A diameter from SU's analysis
        char_length_unit = "mm"
        molar_weight = 142

        output_length_unit = "cm"
        output_time_unit = "s"
        per_solids_volume = false

        execute_on = 'initial timestep_end'
    [../]



    [./CH3Iw_avg]
        type = MicroscaleIntegralAvg
        variable = CH3IwAvg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'CH3Iw0 CH3Iw1 CH3Iw2 CH3Iw3 CH3Iw4 CH3Iw5 CH3Iw6 CH3Iw7 CH3Iw8 CH3Iw9'
        execute_on = 'initial timestep_end'
    [../]

    [./AgI_avg]
        type = MicroscaleIntegralAvg
        variable = AgIAvg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'AgI0 AgI1 AgI2 AgI3 AgI4 AgI5 AgI6 AgI7 AgI8 AgI9'
        execute_on = 'initial timestep_end'
    [../]

    [./Ag_avg]
        type = MicroscaleIntegralAvg
        variable = AgAvg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'Ag0 Ag1 Ag2 Ag3 Ag4 Ag5 Ag6 Ag7 Ag8 Ag9'
        execute_on = 'initial timestep_end'
    [../]



[]

[BCs]

    [./CH3I_Flux]
        type = DGPoreConcFluxBC
        variable = CH3I
        boundary = 'top bottom'
        u_input=1.15E-12 # in mol/cm^3 ###@150C, 1ppb=0.028*10^-12 mol/cm^3
        #u_input=1.15E-6 # in mol/m^3
        porosity=eps_b
        ux=vel_x
        uy=vel_y
        uz=vel_z
    [../]


[]


[Postprocessors]

    [./CH3I_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = CH3I
        execute_on = 'initial timestep_end'
    [../]

    [./AgI_avg]
        type = ElementAverageValue
        variable = AgIAvg
        execute_on = 'initial timestep_end'
    [../]

    # Changed the nodal interior pellet values to be reported
    #   at the inlet of the bed (instead of on an average basis).
    #   This would be interpreted as the interior concentrations
    #   for pellets located at the bed entrance.
    [./AgI0_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI0
        execute_on = 'initial timestep_end'
    [../]

    [./AgI1_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI1
        execute_on = 'initial timestep_end'
    [../]

    [./AgI2_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI2
        execute_on = 'initial timestep_end'
    [../]

    [./AgI3_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI3
        execute_on = 'initial timestep_end'
    [../]

    [./AgI4_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI4
        execute_on = 'initial timestep_end'
    [../]

    [./AgI5_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI5
        execute_on = 'initial timestep_end'
    [../]

    [./AgI6_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI6
        execute_on = 'initial timestep_end'
    [../]

    [./AgI7_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI7
        execute_on = 'initial timestep_end'
    [../]

    [./AgI8_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI8
        execute_on = 'initial timestep_end'
    [../]

    [./AgI9_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = AgI9
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw0_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw0
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw1_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw1
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw2_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw2
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw3_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw3
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw4_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw4
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw5_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw5
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw6_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw6
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw7_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw7
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw8_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw8
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw9_bed_inlet]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CH3Iw9
        execute_on = 'initial timestep_end'
    [../]

    [./Ag_avg]
        type = ElementAverageValue
        variable = AgAvg
        execute_on = 'initial timestep_end'
    [../]

    [./CH3Iw_avg]
        type = ElementAverageValue
        variable = CH3IwAvg
        execute_on = 'initial timestep_end'
    [../]

    [./eps_b]
        type = ElementAverageValue
        variable = eps_b
        execute_on = 'initial timestep_end'
    [../]
    [./eps_total]
        type = ElementAverageValue
        variable = eps_total
        execute_on = 'initial timestep_end'
    [../]
    [./A_0]
        type = ElementAverageValue
        variable = A_0
        execute_on = 'initial timestep_end'
    [../]
    [./k_CH3I]
        type = ElementAverageValue
        variable = k_CH3I
        execute_on = 'initial timestep_end'
    [../]
    [./D_CH3I]
        type = ElementAverageValue
        variable = D_CH3I
        execute_on = 'initial timestep_end'
    [../]
    [./print_Disp]
        type = ElementAverageValue
        variable = Disp
        execute_on = 'initial timestep_end'
    [../]


[]

# Updated solver options for added stability (for -sub_pc_type, you can change 'lu' to 'asm' (or visa versa) for more stabilization of linear steps)

# Adding a preconditioning block
[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
  [../]
[] #END Preconditioning

[Executioner]
    type = Transient
    scheme = bdf2
    petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres asm ilu 100 NONZERO 2 1E-14 1E-12'
# NOTE: The default tolerances are far to strict and cause the program to crawl
#    nl_rel_tol = 1e-10
#   nl_abs_tol = 1e-4
#   l_tol = 1e-8
#   l_max_its = 70
#   nl_max_its = 20
    nl_rel_tol = 1e-16
    nl_abs_tol = 1e-25         # Need a very low tolerance here given how small your residuals are on your unit basis
    nl_rel_step_tol = 1e-20
    nl_abs_step_tol = 1e-20
    nl_max_its = 70
    l_tol = 1e-7
    l_max_its = 300
    line_search = bt    # Options: default none l2 bt basic
    start_time = 0.0
    end_time = 10368000 # 120 days
    #end_time = 103680000
    dtmax = 3600

    [./TimeStepper]
        type = SolutionTimeAdaptiveDT
        dt=6
    [../]
[]


[Outputs]
    exodus = true
    csv = true
    print_linear_residuals = true
[]
