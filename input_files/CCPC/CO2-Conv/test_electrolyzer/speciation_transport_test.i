# Test the speciation and transport equations.

[GlobalParams]
    min_conductivity = 2.26E-3
[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator


    #file = 2D_Electrolyzer_mm.msh    #coarse mesh

    file = 2D_Electrolyzer_mm_split.msh     #fine mesh

    ### ========= boundary_name ==========
    # "cathode_fluid_channel_left"
    # "cathode_fluid_channel_bottom"
    # "cathode_fluid_channel_top"
    # "cathode_fluid_channel_interface_cathode"
    # "cathode_bottom"
    # "cathode_top"
    # "cathode_interface_membrane"
    # "membrane_bottom"
    # "membrane_top"
    # "membrane_interface_anode"
    # "anode_bottom"
    # "anode_top"
    # "anode_interface_anode_fluid_channel"
    # "anode_fluid_channel_bottom"
    # "anode_fluid_channel_top"
    # "anode_fluid_channel_right"

    ### ====== block ========
    # "cathode_fluid_channel"
    # "cathode"
    # "membrane"
    # "anode"
    # "anode_fluid_channel"
  []

[] # END Mesh

[Variables]
  # electrolyte potential (in V or J/C)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      scaling = 1
  [../]

  # electrode potential (in V or J/C)
  [./phi_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      block = 'cathode anode'
      scaling = 1
  [../]

  # Variable for potential difference
  [./phi_diff]
      order = FIRST
      family = LAGRANGE
      block = 'cathode anode'
      [./InitialCondition]
          type = InitialPotentialDifference
          electrode_potential = phi_s
          electrolyte_potential = phi_e
      [../]
      scaling = 1
  [../]

  # relative pressure (units = g/mm/s^2 == Pa)
  [./pressure]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
  [../]

  # velocity in x
  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0
  [../]

  # velocity in y
  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 40.0
  [../]

  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.2E-6 #mol/mm^3
      scaling = 1e6
  [../]

  # Ions/species
  #   NOTE: Good Initial Conditions are VERY IMPORTANT for convergence
  [./H]
      order = FIRST
      family = MONOMIAL
      scaling = 1e10
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
  [../]
  [./H2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/mm^3
      scaling = 1e7
      block = 'cathode_fluid_channel cathode'
  [../]
  [./O2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/mm^3
      scaling = 1e7
      block = 'anode anode_fluid_channel'
  [../]
  [./Na]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1E-7 # 1E-7 # mol/mm^3
      scaling = 1e7
      block = 'cathode_fluid_channel cathode'
  [../]
  [./OH]
      order = FIRST
      family = MONOMIAL
      scaling = 1e10
      block = 'cathode_fluid_channel cathode membrane anode anode_fluid_channel'
  [../]
  [./HCO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 9.8E-8 # 9.8E-8 # mol/mm^3
      scaling = 1e9
      block = 'cathode_fluid_channel cathode'
  [../]
  [./CO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 9.9E-10 # 9.9E-10 # mol/mm^3
      scaling = 1e9
      block = 'cathode_fluid_channel cathode'
  [../]
  [./CO2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1E-9 # 1E-9 # mol/mm^3
      scaling = 1e8
      block = 'cathode_fluid_channel cathode'
  [../]
  [./CO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # mol/cm^3
      scaling = 1e8
      block = 'cathode_fluid_channel cathode'
  [../]


  # activities
  [./a_H]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = H
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
      scaling = 1e2
  [../]
  [./a_H2]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = H2
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1e2
  [../]
  [./a_O2]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = O2
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
      block = 'anode anode_fluid_channel'
      scaling = 1e2
  [../]
  [./a_Na]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = Na
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1e2
  [../]
  [./a_OH]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = OH
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
      scaling = 1e2
  [../]
  [./a_HCO3]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = HCO3
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1e2
  [../]
  [./a_CO3]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = CO3
          activity_coeff = gamma2
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1e2
  [../]
  [./a_CO2]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = CO2
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1e2
  [../]
  [./a_CO]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = CO
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1e2
  [../]


  # Speciation reaction rates
  # rate of water reaction
  # 1/min ==> convert to mol/mm^3/s via scale = C_ref
  [./r_w]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      scaling = 1e2
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
  [../]

  # rate of CO2 -> HCO3 reaction
  # 1/min ==> convert to mol/mm^3/s via scale = C_ref
  [./r_1]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      scaling = 1e2
      block = 'cathode_fluid_channel cathode'
  [../]

  # rate of HCO3 -> CO3 reaction
  # 1/min ==> convert to mol/mm^3/s via scale = C_ref
  [./r_2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      scaling = 1e2
      block = 'cathode_fluid_channel cathode'
  [../]

  # rate of alt CO2 -> HCO3 reaction
  # 1/min ==> convert to mol/mm^3/s via scale = C_ref
  [./r_3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      scaling = 1e2
      block = 'cathode_fluid_channel cathode'
  [../]

  # rate of alt HCO3 -> CO3 reaction
  # 1/min ==> convert to mol/mm^3/s via scale = C_ref
  [./r_4]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      scaling = 1e2
      block = 'cathode_fluid_channel cathode'
  [../]
[]

[ICs]
  [./H_cat]
      type = ConstantIC
      variable = H
      value = 4.5E-15 # 4.5E-15
      block = 'cathode_fluid_channel cathode'
  [../]
  [./H_an]
      type = ConstantIC
      variable = H
      value = 1E-13
      block = 'anode anode_fluid_channel'
  [../]

  [./OH_cat]
      type = ConstantIC
      variable = OH
      value = 2.1E-12 # 2.1E-12
      block = 'cathode_fluid_channel cathode membrane'
  [../]
  [./OH_an]
      type = ConstantIC
      variable = OH
      value = 1E-13
      block = 'anode anode_fluid_channel'
  [../]

  [./ion_str_cat]
      type = InitialIonicStrength
      variable = ion_str
      conversion_factor = 1E6 # mm^3/L
      ion_conc = 'H OH HCO3 CO3 Na'
      ion_valence = '1 1 1 2 1'
      block = 'cathode_fluid_channel cathode'
  [../]
  [./ion_str_an]
      type = InitialIonicStrength
      variable = ion_str
      conversion_factor = 1E6 # mm^3/L
      ion_conc = 'H OH'
      ion_valence = '1 1'
      block = 'anode anode_fluid_channel'
  [../]

[]

[AuxVariables]
  # velocity in z
  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0
  [../]

  # velocity magnitude
  #   NOTE: We MUST set an initial condition here because the
  #         DarcyWeisbachCoefficient requires a non-zero velocity
  #         magnitude in order to estimate the pressure drop.
  [./vel_mag]
      order = FIRST
      family = MONOMIAL
      initial_condition = 40.0  #mm^2/s based on inlet condition
  [../]

  [./D_H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0017  #mm^2/s
  [../]

  # Diffusivities
  [./D_H]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00695 #mm^2/s
  [../]
  [./D_H2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00695 #mm^2/s
  [../]
  [./D_O2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00695 #mm^2/s
  [../]
  [./D_Na]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00217 #mm^2/s
  [../]
  [./D_OH]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00493 #mm^2/s
  [../]
  [./D_HCO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0011 #mm^2/s
  [../]
  [./D_CO3]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0008017 #mm^2/s
  [../]
  [./D_CO2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00191 #mm^2/s
  [../]
  # ---------- below are all assumed ----------
  [./D_CO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.00191 #mm^2/s
  [../]

  [./eps]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.80
  [../]

  [./sol_vol_frac]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.20
  [../]

  [./density]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001 # g/mm^3
  [../]
  [./viscosity]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001 # Pa*s = kg/m/s = g/mm/s
  [../]

  # coefficient for all domains
  [./press_coef]
      order = FIRST
      family = MONOMIAL
  [../]

  # Electrolyte temperature
  [./T_e]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300 #K
  [../]

  # Electrode temperature
  [./T_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300 #K
  [../]

  # Solids avg conductivity
  [./sigma_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.476E4 #C/V/s/mm == 1.476E7 S/m
      block = 'cathode anode'
  [../]

  # Electrode avg conductivity
  #       ~2.26 S/M (for 0.1 M ionic strength)
  #       ~10.7 S/M (for 0.5 M ionic strength)
  #       ~20.1 S/M (for 1.0 M ionic strength)
  #       ~35.2 S/M (for 2.0 M ionic strength)
  [./sigma_e]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.26E-3 #C/V/s/mm == 2.26 S/m (for 0.1 M solution)
  [../]


  # reference conc
  [./C_ref]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-6 # mol/cm^3
  [../]

  # ideal activity coeff
  [./gamma0]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialDaviesActivityCoeff
          temperature = 298
          ionic_strength = ion_str
          ion_valence = 0
      [../]
  [../]
  [./gamma1]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialDaviesActivityCoeff
          temperature = 298
          ionic_strength = ion_str
          ion_valence = 1
      [../]
  [../]
  [./gamma2]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialDaviesActivityCoeff
          temperature = 298
          ionic_strength = ion_str
          ion_valence = 2
      [../]
  [../]


  # ionic strength (in M)
  [./ion_str]
      order = FIRST
      family = MONOMIAL
  [../]
[]

[Kernels]
  ## =============== Potential Difference ==================
  [./phi_diff_equ]
      type = Reaction
      variable = phi_diff
  [../]
  [./phi_diff_sum]
      type = WeightedCoupledSumFunction
      variable = phi_diff
      coupled_list = 'phi_s phi_e'
      weights = '1 -1'
  [../]

  ### ==================== Electrolyte Potentials ==========================
  # Calculate potential from gradients in system
  [./phi_e_potential_conductivity]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = ''
      diffusion = ''
      ion_valence = ''
  [../]
  [./phi_e_J]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = '0'
      weights = '1'
      block = 'cathode anode'
  [../]

  ### ==================== Electrode Potentials ==========================
  # Calculate potential from conductivity
  [./phi_s_pot_cond]
      type = ElectrodePotentialConductivity
      variable = phi_s
      solid_frac = sol_vol_frac
      conductivity = sigma_s
      block = 'cathode anode'
  [../]
  [./phi_s_J]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_s
      coupled_list = '0'
      weights = '-1'
      block = 'cathode anode'
  [../]

  ## =============== Pressure ========================
  [./pressure_laplace_channels]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]
  [./pressure_laplace_darcy]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'cathode anode'
  [../]
  [./pressure_laplace_mem]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = press_coef
      block = 'membrane'
  [../]

  ## =================== vel in x ==========================
  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./x_channel]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]
  [./x_darcy]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'cathode anode'
  [../]
  [./x_mem]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = press_coef
      block = 'membrane'
  [../]

  ## ================== vel in y =========================
  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]
  [./y_channel]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]
  [./y_darcy]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'cathode anode'
  [../]
  [./y_mem]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = press_coef
      block = 'membrane'
  [../]

  ## ===================== H2O balance ====================
  [./H2O_dot]
      type = VariableCoefTimeDerivative
      variable = H2O
      coupled_coef = eps
  [../]
  [./H2O_gadv]
      type = GPoreConcAdvection
      variable = H2O
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H2O_gdiff]
      type = GVarPoreDiffusion
      variable = H2O
      porosity = eps
      Dx = D_H2O
      Dy = D_H2O
      Dz = D_H2O
  [../]


  ## ===================== H balance ====================
  [./H_dot]
      type = VariableCoefTimeDerivative
      variable = H
      coupled_coef = eps
  [../]
  [./H_gadv]
      type = GPoreConcAdvection
      variable = H
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H_gdiff]
      type = GVarPoreDiffusion
      variable = H
      porosity = eps
      Dx = D_H
      Dy = D_H
      Dz = D_H
  [../]

  [./H_rate_all]
      type = ScaledWeightedCoupledSumFunction
      variable = H
      coupled_list = 'r_w'
      weights = '1'
      scale = eps
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
  [../]
  [./H_rate_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = H
      coupled_list = 'r_1 r_2'
      weights = '1 1'
      scale = eps
      block = 'cathode_fluid_channel cathode'
  [../]

  ## ===================== H2 balance ====================
  [./H2_dot]
      type = VariableCoefTimeDerivative
      variable = H2
      coupled_coef = eps
  [../]
  [./H2_gadv]
      type = GPoreConcAdvection
      variable = H2
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H2_gdiff]
      type = GVarPoreDiffusion
      variable = H2
      porosity = eps
      Dx = D_H2
      Dy = D_H2
      Dz = D_H2
  [../]

  ## ===================== O2 balance ====================
  [./O2_dot]
      type = VariableCoefTimeDerivative
      variable = O2
      coupled_coef = eps
  [../]
  [./O2_gadv]
      type = GPoreConcAdvection
      variable = O2
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./O2_gdiff]
      type = GVarPoreDiffusion
      variable = O2
      porosity = eps
      Dx = D_O2
      Dy = D_O2
      Dz = D_O2
  [../]


  ## ===================== Na balance ====================
  [./Na_dot]
      type = VariableCoefTimeDerivative
      variable = Na
      coupled_coef = eps
  [../]
  [./Na_gadv]
      type = GPoreConcAdvection
      variable = Na
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./Na_gdiff]
      type = GVarPoreDiffusion
      variable = Na
      porosity = eps
      Dx = D_Na
      Dy = D_Na
      Dz = D_Na
  [../]


  ## ===================== OH balance ====================
  [./OH_dot]
      type = VariableCoefTimeDerivative
      variable = OH
      coupled_coef = eps
  [../]
  [./OH_gadv]
      type = GPoreConcAdvection
      variable = OH
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./OH_gdiff]
      type = GVarPoreDiffusion
      variable = OH
      porosity = eps
      Dx = D_OH
      Dy = D_OH
      Dz = D_OH
  [../]

  [./OH_rate_all]
      type = ScaledWeightedCoupledSumFunction
      variable = OH
      coupled_list = 'r_w'
      weights = '1'
      scale = eps
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
  [../]
  [./OH_rate_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = OH
      coupled_list = 'r_3 r_4'
      weights = '-1 -1'
      scale = eps
      block = 'cathode_fluid_channel cathode'
  [../]


  ## ===================== HCO3 balance ====================
  [./HCO3_dot]
      type = VariableCoefTimeDerivative
      variable = HCO3
      coupled_coef = eps
  [../]
  [./HCO3_gadv]
      type = GPoreConcAdvection
      variable = HCO3
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./HCO3_gdiff]
      type = GVarPoreDiffusion
      variable = HCO3
      porosity = eps
      Dx = D_HCO3
      Dy = D_HCO3
      Dz = D_HCO3
  [../]

  [./HCO3_rate_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = HCO3
      coupled_list = 'r_1 r_2 r_3 r_4'
      weights = '1 -1 1 -1'
      scale = eps
      block = 'cathode_fluid_channel cathode'
  [../]


  ## ===================== CO3 balance ====================
  [./CO3_dot]
      type = VariableCoefTimeDerivative
      variable = CO3
      coupled_coef = eps
  [../]
  [./CO3_gadv]
      type = GPoreConcAdvection
      variable = CO3
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./CO3_gdiff]
      type = GVarPoreDiffusion
      variable = CO3
      porosity = eps
      Dx = D_CO3
      Dy = D_CO3
      Dz = D_CO3
  [../]

  [./CO3_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = CO3
      coupled_list = 'r_2 r_4'
      weights = '1 1'
      scale = eps
      block = 'cathode_fluid_channel cathode'
  [../]


  ## ===================== CO2 balance ====================
  [./CO2_dot]
      type = VariableCoefTimeDerivative
      variable = CO2
      coupled_coef = eps
  [../]
  [./CO2_gadv]
      type = GPoreConcAdvection
      variable = CO2
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./CO2_gdiff]
      type = GVarPoreDiffusion
      variable = CO2
      porosity = eps
      Dx = D_CO2
      Dy = D_CO2
      Dz = D_CO2
  [../]

  [./CO2_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = CO2
      coupled_list = 'r_1 r_3'
      weights = '-1 -1'
      scale = eps
      block = 'cathode_fluid_channel cathode'
  [../]


  ## ===================== CO balance ====================
  [./CO_dot]
      type = VariableCoefTimeDerivative
      variable = CO
      coupled_coef = eps
  [../]
  [./CO_gadv]
      type = GPoreConcAdvection
      variable = CO
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./CO_gdiff]
      type = GVarPoreDiffusion
      variable = CO
      porosity = eps
      Dx = D_CO
      Dy = D_CO
      Dz = D_CO
  [../]


  ## =============== H+ activity constraint ================
  [./a_H_equ]
      type = Reaction
      variable = a_H
  [../]
  [./a_H_cons]
      type = ActivityConstraint
      variable = a_H
      concentration = H
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== OH- activity constraint ================
  [./a_OH_equ]
      type = Reaction
      variable = a_OH
  [../]
  [./a_OH_cons]
      type = ActivityConstraint
      variable = a_OH
      concentration = OH
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== CO2 activity constraint ================
  [./a_CO2_equ]
      type = Reaction
      variable = a_CO2
  [../]
  [./a_CO2_cons]
      type = ActivityConstraint
      variable = a_CO2
      concentration = CO2
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== HCO3 activity constraint ================
  [./a_HCO3_equ]
      type = Reaction
      variable = a_HCO3
  [../]
  [./a_HCO3_cons]
      type = ActivityConstraint
      variable = a_HCO3
      concentration = HCO3
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== CO3 activity constraint ================
  [./a_CO3_equ]
      type = Reaction
      variable = a_CO3
  [../]
  [./a_CO3_cons]
      type = ActivityConstraint
      variable = a_CO3
      concentration = CO3
      activity_coeff = gamma2
      ref_conc = C_ref
  [../]

  ## =============== Na+ activity constraint ================
  [./a_Na_equ]
      type = Reaction
      variable = a_Na
  [../]
  [./a_Na_cons]
      type = ActivityConstraint
      variable = a_Na
      concentration = Na
      activity_coeff = gamma1
      ref_conc = C_ref
  [../]

  ## =============== H2 activity constraint ================
  [./a_H2_equ]
      type = Reaction
      variable = a_H2
  [../]
  [./a_H2_cons]
      type = ActivityConstraint
      variable = a_H2
      concentration = H2
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== O2 activity constraint ================
  [./a_O2_equ]
      type = Reaction
      variable = a_O2
  [../]
  [./a_O2_cons]
      type = ActivityConstraint
      variable = a_O2
      concentration = O2
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]

  ## =============== CO activity constraint ================
  [./a_CO_equ]
      type = Reaction
      variable = a_CO
  [../]
  [./a_CO_cons]
      type = ActivityConstraint
      variable = a_CO
      concentration = CO
      activity_coeff = gamma0
      ref_conc = C_ref
  [../]


  ## =============== water reaction ================
  [./r_w_equ]
      type = Reaction
      variable = r_w
  [../]
  [./r_w_rxn]  #   H2O <--> H+ + OH-
      type = ConstReaction
      variable = r_w
      this_variable = r_w

      forward_rate = 0.0016
      reverse_rate = 1.6E11

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1e-6 # mol/mm^3

      reactants = '1'
      reactant_stoich = '1'
      products = 'a_H a_OH'
      product_stoich = '1 1'
  [../]

  ## =============== r1 reaction ================
  [./r_1_equ]
      type = Reaction
      variable = r_1
  [../]
  [./r_1_rxn]  #   CO2 + H2O <--> H+ + HCO3-
      type = ConstReaction
      variable = r_1
      this_variable = r_1

      forward_rate = 0.04
      reverse_rate = 93683.3333

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1e-6 # mol/mm^3

      reactants = 'a_CO2'
      reactant_stoich = '1'
      products = 'a_H a_HCO3'
      product_stoich = '1 1'
  [../]

  ## =============== r2 reaction ================
  [./r_2_equ]
      type = Reaction
      variable = r_2
  [../]
  [./r_2_rxn]  #   HCO3- <--> H+ + CO3--
      type = ConstReaction
      variable = r_2
      this_variable = r_2

      forward_rate = 56.28333
      reverse_rate = 1.2288E12

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1e-6 # mol/mm^3

      reactants = 'a_HCO3'
      reactant_stoich = '1'
      products = 'a_H a_CO3'
      product_stoich = '1 1'
  [../]

  ## =============== r3 reaction ================
  [./r_3_equ]
      type = Reaction
      variable = r_3
  [../]
  [./r_3_rxn]  #   CO2 + OH- <--> HCO3-
      type = ConstReaction
      variable = r_3
      this_variable = r_3

      forward_rate = 2100
      reverse_rate = 4.918333E-5

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1e-6 # mol/mm^3

      reactants = 'a_CO2 a_OH'
      reactant_stoich = '1 1'
      products = 'a_HCO3'
      product_stoich = '1'
  [../]

  ## =============== r4 reaction ================
  [./r_4_equ]
      type = Reaction
      variable = r_4
  [../]
  [./r_4_rxn]  #   HCO3- + OH- <--> CO3-- + H2O
      type = ConstReaction
      variable = r_4
      this_variable = r_4

      forward_rate = 6.5E9
      reverse_rate = 1.337E6

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1e-6 # mol/mm^3

      reactants = 'a_HCO3 a_OH'
      reactant_stoich = '1 1'
      products = 'a_CO3'
      product_stoich = '1'
  [../]

[]

[DGKernels]
  ## ===================== H2O balance ====================
  [./H2O_dgadv]
      type = DGPoreConcAdvection
      variable = H2O
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H2O_dgdiff]
      type = DGVarPoreDiffusion
      variable = H2O
      porosity = eps
      Dx = D_H2O
      Dy = D_H2O
      Dz = D_H2O
  [../]


  ## ===================== H balance ====================
  [./H_dgadv]
      type = DGPoreConcAdvection
      variable = H
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H_dgdiff]
      type = DGVarPoreDiffusion
      variable = H
      porosity = eps
      Dx = D_H
      Dy = D_H
      Dz = D_H
  [../]

  ## ===================== H2 balance ====================
  [./H2_dgadv]
      type = DGPoreConcAdvection
      variable = H2
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./H2_dgdiff]
      type = DGVarPoreDiffusion
      variable = H2
      porosity = eps
      Dx = D_H2
      Dy = D_H2
      Dz = D_H2
  [../]

  ## ===================== O2 balance ====================
  [./O2_dgadv]
      type = DGPoreConcAdvection
      variable = O2
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./O2_dgdiff]
      type = DGVarPoreDiffusion
      variable = O2
      porosity = eps
      Dx = D_O2
      Dy = D_O2
      Dz = D_O2
  [../]


  ## ===================== Na balance ====================
  [./Na_dgadv]
      type = DGPoreConcAdvection
      variable = Na
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./Na_dgdiff]
      type = DGVarPoreDiffusion
      variable = Na
      porosity = eps
      Dx = D_Na
      Dy = D_Na
      Dz = D_Na
  [../]


  ## ===================== OH balance ====================
  [./OH_dgadv]
      type = DGPoreConcAdvection
      variable = OH
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./OH_dgdiff]
      type = DGVarPoreDiffusion
      variable = OH
      porosity = eps
      Dx = D_OH
      Dy = D_OH
      Dz = D_OH
  [../]


  ## ===================== HCO3 balance ====================
  [./HCO3_dgadv]
      type = DGPoreConcAdvection
      variable = HCO3
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./HCO3_dgdiff]
      type = DGVarPoreDiffusion
      variable = HCO3
      porosity = eps
      Dx = D_HCO3
      Dy = D_HCO3
      Dz = D_HCO3
  [../]


  ## ===================== CO3 balance ====================
  [./CO3_dgadv]
      type = DGPoreConcAdvection
      variable = CO3
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./CO3_dgdiff]
      type = DGVarPoreDiffusion
      variable = CO3
      porosity = eps
      Dx = D_CO3
      Dy = D_CO3
      Dz = D_CO3
  [../]


  ## ===================== CO2 balance ====================
  [./CO2_dgadv]
      type = DGPoreConcAdvection
      variable = CO2
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./CO2_dgdiff]
      type = DGVarPoreDiffusion
      variable = CO2
      porosity = eps
      Dx = D_CO2
      Dy = D_CO2
      Dz = D_CO2
  [../]


  ## ===================== CO balance ====================
  [./CO_dgadv]
      type = DGPoreConcAdvection
      variable = CO
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./CO_dgdiff]
      type = DGVarPoreDiffusion
      variable = CO
      porosity = eps
      Dx = D_CO
      Dy = D_CO
      Dz = D_CO
  [../]
