# fitting data from Zhuoyi Fixed bed 1
# Fixed bed experiment using IRA-900
# Initial Se concentration:
	# C_T=16.5 mmol/L=33.0E-3 meq/cm^3
# Theoretical exchange capacity for IRA-900 (wet mass): q_T = 1.7 meq/g

[Problem]
    #coord_type = RZ  #deprecipated
[]


[GlobalParams]
    dg_scheme = nipg
    sigma = 10

    micro_length = 0.06        #Radius of IRA-900 beads 0.06cm. Based on the A0= 0.9615 cm-1
    num_nodes = 10
    coord_id = 2

    order = CONSTANT
    family = MONOMIAL     #Setting these as global and removing overwrites in Variables block
[]


# Another thing to consider, since your bed length is the size of 1 particle, you really don't need to discretize the column lengthwise
#		and you can easily get away with just using 'order=CONSTANT'. Thus, your domain basically acts as a CSTR rather than a PFR
# For thicker beds, add the discretization back in and update the order to FIRST

[Mesh]
		coord_type = RZ
    [./my_mesh]
				type = GeneratedMeshGenerator
        dim = 2
        xmin = 0
        xmax = 1.15   #radius in cm
        ymin = 0
        ymax = 4.10  #length in cm
        nx = 3
        ny = 20
    [../]
[]


[Variables]

# NOTE: Several variables had listed 'LAGRANGE' as the family. Should use 'MONOMIAL' for DG variables

# (Cb_A, concentration of SeO42- in bulk phase)
    [./Cb_SeO4] #in meq/mL

       initial_condition = 1e-20  #C_T
    [../]


# (Cp_A, concentration of SeO4 within the pore)
    [./Cp_SeO40] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO41] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO42] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO43] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO44] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO45] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO46] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO47] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO48] #in meq/mL

       initial_condition = 1e-20
    [../]

    [./Cp_SeO49] #in meq/mL

       initial_condition = 1e-20
    [../]


# (q_A, concentration of SeO42- in resin phase)
    [./q_SeO40] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO41] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO42] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO43] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO44] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO45] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO46] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO47] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO48] #in meq/g

       initial_condition = 1e-20
    [../]

    [./q_SeO49] #in meq/g

       initial_condition = 1e-20
    [../]

# (q_B, concentration of Cl- in resin phase)
    [./q_Cl0] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl1] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl2] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl3] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl4] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl5] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl6] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl7] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl8] #in meq/g

       initial_condition = 1.7
    [../]

    [./q_Cl9] #in meq/g

       initial_condition = 1.7
    [../]

  []


[AuxVariables]

    [./eps_b] #bulk porosity
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.376 #Estimated based on empirical equations
    [../]

    [./eps_p] #pore porosity (0.3 given in Sengupta's book)
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.623 #Estimated based on known densities, water content
    [../]

    [./eps_total] #total porosity
       order = FIRST
       family = MONOMIAL
    [../]

    [./km_SeO4] #mass transfer coefficient for macroscale MT
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.0448
    [../]

    [./A_0] #Area per volume coeff for macroscale mass transfer
# A_0 = 3M/(r_p*rho_p*V)
# M=2g, r_p=0.06cm, rho_p=1.04g/mL?, V=100mL
# A_0 = 0.9615 cm-1
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.9615
    [../]

    [./vel_x]
       order = FIRST
       family = LAGRANGE
       initial_condition = 0
    [../]

# lin_vel = Q/A/eps_b
    [./vel_y] #superficial velocity
       order = FIRST
       family = LAGRANGE
       initial_condition = 3.20 #cm/min =5.332 in cm/s   #####calculated linear velocity######
    [../]

    [./vel_z]
       order = FIRST
       family = LAGRANGE
       initial_condition = 0
    [../]


    [./Dp_SeO4] #pore diffusivity of micropore diffusion
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.00159
    [../]

		[./Db_SeO4] #bulk diffusivity of micropore diffusion
       order = FIRST
       family = MONOMIAL
       initial_condition = 0.099
    [../]

    [./Cp_SeO4Avg] #Average of washing concentration within the pellet
       initial_condition = 1e-20
    [../]

    [./q_ClAvg] #Average of q_Cl within the resin; in meq/g
       initial_condition = 1.7
    [../]

    [./q_SeO4Avg] # Average of q_SeO4 within the resin; in meq/g
       initial_condition = 1e-20
    [../]

    [./q_total] # in meq/g
       order = FIRST
       family = MONOMIAL
       initial_condition = 1.7
    [../]

    [./C_total] # in meq/ml
       order = FIRST
       family = MONOMIAL
       initial_condition = 33.0E-3
    [../]

