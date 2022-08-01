## This example file runs the full cell test with all variables coupled
#
#     To maximize efficiency, all variables should be LAGRANGE


[GlobalParams]

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = FullCell_ValidationMesh_cm.msh

    ### ========= boundary_name ==========
    # "neg_collector_left"
    # "neg_collector_bottom"
    # "neg_collector_top"
    # "neg_collector_interface_neg_electrode"
    # "neg_electrode_bottom"
    # "neg_electrode_top"
    # "neg_electrode_interface_membrane"
    # "membrane_bottom"
    # "membrane_top"
    # "membrane_interface_pos_electrode"
    # "pos_electrode_bottom"
    # "pos_electrode_top"
    # "pos_electrode_interface_pos_collector"
    # "pos_collector_bottom"
    # "pos_collector_top"
    # "pos_collector_right"

    ### ====== block ========
    # "neg_collector"
    # "neg_electrode"
    # "membrane"
    # "pos_electrode"
    # "pos_collector"
  []

[] # END Mesh

[Variables]
  # solid potentials
  [./phi_s]
      order = FIRST
      family = LAGRANGE
      # initial_condition (setup in ICs block)
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

  # electrolyte potentials
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.3
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # reaction variable for negative electrode
  #       Rxn:    V(II) <---> V(III) + e-
  [./r_neg]
      order = FIRST
      family = LAGRANGE
      block = 'neg_electrode'
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 0.00105  # cm/min
          equilibrium_potential = -0.255 # V

          reduced_state_vars = 'V_II'
          reduced_state_stoich = '1'

          oxidized_state_vars = 'V_III'
          oxidized_state_stoich = '1'

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1
          electron_transfer_coef = 0.5
      [../]
      scaling = 1
  [../]

  # reaction variable for positive electrode
  #       Rxn:    V(IV) (+ H2O) <---> V(V) (+ 2 H+ ) + e-
  [./r_pos]
      order = FIRST
      family = LAGRANGE
      block = 'pos_electrode'
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 1.8E-5  # cm/min
          equilibrium_potential = 1.004 # V

          reduced_state_vars = 'V_IV'
          reduced_state_stoich = '1'

          oxidized_state_vars = 'V_V'
          oxidized_state_stoich = '1'

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1
          electron_transfer_coef = 0.5
      [../]
      scaling = 1
  [../]

  # Butler-Volmer current density for neg electrode
  [./J_neg]
      order = FIRST
      family = LAGRANGE
      block = 'neg_electrode'
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1
          specific_area = As
          rate_var = r_neg
      [../]
      scaling = 1
  [../]

  # Butler-Volmer current density for pos electrode
  [./J_pos]
      order = FIRST
      family = LAGRANGE
      block = 'pos_electrode'
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 1
          specific_area = As
          rate_var = r_pos
      [../]
      scaling = 1
  [../]

  # Variable for potential difference
  [./phi_diff]
      order = FIRST
      family = LAGRANGE
      block = 'neg_electrode pos_electrode'
      [./InitialCondition]
          type = InitialPotentialDifference
          electrode_potential = phi_s
          electrolyte_potential = phi_e
      [../]
  [../]

  # H2O
  [./H2O]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0042 #mol/cm^3
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # H+
  [./H_p]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0012 #mol/cm^3
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # V2+
  [./V_II]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.000027 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # V3+
  [./V_III]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.001053 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # VO_2+
  [./V_IV]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.001053 #mol/cm^3
      block = 'pos_electrode'
  [../]

  # VO2_+
  [./V_V]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.000027 #mol/cm^3
      block = 'pos_electrode'
  [../]


