# ---------------------------------------------------------------------
# NOTE 1: May need to include O2 adsorption to account for NH3 'spike' when
# O2 level is increased.
# ---------------------------------------------------------------------

[GlobalParams]
  # 'dg_scheme' and 'sigma' are parameters for the DG kernels
  dg_scheme = nipg
  sigma = 10
  # 'transfer_rate' is a lumped parameter for film mass transfer and pore diffusion
  #   The value here is indicative of mass transfer into a washcoat in a monolith
  #   where the monolith channels are squares with rounded corners
  transfer_rate = 5757.541  #min^-1
[] #END GlobalParams

[Problem]
    coord_type = RZ
    #NOTE: For RZ coordinates, x ==> R and y ==> Z (and z ==> nothing)
[] #END Problem

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = 1
    ny = 20
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
        initial_condition = 0.00116278
    [../]

    [./H2Ow]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.00116278
    [../]

    [./NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NH3w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NOx]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NOxw]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NO2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./NO2w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./N2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
    [../]

    [./N2Ow]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-9
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

    [./r3a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r3b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r3c]
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

    [./r13a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r14a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r15a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r16a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r17a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r18a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r19a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r20a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r13b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r14b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r15b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r16b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r17b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r18b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r19b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r20b]
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

    [./r34]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r35]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r36]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r37]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r38]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r39]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r40]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r41]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r42]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r43]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r44]
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

    [./q3a]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q3b]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./q3c]
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

    [./qT]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0
    [../]

    [./S1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./S2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./S3a]
        order = FIRST
        family = MONOMIAL
    [../]

    [./S3b]
        order = FIRST
        family = MONOMIAL
    [../]

    [./S3c]
        order = FIRST
        family = MONOMIAL
    [../]

[] #END Variables

