
[GlobalParams]
  # 'dg_scheme' and 'sigma' are parameters for the DG kernels
  dg_scheme = nipg
  sigma = 10
  # 'transfer_rate' is a lumped parameter for mass-trasfer coefficient (km)
  #     and the ratio of exposed area to catalyst volume (Ga).
  #       transfer_rate = km*Ga*(1-eb)
  transfer_rate = 9539  #min^-1
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 10
    xmin = 0.0
    xmax = 1.0    #2cm diameter
    ymin = 0.0
    ymax = 5.0    #5cm length
[] # END Mesh

[Variables]

## Gas phase variable lists
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.002330029
    [../]

    [./O2w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.002330029
    [../]

    [./H2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.001174
    [../]

    [./H2Ow]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.001174
    [../]

    [./NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NH3w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NOx]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NOxw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NO2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NO2w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2Ow]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

## Reaction variable list
    [./r1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r2a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r2b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r4a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r4b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r5]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r6]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r7]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r8]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r9]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r10]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r11]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r12]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r13]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r14]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r15]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r16]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r17]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r18]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r19]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r20]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r21]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r22]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r23]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r24]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r25]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r26]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r27]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r28]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r29]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r30]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r31]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r32]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r33]
        order = FIRST
        family = MONOMIAL
    [../]


## Surface Variable List
    [./q1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q2a]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q2b]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q4a]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q4b]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q1_NH4NO3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q2_NH4NO3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q3_NH4NO3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./qT]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

# =========== NOTE: Needed to add ICs here due to issues with site balances giving NAN/INF in linear res =========
#		may need to consider a custom IC for sites with site balances
    [./S1]
        order = FIRST
        family = MONOMIAL
	initial_condition = 0.052619
    [../]

    [./S2]
        order = FIRST
        family = MONOMIAL
	initial_condition = 0.0231257
    [../]

    [./S3]
        order = FIRST
        family = MONOMIAL
	initial_condition = 0.026252
    [../]

[] #END Variables

