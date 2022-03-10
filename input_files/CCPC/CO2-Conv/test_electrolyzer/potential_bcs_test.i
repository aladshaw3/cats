# Full full test simulation
# -------------------------
#   NOTE: May need to add some artifical dispersion
#         for numerical stability.

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
      scaling = 1
  [../]

  # electrode potential (in V or J/C)
  [./phi_s]
      order = FIRST
      family = LAGRANGE
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
      initial_condition = 4.0
  [../]

  # -------- Butler-Volmer reaction rates ------------
  # reduced_state <----> oxidized_state
  # H2 + OH- <----> 2 H2O + 2 e-
  [./r_H2]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 6.59167E-12    # mol/mm^2/s
          equilibrium_potential = 0         # V

          reduced_state_vars = 'a_H2'       # assumed
          reduced_state_stoich = '1'        # assumed

          oxidized_state_vars = 'a_H'
          oxidized_state_stoich = '0.1737'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.14   # fitted param
      [../]
      scaling = 1e0
      block = 'cathode'
  [../]
  # 2 H2O <----> 2 O2 + 4 H+ + 4 e-
  [./r_O2]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 1.0E-14    # mol/mm^2/s  (unknown)
          equilibrium_potential = -0.81        # V      (unknown)

          reduced_state_vars = 'H2O'          # assumed    (unknown)
          reduced_state_stoich = '1'        # assumed    (unknown)

          oxidized_state_vars = 'a_H a_O2'
          oxidized_state_stoich = '1 1'  # fitted param     (unknown)

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # unknown
          electron_transfer_coef = 0.5    # unknown
      [../]
      scaling = 1e0
      block = 'anode'
  [../]

  # ------------- Butler-Volmer current densities ---------
  [./J_H2]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_H2
      [../]
      block = 'cathode'
  [../]
  [./J_O2]
      order = FIRST
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # unknown
          specific_area = As
          rate_var = r_O2
      [../]
      block = 'anode'
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


  [./phi_s_cat]
      type = ConstantIC
      variable = phi_s
      value = 0 # V
      block = 'cathode'
  [../]
  [./phi_s_an]
      type = ConstantIC
      variable = phi_s
      value = 0  # V
      block = 'anode'
  [../]

  [./phi_e_cat]
      type = ConstantIC
      variable = phi_e
      value = 0 # V
      block = 'cathode'
  [../]
  [./phi_e_an]
      type = ConstantIC
      variable = phi_e
      value = 0  # V
      block = 'anode'
  [../]

[]