[AuxVariables]

  # Z1CuOH
  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.048389
  [../]

  # Z2Cu sites
  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.026649
  [../]

  # ZH sites
  [./w3a]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001611
  [../]

  # ZH/ZCu sites
  [./w3b]
      order = FIRST
      family = MONOMIAL
      initial_condition = 9.51E-7
  [../]

  # ZH/CuO
  [./w3c]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.009688
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 523.15
  [../]

  [./D]
    order = FIRST
    family = MONOMIAL
    initial_condition = 0.0
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
  # assume ew = 0.2
  [./total_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.13382
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = LAGRANGE
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
        coupled_list = 'r4a r4b'
        weights = '-1 -1'
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
        coupled_list = 'r1 r2a r2b r3a r3b r3c'
        weights = '-1 -1 -1 -1 -1 -1'
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
        coupled_list = 'r6 r7 r8 r11 r12
                        r14a r15a r16a r19a r20a
                        r14b r15b r16b r19b r20b
                        r22 r23 r24 r27 r28
                        r30 r31 r32 r35 r36
                        r38 r39 r40 r43 r44'
        weights = '1 -1 -1 -1 -0.5
                   1 -1 -1 -1 -0.5
                   1 -1 -1 -1 -0.5
                   1 -1 -1 -1 -0.5
                   1 -1 -1 -1 -0.5
                   1 -1 -1 -1 -0.5'
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
        coupled_list = 'r7 r9 r10 r12
                        r15a r17a r18a r20a
                        r15b r17b r18b r20b
                        r23 r25 r26 r28
                        r31 r33 r34 r36
                        r39 r41 r42 r44'
        weights = '1 -1 -1 -0.5
                   1 -1 -1 -0.5
                   1 -1 -1 -0.5
                   1 -1 -1 -0.5
                   1 -1 -1 -0.5
                   1 -1 -1 -0.5'
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
        coupled_list = 'r10 r11
                        r18a r19a
                        r18b r19b
                        r26 r27
                        r34 r35
                        r42 r43'
        weights = '1 1
                   1 1
                   1 1
                   1 1
                   1 1
                   1 1'
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
        coupled_list = 'r1 r5 r6 r8 r9 r10 r11 r12'
        weights = '1 -1 -1 -1 -1 -1 -1 -1'
    [../]

    [./q2a_dot]
        type = TimeDerivative
        variable = q2a
    [../]
    [./q2a_rate]
        type = WeightedCoupledSumFunction
        variable = q2a
        coupled_list = 'r2a r2b r13a r14a r16a r17a r18a r19a r20a r13b r14b r16b r17b r18b r19b r20b'
        weights = '1 -1 -1 -1 -1 -1 -1 -1 -1 1 1 1 1 1 1 1'
    [../]

    [./q2b_dot]
        type = TimeDerivative
        variable = q2b
    [../]
    [./q2b_rate]
        type = WeightedCoupledSumFunction
        variable = q2b
        coupled_list = 'r2b r13b r14b r16b r17b r18b r19b r20b'
        weights = '1 -1 -1 -1 -1 -1 -1 -1'
    [../]

    [./q3a_dot]
        type = TimeDerivative
        variable = q3a
    [../]
    [./q3a_rate]
        type = WeightedCoupledSumFunction
        variable = q3a
        coupled_list = 'r3a r21 r22 r24 r25 r26 r27 r28'
        weights = '1 -1 -1 -1 -1 -1 -1 -1'
    [../]

    [./q3b_dot]
        type = TimeDerivative
        variable = q3b
    [../]
    [./q3b_rate]
        type = WeightedCoupledSumFunction
        variable = q3b
        coupled_list = 'r3b r29 r30 r32 r33 r34 r35 r36'
        weights = '1 -1 -1 -1 -1 -1 -1 -1'
    [../]

    [./q3c_dot]
        type = TimeDerivative
        variable = q3c
    [../]
    [./q3c_rate]
        type = WeightedCoupledSumFunction
        variable = q3c
        coupled_list = 'r3c r37 r38 r40 r41 r42 r43 r44'
        weights = '1 -1 -1 -1 -1 -1 -1 -1'
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

    [./qT_calc]
        type = MaterialBalance
        variable = qT
        this_variable = qT
        coupled_list = 'q1 q2a q2b q3a q3b q3c'
        weights = '1 1 2 1 1 1'
        total_material = qT
    [../]

    [./S1_bal]
        type = MaterialBalance
        variable = S1
        this_variable = S1
        coupled_list = 'q1 S1 q4a'
        weights = '1 1 1'
        total_material = w1
    [../]

    [./S2_bal]
        type = MaterialBalance
        variable = S2
        this_variable = S2
        coupled_list = 'q2a q2b S2 q4b'
        weights = '1 1 1 1'
        total_material = w2
    [../]

    [./S3a_bal]
        type = MaterialBalance
        variable = S3a
        this_variable = S3a
        coupled_list = 'q3a S3a'
        weights = '1 1'
        total_material = w3a
    [../]

    [./S3b_bal]
        type = MaterialBalance
        variable = S3b
        this_variable = S3b
        coupled_list = 'q3b S3b'
        weights = '1 1'
        total_material = w3b
    [../]

    [./S3c_bal]
        type = MaterialBalance
        variable = S3c
        this_variable = S3c
        coupled_list = 'q3c S3c'
        weights = '1 1'
        total_material = w3c
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

    [./r3a_dot]
        type = Reaction
        variable = r3a
    [../]
    [./r3a_rx]  #   NH3w + S3a <-- --> q3a
      type = ArrheniusEquilibriumReaction
      variable = r3a
      this_variable = r3a
      forward_activation_energy = 0
      forward_pre_exponential = 2500000
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S3a'
      reactant_stoich = '1 1'
      products = 'q3a'
      product_stoich = '1'
    [../]

    [./r3b_dot]
        type = Reaction
        variable = r3b
    [../]
    [./r3b_rx]  #   NH3w + S3b <-- --> q3b
      type = ArrheniusEquilibriumReaction
      variable = r3b
      this_variable = r3b
      forward_activation_energy = 0
      forward_pre_exponential = 2500000
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S3b'
      reactant_stoich = '1 1'
      products = 'q3b'
      product_stoich = '1'
    [../]

    [./r3c_dot]
        type = Reaction
        variable = r3c
    [../]
    [./r3c_rx]  #   NH3w + S3c <-- --> q3c
      type = ArrheniusEquilibriumReaction
      variable = r3c
      this_variable = r3c
      forward_activation_energy = 0
      forward_pre_exponential = 2500000
      enthalpy = -91860.8
      entropy = -28.9292
      temperature = temp
      scale = 1.0
      reactants = 'NH3w S3c'
      reactant_stoich = '1 1'
      products = 'q3c'
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

## ======= Start Reaction Set for q1 ======
    [./r5_val]
        type = Reaction
        variable = r5
    [../]
    [./r5_rx]
      type = ArrheniusReaction
      variable = r5
      this_variable = r5

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1 O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r6_val]
        type = Reaction
        variable = r6
    [../]
    [./r6_rx]
      type = ArrheniusReaction
      variable = r6
      this_variable = r6

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1 O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r7_val]
        type = Reaction
        variable = r7
    [../]
    [./r7_rx]
      type = ArrheniusReaction
      variable = r7
      this_variable = r7

      forward_activation_energy = 124748.7
      forward_pre_exponential = 2.725E14

      reverse_activation_energy = 190460.7
      reverse_pre_exponential = 3.1729E16

      temperature = temp
      scale = 1.0
      reactants = 'S1 NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S1 NO2w'
      product_stoich = '1 1'
    [../]

    [./r8_val]
        type = Reaction
        variable = r8
    [../]
    [./r8_rx]
      type = ArrheniusReaction
      variable = r8
      this_variable = r8

      forward_activation_energy = 161314.4
      forward_pre_exponential = 2.8693E26

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1 NOxw O2w'
      reactant_stoich = '1 1 1'
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

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q1 NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

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
      reactants = 'q1 NO2w O2w'
      reactant_stoich = '1 1 1'
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
      reactants = 'q1 NOxw O2w'
      reactant_stoich = '1 1 1'
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
      reactants = 'q1 NOxw NO2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= Start Reaction Set for q2a ======
    [./r13a_val]
        type = Reaction
        variable = r13a
    [../]
    [./r13a_rx]
      type = ArrheniusReaction
      variable = r13a
      this_variable = r13a

      forward_activation_energy = 77096.2
      forward_pre_exponential = 542098776

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r14a_val]
        type = Reaction
        variable = r14a
    [../]
    [./r14a_rx]
      type = ArrheniusReaction
      variable = r14a
      this_variable = r14a

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

    [./r15a_val]
        type = Reaction
        variable = r15a
    [../]
    [./r15a_rx]
      type = ArrheniusReaction
      variable = r15a
      this_variable = r15a

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'S2 NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S2 NO2w'
      product_stoich = '1 1'
    [../]

    [./r16a_val]
        type = Reaction
        variable = r16a
    [../]
    [./r16a_rx]
      type = ArrheniusReaction
      variable = r16a
      this_variable = r16a

      forward_activation_energy = 205633.3
      forward_pre_exponential = 3.13048E29

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r17a_val]
        type = Reaction
        variable = r17a
    [../]
    [./r17a_rx]
      type = ArrheniusReaction
      variable = r17a
      this_variable = r17a

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r18a_val]
        type = Reaction
        variable = r18a
    [../]
    [./r18a_rx]
      type = ArrheniusReaction
      variable = r18a
      this_variable = r18a

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NO2w O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r19a_val]
        type = Reaction
        variable = r19a
    [../]
    [./r19a_rx]
      type = ArrheniusReaction
      variable = r19a
      this_variable = r19a

      forward_activation_energy = 203123.8
      forward_pre_exponential = 6.0903E27

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r20a_val]
        type = Reaction
        variable = r20a
    [../]
    [./r20a_rx]
      type = ArrheniusReaction
      variable = r20a
      this_variable = r20a

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NOxw NO2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]