[AuxVariables]

  # Z1CuOH
  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.052619
  [../]

  # Z2Cu sites
  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0231257
  [../]

  # ZH sites
  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.026252
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 523.15
  [../]

  [./press]
      order = FIRST
      family = MONOMIAL
      initial_condition = 107.39
  [../]

  [./D]
    order = FIRST
    family = MONOMIAL
    initial_condition = 2400.0  #Approximate dispersion
  [../]

  # e_b
  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.3309
  [../]

  # non_pore = (1 - pore)
  [./non_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.6691
  [../]

  # ew =~ 1/5
  # total_pore = ew* (1 - pore)
  # micro_pore_vol = 0.18 cm^3/g
  # assume ew = 0.4
  [./total_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.26764
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 15110 #cm/min
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

[] #END AuxVariables

[ICs]

[] #END ICs

[Kernels]
# ------------------- Start Gas Balances ----------------------
# -------------------------------------------------------------
    # =============== Bulk phase O2 ===============
    [./O2_dot]
        type = VariableCoefTimeDerivative
        variable = O2
        coupled_coef = pore
    [../]
    [./O2_gadv]
        type = GPoreConcAdvection
        variable = O2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_gdiff]
        type = GVarPoreDiffusion
        variable = O2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./O2w_trans]
        type = ConstMassTransfer
        variable = O2
        coupled = O2w
    [../]

    # =============== Washcoat phase O2 ===============
    [./O2w_dot]
        type = VariableCoefTimeDerivative
        variable = O2w
        coupled_coef = total_pore
    [../]
    [./O2_trans]
        type = ConstMassTransfer
        variable = O2w
        coupled = O2
    [../]
    [./O2w_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = O2w
        coupled_list = 'r5 r6
			r7 r8 r9
			r10 r11 r12
			r13 r14 r15 r16 r17
			r18 r19 r20
			r28 r29 r30'
        weights = '-0.5 -0.5
			-0.75 -0.75 -0.75
			-1.25 -1.25 -1.25
			-0.25 -0.25 -0.25 -0.25 -0.25
			-0.75 -0.75 -0.75
			0.25 0.25 0.25'
        scale = non_pore
    [../]

    # =============== Bulk phase H2O ===============
    [./H2O_dot]
        type = VariableCoefTimeDerivative
        variable = H2O
        coupled_coef = pore
    [../]
    [./H2O_gadv]
        type = GPoreConcAdvection
        variable = H2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_gdiff]
        type = GVarPoreDiffusion
        variable = H2O
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./H2Ow_trans]
        type = ConstMassTransfer
        variable = H2O
        coupled = H2Ow
    [../]

    # =============== Washcoat phase H2O ===============
    [./H2Ow_dot]
        type = VariableCoefTimeDerivative
        variable = H2Ow
        coupled_coef = total_pore
    [../]
    [./H2O_trans]
        type = ConstMassTransfer
        variable = H2Ow
        coupled = H2O
    [../]
    [./H2Ow_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = H2Ow
        coupled_list = 'r7 r8 r9
			r10 r11 r12
			r13 r14 r15 r16 r17
			r18 r19 r20
			r21 r22 r23 r24
			r25 r26 r27
			r28 r29 r30
			r31 r32 r33'
        weights = '1.5 1.5 1.5
			1.5 1.5 1.5
			1.5 1.5 1.5 1.5 1.5
			1.5 1.5 1.5
			1 1 1 1
			2 2 2
			0.5 0.5 0.5
			2 2 2'
        scale = non_pore
    [../]

    # =============== Bulk phase NH3 ===============
    [./NH3_dot]
        type = VariableCoefTimeDerivative
        variable = NH3
        coupled_coef = pore
    [../]
    [./NH3_gadv]
        type = GPoreConcAdvection
        variable = NH3
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_gdiff]
        type = GVarPoreDiffusion
        variable = NH3
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./NH3w_trans]
        type = ConstMassTransfer
        variable = NH3
        coupled = NH3w
    [../]

    # =============== Washcoat phase NH3 ===============
    [./NH3w_dot]
        type = VariableCoefTimeDerivative
        variable = NH3w
        coupled_coef = total_pore
    [../]
    [./NH3_trans]
        type = ConstMassTransfer
        variable = NH3w
        coupled = NH3
    [../]
    [./NH3w_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = NH3w
        coupled_list = 'r1 r2a r2b r3'
        weights = '-1 -1 -1 -1'
        scale = non_pore
    [../]

    # =============== Bulk phase NO ===============
    [./NOx_dot]
        type = VariableCoefTimeDerivative
        variable = NOx
        coupled_coef = pore
    [../]
    [./NOx_gadv]
        type = GPoreConcAdvection
        variable = NOx
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NOx_gdiff]
        type = GVarPoreDiffusion
        variable = NOx
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./NOxw_trans]
        type = ConstMassTransfer
        variable = NOx
        coupled = NOxw
    [../]

    # =============== Washcoat phase NO ===============
    [./NOxw_dot]
        type = VariableCoefTimeDerivative
        variable = NOxw
        coupled_coef = total_pore
    [../]
    [./NOx_trans]
        type = ConstMassTransfer
        variable = NOxw
        coupled = NOx
    [../]
    [./NOxw_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = NOxw
        coupled_list = 'r5 r6
			r10 r11 r12
			r13 r14 r15 r16 r17
			r18 r19 r20
			r25 r26 r27'
        weights = '-1 -1
			1 1 1
			-1 -1 -1 -1 -1
			-1 -1 -1
			-1 -1 -1'
        scale = non_pore
    [../]

    # =============== Bulk phase NO2 ===============
    [./NO2_dot]
        type = VariableCoefTimeDerivative
        variable = NO2
        coupled_coef = pore
    [../]
    [./NO2_gadv]
        type = GPoreConcAdvection
        variable = NO2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NO2_gdiff]
        type = GVarPoreDiffusion
        variable = NO2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./NO2w_trans]
        type = ConstMassTransfer
        variable = NO2
        coupled = NO2w
    [../]

    # =============== Washcoat phase NO2 ===============
    [./NO2w_dot]
        type = VariableCoefTimeDerivative
        variable = NO2w
        coupled_coef = total_pore
    [../]
    [./NO2_trans]
        type = ConstMassTransfer
        variable = NO2w
        coupled = NO2
    [../]
    [./NO2w_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = NO2w
        coupled_list = 'r5 r6
			r21 r22 r23 r24
			r25 r26 r27
			r28 r29 r30'
        weights = '1 1
			-2 -2 -2 -2
			1 1 1
			1 1 1'
        scale = non_pore
    [../]

    # =============== Bulk phase N2O ===============
    [./N2O_dot]
        type = VariableCoefTimeDerivative
        variable = N2O
        coupled_coef = pore
    [../]
    [./N2O_gadv]
        type = GPoreConcAdvection
        variable = N2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./N2O_gdiff]
        type = GVarPoreDiffusion
        variable = N2O
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./N2Ow_trans]
        type = ConstMassTransfer
        variable = N2O
        coupled = N2Ow
    [../]

    # =============== Washcoat phase N2O ===============
    [./N2Ow_dot]
        type = VariableCoefTimeDerivative
        variable = N2Ow
        coupled_coef = total_pore
    [../]
    [./N2O_trans]
        type = ConstMassTransfer
        variable = N2Ow
        coupled = N2O
    [../]
    [./N2Ow_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = N2Ow
        coupled_list = 'r18 r19 r20
			r31 r32 r33'
        weights = '1 1 1
			1 1 1'
        scale = non_pore
    [../]

# ------------------- Start Site Balances ----------------------
# -------------------------------------------------------------
    [./q1_dot]
        type = TimeDerivative
        variable = q1
    [../]
    [./q1_rate]
        type = WeightedCoupledSumFunction
        variable = q1
        coupled_list = 'r1 r13 r21 r28'
        weights = '1 -1 -2 1'
    [../]

    [./q2a_dot]
        type = TimeDerivative
        variable = q2a
    [../]
    [./q2a_rate]
        type = WeightedCoupledSumFunction
        variable = q2a
        coupled_list = 'r2a r2b r7 r8 r10 r11 r14 r15 r18 r19 r22 r23 r29'
        weights = '1 -1 -1 1 -1 1 -1 1 -1 1 -2 1 1'
    [../]

    [./q2b_dot]
        type = TimeDerivative
        variable = q2b
    [../]
    [./q2b_rate]
        type = WeightedCoupledSumFunction
        variable = q2b
        coupled_list = 'r2b r8 r11 r15 r19 r23'
        weights = '1 -1 -1 -1 -1 -2'
    [../]

    [./q3_dot]
        type = TimeDerivative
        variable = q3
    [../]
    [./q3_rate]
        type = WeightedCoupledSumFunction
        variable = q3
        coupled_list = 'r3 r9 r12 r16 r17 r20 r24 r30'
        weights = '1 -1 -1 -1 -1 -1 -2 1'
    [../]

    [./q4a_dot]
        type = TimeDerivative
        variable = q4a
    [../]
    [./q4a_rate]
        type = WeightedCoupledSumFunction
        variable = q4a
        coupled_list = 'r4a'
        weights = '1'
    [../]

    [./q4b_dot]
        type = TimeDerivative
        variable = q4b
    [../]
    [./q4b_rate]
        type = WeightedCoupledSumFunction
        variable = q4b
        coupled_list = 'r4b'
        weights = '1'
    [../]

    [./q1_NH4NO3_dot]
        type = TimeDerivative
        variable = q1_NH4NO3
    [../]
    [./q1_NH4NO3_rate]
        type = WeightedCoupledSumFunction
        variable = q1_NH4NO3
        coupled_list = 'r21 r25 r28 r31'
        weights = '1 -1 -1 -1'
    [../]

    [./q2_NH4NO3_dot]
        type = TimeDerivative
        variable = q2_NH4NO3
    [../]
    [./q2_NH4NO3_rate]
        type = WeightedCoupledSumFunction
        variable = q2_NH4NO3
        coupled_list = 'r22 r23 r26 r29 r32'
        weights = '1 1 -1 -1 -1'
    [../]

    [./q3_NH4NO3_dot]
        type = TimeDerivative
        variable = q3_NH4NO3
    [../]
    [./q3_NH4NO3_rate]
        type = WeightedCoupledSumFunction
        variable = q3_NH4NO3
        coupled_list = 'r24 r27 r30 r33'
        weights = '1 -1 -1 -1'
    [../]

    [./qT_calc]
        type = MaterialBalance
        variable = qT
        this_variable = qT
        coupled_list = 'q1 q2a q2b q3 q1_NH4NO3 q2_NH4NO3 q3_NH4NO3'
        weights = '1 1 2 1 1 1 1'
        total_material = qT
    [../]

    [./S1_bal]
        type = MaterialBalance
        variable = S1
        this_variable = S1
        coupled_list = 'q1 S1 q4a q1_NH4NO3'
        weights = '1 1 1 1'
        total_material = w1
    [../]

    [./S2_bal]
        type = MaterialBalance
        variable = S2
        this_variable = S2
        coupled_list = 'q2a q2b S2 q4b q2_NH4NO3'
        weights = '1 1 1 1 1'
        total_material = w2
    [../]

    [./S3_bal]
        type = MaterialBalance
        variable = S3
        this_variable = S3
        coupled_list = 'q3 S3 q3_NH4NO3'
        weights = '1 1 1'
        total_material = w3
    [../]

# ------------------- Start Reaction Balances ----------------------
# -------------------------------------------------------------
    [./r1_val]
        type = Reaction
        variable = r1
    [../]
    [./r1_rx]  #   NH3w + S1 <-- --> q1
      type = ArrheniusEquilibriumReaction
      variable = r1
      this_variable = r1
      forward_activation_energy = 0
      forward_pre_exponential = 250000
      enthalpy = -54547.9
      entropy = -29.9943
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S1'
      reactant_stoich = '1 1'
      products = 'q1'
      product_stoich = '1'
    [../]

    [./r2a_val]
        type = Reaction
        variable = r2a
    [../]
    [./r2a_rx]  #   NH3w + S2 <-- --> q2a
      type = ArrheniusEquilibriumReaction
      variable = r2a
      this_variable = r2a
      forward_activation_energy = 0
      forward_pre_exponential = 300000
      enthalpy = -78073.843
      entropy = -35.311574
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S2'
      reactant_stoich = '1 1'
      products = 'q2a'
      product_stoich = '1'
    [../]

    [./r2b_val]
        type = Reaction
        variable = r2b
    [../]
    [./r2b_rx_a]  #   NH3w + q2a <-- --> q2b
      type = ArrheniusEquilibriumReaction
      variable = r2b
      this_variable = r2b
      forward_activation_energy = 0
      forward_pre_exponential = 150000
      enthalpy = -78064.167
      entropy = -46.821878
      temperature = temp
      scale = 1.0
      reactants = 'NH3w q2a'
      reactant_stoich = '1 1'
      products = 'q2b'
      product_stoich = '1'
    [../]

    [./r3_dot]
        type = Reaction
        variable = r3
    [../]
    [./r3_rx]  #   NH3w + S3 <-- --> q3
      type = ArrheniusEquilibriumReaction
      variable = r3
      this_variable = r3
      forward_activation_energy = 0
      forward_pre_exponential = 2500000
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S3'
      reactant_stoich = '1 1'
      products = 'q3'
      product_stoich = '1'
    [../]

    [./r4a_val]
        type = Reaction
        variable = r4a
    [../]
    [./r4a_rx]  #   H2Ow + S1 <-- --> q4a
      type = ArrheniusEquilibriumReaction
      variable = r4a
      this_variable = r4a
      forward_activation_energy = 0
      forward_pre_exponential = 44000
      enthalpy = -32099.1
      entropy = -24.2494
      temperature = temp
      scale = 1.0
      reactants = 'H2Ow S1'
      reactant_stoich = '1 1'
      products = 'q4a'
      product_stoich = '1'
    [../]

    [./r4b_val]
        type = Reaction
        variable = r4b
    [../]
    [./r4b_rx]  #   H2Ow + S2 <-- --> q4b
      type = ArrheniusEquilibriumReaction
      variable = r4b
      this_variable = r4b
      forward_activation_energy = 0
      forward_pre_exponential = 70000
      enthalpy = -28889.23
      entropy = -26.674
      temperature = temp
      scale = 1.0
      reactants = 'H2Ow S2'
      reactant_stoich = '1 1'
      products = 'q4b'
      product_stoich = '1'
    [../]

## ======= NO Oxidation ======
    [./r5_val]
        type = Reaction
        variable = r5
    [../]
    [./r5_rx]
      type = ArrheniusReaction
      variable = r5
      this_variable = r5

      forward_activation_energy = 45916.39
      forward_pre_exponential = 8280318500

      reverse_activation_energy = 84189.57118
      reverse_pre_exponential = 15044815235

      temperature = temp
      scale = 1.0
      reactants = 'S1 NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S1 NO2w'
      product_stoich = '1 1'
    [../]

    [./r6_val]
        type = Reaction
        variable = r6
    [../]
    [./r6_rx]
      type = ArrheniusReaction
      variable = r6
      this_variable = r6

      forward_activation_energy = 41466.3167
      forward_pre_exponential = 3128122078

      reverse_activation_energy = 85751.51148
      reverse_pre_exponential = 21145769407

      temperature = temp
      scale = 1.0
      reactants = 'S2 NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S2 NO2w'
      product_stoich = '1 1'
    [../]

## ======= NH3 Oxidation ======
    [./r7_val]
        type = Reaction
        variable = r7
    [../]
    [./r7_rx]
      type = ArrheniusReaction
      variable = r7
      this_variable = r7

      forward_activation_energy = 77459.00445
      forward_pre_exponential = 265923294.3

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r8_val]
        type = Reaction
        variable = r8
    [../]
    [./r8_rx]
      type = ArrheniusReaction
      variable = r8
      this_variable = r8

      forward_activation_energy = 74122.66269
      forward_pre_exponential = 126285022.9

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r9_val]
        type = Reaction
        variable = r9
    [../]
    [./r9_rx]
      type = ArrheniusReaction
      variable = r9
      this_variable = r9

      forward_activation_energy = 74323.17448
      forward_pre_exponential = 132690825.9

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH3 Partial Oxidation ======
    [./r10_val]
        type = Reaction
        variable = r10
    [../]
    [./r10_rx]
      type = ArrheniusReaction
      variable = r10
      this_variable = r10

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r11_val]
        type = Reaction
        variable = r11
    [../]
    [./r11_rx]
      type = ArrheniusReaction
      variable = r11
      this_variable = r11

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r12_val]
        type = Reaction
        variable = r12
    [../]
    [./r12_rx]
      type = ArrheniusReaction
      variable = r12
      this_variable = r12

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NO SCR ======
    [./r13_val]
        type = Reaction
        variable = r13
    [../]
    [./r13_rx]
      type = ArrheniusReaction
      variable = r13
      this_variable = r13

      forward_activation_energy = 54989.46429
      forward_pre_exponential = 3.93042E+13

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1 NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r14_val]
        type = Reaction
        variable = r14
    [../]
    [./r14_rx]
      type = ArrheniusReaction
      variable = r14
      this_variable = r14

      forward_activation_energy = 57733.39847
      forward_pre_exponential = 6.85708E+13

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r15_val]
        type = Reaction
        variable = r15
    [../]
    [./r15_rx]
      type = ArrheniusReaction
      variable = r15
      this_variable = r15

      forward_activation_energy = 55398.91238
      forward_pre_exponential = 4.72181E+13

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r16_val]
        type = Reaction
        variable = r16
    [../]
    [./r16_rx]
      type = ArrheniusReaction
      variable = r16
      this_variable = r16

      forward_activation_energy = 60229.72112
      forward_pre_exponential = 1.40006E+15

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 NOxw O2w S1'
      reactant_stoich = '1 1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r17_val]
        type = Reaction
        variable = r17
    [../]
    [./r17_rx]
      type = ArrheniusReaction
      variable = r17
      this_variable = r17

      forward_activation_energy = 42369.42133
      forward_pre_exponential = 7.63674E+13

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 NOxw O2w S2'
      reactant_stoich = '1 1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= N2O from NO SCR ======
    [./r18_val]
        type = Reaction
        variable = r18
    [../]
    [./r18_rx]
      type = ArrheniusReaction
      variable = r18
      this_variable = r18

      forward_activation_energy = 49462.64319
      forward_pre_exponential = 2.18635E+11

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r19_val]
        type = Reaction
        variable = r19
    [../]
    [./r19_rx]
      type = ArrheniusReaction
      variable = r19
      this_variable = r19

      forward_activation_energy = 44323.79215
      forward_pre_exponential = 78876971174

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r20_val]
        type = Reaction
        variable = r20
    [../]
    [./r20_rx]
      type = ArrheniusReaction
      variable = r20
      this_variable = r20

      forward_activation_energy = 37024.38533
      forward_pre_exponential = 6.66875E+11

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 NOxw O2w S2'
      reactant_stoich = '1 1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH4NO3 Formation ======
    [./r21_val]
        type = Reaction
        variable = r21
    [../]
    [./r21_rx]
      type = ArrheniusReaction
      variable = r21
      this_variable = r21

      forward_activation_energy = 68215.9249
      forward_pre_exponential = 2.28114E+12

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1 NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r22_val]
        type = Reaction
        variable = r22
    [../]
    [./r22_rx]
      type = ArrheniusReaction
      variable = r22
      this_variable = r22

      forward_activation_energy = 68243.03474
      forward_pre_exponential = 2.29565E+12

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r23_val]
        type = Reaction
        variable = r23
    [../]
    [./r23_rx]
      type = ArrheniusReaction
      variable = r23
      this_variable = r23

      forward_activation_energy = 86550.90572
      forward_pre_exponential = 6.33945E+13

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r24_val]
        type = Reaction
        variable = r24
    [../]
    [./r24_rx]
      type = ArrheniusReaction
      variable = r24
      this_variable = r24

      forward_activation_energy = 68243.84412
      forward_pre_exponential = 2.29607E+12

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH4NO3 Fast SCR ======
    [./r25_val]
        type = Reaction
        variable = r25
    [../]
    [./r25_rx]
      type = ArrheniusReaction
      variable = r25
      this_variable = r25

      forward_activation_energy = 63279.2687
      forward_pre_exponential = 1.29813E+12

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1_NH4NO3 NOxw'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r26_val]
        type = Reaction
        variable = r26
    [../]
    [./r26_rx]
      type = ArrheniusReaction
      variable = r26
      this_variable = r26

      forward_activation_energy = 55329.06547
      forward_pre_exponential = 2.12661E+11

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2_NH4NO3 NOxw'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r27_val]
        type = Reaction
        variable = r27
    [../]
    [./r27_rx]
      type = ArrheniusReaction
      variable = r27
      this_variable = r27

      forward_activation_energy = 53922.06929
      forward_pre_exponential = 1.42659E+11

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3_NH4NO3 NOxw'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH4NO3 NO2 SCR ======
    [./r28_val]
        type = Reaction
        variable = r28
    [../]
    [./r28_rx]
      type = ArrheniusReaction
      variable = r28
      this_variable = r28

      forward_activation_energy = 68525.008
      forward_pre_exponential = 22539132100

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

    [./r29_val]
        type = Reaction
        variable = r29
    [../]
    [./r29_rx]
      type = ArrheniusReaction
      variable = r29
      this_variable = r29

      forward_activation_energy = 67842.46782
      forward_pre_exponential = 19660088090

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

    [./r30_val]
        type = Reaction
        variable = r30
    [../]
    [./r30_rx]
      type = ArrheniusReaction
      variable = r30
      this_variable = r30

      forward_activation_energy = 68293.82218
      forward_pre_exponential = 21115215429

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