[AuxVariables]

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

  #Specific surface area
  [./As]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.0E3  # mm^-1
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

  [./SchloeglElecCoeff]
      order = FIRST
      family = MONOMIAL
      block = 'membrane'
  [../]

  # Electrolyte current density in x (C/mm^2/s)
  [./ie_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # Electrolyte current density in y (C/mm^2/s)
  [./ie_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
  [../]

  # electrode current density in x (C/mm^2/s)
  [./is_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'cathode anode'
  [../]

  # electrode current density in y (C/mm^2/s)
  [./is_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0
      block = 'cathode anode'
  [../]
[]

[Kernels]
  ## =============== Butler-Volmer Current ================
  [./J_H2_equ]
      type = Reaction
      variable = J_H2
  [../]
  [./J_H2_rxn]  # H2 + OH- <----> 2 H2O + 2 e-
      type = ButlerVolmerCurrentDensity
      variable = J_H2

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_H2
  [../]

  [./J_O2_equ]
      type = Reaction
      variable = J_O2
  [../]
  [./J_O2_rxn]  # 2 H2O <----> 2 O2 + 4 H+ + 4 e-
      type = ButlerVolmerCurrentDensity
      variable = J_O2

      number_of_electrons = 1  # unknown
      specific_area = As
      rate_var = r_O2
  [../]


  ## =============== Butler-Volmer Kinetics ================
  [./r_H2_equ]
      type = Reaction
      variable = r_H2
  [../]
  [./r_H2_rxn]  # H2 + OH- <----> 2 H2O + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_H2

      reaction_rate_const = 6.59167E-12    # mol/mm^2/s
      equilibrium_potential = 0         # V

      reduced_state_vars = 'a_H2'       # assumed
      reduced_state_stoich = '1'        # assumed

      oxidized_state_vars = 'a_H'
      oxidized_state_stoich = '0.1737'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.14   # fitted param
  [../]

  [./r_O2_equ]
      type = Reaction
      variable = r_O2
  [../]
  [./r_O2_rxn]  # 2 H2O <----> 2 O2 + 4 H+ + 4 e-
      type = ModifiedButlerVolmerReaction
      variable = r_O2

      reaction_rate_const = 1.0E-14    # mol/mm^2/s  (unknown)
      equilibrium_potential = -0.81         # V      (unknown)

      reduced_state_vars = 'H2O'          # assumed    (unknown)
      reduced_state_stoich = '1'        # assumed    (unknown)

      oxidized_state_vars = 'a_H a_O2'
      oxidized_state_stoich = '1 1'  # fitted param     (unknown)

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # unknown
      electron_transfer_coef = 0.5    # unknown
  [../]


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
  [./phi_e_potential_conductivity_cat]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      block = 'cathode cathode_fluid_channel'
  [../]
  [./phi_e_ionic_conductivity_cat]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = eps
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      block = 'cathode cathode_fluid_channel'
  [../]
  [./phi_e_potential_conductivity_an]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      block = 'anode anode_fluid_channel'
  [../]
  [./phi_e_ionic_conductivity_an]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = eps
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      block = 'anode anode_fluid_channel'
  [../]
  [./phi_e_potential_conductivity_mem]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      block = 'membrane'
  [../]
  [./phi_e_ionic_conductivity_mem]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = eps
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      block = 'membrane'
  [../]

  [./phi_e_J_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = 'J_H2'
      weights = '1'
      block = 'cathode'
  [../]
  [./phi_e_J_an]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = 'J_O2'
      weights = '1'
      block = 'anode'
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

  [./phi_s_J_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_s
      coupled_list = 'J_H2'
      weights = '-1'
      block = 'cathode'
  [../]
  [./phi_s_J_an]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_s
      coupled_list = 'J_O2'
      weights = '-1'
      block = 'anode'
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
  [./x_schloegl_ele]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = phi_e
      ux = SchloeglElecCoeff
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
  [./y_schloegl_ele]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = phi_e
      uy = SchloeglElecCoeff
      block = 'membrane'
  [../]

[]

[DGKernels]
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

  ## ============================ D_H2O calc ===========================
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

  [./schloegl_ele_calc]
      type = SchloeglElectrokineticCoefficient
      variable = SchloeglElecCoeff
      electrokinetic_permeability = 1.13E-13  # mm^2
      viscosity = viscosity                   # g/mm/s == Pa*s
      ion_conc = OH                           # mol/mm^3
      conversion_factor = 1e9                 # Pa*mm^3/J
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./sigma_e_calc_cat]
      type = ElectrolyteConductivity
      variable = sigma_e
      temperature = T_e
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel cathode'
  [../]
  [./sigma_e_calc_mem]
      type = ElectrolyteConductivity
      variable = sigma_e
      temperature = T_e
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]
  [./sigma_e_calc_an]
      type = ElectrolyteConductivity
      variable = sigma_e
      temperature = T_e
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      execute_on = 'initial timestep_end'
      block = 'anode_fluid_channel anode'
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


  [./ie_x_calc_cat]
      type = AuxElectrolyteCurrent
      variable = ie_x
      direction = 0         # 0=x
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel cathode'
  [../]
  [./ie_y_calc_cat]
      type = AuxElectrolyteCurrent
      variable = ie_y
      direction = 1         # 0=x
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel cathode'
  [../]

  [./ie_x_calc_an]
      type = AuxElectrolyteCurrent
      variable = ie_x
      direction = 0         # 0=x
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      execute_on = 'initial timestep_end'
      block = 'anode_fluid_channel anode'
  [../]
  [./ie_y_calc_an]
      type = AuxElectrolyteCurrent
      variable = ie_y
      direction = 1         # 0=x
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      execute_on = 'initial timestep_end'
      block = 'anode_fluid_channel anode'
  [../]


  [./ie_x_calc_mem]
      type = AuxElectrolyteCurrent
      variable = ie_x
      direction = 0         # 0=x
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]
  [./ie_y_calc_mem]
      type = AuxElectrolyteCurrent
      variable = ie_y
      direction = 1         # 0=x
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH'
      diffusion = 'D_OH'
      ion_valence = '-1'
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]


  [./is_x_calc]
      type = AuxElectrodeCurrent
      variable = is_x
      direction = 0         # 0=x
      electric_potential = phi_s
      solid_frac = sol_vol_frac
      conductivity = sigma_s
      execute_on = 'initial timestep_end'
  [../]
  [./is_y_calc]
      type = AuxElectrodeCurrent
      variable = is_y
      direction = 1         # 0=x
      electric_potential = phi_s
      solid_frac = sol_vol_frac
      conductivity = sigma_s
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
      value = 4   # vel in mm/s
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
  [./phi_e_ground_side_flux]
      type = CoupledNeumannBC
      variable = phi_e
      boundary = 'cathode_fluid_channel_left'
      #
      ## edge value was defined at 0 V
      coupled = 0
  [../]

  # Applied Voltage
  [./phi_s_applied_side]
      type = CoupledDirichletBC
      variable = phi_s
      boundary = 'anode_top'
      #
      ## edge value was defined at 0 V
      coupled = 1 # in V
  [../]
  [./phi_e_applied_side]
      type = CoupledNeumannBC
      variable = phi_e
      boundary = 'anode_fluid_channel_right'
      #
      ## edge value was defined at 0 V
      coupled = 0
  [../]

[]

[Postprocessors]


  [./ie_x_cathode]
      type = ElementAverageValue
      block = 'cathode'
      variable = ie_x
      execute_on = 'initial timestep_end'
  [../]

  [./ie_x_anode]
      type = ElementAverageValue
      block = 'anode'
      variable = ie_x
      execute_on = 'initial timestep_end'
  [../]


  [./V_e_cathode]
      type = ElementAverageValue
      block = 'cathode'
      variable = phi_e
      execute_on = 'initial timestep_end'
  [../]
  [./V_e_anode]
      type = ElementAverageValue
      block = 'anode'
      variable = phi_e
      execute_on = 'initial timestep_end'
  [../]

  [./is_x_cathode]
      type = ElementAverageValue
      block = 'cathode'
      variable = is_x
      execute_on = 'initial timestep_end'
  [../]

  [./is_x_anode]
      type = ElementAverageValue
      block = 'anode'
      variable = is_x
      execute_on = 'initial timestep_end'
  [../]


  [./V_s_cathode]
      type = ElementAverageValue
      block = 'cathode'
      variable = phi_s
      execute_on = 'initial timestep_end'
  [../]
  [./V_s_anode]
      type = ElementAverageValue
      block = 'anode'
      variable = phi_s
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

                         50
                         50

                         50
                         50

                         1e-6
                         1e-6

                         mumps

                          0.01
                          0.
                          500'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
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
