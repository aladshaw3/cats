
[GlobalParams]
  # 'dg_scheme' and 'sigma' are parameters for the DG kernels
  dg_scheme = nipg
  sigma = 10
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
        initial_condition = 0.002126764
    [../]

    [./O2w]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.002126764
    [../]

    [./H2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.001074836
    [../]

    [./H2Ow]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.001074836
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
	      initial_condition = 0.05036
    [../]

    [./S2]
        order = FIRST
        family = MONOMIAL
	      initial_condition = 0.02518
    [../]

    [./S3]
        order = FIRST
        family = MONOMIAL
      	initial_condition = 0.009914
    [../]

[] #END Variables

[AuxVariables]

  #===========Update with Aging==============
  # Z1CuOH
  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.05036
  [../]

  # Z2Cu sites
  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.02518
  [../]

  # ZH sites
  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.009914
  [../]

  # CuO sites
  [./CuO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.33028E-12
  [../]
  #=====================================

  #=========Update with T run ==========
  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 523.15
  [../]
  #=====================================

  [./press]
      order = FIRST
      family = MONOMIAL
      initial_condition = 101.35
  [../]

  [./D]
    order = FIRST
    family = MONOMIAL
    #Autocalculated in AuxKernel
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

  # assume ew = 0.4
  [./micro_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.4
  [../]

  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  [./vel_y]
      order = FIRST
      family = MONOMIAL
      #cm/min (Autocalculated from space_velocity)
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
  [../]

  # area to volume ratio for monolith - auto calculated in properties
  [./Ga]
      order = FIRST
      family = MONOMIAL
  [../]

  # hydraulic diameter for monolith - auto calculated in properties
  [./dh]
      order = FIRST
      family = MONOMIAL
  [../]

  # effective thickness of microscale
  [./wt]
      order = FIRST
      family = MONOMIAL
  [../]

  # Mass transfer coefficient - auto calculated in properties
  [./km]
      order = FIRST
      family = MONOMIAL
  [../]


  # Inlet concentration conditions
  [./O2_percent]
      order = FIRST
      family = MONOMIAL
      initial_condition = 10
  [../]

  [./O2_inlet]
      order = FIRST
      family = MONOMIAL
  [../]

  [./H2O_percent]
      order = FIRST
      family = MONOMIAL
      initial_condition = 5
  [../]

  [./H2O_inlet]
      order = FIRST
      family = MONOMIAL
  [../]

  [./NH3_ppm]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1E-15
  [../]

  [./NH3_inlet]
      order = FIRST
      family = MONOMIAL
  [../]

  [./NOx_ppm]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1E-15
  [../]

  [./NOx_inlet]
      order = FIRST
      family = MONOMIAL
  [../]

  [./NO2_ppm]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1E-15
  [../]

  [./NO2_inlet]
      order = FIRST
      family = MONOMIAL
  [../]

  [./N2O_ppm]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1E-15
  [../]

  [./N2O_inlet]
      order = FIRST
      family = MONOMIAL
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
        type = FilmMassTransfer
        variable = O2
        coupled = O2w

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase O2 ===============
    [./O2w_dot]
        type = VariableCoefTimeDerivative
        variable = O2w
        coupled_coef = total_pore
    [../]
    [./O2_trans]
        type = FilmMassTransfer
        variable = O2w
        coupled = O2

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./O2w_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = O2w
        coupled_list = 'r5 r6
			r7 r8 r9
			r10 r11 r12
			r13 r14 r15 r16 r17
			r18 r19 r20
			r28 r29 r30
      r34 r35 r36
      r37 r38 r39'
        weights = '-0.5 -0.5
			-0.75 -0.75 -0.75
			-1.25 -1.25 -1.25
			-0.25 -0.25 -0.25 -0.25 -0.25
			-0.75 -0.75 -0.75
			0.25 0.25 0.25
      -0.75 -1.25 -1
      -1 -1 -1'
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
        type = FilmMassTransfer
        variable = H2O
        coupled = H2Ow

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase H2O ===============
    [./H2Ow_dot]
        type = VariableCoefTimeDerivative
        variable = H2Ow
        coupled_coef = total_pore
    [../]
    [./H2O_trans]
        type = FilmMassTransfer
        variable = H2Ow
        coupled = H2O

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
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
			r31 r32 r33
      r34 r35 r36
      r37 r38 r39'
        weights = '1.5 1.5 1.5
			1.5 1.5 1.5
			1.5 1.5 1.5 1.5 1.5
			1.5 1.5 1.5
			1 1 1 1
			2 2 2
			0.5 0.5 0.5
			2 2 2
      1.5 1.5 1.5
      1.5 1.5 1.5'
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
        type = FilmMassTransfer
        variable = NH3
        coupled = NH3w

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase NH3 ===============
    [./NH3w_dot]
        type = VariableCoefTimeDerivative
        variable = NH3w
        coupled_coef = total_pore
    [../]
    [./NH3_trans]
        type = FilmMassTransfer
        variable = NH3w
        coupled = NH3

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
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
        type = FilmMassTransfer
        variable = NOx
        coupled = NOxw

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase NO ===============
    [./NOxw_dot]
        type = VariableCoefTimeDerivative
        variable = NOxw
        coupled_coef = total_pore
    [../]
    [./NOx_trans]
        type = FilmMassTransfer
        variable = NOxw
        coupled = NOx

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./NOxw_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = NOxw
        coupled_list = 'r5 r6
			                 r10 r11 r12
			                 r13 r14 r15 r16 r17
			                    r18 r19 r20
			                       r25 r26 r27 r35'
        weights = '-1 -1
			             1 1 1
			                -1 -1 -1 -1 -1
			                   -1 -1 -1
			                      -1 -1 -1 1'
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
        type = FilmMassTransfer
        variable = NO2
        coupled = NO2w

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase NO2 ===============
    [./NO2w_dot]
        type = VariableCoefTimeDerivative
        variable = NO2w
        coupled_coef = total_pore
    [../]
    [./NO2_trans]
        type = FilmMassTransfer
        variable = NO2w
        coupled = NO2

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
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
        type = FilmMassTransfer
        variable = N2O
        coupled = N2Ow

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase N2O ===============
    [./N2Ow_dot]
        type = VariableCoefTimeDerivative
        variable = N2Ow
        coupled_coef = total_pore
    [../]
    [./N2O_trans]
        type = FilmMassTransfer
        variable = N2Ow
        coupled = N2O

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]
    [./N2Ow_rxns]
        type = ScaledWeightedCoupledSumFunction
        variable = N2Ow
        coupled_list = 'r18 r19 r20
			                 r31 r32 r33
                       r36 r37 r38 r39'
        weights = '1 1 1
			             1 1 1
                   0.5 0.5 0.5 0.5'
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
        coupled_list = 'r2a r2b r7 r8 r10 r11 r14 r15 r18 r19 r22 r23 r29 r37 r38'
        weights = '1 -1 -1 1 -1 1 -1 1 -1 1 -2 1 1 -1 1'
    [../]

    [./q2b_dot]
        type = TimeDerivative
        variable = q2b
    [../]
    [./q2b_rate]
        type = WeightedCoupledSumFunction
        variable = q2b
        coupled_list = 'r2b r8 r11 r15 r19 r23 r38'
        weights = '1 -1 -1 -1 -1 -2 -1'
    [../]

    [./q3_dot]
        type = TimeDerivative
        variable = q3
    [../]
    [./q3_rate]
        type = WeightedCoupledSumFunction
        variable = q3
        coupled_list = 'r3 r9 r12 r16 r17 r20 r24 r30 r34 r35 r36 r39'
        weights = '1 -1 -1 -1 -1 -1 -2 1 -1 -1 -1 -1'
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

      forward_activation_energy = 47276.5598305903

      forward_pre_exponential = 11695552804.8967


      reverse_activation_energy = 83661.4960321029

      reverse_pre_exponential = 15221221335.6318


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

      forward_activation_energy = 40292.573419771

      forward_pre_exponential = 1764591354.12529


      reverse_activation_energy = 66133.7226681343

      reverse_pre_exponential = 445004565.411014


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

      forward_activation_energy = 109893.989315212

      forward_pre_exponential = 201354205156.26


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

      forward_activation_energy = 105475.829659577

      forward_pre_exponential = 79258458661.5525


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

      forward_activation_energy = 92930.2488072898

      forward_pre_exponential = 4782418398.20257


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

      forward_activation_energy = 264372.573707305

      forward_pre_exponential = 3.00708980881736E+021


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

      forward_activation_energy = 266700.909300748

      forward_pre_exponential = 5.00241449799262E+021


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

      forward_activation_energy = 262542.766347393

      forward_pre_exponential = 1.73648545789896E+021


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

      forward_activation_energy = 64369.0048614155

      forward_pre_exponential = 215448914486920


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

      forward_activation_energy = 68458.0907606441

      forward_pre_exponential = 480755185877306


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

      forward_activation_energy = 62840.8727236646

      forward_pre_exponential = 193808453827601


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

      forward_activation_energy = 74710.7188194458

      forward_pre_exponential = 1.97353517884464E+016


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

      forward_activation_energy = 51733.2741199806

      forward_pre_exponential = 416908818419927


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

      forward_activation_energy = 68097.5857311348

      forward_pre_exponential = 9852117774702.59


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

      forward_activation_energy = 53348.7939925618

      forward_pre_exponential = 549134642312.816


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

      forward_activation_energy = 54973.4705433069

      forward_pre_exponential = 24297420482808.3


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

      forward_activation_energy = 83228.994598853

      forward_pre_exponential = 58400809824542.5


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

      forward_activation_energy = 46542.7502106114

      forward_pre_exponential = 38501064847.5296


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

      forward_activation_energy = 74745.5766840454

      forward_pre_exponential = 7679966294988.46


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

      forward_activation_energy = 69553.7552729703

      forward_pre_exponential = 4283214401806.32


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

      forward_activation_energy = 60385.1781512077

      forward_pre_exponential = 597998014891.891


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

      forward_activation_energy = 44273.3771645294

      forward_pre_exponential = 27926857213.1103


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

      forward_activation_energy = 35305.8877645772

      forward_pre_exponential = 3264125667.18016


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

      forward_activation_energy = 62274.7865478891

      forward_pre_exponential = 3981206299.57382


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

      forward_activation_energy = 88840.3360298979

      forward_pre_exponential = 782550038508.621


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

      forward_activation_energy = 58846.3092873565

      forward_pre_exponential = 2806352634.73924


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

      forward_activation_energy = 104921.673067076

      forward_pre_exponential = 2415062978427.7


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

      forward_activation_energy = 92225.1656854523

      forward_pre_exponential = 203829753246.798


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

      forward_activation_energy = 62323.1980005945

      forward_pre_exponential = 268058541.900285


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3_NH4NO3'
      reactant_stoich = '1'
      products = ''
      product_stoich = ''
    [../]

## ======= CuO Facilitated NH3 Oxidation ======
    [./r34_val]
        type = Reaction
        variable = r34
    [../]
    [./r34_rx]
      type = ArrheniusReaction
      variable = r34
      this_variable = r34

      forward_activation_energy = 333936.49

      forward_pre_exponential = 1.26594E+29


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 CuO O2w'
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

      forward_activation_energy = 155911.73

      forward_pre_exponential = 1.20378E+15


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 CuO O2w'
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

      forward_activation_energy = 172494.81

      forward_pre_exponential = 8.9329E+15


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 CuO O2w'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= N2O Formation from  NH3 Oxidation ======
    [./r37_val]
        type = Reaction
        variable = r37
    [../]
    [./r37_rx]
      type = ArrheniusReaction
      variable = r37
      this_variable = r37

      forward_activation_energy = 288305.85

      forward_pre_exponential = 6.62239E+21


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2a O2w'
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

      forward_activation_energy = 290624.89

      forward_pre_exponential = 1.04801E+22


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q2b O2w'
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

      forward_activation_energy = 285451.76

      forward_pre_exponential = 3.23131E+21


      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'q3 O2w'
      reactant_stoich = '1 1'
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

    [./Ga_calc]
        type = MonolithAreaVolumeRatio
        variable = Ga
        cell_density = 62   #cells/cm^2
        channel_vol_ratio = pore
        per_solids_volume = true
        execute_on = 'initial timestep_end'
    [../]

    [./dh_calc]
        type = MonolithHydraulicDiameter
        variable = dh
        cell_density = 62   #cells/cm^2
        channel_vol_ratio = pore
        execute_on = 'initial timestep_end'
    [../]

    [./wt_calc]
        type = MonolithMicroscaleTotalThickness
        variable = wt
        cell_density = 62   #cells/cm^2
        channel_vol_ratio = pore
        execute_on = 'initial timestep_end'
    [../]

    [./non_pore_calc]
        type = SolidsVolumeFraction
        variable = non_pore
        porosity = pore
        execute_on = 'initial timestep_end'
    [../]

    [./total_pore_calc]
        type = MicroscalePoreVolumePerTotalVolume
        variable = total_pore
        porosity = pore
        microscale_porosity = micro_pore
        execute_on = 'initial timestep_end'
    [../]

    [./km_calc]
        type = SimpleGasMonolithMassTransCoef
        variable = km

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.826
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./Disp_calc]
        type = SimpleGasDispersion
        variable = D

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore

        # NOTE: For this calculation, use bed diameter as char_length
        characteristic_length = 2
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.826
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]


    # ==== Setting the time variant inlet conditions ======
    [./O2_step_input]
        type = TemporalStepFunction
        variable = O2_percent

        start_value = 10
        aux_vals = '0.2 10'
        aux_times = '2.0917 30.0917'
        time_spans = '0.5 0.5'

        execute_on = 'initial timestep_begin nonlinear'
    [../]

    [./O2_convert_to_molar]
        type = SimpleGasVolumeFractionToConcentration
        variable = O2_inlet

        pressure = press
        pressure_unit = "kPa"
        temperature = temp

        volfrac = O2_percent

        output_volume_unit = "L"
        input_volfrac_unit = "%"

        execute_on = 'initial timestep_end'
    [../]

    [./H2O_step_input]
        type = TemporalStepFunction
        variable = H2O_percent

        start_value = 5
        aux_vals = '5'
        aux_times = '3'
        time_spans = '0.5'

        execute_on = 'initial timestep_begin nonlinear'
    [../]

    [./H2O_convert_to_molar]
        type = SimpleGasVolumeFractionToConcentration
        variable = H2O_inlet

        pressure = press
        pressure_unit = "kPa"
        temperature = temp

        volfrac = H2O_percent

        output_volume_unit = "L"
        input_volfrac_unit = "%"

        execute_on = 'initial timestep_end'
    [../]


    [./NH3_step_input]
        type = TemporalStepFunction
        variable = NH3_ppm

        start_value = 1E-15
        aux_vals = '300 1E-15 300 1E-15 300 1E-15'
        aux_times = '2.0917   42.425    54.5917    84.925    105.425   143.5917'
        time_spans = '0.5      0.5    0.5    0.5    0.5    0.5'

        execute_on = 'initial timestep_begin nonlinear'
    [../]

    [./NH3_convert_to_molar]
        type = SimpleGasVolumeFractionToConcentration
        variable = NH3_inlet

        pressure = press
        pressure_unit = "kPa"
        temperature = temp

        volfrac = NH3_ppm

        output_volume_unit = "L"
        input_volfrac_unit = "ppm"

        execute_on = 'initial timestep_end'
    [../]


    [./NO_step_input]
        type = TemporalStepFunction
        variable = NOx_ppm

        start_value = 1E-15
        aux_vals = '300 150 300'
        aux_times = '42.425    96.925    153.5917'
        time_spans = '0.5      0.5    0.5'

        execute_on = 'initial timestep_begin nonlinear'
    [../]

    [./NO_convert_to_molar]
        type = SimpleGasVolumeFractionToConcentration
        variable = NOx_inlet

        pressure = press
        pressure_unit = "kPa"
        temperature = temp

        volfrac = NOx_ppm

        output_volume_unit = "L"
        input_volfrac_unit = "ppm"

        execute_on = 'initial timestep_end'
    [../]


    [./NO2_step_input]
        type = TemporalStepFunction
        variable = NO2_ppm

        start_value = 1E-15
        aux_vals = '150 1E-15'
        aux_times = '96.925    153.5917'
        time_spans = '0.5      0.5'

        execute_on = 'initial timestep_begin nonlinear'
    [../]

    [./NO2_convert_to_molar]
        type = SimpleGasVolumeFractionToConcentration
        variable = NO2_inlet

        pressure = press
        pressure_unit = "kPa"
        temperature = temp

        volfrac = NO2_ppm

        output_volume_unit = "L"
        input_volfrac_unit = "ppm"

        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]

    # ============== O2 BCs ================
    [./O2_FluxIn]
        type = DGFlowMassFluxBC
        variable = O2
        boundary = 'bottom'
        input_var = O2_inlet
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./O2_FluxOut]
        type = DGFlowMassFluxBC
        variable = O2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== H2O BCs ================
    [./H2O_FluxIn]
        type = DGFlowMassFluxBC
        variable = H2O
        boundary = 'bottom'
        input_var = H2O_inlet
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2O_FluxOut]
        type = DGFlowMassFluxBC
        variable = H2O
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NH3 BCs ================
    [./NH3_FluxIn]
        type = DGFlowMassFluxBC
        variable = NH3
        boundary = 'bottom'
        input_var = NH3_inlet
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NH3_FluxOut]
        type = DGFlowMassFluxBC
        variable = NH3
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NO BCs ================
    [./NOx_FluxIn]
        type = DGFlowMassFluxBC
        variable = NOx
        boundary = 'bottom'
        input_var = NOx_inlet
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NOx_FluxOut]
        type = DGFlowMassFluxBC
        variable = NOx
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NO2 BCs ================
    [./NO2_FluxIn]
        type = DGFlowMassFluxBC
        variable = NO2
        boundary = 'bottom'
        input_var = NO2_inlet
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./NO2_FluxOut]
        type = DGFlowMassFluxBC
        variable = NO2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== N2O BCs ================
    [./N2O_FluxIn]
        type = DGFlowMassFluxBC
        variable = N2O
        boundary = 'bottom'
        input_var = 1E-15
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./N2O_FluxOut]
        type = DGFlowMassFluxBC
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
  line_search = l2
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = 0.0
  end_time = 161.0
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