## ======= NH4NO3 N2O Formation ======
    [./r31_val]
        type = Reaction
        variable = r31
    [../]
    [./r31_rx]
      type = ArrheniusReaction
      variable = r31
      this_variable = r31

      forward_activation_energy = 91481.80071
      forward_pre_exponential = 1.48923E+11

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

    [./r32_val]
        type = Reaction
        variable = r32
    [../]
    [./r32_rx]
      type = ArrheniusReaction
      variable = r32
      this_variable = r32

      forward_activation_energy = 94891.77819
      forward_pre_exponential = 3.73044E+11

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

    [./r33_val]
        type = Reaction
        variable = r33
    [../]
    [./r33_rx]
      type = ArrheniusReaction
      variable = r33
      this_variable = r33

      forward_activation_energy = 68627.01632
      forward_pre_exponential = 1763568982

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]


[] #END Kernels

[DGKernels]

    # =========== O2 DG kernels ===========
    [./O2_dgadv]
        type = DGPoreConcAdvection
        variable = O2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_dgdiff]
        type = DGVarPoreDiffusion
        variable = O2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== H2O DG kernels ===========
    [./H2O_dgadv]
        type = DGPoreConcAdvection
        variable = H2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_dgdiff]
        type = DGVarPoreDiffusion
        variable = H2O
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== NH3 DG kernels ===========
    [./NH3_dgadv]
        type = DGPoreConcAdvection
        variable = NH3
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_dgdiff]
        type = DGVarPoreDiffusion
        variable = NH3
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== NO DG kernels ===========
    [./NOx_dgadv]
        type = DGPoreConcAdvection
        variable = NOx
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NOx_dgdiff]
        type = DGVarPoreDiffusion
        variable = NOx
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== NO2 DG kernels ===========
    [./NO2_dgadv]
        type = DGPoreConcAdvection
        variable = NO2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NO2_dgdiff]
        type = DGVarPoreDiffusion
        variable = NO2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== N2O DG kernels ===========
    [./N2O_dgadv]
        type = DGPoreConcAdvection
        variable = N2O
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./N2O_dgdiff]
        type = DGVarPoreDiffusion
        variable = N2O
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