## ======= Start Reaction Set for q2b ======
    [./r13b_val]
        type = Reaction
        variable = r13b
    [../]
    [./r13b_rx]
      type = ArrheniusReaction
      variable = r13b
      this_variable = r13b

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

    [./r14b_val]
        type = Reaction
        variable = r14b
    [../]
    [./r14b_rx]
      type = ArrheniusReaction
      variable = r14b
      this_variable = r14b

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

    [./r15b_val]
        type = Reaction
        variable = r15b
    [../]
    [./r15b_rx]
      type = ArrheniusReaction
      variable = r15b
      this_variable = r15b

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'q2a NO2w'
      product_stoich = '1 1'
    [../]

    [./r16b_val]
        type = Reaction
        variable = r16b
    [../]
    [./r16b_rx]
      type = ArrheniusReaction
      variable = r16b
      this_variable = r16b

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r17b_val]
        type = Reaction
        variable = r17b
    [../]
    [./r17b_rx]
      type = ArrheniusReaction
      variable = r17b
      this_variable = r17b

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r18b_val]
        type = Reaction
        variable = r18b
    [../]
    [./r18b_rx]
      type = ArrheniusReaction
      variable = r18b
      this_variable = r18b

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NO2w O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r19b_val]
        type = Reaction
        variable = r19b
    [../]
    [./r19b_rx]
      type = ArrheniusReaction
      variable = r19b
      this_variable = r19b

      forward_activation_energy = 94876.9
      forward_pre_exponential = 3.64323E16

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r20b_val]
        type = Reaction
        variable = r20b
    [../]
    [./r20b_rx]
      type = ArrheniusReaction
      variable = r20b
      this_variable = r20b

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b NOxw NO2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= Start Reaction Set for q3a ======
    [./r21_val]
        type = Reaction
        variable = r21
    [../]
    [./r21_rx]
      type = ArrheniusReaction
      variable = r21
      this_variable = r21

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3a O2w'
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

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3a O2w'
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

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'S3a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S3a NO2w'
      product_stoich = '1 1'
    [../]

    [./r24_val]
        type = Reaction
        variable = r24
    [../]
    [./r24_rx]
      type = ArrheniusReaction
      variable = r24
      this_variable = r24

      forward_activation_energy = 119249.8
      forward_pre_exponential = 4.822338E20

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r25_val]
        type = Reaction
        variable = r25
    [../]
    [./r25_rx]
      type = ArrheniusReaction
      variable = r25
      this_variable = r25

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3a NO2w'
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

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3a NO2w O2w'
      reactant_stoich = '1 1 1'
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

      forward_activation_energy = 100280.5
      forward_pre_exponential = 1.7555E17

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3a NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r28_val]
        type = Reaction
        variable = r28
    [../]
    [./r28_rx]
      type = ArrheniusReaction
      variable = r28
      this_variable = r28

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3a NOxw NO2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= Start Reaction Set for q3b ======
    [./r29_val]
        type = Reaction
        variable = r29
    [../]
    [./r29_rx]
      type = ArrheniusReaction
      variable = r29
      this_variable = r29

      forward_activation_energy = 58674.5
      forward_pre_exponential = 33445842

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3b O2w'
      reactant_stoich = '1 1'
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

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3b O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r31_val]
        type = Reaction
        variable = r31
    [../]
    [./r31_rx]
      type = ArrheniusReaction
      variable = r31
      this_variable = r31

      forward_activation_energy = 43962
      forward_pre_exponential = 5.01205E10

      reverse_activation_energy = 93653.9
      reverse_pre_exponential = 6.1464E11

      temperature = temp
      scale = 1.0
      reactants = 'S3b NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S3b NO2w'
      product_stoich = '1 1'
    [../]

    [./r32_val]
        type = Reaction
        variable = r32
    [../]
    [./r32_rx]
      type = ArrheniusReaction
      variable = r32
      this_variable = r32

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3b NOxw O2w'
      reactant_stoich = '1 1 1'
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

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3b NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r34_val]
        type = Reaction
        variable = r34
    [../]
    [./r34_rx]
      type = ArrheniusReaction
      variable = r34
      this_variable = r34

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3b NO2w O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r35_val]
        type = Reaction
        variable = r35
    [../]
    [./r35_rx]
      type = ArrheniusReaction
      variable = r35
      this_variable = r35

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3b NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r36_val]
        type = Reaction
        variable = r36
    [../]
    [./r36_rx]
      type = ArrheniusReaction
      variable = r36
      this_variable = r36

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3b NOxw NO2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= Start Reaction Set for q3c ======
    [./r37_val]
        type = Reaction
        variable = r37
    [../]
    [./r37_rx]
      type = ArrheniusReaction
      variable = r37
      this_variable = r37

      forward_activation_energy = 120116.6
      forward_pre_exponential = 1.55166E11

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3c O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r38_val]
        type = Reaction
        variable = r38
    [../]
    [./r38_rx]
      type = ArrheniusReaction
      variable = r38
      this_variable = r38

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3c O2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r39_val]
        type = Reaction
        variable = r39
    [../]
    [./r39_rx]
      type = ArrheniusReaction
      variable = r39
      this_variable = r39

      forward_activation_energy = 44670.9
      forward_pre_exponential = 3.22636E10

      reverse_activation_energy = 95712
      reverse_pre_exponential = 4.0929E11

      temperature = temp
      scale = 1.0
      reactants = 'S3c NOxw O2w'
      reactant_stoich = '1 1 1'
      products = 'S3c NO2w'
      product_stoich = '1 1'
    [../]

    [./r40_val]
        type = Reaction
        variable = r40
    [../]
    [./r40_rx]
      type = ArrheniusReaction
      variable = r40
      this_variable = r40

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3c NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r41_val]
        type = Reaction
        variable = r41
    [../]
    [./r41_rx]
      type = ArrheniusReaction
      variable = r41
      this_variable = r41

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3c NO2w'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r42_val]
        type = Reaction
        variable = r42
    [../]
    [./r42_rx]
      type = ArrheniusReaction
      variable = r42
      this_variable = r42

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3c NO2w O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r43_val]
        type = Reaction
        variable = r43
    [../]
    [./r43_rx]
      type = ArrheniusReaction
      variable = r43
      this_variable = r43

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3c NOxw O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r44_val]
        type = Reaction
        variable = r44
    [../]
    [./r44_rx]
      type = ArrheniusReaction
      variable = r44
      this_variable = r44

      forward_activation_energy = 0
      forward_pre_exponential = 0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3c NOxw NO2w'
      reactant_stoich = '1 1 1'
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
        input_times = '2.0917 29.59167'
        time_spans = '0.25 0.25'
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
        u_input = 0.00116278
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '0.001134258 0.001137267   0.001131913'
        input_times = '3.75   108.425    150'
        time_spans = '0.25  0.25  0.25'
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
        u_input = 1E-9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '6.9499E-6   1E-9   6.9499E-6  1E-9    6.9499E-6   1E-9'
        input_times = '2.0917   42.5917    55.425    88.5917    107.925   149.2583'
        time_spans = '0.25      0.25    0.25    0.25    0.25    0.25'
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
        u_input = 1E-9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '6.9239E-6   3.44803E-6   6.9239E-6'
        input_times = '42.5917    100.925    159.0917'
        time_spans = '0.25      0.25    0.25'
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
        u_input = 1E-9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '3.37554E-6   1E-9'
        input_times = '100.925    159.0917'
        time_spans = '0.25      0.25    0.25'
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
        u_input = 1E-9
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        input_vals = '1E-9'
        input_times = '1'
        time_spans = '0.25'
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

    [./q3a]
        type = ElementAverageValue
        variable = q3a
        execute_on = 'initial timestep_end'
    [../]

    [./q3b]
        type = ElementAverageValue
        variable = q3b
        execute_on = 'initial timestep_end'
    [../]

    [./q3c]
        type = ElementAverageValue
        variable = q3c
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
  end_time = 167.0
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