[]

[InterfaceKernels]
[] #END InterfaceKernels

[AuxKernels]
  [./vel_calc]
      type = VectorMagnitude
      variable = vel_mag
      ux = vel_x
      uy = vel_y
      uz = vel_z
      execute_on = 'timestep_end'
  [../]

  [./eps_calc_one]
      type = ConstantAux
      variable = eps
      value = 0.999

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel membrane anode_fluid_channel'
  [../]
  [./eps_calc_two]
      type = ConstantAux
      variable = eps
      value = 0.80

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_H2O_calc_channels]
      type = SimpleFluidDispersion
      variable = D_H2O
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_H2O_calc_elec]
      type = SimpleFluidDispersion
      variable = D_H2O
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_H2O_calc_mem]
      type = SimpleFluidDispersion
      variable = D_H2O
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  ## ============================ D_H calc ===========================
  [./D_H_calc_channels]
      type = SimpleFluidDispersion
      variable = D_H
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_H_calc_elec]
      type = SimpleFluidDispersion
      variable = D_H
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_H_calc_mem]
      type = SimpleFluidDispersion
      variable = D_H
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]


  ## ============================ D_H2 calc ===========================
  [./D_H2_calc_channels]
      type = SimpleFluidDispersion
      variable = D_H2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_H2_calc_elec]
      type = SimpleFluidDispersion
      variable = D_H2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_H2_calc_mem]
      type = SimpleFluidDispersion
      variable = D_H2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]



  ## ============================ D_O2 calc ===========================
  [./D_O2_calc_channels]
      type = SimpleFluidDispersion
      variable = D_O2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_O2_calc_elec]
      type = SimpleFluidDispersion
      variable = D_O2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_O2_calc_mem]
      type = SimpleFluidDispersion
      variable = D_O2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00695
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]



  ## ============================ D_Na calc ===========================
  [./D_Na_calc_channels]
      type = SimpleFluidDispersion
      variable = D_Na
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00217
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_Na_calc_elec]
      type = SimpleFluidDispersion
      variable = D_Na
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00217
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_Na_calc_mem]
      type = SimpleFluidDispersion
      variable = D_Na
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00217
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]


  ## ============================ D_OH calc ===========================
  [./D_OH_calc_channels]
      type = SimpleFluidDispersion
      variable = D_OH
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00493
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_OH_calc_elec]
      type = SimpleFluidDispersion
      variable = D_OH
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00493
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_OH_calc_mem]
      type = SimpleFluidDispersion
      variable = D_OH
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00493
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]


  ## ============================ D_HCO3 calc ===========================
  [./D_HCO3_calc_channels]
      type = SimpleFluidDispersion
      variable = D_HCO3
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0011
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_HCO3_calc_elec]
      type = SimpleFluidDispersion
      variable = D_HCO3
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0011
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_HCO3_calc_mem]
      type = SimpleFluidDispersion
      variable = D_HCO3
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0011
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]


  ## ============================ D_CO3 calc ===========================
  [./D_CO3_calc_channels]
      type = SimpleFluidDispersion
      variable = D_CO3
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0008017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_CO3_calc_elec]
      type = SimpleFluidDispersion
      variable = D_CO3
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0008017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_CO3_calc_mem]
      type = SimpleFluidDispersion
      variable = D_CO3
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.0008017
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]



  ## ============================ D_CO2 calc ===========================
  [./D_CO2_calc_channels]
      type = SimpleFluidDispersion
      variable = D_CO2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00191
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_CO2_calc_elec]
      type = SimpleFluidDispersion
      variable = D_CO2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00191
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_CO2_calc_mem]
      type = SimpleFluidDispersion
      variable = D_CO2
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00191
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]



  ## ============================ D_CO calc ===========================
  [./D_CO_calc_channels]
      type = SimpleFluidDispersion
      variable = D_CO
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00191
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./D_CO_calc_elec]
      type = SimpleFluidDispersion
      variable = D_CO
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00191
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = true
      include_porosity_correction = true

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./D_CO_calc_mem]
      type = SimpleFluidDispersion
      variable = D_CO
      temperature = 298
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z
      vel_length_unit = "mm"
      vel_time_unit = "s"

      ref_diffusivity = 0.00191
      diff_length_unit = "mm"
      diff_time_unit = "s"

      include_dispersivity_correction = false
      include_porosity_correction = false

      output_length_unit = "mm"
      output_time_unit = "s"

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]


  [./dens_calc]
      type = SimpleFluidDensity
      variable = density
      temperature = 298

      output_volume_unit = "mm^3"
      output_mass_unit = "g"

      execute_on = 'initial timestep_end'
  [../]

  [./visc_calc]
      type = SimpleFluidViscosity
      variable = viscosity
      temperature = 298

      output_length_unit = "mm"
      output_mass_unit = "g"
      output_time_unit = "s"

      unit_basis = "mass"

      execute_on = 'initial timestep_end'
  [../]


  [./coef_calc_channels]
      type = DarcyWeisbachCoefficient
      variable = press_coef

      friction_factor = 0.05
      density = density          #g/mm^3
      velocity = vel_mag         #mm/s
      hydraulic_diameter = 1.6   #mm

      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel anode_fluid_channel'
  [../]

  [./coef_calc_elec]
      type = KozenyCarmanDarcyCoefficient
      variable = press_coef

      porosity = eps
      viscosity = viscosity   #g/mm/s
      particle_diameter = 0.1 #mm
      kozeny_carman_const = 5.55

      execute_on = 'initial timestep_end'
      block = 'cathode anode'
  [../]

  [./coef_calc_mem]
      type = SchloeglDarcyCoefficient
      variable = press_coef

      hydraulic_permeability = 1.58E-12  #mm^2
      viscosity = viscosity  #g/mm/s

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./sigma_e_calc]
      type = ElectrolyteConductivity
      variable = sigma_e
      temperature = T_e
      ion_conc = ''
      diffusion = ''
      ion_valence = ''
      execute_on = 'initial timestep_end'
  [../]

  [./sol_vol_calc]
      type = SolidsVolumeFraction
      variable = sol_vol_frac
      porosity = eps
      execute_on = 'initial timestep_end'
  [../]

  [./calc_ions_cat]
      type = IonicStrength
      variable = ion_str
      conversion_factor = 1E6 # mm^3/L
      ion_conc = 'H OH HCO3 CO3 Na'
      ion_valence = '1 1 1 2 1'
      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel cathode'
  [../]

  [./calc_ions_an]
      type = IonicStrength
      variable = ion_str
      conversion_factor = 1E6 # mm^3/L
      ion_conc = 'H OH'
      ion_valence = '1 1'
      execute_on = 'initial timestep_end'
      block = 'anode_fluid_channel anode'
  [../]

  [./calc_gamma0]
      type = DaviesActivityCoeff
      variable = gamma0
      temperature = 298
      ionic_strength = ion_str
      ion_valence = 0
      execute_on = 'initial timestep_end'
  [../]

  [./calc_gamma1]
      type = DaviesActivityCoeff
      variable = gamma1
      temperature = 298
      ionic_strength = ion_str
      ion_valence = 1
      execute_on = 'initial timestep_end'
  [../]

  [./calc_gamma2]
      type = DaviesActivityCoeff
      variable = gamma2
      temperature = 298
      ionic_strength = ion_str
      ion_valence = 2
      execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  # exit pressure
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      value = 0
  [../]

  # inlet pressure grad
  [./press_grad_at_inlet]
      type = NeumannBC
      variable = pressure
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      value = 40   # vel in mm/s
  [../]

  # zero pressure grad at non-exits
  [./press_grad_at_non_exits]
      type = NeumannBC
      variable = pressure
      boundary = 'cathode_bottom cathode_top anode_bottom anode_top membrane_bottom membrane_top'
      value = 0
  [../]

  # Ground state
  [./phi_s_ground_side]
      type = CoupledDirichletBC
      variable = phi_s
      boundary = 'cathode_fluid_channel_interface_cathode'
      #
      ## edge value was defined at 0 V
      coupled = 0 # in V
  [../]
  [./phi_e_ground_side]
      type = CoupledDirichletBC
      variable = phi_e
      boundary = 'cathode_fluid_channel_left'
      #
      ## edge value was defined at 0 V
      coupled = 0 # in V
  [../]

  # Applied Voltage
  [./phi_s_applied_side]
      type = CoupledDirichletBC
      variable = phi_s
      boundary = 'anode_interface_anode_fluid_channel'
      #
      ## edge value was defined at 0 V
      coupled = 0 # in V
  [../]
  [./phi_e_applied_side]
      type = CoupledDirichletBC
      variable = phi_e
      boundary = 'anode_fluid_channel_right'
      #
      ## edge value was defined at 0 V
      coupled = 0 # in V
  [../]

  ## =============== H2O fluxes ================
  [./H2O_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = H2O
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1.2E-6
  [../]
  [./H2O_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = H2O
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1.2E-6
  [../]
  [./H2O_FluxOut]
      type = DGFlowMassFluxBC
      variable = H2O
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== H fluxes ================
  [./H_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = H
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 4.5E-15
  [../]
  [./H_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = H
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1.0E-13
  [../]
  [./H_FluxOut]
      type = DGFlowMassFluxBC
      variable = H
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== H2 fluxes ================
  [./H2_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = H2
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 0
  [../]
  [./H2_FluxOut]
      type = DGFlowMassFluxBC
      variable = H2
      boundary = 'cathode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== O2 fluxes ================
  [./O2_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = O2
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 0
  [../]
  [./O2_FluxOut]
      type = DGFlowMassFluxBC
      variable = O2
      boundary = 'anode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== Na fluxes ================
  [./Na_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = Na
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1E-6
  [../]
  [./Na_FluxOut]
      type = DGFlowMassFluxBC
      variable = Na
      boundary = 'cathode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== OH fluxes ================
  [./OH_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = OH
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 2.1E-12
  [../]
  [./OH_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = OH
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1.0E-13
  [../]
  [./OH_FluxOut]
      type = DGFlowMassFluxBC
      variable = OH
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== HCO3 fluxes ================
  [./HCO3_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = HCO3
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 9.8E-8
  [../]
  [./HCO3_FluxOut]
      type = DGFlowMassFluxBC
      variable = HCO3
      boundary = 'cathode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== CO3 fluxes ================
  [./CO3_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = CO3
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 9.9E-10
  [../]
  [./CO3_FluxOut]
      type = DGFlowMassFluxBC
      variable = CO3
      boundary = 'cathode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== CO2 fluxes ================
  [./CO2_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = CO2
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1E-8
  [../]
  [./CO2_FluxOut]
      type = DGFlowMassFluxBC
      variable = CO2
      boundary = 'cathode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ## =============== CO fluxes ================
  [./CO_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = CO
      boundary = 'cathode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 0
  [../]
  [./CO_FluxOut]
      type = DGFlowMassFluxBC
      variable = CO
      boundary = 'cathode_fluid_channel_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
[]

[Postprocessors]
  [./pressure_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vel_y_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./H2O_inlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_bottom anode_fluid_channel_bottom'
      variable = H2O
      execute_on = 'initial timestep_end'
  [../]

  [./H2O_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
      variable = H2O
      execute_on = 'initial timestep_end'
  [../]
[]


[Executioner]
  type = Transient
  scheme = implicit-euler

  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason
                    -snes_linesearch_monitor

                    -ksp_gmres_modifiedgramschmidt'

  # NOTE: The sub_pc_type arg not used if pc_type is ksp,
  #       Instead, set the ksp_ksp_type to the pc method
  #       you want. Then, also set the ksp_pc_type to be
  #       the terminal preconditioner.
  #
  # Good terminal precon options: lu, ilu, asm, gasm, pbjacobi
  #                               bjacobi, redundant, telescope
  petsc_options_iname ='-ksp_type
                        -pc_type

                        -sub_pc_type

                        -snes_max_it

                        -sub_pc_factor_shift_type
                        -pc_factor_shift_type
                        -ksp_pc_factor_shift_type

                        -pc_asm_overlap

                        -snes_atol
                        -snes_rtol

                        -ksp_ksp_type
                        -ksp_pc_type

                        -ksp_gmres_restart
                        -ksp_ksp_gmres_restart

                        -ksp_max_it
                        -ksp_ksp_max_it

                        -ksp_rtol
                        -ksp_atol

                        -ksp_pc_factor_mat_solver_type

                        	-mat_mumps_cntl_1
                          -mat_mumps_cntl_3
                          -mat_mumps_icntl_23'

  ## NOTE: May be best to just use lu as pc_type instead of ksp
  petsc_options_value = 'fgmres
                         ksp

                         lu

                         50

                         NONZERO
                         NONZERO
                         NONZERO

                         20

                         1E-6
                         1E-8

                         fgmres
                         lu

                         30
                         30

                         30
                         30

                         1e-6
                         1e-6

                         mumps

                          0.01
                          0.
                          500'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = l2
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10

  start_time = 0.0
  end_time = 2.5
  dtmax = 60

  [./TimeStepper]
		  type = SolutionTimeAdaptiveDT
      dt = 0.01
  [../]

[] #END Executioner

[Preconditioning]
    [./SMP_PJFNK]
      type = SMP
      full = true
      solve_type = pjfnk
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = true

[] #END Outputs