[] #END DGKernels

[AuxKernels]

    [./velocity]
        # NOTE: velocity must use same shape function type as temperature and space-velocity
        type = GasVelocityCylindricalReactor
        variable = vel_y
        porosity = 0.3309
        space_velocity = 1000   #volumes per min
        inlet_temperature = temp
        ref_pressure = 101.35
        ref_temperature = 273.15
        radius = 1  #cm
        length = 5  #cm
        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]

    # ============== O2 BCs ================
    [./O2_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = O2
        boundary = 'bottom'
        u_input = 0.002330029
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '4.66006E-5 0.002330029'
        input_times = '2.0917 29.758'
        time_spans = '0.5 0.5'
    [../]
    [./O2_FluxOut]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== H2O BCs ================
    [./H2O_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = H2O
        boundary = 'bottom'
        u_input = 0.001174
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '0.00115689 0.001144255    0.00113886'
        input_times = '3.5917   31.5    203.5'
        time_spans = '0.5  0.5  0.5'
    [../]
    [./H2O_FluxOut]
        type = DGPoreConcFluxBC
        variable = H2O
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NH3 BCs ================
    [./NH3_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = NH3
        boundary = 'bottom'
        u_input = 1E-15
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '6.9499E-6   1E-15   6.9499E-6  1E-15    6.9499E-6   1E-15'
        input_times = '2.0917   40.75    56.2583    101.425    130.425    190.7583'
        time_spans = '0.5      0.5    0.5    0.5    0.5    0.5'
    [../]
    [./NH3_FluxOut]
        type = DGPoreConcFluxBC
        variable = NH3
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NO BCs ================
    [./NOx_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = NOx
        boundary = 'bottom'
        u_input = 1E-15
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '6.9239E-6   3.44803E-6   6.9239E-6'
        input_times = '40.75    116.925    203.7583'
        time_spans = '0.5      0.5   0.5'
    [../]
    [./NOx_FluxOut]
        type = DGPoreConcFluxBC
        variable = NOx
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NO2 BCs ================
    [./NO2_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = NO2
        boundary = 'bottom'
        u_input = 1E-15
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '3.37554E-6   1E-15'
        input_times = '116.925    203.7583'
        time_spans = '0.5      0.5    0.5'
    [../]
    [./NO2_FluxOut]
        type = DGPoreConcFluxBC
        variable = NO2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== N2O BCs ================
    [./N2O_FluxIn]
        type = DGPoreConcFluxStepwiseBC
        variable = N2O
        boundary = 'bottom'
        u_input = 1E-15
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '1E-15'
        input_times = '1'
        time_spans = '1'
    [../]
    [./N2O_FluxOut]
        type = DGPoreConcFluxBC
        variable = N2O
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[] #END BCs

[Materials]

[] #END Materials

[Postprocessors]

    [./O2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./O2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = O2
        execute_on = 'initial timestep_end'
    [../]

    [./H2O_out]
        type = SideAverageValue
        boundary = 'top'
        variable = H2O
        execute_on = 'initial timestep_end'
    [../]

    [./H2O_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2O
        execute_on = 'initial timestep_end'
    [../]

    [./NH3_out]
        type = SideAverageValue
        boundary = 'top'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./NH3_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./NO_out]
        type = SideAverageValue
        boundary = 'top'
        variable = NOx
        execute_on = 'initial timestep_end'
    [../]

    [./NO_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NOx
        execute_on = 'initial timestep_end'
    [../]

    [./NO2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = NO2
        execute_on = 'initial timestep_end'
    [../]

    [./NO2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = NO2
        execute_on = 'initial timestep_end'
    [../]

    [./N2O_out]
        type = SideAverageValue
        boundary = 'top'
        variable = N2O
        execute_on = 'initial timestep_end'
    [../]

    [./N2O_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = N2O
        execute_on = 'initial timestep_end'
    [../]

    [./temp_avg]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    [./qT]
        type = ElementAverageValue
        variable = qT
        execute_on = 'initial timestep_end'
    [../]

    [./q1]
        type = ElementAverageValue
        variable = q1
        execute_on = 'initial timestep_end'
    [../]

    [./q2a]
        type = ElementAverageValue
        variable = q2a
        execute_on = 'initial timestep_end'
    [../]

    [./q2b]
        type = ElementAverageValue
        variable = q2b
        execute_on = 'initial timestep_end'
    [../]

    [./q3]
        type = ElementAverageValue
        variable = q3
        execute_on = 'initial timestep_end'
    [../]

    [./q1_NH4NO3]
        type = ElementAverageValue
        variable = q1_NH4NO3
        execute_on = 'initial timestep_end'
    [../]

    [./q2_NH4NO3]
        type = ElementAverageValue
        variable = q2_NH4NO3
        execute_on = 'initial timestep_end'
    [../]

    [./q3_NH4NO3]
        type = ElementAverageValue
        variable = q3_NH4NO3
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
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 212.0
  dtmax = 0.25

  [./TimeStepper]
     type = ConstantDT
     dt = 0.25
  [../]
[] #END Executioner

[Outputs]
  print_linear_residuals = true
  exodus = true
  csv = true
[] #END Outputs