[]

[Kernels]
    # macroscale conservation of mass on SeO4
    [./SeO4Accum]
       type = VariableCoefTimeDerivative
       variable = Cb_SeO4
       coupled_coef = eps_b
    [../]

    [./SeO4Adv]
       type = GPoreConcAdvection
       variable = Cb_SeO4
       porosity = eps_b
       ux = vel_x
       uy = vel_y
       uz = vel_z
    [../]
    [./SeO4Diff]
        type = GVarPoreDiffusion
        variable = Cb_SeO4
        porosity = eps_b
        Dx = Db_SeO4
        Dy = Db_SeO4 #axial dispersion cm^2/min (mostly for stabilization - need to check to see if valid. Otherwise, use 'order = CONSTANT' for stabilization)
        Dz = Db_SeO4
    [../]
    [./SeO4_trans]
       type = FilmMassTransfer
       variable = Cb_SeO4
       coupled = Cp_SeO49
       rate_variable = km_SeO4
       av_ratio = A_0
    [../]


    ######## NOTE: The nodal_time_coef for the MicroscaleCoupledCoefTimeDerivative should be your density of the aerogel
    #				This is because you need to convert from meq/g (in q_SeO4 units) to meq/mL (in C_SeO4 units)
    #				Thus, this parameter should be material density in g/mL

    # inner BC
    [./Cp_SeO40_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO40
        nodal_time_var = eps_total
        node_id = 0
    [../]
    [./Cp_SeO40_diff_inner]
        type = MicroscaleVariableDiffusionInnerBC
        variable = Cp_SeO40
        node_id = 0
        upper_neighbor = Cp_SeO41
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
    [../]
    [./q_SeO40_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO40
        coupled_at_node = q_SeO40
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 0
    [../]


    [./Cp_SeO41_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO41
        nodal_time_var = eps_total
        node_id = 1
    [../]
    [./Cp_SeO41_diff]
        type = MicroscaleVariableDiffusion
        variable = Cp_SeO41
        node_id = 1
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        upper_neighbor = Cp_SeO42
        lower_neighbor = Cp_SeO40
    [../]
    [./q_SeO41_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO41
        coupled_at_node = q_SeO41
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 1
    [../]


    [./Cp_SeO42_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO42
        nodal_time_var = eps_total
        node_id = 2
    [../]
    [./Cp_SeO42_diff]
        type = MicroscaleVariableDiffusion
        variable = Cp_SeO42
        node_id = 2
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        upper_neighbor = Cp_SeO43
        lower_neighbor = Cp_SeO41
    [../]
    [./q_SeO42_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO42
        coupled_at_node = q_SeO42
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 2
    [../]


    [./Cp_SeO43_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO43
        nodal_time_var = eps_total
        node_id = 3
    [../]
    [./Cp_SeO43_diff]
        type = MicroscaleVariableDiffusion
        variable = Cp_SeO43
        node_id = 3
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        upper_neighbor = Cp_SeO44
        lower_neighbor = Cp_SeO42
    [../]
    [./q_SeO43_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO43
        coupled_at_node = q_SeO43
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 3
    [../]


    [./Cp_SeO44_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO44
        nodal_time_var = eps_total
        node_id = 4
    [../]
    [./Cp_SeO44_diff]
        type = MicroscaleVariableDiffusion
        variable = Cp_SeO44
        node_id = 4
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        upper_neighbor = Cp_SeO45
        lower_neighbor = Cp_SeO43
    [../]
    [./q_SeO44_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO44
        coupled_at_node = q_SeO44
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 4
    [../]


    [./Cp_SeO45_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO45
        nodal_time_var = eps_total
        node_id = 5
    [../]
    [./Cp_SeO45_diff]
        type = MicroscaleVariableDiffusion
        variable = Cp_SeO45
        node_id = 5
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        upper_neighbor = Cp_SeO46
        lower_neighbor = Cp_SeO44
    [../]
    [./q_SeO45_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO45
        coupled_at_node = q_SeO45
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 5
    [../]


    [./Cp_SeO46_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO46
        nodal_time_var = eps_total
        node_id = 6
    [../]
    [./Cp_SeO46_diff]
        type = MicroscaleVariableDiffusion
        variable = Cp_SeO46
        node_id = 6
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        upper_neighbor = Cp_SeO47
        lower_neighbor = Cp_SeO45
    [../]
    [./q_SeO46_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO46
        coupled_at_node = q_SeO46
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 6
    [../]

    [./Cp_SeO47_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO47
        nodal_time_var = eps_total
        node_id = 7
    [../]
    [./Cp_SeO47_diff]
        type = MicroscaleVariableDiffusion
        variable = Cp_SeO47
        node_id = 7
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        upper_neighbor = Cp_SeO48
        lower_neighbor = Cp_SeO46
    [../]
    [./q_SeO47_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO47
        coupled_at_node = q_SeO47
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 7
    [../]


    [./Cp_SeO48_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO48
        nodal_time_var = eps_total
        node_id = 8
    [../]
    [./Cp_SeO48_diff]
        type = MicroscaleVariableDiffusion
        variable = Cp_SeO48
        node_id = 8
        current_diff = Dp_SeO4
        upper_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        upper_neighbor = Cp_SeO49
        lower_neighbor = Cp_SeO47
    [../]
    [./q_SeO48_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO48
        coupled_at_node = q_SeO48
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 8
    [../]


    #outer BC
    [./Cp_SeO49_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = Cp_SeO49
        nodal_time_var = eps_total
        node_id = 9
    [../]
    [./Cp_SeO49_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        macro_variable = Cb_SeO4
        variable = Cp_SeO49
        node_id = 9
        current_diff = Dp_SeO4
        lower_diff = Dp_SeO4
        lower_neighbor = Cp_SeO48
        rate_variable = km_SeO4
    [../]
    [./q_SeO49_trans]
        type = MicroscaleCoupledCoefTimeDerivative
        variable = Cp_SeO49
        coupled_at_node = q_SeO49
        nodal_time_coef = 1.04  #density = 1.04g/cm^3
        node_id = 9
    [../]


############## NOTE: There may be a better way to do the coupling of SeO4 and Cl instead of using material balance. If you have more trouble let me know. ####################
################## Current configuration may result in large negative values. If you see these, let me know and we will reformulate ##############


    [./q_SeO40_dot]
        type = TimeDerivative
        variable = q_SeO40
    [../]
    [./q_SeO40_rxn]
#   SeO40 + 2R-Cl0 <-- --> R-SeO40 + 2Cl0
#   Cp_SeO40  q_Cl0        q_SeO40 + Cp_Cl0
#   meq/mL    meq/g
        type = ConstReaction
        variable = q_SeO40
        this_variable = q_SeO40
        forward_rate = 1E4      ######to be determined####### (meq/g*meq/mL)^-1
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO40 q_Cl0'
        reactant_stoich = '1 2'
        products = 'q_SeO40'
        product_stoich = '1'
    [../]

    [./q_SeO41_dot]
        type = TimeDerivative
        variable = q_SeO41
    [../]
    [./q_SeO41_rxn]
#   SeO41 + 2R-Cl1 <-- --> R-SeO41 + 2Cl1
#   Cp_SeO41  q_Cl1        q_SeO41 + Cp_Cl1
        type = ConstReaction
        variable = q_SeO41
        this_variable = q_SeO41
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO41 q_Cl1'
        reactant_stoich = '1 2'
        products = 'q_SeO41'
        product_stoich = '1'
    [../]


    [./q_SeO42_dot]
        type = TimeDerivative
        variable = q_SeO42
    [../]
    [./q_SeO42_rxn]
#   SeO42 + 2R-Cl2 <-- --> R-SeO42 + 2Cl2
#   Cp_SeO42  q_Cl2        q_SeO42 + Cp_Cl2
        type = ConstReaction
        variable = q_SeO42
        this_variable = q_SeO42
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO42 q_Cl2'
        reactant_stoich = '1 2'
        products = 'q_SeO42'
        product_stoich = '1'
    [../]


    [./q_SeO43_dot]
        type = TimeDerivative
        variable = q_SeO43
    [../]
    [./q_SeO43_rxn]
#   SeO43 + 2R-Cl3 <-- --> R-SeO43 + 2Cl3
#   Cp_SeO43  q_Cl3       q_SeO43 + Cp_Cl3
        type = ConstReaction
        variable = q_SeO43
        this_variable = q_SeO43
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO43 q_Cl3'
        reactant_stoich = '1 2'
        products = 'q_SeO43'
        product_stoich = '1'
    [../]


    [./q_SeO44_dot]
        type = TimeDerivative
        variable = q_SeO44
    [../]
    [./q_SeO44_rxn]
#   SeO44 + 2R-Cl4 <-- --> R-SeO44 + 2Cl4
#   Cp_SeO44  q_Cl4        q_SeO44 + Cp_Cl4
        type = ConstReaction
        variable = q_SeO44
        this_variable = q_SeO44
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO44 q_Cl4'
        reactant_stoich = '1 2'
        products = 'q_SeO44'
        product_stoich = '1'
    [../]


    [./q_SeO45_dot]
        type = TimeDerivative
        variable = q_SeO45
    [../]
    [./q_SeO45_rxn]
#   SeO45 + 2R-Cl5 <-- --> R-SeO45 + 2Cl5
#   Cp_SeO45  q_Cl5        q_SeO45 + Cp_Cl5
        type = ConstReaction
        variable = q_SeO45
        this_variable = q_SeO45
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO45 q_Cl5'
        reactant_stoich = '1 2'
        products = 'q_SeO45'
        product_stoich = '1'
    [../]


    [./q_SeO46_dot]
        type = TimeDerivative
        variable = q_SeO46
    [../]
    [./q_SeO46_rxn]
#   SeO46 + 2R-SeO46 <-- --> R-SeO46 + 2Cl6
#   Cp_SeO46  q_Cl6        q_SeO46 + Cp_Cl6
        type = ConstReaction
        variable = q_SeO46
        this_variable = q_SeO46
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO46 q_Cl6'
        reactant_stoich = '1 2'
        products = 'q_SeO46'
        product_stoich = '1'
    [../]


    [./q_SeO47_dot]
        type = TimeDerivative
        variable = q_SeO47
    [../]
    [./q_SeO47_rxn]
#   SeO47 + 2R-Cl7 <-- --> R-SeO47 + 2Cl7
#   Cp_SeO47  q_Cl7        q_SeO47 + Cp_Cl7
        type = ConstReaction
        variable = q_SeO47
        this_variable = q_SeO47
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO47 q_Cl7'
        reactant_stoich = '1 2'
        products = 'q_SeO47'
        product_stoich = '1'
    [../]


    [./q_SeO48_dot]
        type = TimeDerivative
        variable = q_SeO48
    [../]
    [./q_SeO48_rxn]
#   SeO48 + 2R-Cl8 <-- --> R-SeO48 + 2Cl8
#   Cp_SeO48  q_Cl8        q_SeO48 + Cp_Cl8
        type = ConstReaction
        variable = q_SeO48
        this_variable = q_SeO48
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO48 q_Cl8'
        reactant_stoich = '1 2'
        products = 'q_SeO48'
        product_stoich = '1'
    [../]


    [./q_SeO49_dot]
        type = TimeDerivative
        variable = q_SeO49
    [../]
    [./q_SeO49_rxn]
#   SeO49 + 2R-Cl9 <-- --> R-SeO49 + 2Cl9
#   Cp_SeO49  q_Cl9        q_SeO49 + Cp_Cl9
        type = ConstReaction
        variable = q_SeO49
        this_variable = q_SeO49
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = 1.0
        reactants = 'Cp_SeO49 q_Cl9'
        reactant_stoich = '1 2'
        products = 'q_SeO49'
        product_stoich = '1'
    [../]

############### coupling qCl########

    [./q_Cl0_dot]
        type = TimeDerivative
        variable = q_Cl0
    [../]
    [./q_Cl0_rxn]
#   SeO40 + 2R-Cl0 <-- --> R-SeO40 + 2Cl0
#   Cp_SeO40  q_Cl0        q_SeO40 + Cp_Cl0
#   meq/mL    meq/g
        type = ConstReaction
        variable = q_Cl0
        this_variable = q_Cl0
        forward_rate = 1E4      ######to be determined####### (meq/g*meq/mL)^-1
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO40 q_Cl0'
        reactant_stoich = '1 2'
        products = 'q_SeO40'
        product_stoich = '1'
    [../]

    [./q_Cl1_dot]
        type = TimeDerivative
        variable = q_Cl1
    [../]
    [./q_Cl1_rxn]
#   SeO41 + 2R-Cl1 <-- --> R-SeO41 + 2Cl1
#   Cp_SeO41  q_Cl1        q_SeO41 + Cp_Cl1
        type = ConstReaction
        variable = q_Cl1
        this_variable = q_Cl1
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO41 q_Cl1'
        reactant_stoich = '1 2'
        products = 'q_SeO41'
        product_stoich = '1'
    [../]


    [./q_Cl2_dot]
        type = TimeDerivative
        variable = q_Cl2
    [../]
    [./q_Cl2_rxn]
#   SeO42 + 2R-Cl2 <-- --> R-SeO42 + 2Cl2
#   Cp_SeO42  q_Cl2        q_SeO42 + Cp_Cl2
        type = ConstReaction
        variable = q_Cl2
        this_variable = q_Cl2
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO42 q_Cl2'
        reactant_stoich = '1 2'
        products = 'q_SeO42'
        product_stoich = '1'
    [../]


    [./q_Cl3_dot]
        type = TimeDerivative
        variable = q_Cl3
    [../]
    [./q_Cl3_rxn]
#   SeO43 + 2R-Cl3 <-- --> R-SeO43 + 2Cl3
#   Cp_SeO43  q_Cl3       q_SeO43 + Cp_Cl3
        type = ConstReaction
        variable = q_Cl3
        this_variable = q_Cl3
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO43 q_Cl3'
        reactant_stoich = '1 2'
        products = 'q_SeO43'
        product_stoich = '1'
    [../]


    [./q_Cl4_dot]
        type = TimeDerivative
        variable = q_Cl4
    [../]
    [./q_Cl4_rxn]
#   SeO44 + 2R-Cl4 <-- --> R-SeO44 + 2Cl4
#   Cp_SeO44  q_Cl4        q_SeO44 + Cp_Cl4
        type = ConstReaction
        variable = q_Cl4
        this_variable = q_Cl4
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO44 q_Cl4'
        reactant_stoich = '1 2'
        products = 'q_SeO44'
        product_stoich = '1'
    [../]


    [./q_Cl5_dot]
        type = TimeDerivative
        variable = q_Cl5
    [../]
    [./q_Cl5_rxn]
#   SeO45 + 2R-Cl5 <-- --> R-SeO45 + 2Cl5
#   Cp_SeO45  q_Cl5        q_SeO45 + Cp_Cl5
        type = ConstReaction
        variable = q_Cl5
        this_variable = q_Cl5
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO45 q_Cl5'
        reactant_stoich = '1 2'
        products = 'q_SeO45'
        product_stoich = '1'
    [../]


    [./q_Cl6_dot]
        type = TimeDerivative
        variable = q_Cl6
    [../]
    [./q_Cl6_rxn]
#   SeO46 + 2R-SeO46 <-- --> R-SeO46 + 2Cl6
#   Cp_SeO46  q_Cl6        q_SeO46 + Cp_Cl6
        type = ConstReaction
        variable = q_Cl6
        this_variable = q_Cl6
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO46 q_Cl6'
        reactant_stoich = '1 2'
        products = 'q_SeO46'
        product_stoich = '1'
    [../]


    [./q_Cl7_dot]
        type = TimeDerivative
        variable = q_Cl7
    [../]
    [./q_Cl7_rxn]
#   SeO47 + 2R-Cl7 <-- --> R-SeO47 + 2Cl7
#   Cp_SeO47  q_Cl7        q_SeO47 + Cp_Cl7
        type = ConstReaction
        variable = q_Cl7
        this_variable = q_Cl7
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO47 q_Cl7'
        reactant_stoich = '1 2'
        products = 'q_SeO47'
        product_stoich = '1'
    [../]


    [./q_Cl8_dot]
        type = TimeDerivative
        variable = q_Cl8
    [../]
    [./q_Cl8_rxn]
#   SeO48 + 2R-Cl8 <-- --> R-SeO48 + 2Cl8
#   Cp_SeO48  q_Cl8        q_SeO48 + Cp_Cl8
        type = ConstReaction
        variable = q_Cl8
        this_variable = q_Cl8
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO48 q_Cl8'
        reactant_stoich = '1 2'
        products = 'q_SeO48'
        product_stoich = '1'
    [../]


    [./q_Cl9_dot]
        type = TimeDerivative
        variable = q_Cl9
    [../]
    [./q_Cl9_rxn]
#   SeO49 + 2R-Cl9 <-- --> R-SeO49 + 2Cl9
#   Cp_SeO49  q_Cl9        q_SeO49 + Cp_Cl9
        type = ConstReaction
        variable = q_Cl9
        this_variable = q_Cl9
        forward_rate = 1E4      ######to be determined#######
        reverse_rate = 0
        scale = -2.0
        reactants = 'Cp_SeO49 q_Cl9'
        reactant_stoich = '1 2'
        products = 'q_SeO49'
        product_stoich = '1'
    [../]


 []

## Forgot to add DG kernels
[DGKernels]
		[./SeO4Adv_dg]
			 type = DGPoreConcAdvection
			 variable = Cb_SeO4
			 porosity = eps_b
			 ux = vel_x
			 uy = vel_y
			 uz = vel_z
		[../]
		[./SeO4Diff_dg]
				type = DGVarPoreDiffusion
				variable = Cb_SeO4
				porosity = eps_b
				Dx = Db_SeO4
				Dy = Db_SeO4 #axial dispersion cm^2/min (mostly for stabilization - need to check to see if valid. Otherwise, use 'order = CONSTANT' for stabilization)
				Dz = Db_SeO4
		[../]
[]

[AuxKernels]

    [./total_eps_calc]
        type = MicroscalePoreVolumePerTotalVolume
        variable = eps_total
        porosity = eps_b
        microscale_porosity = eps_p
        execute_on = 'initial timestep_end'
    [../]


    [./Cp_SeO4_avg]
        type = MicroscaleIntegralAvg
        variable = Cp_SeO4Avg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'Cp_SeO40 Cp_SeO41 Cp_SeO42 Cp_SeO43 Cp_SeO44 Cp_SeO45 Cp_SeO46 Cp_SeO47 Cp_SeO48 Cp_SeO49'
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl_avg]
        type = MicroscaleIntegralAvg
        variable = q_ClAvg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'q_Cl0 q_Cl1 q_Cl2 q_Cl3 q_Cl4 q_Cl5 q_Cl6 q_Cl7 q_Cl8 q_Cl9'
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO4_avg]
        type = MicroscaleIntegralAvg
        variable = q_SeO4Avg
        space_factor = 1.0
        first_node = 0
        micro_vars = 'q_SeO40 q_SeO41 q_SeO42 q_SeO43 q_SeO44 q_SeO45 q_SeO46 q_SeO47 q_SeO48 q_SeO49'
        execute_on = 'initial timestep_end'
    [../]

[]


[BCs]

    [./SeO4_Flux_in]
        type = DGPoreConcFluxBC
        variable = Cb_SeO4
        boundary = 'bottom'
        u_input = 33.0E-3 # in meq/cm^3
        porosity = eps_b
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
		[./SeO4_Flux_out]
        type = DGPoreConcFluxBC
        variable = Cb_SeO4
        boundary = 'top'
        porosity = eps_b
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]


[]

[Postprocessors]

    [./Cp_SeO40_avg]
        type = ElementAverageValue
        variable = Cp_SeO40
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO41_avg]
        type = ElementAverageValue
        variable = Cp_SeO41
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO42_avg]
        type = ElementAverageValue
        variable = Cp_SeO42
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO43_avg]
        type = ElementAverageValue
        variable = Cp_SeO43
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO44_avg]
        type = ElementAverageValue
        variable = Cp_SeO44
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO45_avg]
        type = ElementAverageValue
        variable = Cp_SeO45
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO46_avg]
        type = ElementAverageValue
        variable = Cp_SeO46
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO47_avg]
        type = ElementAverageValue
        variable = Cp_SeO47
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO48_avg]
        type = ElementAverageValue
        variable = Cp_SeO48
        execute_on = 'initial timestep_end'
    [../]

    [./Cp_SeO49_avg]
        type = ElementAverageValue
        variable = Cp_SeO49
        execute_on = 'initial timestep_end'
    [../]


    [./q_SeO40_avg]
        type = ElementAverageValue
        variable = q_SeO40
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO41_avg]
        type = ElementAverageValue
        variable = q_SeO41
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO42_avg]
        type = ElementAverageValue
        variable = q_SeO42
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO43_avg]
        type = ElementAverageValue
        variable = q_SeO43
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO44_avg]
        type = ElementAverageValue
        variable = q_SeO44
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO45_avg]
        type = ElementAverageValue
        variable = q_SeO45
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO46_avg]
        type = ElementAverageValue
        variable = q_SeO46
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO47_avg]
        type = ElementAverageValue
        variable = q_SeO47
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO48_avg]
        type = ElementAverageValue
        variable = q_SeO48
        execute_on = 'initial timestep_end'
    [../]

    [./q_SeO49_avg]
        type = ElementAverageValue
        variable = q_SeO49
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl0_avg]
        type = ElementAverageValue
        variable = q_Cl0
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl1_avg]
        type = ElementAverageValue
        variable = q_Cl1
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl2_avg]
        type = ElementAverageValue
        variable = q_Cl2
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl3_avg]
        type = ElementAverageValue
        variable = q_Cl3
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl4_avg]
        type = ElementAverageValue
        variable = q_Cl4
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl5_avg]
        type = ElementAverageValue
        variable = q_Cl5
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl6_avg]
        type = ElementAverageValue
        variable = q_Cl6
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl7_avg]
        type = ElementAverageValue
        variable = q_Cl7
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl8_avg]
        type = ElementAverageValue
        variable = q_Cl8
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl9_avg]
        type = ElementAverageValue
        variable = q_Cl9
        execute_on = 'initial timestep_end'
    [../]



    [./q_SeO4_avg]
        type = ElementAverageValue
        variable = q_SeO4Avg
        execute_on = 'initial timestep_end'
    [../]

    [./q_Cl_avg]
        type = ElementAverageValue
        variable = q_ClAvg
        execute_on = 'initial timestep_end'
    [../]

    [./Cb_SeO4_out]
        type = SideAverageValue
        boundary = 'top'
        variable = Cb_SeO4
        execute_on = 'initial timestep_end'
    [../]
    [./Cb_SeO4_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = Cb_SeO4
        execute_on = 'initial timestep_end'
    [../]


    [./eps_p]
        type = ElementAverageValue
        variable = eps_p
        execute_on = 'initial timestep_end'
    [../]
    [./A_0]
        type = ElementAverageValue
        variable = A_0
        execute_on = 'initial timestep_end'
    [../]
    [./km_SeO4]
        type = ElementAverageValue
        variable = km_SeO4
        execute_on = 'initial timestep_end'
    [../]
    [./Dp_SeO4]
        type = ElementAverageValue
        variable = Dp_SeO4
        execute_on = 'initial timestep_end'
    [../]


[]


[Preconditioning]
    [./smp]
        type = SMP
        full = true
        solve_type = pjfnk   #default to newton, but use pjfnk if newton too slow
    [../]
[]


# Updated solver options for added stability (for -sub_pc_type, you can change 'lu' to 'asm' (or visa versa) for more stabilization of linear steps)


[Executioner]
    type = Transient
    scheme = bdf2
    petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-20        # Need a very low tolerance here given how small your residuals are on your unit basis
    nl_rel_step_tol = 1e-8
    nl_abs_step_tol = 1e-8
    nl_max_its = 70
    l_tol = 1e-7
    l_max_its = 300
    line_search = bt    # Options: default none l2 bt basic
    start_time = 0.0
    end_time = 120
    dtmax = 0.01

    [./TimeStepper]
        type = SolutionTimeAdaptiveDT
        dt = 0.01
    [../]
[]


[Outputs]
    exodus = true
    csv = true
    print_linear_residuals = false
[]
