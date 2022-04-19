# Full full test simulation
# -------------------------
#   Try using different concentration basis. Using
#       micro-moles/mm^3 for concentration to test
#       for better convergence and better scaling.

[GlobalParams]
#       ~2.26 S/m (for 0.1 M ionic strength)
#       ~10.7 S/m (for 0.5 M ionic strength)
#       ~20.1 S/m (for 1.0 M ionic strength)
#       ~35.2 S/m (for 2.0 M ionic strength)
    min_conductivity = 2.267E-3
    tight_coupling = false

    faraday_const = 0.0964853   # C/umol
    gas_const = 8.314462E-6     # J/K/umol
[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator


    file = 2D_Electrolyzer_mm.msh    #coarse mesh

    #file = 2D_Electrolyzer_mm_split.msh     #fine mesh

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

  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.2 #umol/mm^3
      scaling = 1
  [../]

  # Ions/species
  #   NOTE: Good Initial Conditions are VERY IMPORTANT for convergence
  [./H]
      order = FIRST
      family = MONOMIAL
      scaling = 1
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
  [../]
  [./H2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-15 # umol/mm^3
      scaling = 1
      block = 'cathode_fluid_channel cathode'
  [../]
  [./O2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-15  # umol/mm^3
      scaling = 1
      block = 'anode anode_fluid_channel'
  [../]
  [./Na]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.1 # umol/mm^3
      scaling = 1
      block = 'cathode_fluid_channel cathode'
  [../]
  [./OH]
      order = FIRST
      family = MONOMIAL
      scaling = 1
      block = 'cathode_fluid_channel cathode membrane anode anode_fluid_channel'
  [../]
  [./HCO3]
      order = FIRST
      family = MONOMIAL
      ##initial_condition = 0.098 # umol/mm^3
      scaling = 1
      block = 'cathode_fluid_channel cathode membrane anode anode_fluid_channel'
  [../]
  [./CO3]
      order = FIRST
      family = MONOMIAL
      ##initial_condition = 9.9E-4 # umol/mm^3
      scaling = 1
      block = 'cathode_fluid_channel cathode membrane anode anode_fluid_channel'
  [../]
  [./CO2]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001 # umol/mm^3
      scaling = 1
      block = 'cathode_fluid_channel cathode'
  [../]
  [./CO]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-15  # umol/cm^3
      scaling = 1E10
      block = 'cathode_fluid_channel cathode'
  [../]


  # activities
  [./a_H]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = H
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
      scaling = 1
  [../]
  [./a_H2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = H2
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1
  [../]
  [./a_O2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = O2
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
      block = 'anode anode_fluid_channel'
      scaling = 1
  [../]
  [./a_Na]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = Na
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1
  [../]
  [./a_OH]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = OH
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
      scaling = 1
  [../]
  [./a_HCO3]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = HCO3
          activity_coeff = gamma1
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1
  [../]
  [./a_CO3]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = CO3
          activity_coeff = gamma2
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1
  [../]
  [./a_CO2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = CO2
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1
  [../]
  [./a_CO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialActivity
          concentration = CO
          activity_coeff = gamma0
          ref_conc = C_ref
      [../]
      block = 'cathode_fluid_channel cathode'
      scaling = 1
  [../]


  # Speciation reaction rates
  # rate of water reaction
  # 1/min ==> convert to umol/mm^3/s via scale = C_ref
  [./r_w]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
      scaling = 1
      block = 'cathode_fluid_channel cathode anode anode_fluid_channel'
  [../]

  # rate of CO2 -> HCO3 reaction
  # 1/min ==> convert to umol/mm^3/s via scale = C_ref
  [./r_1]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
      scaling = 1
      block = 'cathode_fluid_channel cathode'
  [../]

  # rate of HCO3 -> CO3 reaction
  # 1/min ==> convert to umol/mm^3/s via scale = C_ref
  [./r_2]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
      scaling = 1
      block = 'cathode_fluid_channel cathode'
  [../]

  # rate of alt CO2 -> HCO3 reaction
  # 1/min ==> convert to umol/mm^3/s via scale = C_ref
  [./r_3]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
      scaling = 1
      block = 'cathode_fluid_channel cathode'
  [../]

  # rate of alt HCO3 -> CO3 reaction
  # 1/min ==> convert to umol/mm^3/s via scale = C_ref
  [./r_4]
      order = CONSTANT
      family = MONOMIAL
      initial_condition = 0
      scaling = 1
      block = 'cathode_fluid_channel cathode'
  [../]

  # -------- Butler-Volmer reaction rates ------------
  # reduced_state <----> oxidized_state
  # H2 + 2 OH- <----> 2 H2O + 2 e-
  [./r_H2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 6.59167E-1    # umol/mm^2/s  fitted param 6.59167E-6
          equilibrium_potential = 0         # V

          reduced_state_vars = 'a_H2'       # assumed
          reduced_state_stoich = '1'        # assumed

          oxidized_state_vars = 'a_H'
          oxidized_state_stoich = '1'  # fitted param 0.1737

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.14   # fitted param
      [../]
      scaling = 1
      block = 'cathode'
  [../]
  # H2O <----> 0.5 O2 + 2 H+ + 2 e-
  [./r_O2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 2.258E-3    # umol/mm^2/s  (based on literature)
          equilibrium_potential = 1.23         # V      (based on expected Eo for half-rxn)

          reduced_state_vars = '1'          # assumed that activity of H2O == 1
          reduced_state_stoich = '1'        # assumed

          oxidized_state_vars = 'a_H a_O2'
          oxidized_state_stoich = '2 1'  # use stoich for H+

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # (based on literature)
          electron_transfer_coef = 0.54    # (based on literature)
      [../]
      scaling = 1
      block = 'anode'
  [../]
  # CO + 2 OH- <----> CO2 + H2O + 2 e-
  [./r_CO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 2.0833E-6    # umol/mm^2/s fitted param 2.0833E-7
          equilibrium_potential = -0.11         # V

          reduced_state_vars = 'a_CO'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'a_H a_CO2'
          oxidized_state_stoich = '1 1'  # fitted param 0.6774 1.5

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.35   # fitted param
      [../]
      scaling = 1
      block = 'cathode'
  [../]

  # ------------- Butler-Volmer current densities ---------
  [./J_H2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_H2
      [../]
      block = 'cathode'
      scaling = 1
  [../]
  [./J_O2]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # unknown
          specific_area = As
          rate_var = r_O2
      [../]
      block = 'anode'
      scaling = 1
  [../]
  [./J_CO]
      order = CONSTANT
      family = MONOMIAL
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1       # params are fitted to this standard
          specific_area = As
          rate_var = r_CO
      [../]
      block = 'cathode'
      scaling = 1
  [../]
[]

[ICs]
  [./H_cat]
      type = ConstantIC
      variable = H
      value = 4.5E-9 # umol/mm^3
      block = 'cathode_fluid_channel cathode'
  [../]
  [./H_an]
      type = ConstantIC
      variable = H
      value = 1E-7
      block = 'anode anode_fluid_channel'
  [../]

  [./OH_cat]
      type = ConstantIC
      variable = OH
      value = 2.1E-6
      block = 'cathode_fluid_channel cathode membrane'
  [../]
  [./OH_an]
      type = ConstantIC
      variable = OH
      value = 1E-7
      block = 'anode anode_fluid_channel'
  [../]


  [./HCO3_cat]
      type = ConstantIC
      variable = HCO3
      value = 0.098
      block = 'cathode_fluid_channel cathode membrane'
  [../]
  [./HCO3_an]
      type = ConstantIC
      variable = HCO3
      value = 1e-15
      block = 'anode anode_fluid_channel'
  [../]

  [./CO3_cat]
      type = ConstantIC
      variable = CO3
      value = 9.8E-4
      block = 'cathode_fluid_channel cathode membrane'
  [../]
  [./CO3_an]
      type = ConstantIC
      variable = CO3
      value = 1e-15
      block = 'anode anode_fluid_channel'
  [../]

  [./ion_str_cat]
      type = InitialIonicStrength
      variable = ion_str
      conversion_factor = 1 # mm^3/L*mol/umol
      ion_conc = 'H OH HCO3 CO3 Na'
      ion_valence = '1 1 1 2 1'
      block = 'cathode_fluid_channel cathode'
  [../]
  [./ion_str_an]
      type = InitialIonicStrength
      variable = ion_str
      conversion_factor = 1 # mm^3/L*mol/umol
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
  # Some calculations put the specific_area of the catalyst layer
  #   at ~ 4.57E+4 mm^-1. In our case, the catalyst layer is roughly
  #   0.01 times the size of the full electrode, thus, the area of
  #   active catalyst would be ~ 4.57E+2 mm^-1
  [./As]
      order = FIRST
      family = MONOMIAL
      initial_condition = 4.57E2  # mm^-1
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

  # Electrolyte avg conductivity
  #       ~2.26 S/m (for 0.1 M ionic strength)
  #       ~10.7 S/m (for 0.5 M ionic strength)
  #       ~20.1 S/m (for 1.0 M ionic strength)
  #       ~35.2 S/m (for 2.0 M ionic strength)
  [./sigma_e]
      order = FIRST
      family = MONOMIAL
      initial_condition = 2.26E-3 #C/V/s/mm == 2.26 S/m (for 0.1 M solution)
  [../]


  # reference conc
  [./C_ref]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1 # umol/mm^3
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

  # applied voltage
  [./voltage]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.1
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

  [./J_CO_equ]
      type = Reaction
      variable = J_CO
  [../]
  [./J_CO_rxn]  # CO + 2 OH- <----> CO2 + H2O + 2 e-
      type = ButlerVolmerCurrentDensity
      variable = J_CO

      number_of_electrons = 1  # params are fitted to this standard
      specific_area = As
      rate_var = r_CO
  [../]


  ## =============== Butler-Volmer Kinetics ================
  [./r_H2_equ]
      type = Reaction
      variable = r_H2
  [../]
  [./r_H2_rxn]  # H2 + 2 OH- <----> 2 H2O + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_H2

      reaction_rate_const = 6.59167E-1    # umol/mm^2/s  fitted param 6.59167E-6
      equilibrium_potential = 0         # V

      reduced_state_vars = 'a_H2'       # assumed
      reduced_state_stoich = '1'        # assumed

      oxidized_state_vars = 'a_H'
      oxidized_state_stoich = '1'  # fitted param 0.1737

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.14   # fitted param
  [../]

  [./r_O2_equ]
      type = Reaction
      variable = r_O2
  [../]
  [./r_O2_rxn]  # H2O <----> 0.5 O2 + 2 H+ + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_O2

      reaction_rate_const = 2.258E-3    # umol/mm^2/s  (based on literature)
      equilibrium_potential = 1.23         # V      (based on expected Eo for half-rxn)

      reduced_state_vars = '1'          # assumed that activity of H2O == 1
      reduced_state_stoich = '1'        # assumed

      oxidized_state_vars = 'a_H a_O2'
      oxidized_state_stoich = '2 1'  # use stoich for H+

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # (based on literature)
      electron_transfer_coef = 0.54    # (based on literature)
  [../]

  [./r_CO_equ]
      type = Reaction
      variable = r_CO
  [../]
  [./r_CO_rxn]  # CO + 2 OH- <----> CO2 + H2O + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_CO

      reaction_rate_const = 2.0833E-6    # umol/mm^2/s fitted param 2.0833E-7
      equilibrium_potential = -0.11         # V

      reduced_state_vars = 'a_CO'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'a_H a_CO2'
      oxidized_state_stoich = '1 1'  # fitted param 0.6774 1.5

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.35   # fitted param
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
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      block = 'anode anode_fluid_channel'
  [../]
  [./phi_e_ionic_conductivity_an]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = eps
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      block = 'anode anode_fluid_channel'
  [../]
  [./phi_e_potential_conductivity_mem]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      block = 'membrane'
  [../]
  [./phi_e_ionic_conductivity_mem]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = eps
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      block = 'membrane'
  [../]

  [./phi_e_J_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = 'J_H2 J_CO'
      weights = '1 1'
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
      coupled_list = 'J_H2 J_CO'
      weights = '-1 -1'
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
  [./H_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = H
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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

  [./H_surf_rate_an]
      type = ScaledWeightedCoupledSumFunction
      variable = H
      coupled_list = 'r_O2'
      weights = '2'
      scale = As
      block = 'anode'
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

  [./H2_surf_rate_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = H2
      coupled_list = 'r_H2'
      weights = '-1'
      scale = As
      block = 'cathode'
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

  [./O2_surf_rate_an]
      type = ScaledWeightedCoupledSumFunction
      variable = O2
      coupled_list = 'r_O2'
      weights = '0.5'
      scale = As
      block = 'anode'
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
  [./Na_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = Na
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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
  [./OH_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = OH
      valence = -1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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

  [./OH_surf_rate_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = OH
      coupled_list = 'r_H2 r_CO'
      weights = '-2 -2'
      scale = As
      block = 'cathode'
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
  [./HCO3_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = HCO3
      valence = -1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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
  [./CO3_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = CO3
      valence = -2
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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

  [./CO2_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = CO2
      coupled_list = 'r_CO'
      weights = '1'
      scale = As
      block = 'cathode'
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

  [./CO_surf_rate]
      type = ScaledWeightedCoupledSumFunction
      variable = CO
      coupled_list = 'r_CO'
      weights = '-1'
      scale = As
      block = 'cathode'
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

      forward_rate = 1.6E-3
      reverse_rate = 1.6E11

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1 # umol/mm^3

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
      scale = 1 # umol/mm^3

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
      scale = 1 # umol/mm^3

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
      scale = 1 # umol/mm^3

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
      scale = 1 # umol/mm^3

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
  [./H_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = H
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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
  [./Na_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = Na
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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
  [./OH_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = OH
      valence = -1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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
  [./HCO3_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = HCO3
      valence = -1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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
  [./CO3_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = CO3
      valence = -2
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
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
      ion_conc = OH                           # umol/mm^3
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
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]
  [./sigma_e_calc_an]
      type = ElectrolyteConductivity
      variable = sigma_e
      temperature = T_e
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
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
      conversion_factor = 1 # mm^3/L*mol/umol
      ion_conc = 'H OH HCO3 CO3 Na'
      ion_valence = '1 1 1 2 1'
      execute_on = 'initial timestep_end'
      block = 'cathode_fluid_channel cathode'
  [../]

  [./calc_ions_an]
      type = IonicStrength
      variable = ion_str
      conversion_factor = 1 # mm^3/L*mol/umol
      ion_conc = 'H OH HCO3 CO3'
      ion_valence = '1 1 1 2'
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
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
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
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
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
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
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
      ion_conc = 'OH HCO3 CO3'
      diffusion = 'D_OH D_HCO3 D_CO3'
      ion_valence = '-1 -1 -2'
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

  [./voltage_step_input]
      type = TemporalStepFunction
      variable = voltage

      start_value = -0.1
      aux_vals = '-0.2 -0.4 -0.8 -1.0 -2.0'
      aux_times = '120   480    1000    2000   5000'
      time_spans = '60      120    180    360    720'

      execute_on = 'initial timestep_begin nonlinear'
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
      value = 0.4   # vel in mm/s
  [../]

  # zero pressure grad at non-exits
  [./press_grad_at_non_exits]
      type = NeumannBC
      variable = pressure
      boundary = 'cathode_bottom cathode_top anode_bottom anode_top membrane_bottom membrane_top'
      value = 0
  [../]

  # Ground state solid
  [./phi_s_ground_side]
      type = CoupledDirichletBC
      variable = phi_s
      boundary = 'cathode_fluid_channel_interface_cathode'
      #
      ## edge value was defined at 0 V
      coupled = voltage # in V
  [../]

  # electrolyte
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

      variable = phi_s
      boundary = 'anode_interface_anode_fluid_channel'
      #
      ## edge value was defined at 0 V

      type = CoupledDirichletBC
      coupled = 0 # in V

      #type = FunctionDirichletBC
      #function = '0.1*t' # in V
  [../]

  # electrolyte
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
      input_var = 1.2
  [../]
  [./H2O_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = H2O
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1.2
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
      input_var = 4.5E-9
  [../]
  [./H_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = H
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1.0E-7
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
      input_var = 1e-15
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
      input_var = 1e-15
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
      input_var = 0.1
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
      input_var = 2.1E-6
  [../]
  [./OH_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = OH
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1.0E-7
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
      input_var = 0.098
  [../]
  [./HCO3_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = HCO3
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1e-15
  [../]
  [./HCO3_FluxOut]
      type = DGFlowMassFluxBC
      variable = HCO3
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
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
      input_var = 9.9E-4
  [../]
  [./CO3_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = CO3
      boundary = 'anode_fluid_channel_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 1e-15
  [../]
  [./CO3_FluxOut]
      type = DGFlowMassFluxBC
      variable = CO3
      boundary = 'cathode_fluid_channel_top anode_fluid_channel_top'
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
      input_var = 1E-3
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
      input_var = 1e-15
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

  [./CO2_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top'
      variable = CO2
      execute_on = 'initial timestep_end'
  [../]

  [./CO_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top'
      variable = CO
      execute_on = 'initial timestep_end'
  [../]

  [./H2_outlet]
      type = SideAverageValue
      boundary = 'cathode_fluid_channel_top'
      variable = H2
      execute_on = 'initial timestep_end'
  [../]

  [./O2_outlet]
      type = SideAverageValue
      boundary = 'anode_fluid_channel_top'
      variable = O2
      execute_on = 'initial timestep_end'
  [../]

  [./OH_cathode]
      type = ElementAverageValue
      block = 'cathode'
      variable = OH
      execute_on = 'initial timestep_end'
  [../]

  [./H_cathode]
      type = ElementAverageValue
      block = 'cathode'
      variable = H
      execute_on = 'initial timestep_end'
  [../]

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

                         1e-16
                         1e-6

                         mumps

                          0.01
                          0.
                          500'


  line_search = l2
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10

  start_time = 0.0
  end_time = 25
  dtmax = 180

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
    interval = 3

[] #END Outputs