## Energy Balance Components ##

  # Electrolyte energy density
  [./E_f]
      order = FIRST
      family = LAGRANGE
      [./InitialCondition]
          type = InitialPhaseEnergy
          specific_heat = cp_f
          density = rho_f
          temperature = T_e
      [../]
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # Electrode energy density
  [./E_s]
      order = FIRST
      family = LAGRANGE
      [./InitialCondition]
          type = InitialPhaseEnergy
          specific_heat = cp_s
          density = rho_s
          temperature = T_s
      [../]
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

  # electrolyte temperature
  [./T_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 300 # K
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # solid temperature (may need separate T for membrane?)
  [./T_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 300 # K
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

[]

[AuxVariables]

  # Diffusivities
  [./D_H2O]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0012 #cm^2/min
      block = 'neg_electrode membrane pos_electrode'
  [../]
  [./D_H_p]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0012 #cm^2/min
      block = 'neg_electrode membrane pos_electrode'
  [../]
  [./D_H_p_membrane]
      order = FIRST
      family = LAGRANGE
      initial_condition = 8.40E-4 #cm^2/min
      block = 'neg_electrode membrane pos_electrode'
  [../]
  [./D_V_II]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.18745E-4 #cm^2/min
      block = 'neg_electrode'
  [../]
  [./D_V_III]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.18745E-4 #cm^2/min
      block = 'neg_electrode'
  [../]
  [./D_V_IV]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.9296E-4 #cm^2/min
      block = 'pos_electrode'
  [../]
  [./D_V_V]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.9296E-4 #cm^2/min
      block = 'pos_electrode'
  [../]

  # electrode porosity (switch to 1 inside membrane)
  [./eps]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.68
      block = 'neg_electrode membrane pos_electrode'
  [../]

  [./sol_frac]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.32
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

  # effective solid volume (1-eps)^(3/2)
  [./eff_sol_vol]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.18101936
      block = 'neg_electrode pos_electrode'
  [../]

  # water viscosity
  [./viscosity]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.667E-8 # kPa*min
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # electrode conductivity (C/V/cm/min)
  [./sigma_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 300     # 500 S/m  : 1 S = 1 A/V = 1 C/V/s
      block = 'neg_electrode pos_electrode'
  [../]

  # collector conductivity (C/V/cm/min)
  [./sigma_c]
      order = FIRST
      family = LAGRANGE
      initial_condition = 600  # 1000 S/m  : 1 S = 1 A/V = 1 C/V/s
      block = 'neg_collector pos_collector'
  [../]

  #Specific surface area
  [./As]
    order = FIRST
    family = LAGRANGE
    initial_condition = 2E4  # cm^-1
    block = 'neg_electrode pos_electrode'
  [../]

  # Keff calculation to check values for problems
  #   Just to check some computed values
  [./Keff]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0 # C/V/cm/min
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # Current flux at boundary
  ## I/a for charging (where I=current = 10 A && a=surface area = 10cm x 10cm)
  # 1 A = 1 C/s ==>  10 A = 600 C/min
  # value = I/A = 6 C/min/cm^2
  [./current_input]
      order = FIRST
      family = LAGRANGE
      initial_condition = 6 # C/min/cm^2
      block = 'pos_collector'
  [../]

  # rho_f
  [./rho_f]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0014 # kg/cm^3
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # rho_s
  [./rho_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0014 # kg/cm^3
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

  # K_f
  [./K_f]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.1 # J/min/cm/K
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # K_s
  [./K_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.1 # J/min/cm/K
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

  # cp_f
  [./cp_f]
      order = FIRST
      family = LAGRANGE
      initial_condition = 3200 # J/kg/K
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # cp_s
  [./cp_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 3200 # J/kg/K
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

  # h
  [./h]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.15 # J/min/cm^2/K
      block = 'neg_electrode pos_electrode'
  [../]

  # hw
  [./hw]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.35 # J/min/cm^2/K
      block = 'neg_collector neg_electrode membrane pos_electrode pos_collector'
  [../]

  # T_w
  [./T_w]
      order = FIRST
      family = LAGRANGE
      initial_condition = 300 # K
      block = 'neg_collector neg_electrode membrane pos_electrode pos_collector'
  [../]
[]

[ICs]
  ### ==================== Solid Potentials ==========================
  [./phi_s_neg_side]
      type = ConstantIC
      variable = phi_s
      value = 0 # in V
      block = 'neg_collector neg_electrode'
  [../]
  [./phi_s_pos_side]
      type = ConstantIC
      variable = phi_s
      value = 1.59 # in V
      block = 'pos_electrode pos_collector'
  [../]
[]

[Kernels]
  ### ==================== Solid Potentials ==========================
  # in electrodes
  [./phi_s_conductivity_in_electrode]
      type = ElectrodePotentialConductivity
      variable = phi_s
      solid_frac = eff_sol_vol
      conductivity = sigma_s
      block = 'neg_electrode pos_electrode'
  [../]

  # in collector
  [./phi_s_conductivity_in_collector]
      type = ElectrodePotentialConductivity
      variable = phi_s
      solid_frac = 1
      conductivity = sigma_c
      block = 'neg_collector pos_collector'
  [../]

  # reactions in electrodes
  [./phi_s_J_neg]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_s
      coupled_list = 'J_neg'
      weights = '-1'
      scale = 1
      block = 'neg_electrode'
  [../]
  [./phi_s_J_pos]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_s
      coupled_list = 'J_pos'
      weights = '-1'
      scale = 1
      block = 'pos_electrode'
  [../]

  ### ==================== Electrolyte Potentials ==========================
  # in electrodes
  [./phi_e_conductivity_in_neg_electrodes]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p V_II V_III'
      diffusion = 'D_H_p D_V_II D_V_III'
      ion_valence = '1 2 3'
      block = 'neg_electrode'
  [../]
  [./phi_e_conductivity_in_pos_electrodes]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p V_IV V_V'
      diffusion = 'D_H_p D_V_IV D_V_V'
      ion_valence = '1 2 1'
      block = 'pos_electrode'
  [../]

  # in membrane
  [./phi_e_conductivity_in_membrane]
      type = ElectrolytePotentialConductivity
      variable = phi_e
      porosity = 1
      temperature = T_e
      ion_conc = 'H_p'
      ion_valence = '1'
      diffusion = 'D_H_p'
      block = 'membrane'
  [../]

  # reactions in electrodes
  [./phi_e_J_neg]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = 'J_neg'
      weights = '1'
      scale = 1
      block = 'neg_electrode'
  [../]
  [./phi_e_J_pos]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = 'J_pos'
      weights = '1'
      scale = 1
      block = 'pos_electrode'
  [../]


  ## =============== Butler-Volmer Kinetics ================
  # Rxn:    V(II) <---> V(III) + e-
  [./r_equ_neg]
      type = Reaction
      variable = r_neg
  [../]
  [./r_rxn_neg]
      type = ModifiedButlerVolmerReaction
      variable = r_neg

      reaction_rate_const = 0.00105  # cm/min
      equilibrium_potential = -0.255 # V

      reduced_state_vars = 'V_II'
      reduced_state_stoich = '1'

      oxidized_state_vars = 'V_III'
      oxidized_state_stoich = '1'

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1
      electron_transfer_coef = 0.5

      # NOTE: We can use 'scale' as a correction factor for rate
      ##      Correction factor comes from Reference [2]
      scale = 0.0375
  [../]

  # Rxn:    V(IV) (+ H2O) <---> V(V) (+ 2 H+ ) + e-
  [./r_equ_pos]
      type = Reaction
      variable = r_pos
  [../]
  [./r_rxn_pos]
      type = ModifiedButlerVolmerReaction
      variable = r_pos

      reaction_rate_const = 1.8E-5  # cm/min
      equilibrium_potential = 1.004 # V

      reduced_state_vars = 'V_IV'
      reduced_state_stoich = '1'

      oxidized_state_vars = 'V_V'
      oxidized_state_stoich = '1'

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1
      electron_transfer_coef = 0.5

      # NOTE: We can use 'scale' as a correction factor for rate
      ##      Correction factor comes from Reference [2]
      scale = 0.0375
  [../]


  ## =============== Butler-Volmer Current ================
  [./J_equ_neg]
      type = Reaction
      variable = J_neg
  [../]
  [./J_rxn_neg]
      type = ButlerVolmerCurrentDensity
      variable = J_neg

      number_of_electrons = 1
      specific_area = As
      rate_var = r_neg
  [../]

  [./J_equ_pos]
      type = Reaction
      variable = J_pos
  [../]
  [./J_rxn_pos]
      type = ButlerVolmerCurrentDensity
      variable = J_pos

      number_of_electrons = 1
      specific_area = As
      rate_var = r_pos
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


  ### ==================== H2O Transport ==========================

  # Divided Sub-domain kernels
  [./H2O_dot_electrodes]
      type = VariableCoefTimeDerivative
      variable = H2O
      coupled_coef = eps
      block = 'neg_electrode pos_electrode'
  [../]
  [./H2O_dot_membrane]
      type = VariableCoefTimeDerivative
      variable = H2O
      coupled_coef = 1
      block = 'membrane'
  [../]

  # Transport kernels
  #     vel is Darcy vel so no eps correction
  [./H2O_gdiff]
      type = GVarPoreDiffusion
      variable = H2O
      porosity = eps
      Dx = D_H2O
      Dy = D_H2O
      Dz = D_H2O
  [../]

  # reaction kernels for positive electrode
  #       Rxn:    V(IV) (+ H2O) <---> V(V) (+ 2 H+ ) + e-
  [./H2O_pos_rxn]
    type = ScaledWeightedCoupledSumFunction
    variable = H2O
    coupled_list = 'r_pos'
    weights = '-1'
    scale = As
    block = 'pos_electrode'
  [../]


  ### ==================== H+ Transport ==========================
  # Divided Sub-domain kernels
  [./Hp_dot_electrodes]
      type = VariableCoefTimeDerivative
      variable = H_p
      coupled_coef = eps
      block = 'neg_electrode pos_electrode'
  [../]
  [./Hp_dot_membrane]
      type = VariableCoefTimeDerivative
      variable = H_p
      coupled_coef = 1
      block = 'membrane'
  [../]

  # Transport kernels
  #     vel is Darcy vel so no eps correction
  [./Hp_gdiff]
      type = GVarPoreDiffusion
      variable = H_p
      porosity = eps
      Dx = D_H_p
      Dy = D_H_p
      Dz = D_H_p
      block = 'neg_electrode pos_electrode'
  [../]
  [./Hp_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = H_p
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_H_p
      Dy = D_H_p
      Dz = D_H_p
      block = 'neg_electrode pos_electrode'
  [../]

  # reaction kernels for positive electrode
  #       Rxn:    V(IV) (+ H2O) <---> V(V) (+ 2 H+ ) + e-
  [./Hp_pos_rxn]
    type = ScaledWeightedCoupledSumFunction
    variable = H_p
    coupled_list = 'r_pos'
    weights = '2'
    scale = As
    block = 'pos_electrode'
  [../]


  ### ==================== V2+ Transport ==========================
  # Divided Sub-domain kernels
  [./V2p_dot_electrodes]
      type = VariableCoefTimeDerivative
      variable = V_II
      coupled_coef = eps
      block = 'neg_electrode'
  [../]

  # Transport kernels
  #     vel is Darcy vel so no eps correction
  [./V2p_gdiff]
      type = GVarPoreDiffusion
      variable = V_II
      porosity = eps
      Dx = D_V_II
      Dy = D_V_II
      Dz = D_V_II
  [../]
  [./V2p_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = V_II
      valence = 2
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_V_II
      Dy = D_V_II
      Dz = D_V_II
  [../]

  # reaction kernels for positive electrode
  #       Rxn:    V(II) <---> V(III) + e-
  [./V2p_pos_rxn]
      type = ScaledWeightedCoupledSumFunction
      variable = V_II
      coupled_list = 'r_neg'
      weights = '-1'
      scale = As
      block = 'neg_electrode'
  [../]


  ### ==================== V3+ Transport ==========================
  # Divided Sub-domain kernels
  [./V3p_dot_electrodes]
      type = VariableCoefTimeDerivative
      variable = V_III
      coupled_coef = eps
      block = 'neg_electrode'
  [../]

  # Transport kernels
  #     vel is Darcy vel so no eps correction
  [./V3p_gdiff]
      type = GVarPoreDiffusion
      variable = V_III
      porosity = eps
      Dx = D_V_III
      Dy = D_V_III
      Dz = D_V_III
  [../]
  [./V3p_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = V_III
      valence = 3
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_V_III
      Dy = D_V_III
      Dz = D_V_III
  [../]

  # reaction kernels for positive electrode
  #       Rxn:    V(II) <---> V(III) + e-
  [./V3p_pos_rxn]
      type = ScaledWeightedCoupledSumFunction
      variable = V_III
      coupled_list = 'r_neg'
      weights = '1'
      scale = As
      block = 'neg_electrode'
  [../]


  ### ==================== VO_2+ Transport ==========================
  # Divided Sub-domain kernels
  [./VO_2p_dot_electrodes]
      type = VariableCoefTimeDerivative
      variable = V_IV
      coupled_coef = eps
      block = 'pos_electrode'
  [../]

  # Transport kernels
  #     vel is Darcy vel so no eps correction
  [./VO_2p_gdiff]
      type = GVarPoreDiffusion
      variable = V_IV
      porosity = eps
      Dx = D_V_IV
      Dy = D_V_IV
      Dz = D_V_IV
  [../]
  [./VO_2p_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = V_IV
      valence = 2
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_V_IV
      Dy = D_V_IV
      Dz = D_V_IV
  [../]

  # reaction kernels for positive electrode
  #       Rxn:    V(IV) (+ H2O) <---> V(V) (+ 2 H+ ) + e-
  [./VO_2p_pos_rxn]
      type = ScaledWeightedCoupledSumFunction
      variable = V_IV
      coupled_list = 'r_pos'
      weights = '-1'
      scale = As
      block = 'pos_electrode'
  [../]


  ### ==================== VO2_+ Transport ==========================
  # Divided Sub-domain kernels
  [./VO2_p_dot_electrodes]
      type = VariableCoefTimeDerivative
      variable = V_V
      coupled_coef = eps
      block = 'pos_electrode'
  [../]

  # Transport kernels
  #     vel is Darcy vel so no eps corrections
  [./VO2_p_gdiff]
      type = GVarPoreDiffusion
      variable = V_V
      porosity = eps
      Dx = D_V_V
      Dy = D_V_V
      Dz = D_V_V
  [../]
  [./VO2_p_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = V_V
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_V_V
      Dy = D_V_V
      Dz = D_V_V
  [../]

  # reaction kernels for positive electrode
  #       Rxn:    V(IV) (+ H2O) <---> V(V) (+ 2 H+ ) + e-
  [./VO2_p_pos_rxn]
      type = ScaledWeightedCoupledSumFunction
      variable = V_V
      coupled_list = 'r_pos'
      weights = '1'
      scale = As
      block = 'pos_electrode'
  [../]


  ## ============= Energy Balance in Electrolyte =============== ##
  [./Ef_dot]
      type = VariableCoefTimeDerivative
      variable = E_f
      coupled_coef = eps
  [../]
  [./Ef_gdiff]
      type = GPhaseThermalConductivity
      variable = E_f
      temperature = T_e
      volume_frac = eps
      Dx = K_f
      Dy = K_f
      Dz = K_f
  [../]
  [./Ef_trans]
      type = PhaseEnergyTransfer
      variable = E_f
      this_phase_temp = T_e
      other_phase_temp = T_s
      transfer_coef = h
      specific_area = As
      volume_frac = 1
      block = 'pos_electrode neg_electrode'
  [../]
  [./Ef_ohmic_term_neg_electrode]
      type = GElectrolyteOhmicHeating
      variable = E_f
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p V_II V_III'
      diffusion = 'D_H_p D_V_II D_V_III'
      ion_valence = '1 2 3'
      block = 'neg_electrode'
  [../]
  [./Ef_ohmic_term_pos_electrode]
      type = GElectrolyteOhmicHeating
      variable = E_f
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p V_IV V_V'
      diffusion = 'D_H_p D_V_IV D_V_V'
      ion_valence = '1 2 1'
      block = 'pos_electrode'
  [../]
  [./Ef_ohmic_term_membrane]
      type = GElectrolyteOhmicHeating
      variable = E_f
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p'
      ion_valence = '1'
      diffusion = 'D_H_p'
      block = 'membrane'
  [../]

  [./Tf_calc]
      type = PhaseTemperature
      variable = T_e
      energy = E_f
      specific_heat = cp_f
      density = rho_f
  [../]

  ## ============= Energy Balance in Electrode =============== ##
  [./Es_dot]
      type = VariableCoefTimeDerivative
      variable = E_s
      coupled_coef = sol_frac
  [../]
  [./Es_gdiff]
      type = GPhaseThermalConductivity
      variable = E_s
      temperature = T_s
      volume_frac = sol_frac
      Dx = K_s
      Dy = K_s
      Dz = K_s
  [../]
  [./Es_trans]
      type = PhaseEnergyTransfer
      variable = E_s
      this_phase_temp = T_s
      other_phase_temp = T_e
      transfer_coef = h
      specific_area = As
      volume_frac = 1
      block = 'pos_electrode neg_electrode'
  [../]
  [./Es_ohmic_term_electrode]
      type = GElectrodeOhmicHeating
      variable = E_s
      electric_potential = phi_s
      solid_frac = eff_sol_vol
      conductivity = sigma_s
      block = 'neg_electrode pos_electrode'
  [../]
  [./Es_ohmic_term_collector]
      type = GElectrodeOhmicHeating
      variable = E_s
      electric_potential = phi_s
      solid_frac = 1
      conductivity = sigma_c
      block = 'neg_collector pos_collector'
  [../]

  [./Ts_calc]
      type = PhaseTemperature
      variable = T_s
      energy = E_s
      specific_heat = cp_s
      density = rho_s
  [../]
[]

[DGKernels]

[]

[AuxKernels]

  ### ==================== Variations in eps =====================
  # in electrode
  [./eps_elec]
      type = ConstantAux
      variable = eps
      value = 0.68

      execute_on = 'initial timestep_end'
      block = 'neg_electrode pos_electrode'
  [../]

  [./sol_frac_elec]
      type = ConstantAux
      variable = sol_frac
      value = 0.32

      execute_on = 'initial timestep_end'
      block = 'neg_electrode pos_electrode'
  [../]

  [./sol_frac_coll]
      type = ConstantAux
      variable = sol_frac
      value = 0.999

      execute_on = 'initial timestep_end'
      block = 'neg_collector pos_collector'
  [../]

  # in membrane
  [./eps_mem]
      type = ConstantAux
      variable = eps
      value = 0.999

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  ### ==================== Variations in D_H2O =====================
  # Units: cm^2/min  (D = 2.3E-9 m^2/s in electrode, Deff = 5.75E-10 m^2/s in membrane)
  # in electrode (D*eps^0.5)
  [./D_H2O_elec]
      type = ConstantAux
      variable = D_H2O
      value = 0.0011379772

      execute_on = 'initial timestep_end'
      block = 'neg_electrode pos_electrode'
  [../]

  # in membrane (Deff)
  [./D_H2O_mem]
      type = ConstantAux
      variable = D_H2O
      value = 3.45E-4

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  ### ==================== Variations in D_H_p =====================
  # Units: cm^2/min  (D = 9.31E-9 m^2/s in electrode, Deff = 1.4E-9 m^2/s in membrane)
  # in electrode (D*eps^0.5)
  [./D_H_p_elec]
      type = ConstantAux
      variable = D_H_p
      value = 0.0046063336

      execute_on = 'initial timestep_end'
      block = 'neg_electrode pos_electrode'
  [../]

  # in membrane (Deff)
  [./D_H_p_mem]
      type = ConstantAux
      variable = D_H_p
      value = 8.40E-4

      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./Keff_calc_neg_electrodes]
      type = ElectrolyteConductivity
      variable = Keff
      temperature = T_e
      ion_conc = 'H_p V_II V_III'
      diffusion = 'D_H_p D_V_II D_V_III'
      ion_valence = '1 2 3'
      execute_on = 'initial timestep_end'
      block = 'neg_electrode'
  [../]

  [./Keff_calc_pos_electrodes]
      type = ElectrolyteConductivity
      variable = Keff
      temperature = T_e
      ion_conc = 'H_p V_IV V_V'
      diffusion = 'D_H_p D_V_IV D_V_V'
      ion_valence = '1 2 1'
      execute_on = 'initial timestep_end'
      block = 'pos_electrode'
  [../]

  [./Keff_calc_membrane]
      type = ElectrolyteConductivity
      variable = Keff
      temperature = T_e
      ion_conc = 'H_p'
      diffusion = 'D_H_p'
      ion_valence = '1'
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  # ================== Charge Discharge Cycle ==================
  # Case: time: 0 - 4 min (charging at 10 A)
  #       time: 4 - 6 min (zero current pull)
  #       time: 6 - 10 min (discharging at 10 A)
  [./step_input_fr_charge]
      type = TemporalStepFunction
      variable = current_input
      start_value = 6
      aux_vals = '0 -6'
      aux_times = '4 6'
      time_spans = '0.0 0.0'
      execute_on = 'initial timestep_begin nonlinear'
  [../]

[]

[BCs]
  ### ==================== Solid Potentials ==========================
  # Applied current on the neg & pos collector plates
  #   NOTE: SIGNS ARE REVERSED FOR DISCHARGING

  # ---- Fix a 'ground' state on one side of the system -------
  #   (This BC type may be more numerically stable)
  [./phi_s_neg_side_dirichlet]
      type = CoupledDirichletBC
      variable = phi_s
      boundary = 'neg_collector_left'
      #
      ## edge value was defined at 0.131 V
      # From literature [1], the ground state is off-set by 0.131 V
      coupled = 0.131
  [../]

  # ---- Set current density entering and match with current density leaving -------
  [./phi_s_pos_side_current_charging]
      type = CoupledNeumannBC
      variable = phi_s
      boundary = 'pos_collector_right'

      ## I/a for charging (where I=current = 10 A && a=surface area = 10cm x 10cm)
      # 1 A = 1 C/s ==>  10 A = 600 C/min
      # value = I/A = 6 C/min/cm^2
      coupled = current_input
  [../]


  ### ==================== H2O ==========================


  ### ==================== H+ ==========================


  # This BC facilitates the 'jumping' of protons across the membrane
  #   while maintaining the total proton concentration inside the
  #   membrane itself as a constant value.
  #
  #   NOTE: An alternative is to turn this BC off, but turn back on
  #         the diffusion fluxes for protons in the Kernels and DGKernels.
  #         Each way gives fairly similar results.
  [./Hp_MembraneFlux]
      type = DGDiffuseFlowMassFluxBC
      variable = H_p
      boundary = 'neg_electrode_interface_membrane membrane_interface_pos_electrode'
      porosity = eps
      Dx = D_H_p
      Dy = D_H_p
      Dz = D_H_p
      input_var = 0.0012   # Concentration of protons in membrane
  [../]


  ### ==================== V2+ ==========================


  ### ==================== V3+ ==========================


  ### ==================== VO_2+ ==========================


  ### ==================== VO2_+ ==========================


  ### ============ Wall Temperature Controls =============== ###
  [./Ef_WallFluxIn]
      type = DGWallEnergyFluxBC
      variable = E_f
      boundary = 'neg_electrode_bottom neg_electrode_top
                  pos_electrode_bottom pos_electrode_top
                  membrane_bottom membrane_top'
      transfer_coef = hw
      wall_temp = T_w
      temperature = T_e
      area_frac = eps
  [../]

  [./Es_WallFluxIn]
      type = DGWallEnergyFluxBC
      variable = E_s
      boundary = 'neg_collector_left pos_collector_right
                  neg_electrode_bottom neg_electrode_top
                  pos_electrode_bottom pos_electrode_top'
      transfer_coef = hw
      wall_temp = T_w
      temperature = T_s
      area_frac = sol_frac
  [../]

[]


[Postprocessors]

  [./phi_s_pos_collector]
      type = ElementAverageValue
      block = 'pos_collector'
      variable = phi_s
      execute_on = 'initial timestep_end'
  [../]

  [./V_II_neg]
      type = ElementAverageValue
      block = 'neg_electrode'
      variable = V_II
      execute_on = 'initial timestep_end'
  [../]

  [./V_III_neg]
      type = ElementAverageValue
      block = 'neg_electrode'
      variable = V_III
      execute_on = 'initial timestep_end'
  [../]

  [./V_IV_pos]
      type = ElementAverageValue
      block = 'pos_electrode'
      variable = V_IV
      execute_on = 'initial timestep_end'
  [../]

  [./V_V_pos]
      type = ElementAverageValue
      block = 'pos_electrode'
      variable = V_V
      execute_on = 'initial timestep_end'
  [../]

  [./current_input]
      type = SideAverageValue
      boundary = 'pos_collector_right'
      variable = current_input
      execute_on = 'initial timestep_end'
  [../]

  [./T_s_neg]
      type = ElementAverageValue
      block = 'neg_electrode'
      variable = T_s
      execute_on = 'initial timestep_end'
  [../]

  [./T_s_pos]
      type = ElementAverageValue
      block = 'pos_electrode'
      variable = T_s
      execute_on = 'initial timestep_end'
  [../]

  [./T_e_neg]
      type = ElementAverageValue
      block = 'neg_electrode'
      variable = T_e
      execute_on = 'initial timestep_end'
  [../]

  [./T_e_pos]
      type = ElementAverageValue
      block = 'pos_electrode'
      variable = T_e
      execute_on = 'initial timestep_end'
  [../]

[]

[Executioner]
  type = Transient
  scheme = implicit-euler

  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason
                   -snes_linesearch_monitor

                    -ksp_gmres_modifiedgramschmidt
                    -ksp_ksp_gmres_modifiedgramschmidt'

  # NOTE: The sub_pc_type arg not used if pc_type is ksp,
  #       Instead, set the ksp_ksp_type to the pc method
  #       you want. Then, also set the ksp_pc_type to be
  #       the terminal preconditioner.
  #
  # Good terminal precon options: lu, ilu, asm, gasm, pbjacobi
  #                               bjacobi, redundant, telescope
  #
  # NOTE: -ksp_pc_factor_mat_solver_type == (mumps or superlu_dist)
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

                        -ksp_atol
                        -ksp_rtol'

  ### NOTE:
  #   -mat_mumps_cntl_1  = Relative Pivot Tolerance (accepts column entry as pivot if value >= Tolerance)
  #   -mat_mumps_cntl_3  = Absolute Pivot Tolerance
  #   -mat_mumps_icntl_23 = Max Factorization Memory for Pivoting (MB)

  ## NOTE: May be best to just use lu as pc_type instead of ksp
  petsc_options_value = 'fgmres
                         lu

                         lu

                         50

                         NONZERO
                         NONZERO
                         NONZERO

                         10

                         1E-6
                         1E-8

                         fgmres
                         lu

                         30
                         30

                         30
                         30

                         1e-6
                         1e-8'

  line_search = none

  ## NOTE: For sudden changes in current, may need to reduce max time step
  start_time = 0
  end_time = 9.5
  dtmax = 0.5
  dtmin = 1e-6

  # First few times step needs to be fairly small, but afterwards can accelerate
  #   Current setup: Increase/decrease step size by 50% of prior step
  #
  #   NOTE: May need a custom time stepper since this one may actually reduce
  #     the step size even on successful step. It depends on what your needs
  #     are in terms of accuracy vs computational efficiency.
  [./TimeStepper]
		  type = IterationAdaptiveDT
      dt = 0.25
  [../]

[] #END Executioner

[Preconditioning]
    [./SMP_PJFNK]
      type = SMP
      full = true
      trust_my_coupling = true
      coupled_groups = 'phi_s,J_neg phi_s,J_pos
                        phi_e,J_neg phi_e,J_pos
                        phi_diff,phi_s phi_diff,phi_e
                        J_neg,r_neg J_pos,r_pos
                        H2O,r_pos H_p,r_pos
                        V_IV,r_pos V_V,r_pos
                        V_II,r_neg V_III,r_neg
                        H_p,phi_e
                        V_IV,phi_e V_V,phi_e
                        V_II,phi_e V_III,phi_e'
      solve_type = pjfnk
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = true

[] #END Outputs
