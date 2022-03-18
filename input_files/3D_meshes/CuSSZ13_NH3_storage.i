# ----------- NH3 storage at 150 oC -----------
#
#   Validation of Interface Transfer Kernels
#   ========================================
#
#   Results from this 3D simulation match our
#   1D-0D simulation case for volume averaged
#   washcoat mass transfer. This demonstrates
#   how you would create the equivalent case
#   for a full 3D simulation of the same model.

[GlobalParams]
  dg_scheme = nipg
  sigma = 10
[] #END GlobalParams


[Mesh]
    #FileMeshGenerator automatically assigns boundary names from the .msh file
    #.msh file MUST HAVE specific boundary names in it (use msh format 4.1)
    [./mesh_file]
        type = FileMeshGenerator
        file = Monolith_Composite_Updated.msh
    [../]
    #The above file contains the following boundary names
    #boundary_name = 'inlet outlet washcoat_walls interface wash_in wash_out'
    #block_name = 'washcoat channel'

    # 5cm length x 0.127 cm full channel dia
[]

[Variables]
  [./NH3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-15
      block = 'channel'
  [../]

  [./NH3w]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-15
      block = 'washcoat'
  [../]

  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001337966847917
      block = 'channel'
  [../]

  [./H2Ow]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001337966847917
      block = 'washcoat'
  [../]


  [./q1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'washcoat'
  [../]

  [./q2a]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'washcoat'
  [../]

  [./q2b]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'washcoat'
  [../]

  [./q3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'washcoat'
  [../]

  [./q4a]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'washcoat'
  [../]

  [./q4b]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'washcoat'
  [../]


  [./r1]
      order = FIRST
      family = MONOMIAL
      block = 'washcoat'
  [../]

  [./r2a]
      order = FIRST
      family = MONOMIAL
      block = 'washcoat'
  [../]

  [./r2b]
      order = FIRST
      family = MONOMIAL
      block = 'washcoat'
  [../]

  [./r3]
      order = FIRST
      family = MONOMIAL
      block = 'washcoat'
  [../]

  [./r4a]
      order = FIRST
      family = MONOMIAL
      block = 'washcoat'
  [../]

  [./r4b]
      order = FIRST
      family = MONOMIAL
      block = 'washcoat'
  [../]

   [./S1]
       order = FIRST
       family = MONOMIAL
       block = 'washcoat'
       initial_condition = 0.052619
   [../]

   [./S2]
       order = FIRST
       family = MONOMIAL
       block = 'washcoat'
       initial_condition = 0.0231257
   [../]

   [./S3]
       order = FIRST
       family = MONOMIAL
       block = 'washcoat'
       initial_condition = 0.026252
   [../]

  [./qT]
      order = FIRST
      family = MONOMIAL
      block = 'washcoat'
  [../]

  [./q2]
      order = FIRST
      family = MONOMIAL
      block = 'washcoat'
  [../]
[]

[AuxVariables]

  # Z1CuOH
  [./w1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.052619
      block = 'washcoat'
  [../]

  # Z2Cu sites
  [./w2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0231257
      block = 'washcoat'
  [../]

  # ZH sites
  [./w3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.026252
      block = 'washcoat'
  [../]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 423.15
  [../]

  [./D]
    order = FIRST
    family = MONOMIAL
    initial_condition = 2400.0  #Approximate dispersion
  [../]

  [./Dw]
    order = FIRST
    family = MONOMIAL
    initial_condition = 2400.0  #Approximate dispersion
  [../]

  # hydraulic diameter for monolith - auto calculated in properties
  [./dh]
      order = FIRST
      family = MONOMIAL
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

  [./micro_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.4
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

  # The rates of reactions are originally in moles per total volume per time
  #   but the washcoat mass balance is in moles per solids volume per time,
  #   thus, this acts as a conversion factor for the rates.
  [./non_pore_inverse]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.5  ## = 1/(1-eps_b) [volume solids / total volume]
  [../]

  # Mass transfer coefficient - auto calculated in properties
  [./km]
      order = FIRST
      family = MONOMIAL
  [../]

  # Area to volume ratio - auto calculated in properties
  #   Not used, but calculated for reference
  [./Ga]
      order = FIRST
      family = MONOMIAL
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
[]

[Kernels]
  # ======================== NH3 balance ======================
  #------------------- Channel -------------------
  [./NH3_dot]
      type = VariableCoefTimeDerivative
      variable = NH3
      coupled_coef = 1
      block = 'channel'
  [../]
  [./NH3_gadv]
      type = GPoreConcAdvection
      variable = NH3
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      block = 'channel'
  [../]
  [./NH3_gdiff]
      type = GVarPoreDiffusion
      variable = NH3
      porosity = 1
      Dx = D
      Dy = D
      Dz = D
      block = 'channel'
  [../]

  #------------------- Washcoat -------------------
  [./NH3w_dot]
      type = VariableCoefTimeDerivative
      variable = NH3w
      coupled_coef = micro_pore
      block = 'washcoat'
  [../]
  [./NH3w_gdiff]
      type = GVarPoreDiffusion
      variable = NH3w
      porosity = micro_pore
      Dx = Dw
      Dy = Dw
      Dz = Dw
      block = 'washcoat'
  [../]
  [./NH3w_rxns]
      type = ScaledWeightedCoupledSumFunction
      variable = NH3w
      coupled_list = 'r1 r2a r2b r3'
      weights = '-1 -1 -1 -1'
      scale = non_pore_inverse
  [../]

  # ======================== H2O balance ======================
  #------------------- Channel -------------------
  [./H2O_dot]
      type = VariableCoefTimeDerivative
      variable = H2O
      coupled_coef = 1
      block = 'channel'
  [../]
  [./H2O_gadv]
      type = GPoreConcAdvection
      variable = H2O
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      block = 'channel'
  [../]
  [./H2O_gdiff]
      type = GVarPoreDiffusion
      variable = H2O
      porosity = 1
      Dx = D
      Dy = D
      Dz = D
      block = 'channel'
  [../]

  #------------------- Washcoat -------------------
  [./H2Ow_dot]
      type = VariableCoefTimeDerivative
      variable = H2Ow
      coupled_coef = micro_pore
      block = 'washcoat'
  [../]
  [./H2Ow_gdiff]
      type = GVarPoreDiffusion
      variable = H2Ow
      porosity = micro_pore
      Dx = Dw
      Dy = Dw
      Dz = Dw
      block = 'washcoat'
  [../]
  [./H2Ow_rxns]
      type = ScaledWeightedCoupledSumFunction
      variable = H2Ow
      coupled_list = 'r4a r4b'
      weights = '-1 -1'
      scale = non_pore_inverse
  [../]

  # =========== Surface Balances ==================
  # ------------ Adsorption -------------
  [./q1_dot]
      type = TimeDerivative
      variable = q1
  [../]
  [./q1_rate]
      type = WeightedCoupledSumFunction
      variable = q1
      coupled_list = 'r1'
      weights = '1'
  [../]

  [./q2a_dot]
      type = TimeDerivative
      variable = q2a
  [../]
  [./q2a_rate]
      type = WeightedCoupledSumFunction
      variable = q2a
      coupled_list = 'r2a r2b'
      weights = '1 -1'
  [../]

  [./q2b_dot]
      type = TimeDerivative
      variable = q2b
  [../]
  [./q2b_rate]
      type = WeightedCoupledSumFunction
      variable = q2b
      coupled_list = 'r2b'
      weights = '1'
  [../]

  [./q3_dot]
      type = TimeDerivative
      variable = q3
  [../]
  [./q3_rate]
      type = WeightedCoupledSumFunction
      variable = q3
      coupled_list = 'r3'
      weights = '1'
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
      coupled_list = 'q1 q2a q2b q3'
      weights = '1 1 2 1'
      total_material = qT
  [../]

  [./q2_calc]
      type = MaterialBalance
      variable = q2
      this_variable = q2
      coupled_list = 'q2a q2b'
      weights = '1 2'
      total_material = q2
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

  [./S3_bal]
      type = MaterialBalance
      variable = S3
      this_variable = S3
      coupled_list = 'q3 S3'
      weights = '1 1'
      total_material = w3
  [../]


  # ================= Reaction Constraints ===============
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

[]


[DGKernels]

    [./NH3_dgadv]
        type = DGPoreConcAdvection
        variable = NH3
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 'channel'
    [../]
    [./NH3_dgdiff]
        type = DGVarPoreDiffusion
        variable = NH3
        porosity = 1
        Dx = D
        Dy = D
        Dz = D
        block = 'channel'
    [../]

    [./NH3w_dgdiff]
        type = DGVarPoreDiffusion
        variable = NH3w
        porosity = micro_pore
        Dx = Dw
        Dy = Dw
        Dz = Dw
        block = 'washcoat'
    [../]


    [./H2O_dgadv]
        type = DGPoreConcAdvection
        variable = H2O
        porosity = 1
        ux = vel_x
        uy = vel_y
        uz = vel_z
        block = 'channel'
    [../]
    [./H2O_dgdiff]
        type = DGVarPoreDiffusion
        variable = H2O
        porosity = 1
        Dx = D
        Dy = D
        Dz = D
        block = 'channel'
    [../]

    [./H2Ow_dgdiff]
        type = DGVarPoreDiffusion
        variable = H2Ow
        porosity = micro_pore
        Dx = Dw
        Dy = Dw
        Dz = Dw
        block = 'washcoat'
    [../]

[] #END DGKernels

[InterfaceKernels]
   [./NH3_interface_kernel]
       type = InterfaceMassTransfer
       variable = NH3         #variable must be the variable in the master block
       neighbor_var = NH3w    #neighbor_var must the the variable in the paired block
       boundary = 'interface'
       transfer_rate = km
       area_frac = 1
   [../]

   [./H2O_interface_kernel]
       type = InterfaceMassTransfer
       variable = H2O         #variable must be the variable in the master block
       neighbor_var = H2Ow    #neighbor_var must the the variable in the paired block
       boundary = 'interface'
       transfer_rate = km
       area_frac = 1
   [../]
[] #END InterfaceKernels

[AuxKernels]

    # Simple velocity calculation based on space_velocity
    [./velocity]
        type = GasVelocityCylindricalReactor
        variable = vel_y
        porosity = pore
        space_velocity = 500   #volumes per min
        inlet_temperature = temp
        ref_pressure = 101.35
        ref_temperature = 273.15
        radius = 1  #cm
        length = 5  #cm
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

    [./dh_calc]
        type = MonolithHydraulicDiameter
        variable = dh
        cell_density = 62   #cells/cm^2
        channel_vol_ratio = pore
        execute_on = 'initial timestep_end'
    [../]

    [./Ga_calc]
        type = MonolithAreaVolumeRatio
        variable = Ga
        cell_density = 62   #cells/cm^2
        channel_vol_ratio = pore
        per_solids_volume = false
        execute_on = 'initial timestep_end'
    [../]

    [./km_calc]
        type = SimpleGasMonolithMassTransCoef
        variable = km

        pressure = 101.35
        temperature = temp
        micro_porosity = micro_pore
        effective_diffusivity_factor = 1
        macro_porosity = 1
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.561
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

        pressure = 101.35
        temperature = temp
        micro_porosity = 1
        macro_porosity = 1

        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./Dw_calc]
        type = SimpleGasPoreDiffusivity
        variable = Dw

        pressure = 101.35
        temperature = temp
        micro_porosity = 1
        effective_diffusivity_factor = 1
        macro_porosity = 1

        # NOTE: For this calculation, use bed diameter as char_length
        characteristic_length = dh
        char_length_unit = "cm"

        velocity = vel_y
        vel_length_unit = "cm"
        vel_time_unit = "min"

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]


    [./temp_increase]
        type = LinearChangeInTime
        variable = temp
        start_time = 225.425
        end_time = 305.3
        end_value = 809.5651714
        execute_on = 'initial timestep_end'
    [../]


[] #END AuxKernels


[BCs]

    [./NH3_FluxIn]
      type = DGPoreConcFluxStepwiseBC
      variable = NH3
      boundary = 'inlet'
      u_input = 1E-15
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_vals = '2.88105E-05    2.28698E-05    1.70674E-05    1.13344E-05    5.76691E-06    2.87521E-06    1.43838E-06    7.21421E-07    3.67254E-07    3.81105E-09'
      input_times = '2.09166667    15.925    24.425    32.7583333    42.425    55.0916667    77.0916667    109.091667    154.925    225.425'
      time_spans = '0.25    0.25    0.25    0.25    0.25    0.25    0.25    0.25    0.25    0.25'
    [../]
    [./NH3_FluxOut]
      type = DGPoreConcFluxBC
      variable = NH3
      boundary = 'outlet'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
    [../]

    [./H2O_FluxIn]
        type = DGConcentrationFluxBC
        variable = H2O
        boundary = 'inlet'
    		u_input = 0.001337966847917
    		ux = vel_x
    		uy = vel_y
    		uz = vel_z
    [../]

    [./H2O_FluxOut]
        type = DGConcentrationFluxBC
        variable = H2O
        boundary = 'outlet'
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

[] #END BCs


[Postprocessors]

    [./NH3_out]
        type = SideAverageValue
        boundary = 'outlet'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./NH3_bypass]
        type = SideAverageValue
        boundary = 'inlet'
        variable = NH3
        execute_on = 'initial timestep_end'
    [../]

    [./Z1CuOH]
        type = ElementAverageValue
        variable = q1
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]

    [./Z2Cu]
        type = ElementAverageValue
        variable = q2
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]

    [./ZH]
        type = ElementAverageValue
        variable = q3
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]

    [./total]
        type = ElementAverageValue
        variable = qT
        block = 'washcoat'
        execute_on = 'initial timestep_end'
    [../]

    [./temp_avg]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    # Use this to check and make sure the eps value is accurate
    [./zArea_channel]
        type = AreaPostprocessor
        boundary = 'inlet'
        execute_on = 'initial timestep_end'
    [../]

    [./zArea_washcoat]
        type = AreaPostprocessor
        boundary = 'wash_in'
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
  scheme = bdf2
  petsc_options = '-snes_converged_reason'
  petsc_options_iname ='-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type -pc_asm_overlap -snes_atol -snes_rtol'
  petsc_options_value = 'gmres lu ilu 100 NONZERO 2 1E-14 1E-12'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = -1.0
  end_time = 310.0
  dtmax = 1

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
