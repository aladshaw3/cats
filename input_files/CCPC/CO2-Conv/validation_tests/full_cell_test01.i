## This example file runs the full cell test with all variables coupled
#
#     To maximize stability, all variables should be MONOMIAL except for
#         * pressure
#         * phi_s
#         * phi_e
#
#     These above variables are Poisson/Laplacian Dominated processes and are
#         easier to model with CGFE with LAGRANGE shape functions.
#
#     All other variables should be DGFE with MONOMIAL shape functions to maximize
#         stability and create sharper/smoother results nearest the interfaces.
#
#         - This mixing of methods appears to be relatively efficient and stable
#             (good stability comes from DGFE, but makes the problem size larger)
#             (good efficiency comes from CGFE, but makes the problem less stable)
#             (efficiency is improved with proper Jacobians/PC and good ICs/states)


#### NOTES ####
#
#   Expected voltage at time 0 is CORRECT!!!
#     Literature reports expected voltage of ~1.6 V
#     We calculate ~1.47 V  -HOWEVER-
#     Literature also reports a total vertical shift of 0.131 V
#     due to contact resistances between the electrode and current
#     collectors. Thus, our voltage of 1.47 + 0.131 should compare
#     to their results: 1.47+0.131 = ~1.6 V == 1.6 V (lit)

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
      initial_condition = 0
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # pressure
  [./pressure]
      order = FIRST
      family = LAGRANGE
      initial_condition = 300 # kPa
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # velocity in x
  [./vel_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # velocity in y
  [./vel_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # reaction variable for negative electrode
  #       Rxn:    V(II) <---> V(III) + e-
  [./r_neg]
      order = FIRST
      family = MONOMIAL
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
      family = MONOMIAL
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
      family = MONOMIAL
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
      family = MONOMIAL
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
      family = MONOMIAL
      block = 'neg_electrode pos_electrode'
      [./InitialCondition]
          type = InitialPotentialDifference
          electrode_potential = phi_s
          electrolyte_potential = phi_e
      [../]
  [../]

  # Electrolyte current density in x (C/cm^2/min)
  [./ie_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # Electrolyte current density in y (C/cm^2/min)
  [./ie_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # electrode current density in x (C/cm^2/min)
  [./is_x]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

  # electrode current density in y (C/cm^2/min)
  [./is_y]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1e-20
      block = 'neg_collector neg_electrode pos_electrode pos_collector'
  [../]

  # H2O
  [./H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0042 #mol/cm^3
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # H+
  [./H_p]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #mol/cm^3
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # HSO4-
  [./HSO4_m]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #mol/cm^3
      block = 'neg_electrode pos_electrode'
  [../]

  # V2+
  [./V_II]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.000027 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # V3+
  [./V_III]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001053 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # VO_2+
  [./V_IV]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001053 #mol/cm^3
      block = 'pos_electrode'
  [../]

  # VO2_+
  [./V_V]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.000027 #mol/cm^3
      block = 'pos_electrode'
  [../]

[]

[AuxVariables]

  # H2O
  [./H2O_inlet_pos]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0042 #mol/cm^3
      block = 'pos_electrode'
  [../]
  [./H2O_inlet_neg]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0042 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # H+
  [./H_p_inlet_pos]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #mol/cm^3
      block = 'pos_electrode'
  [../]
  [./H_p_inlet_neg]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # HSO4-
  [./HSO4_m_inlet_pos]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #mol/cm^3
      block = 'pos_electrode'
  [../]
  [./HSO4_m_inlet_neg]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # V2+
  [./V_II_inlet]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.000027 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # V3+
  [./V_III_inlet]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001053 #mol/cm^3
      block = 'neg_electrode'
  [../]

  # VO_2+
  [./V_IV_inlet]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.001053 #mol/cm^3
      block = 'pos_electrode'
  [../]

  # VO2_+
  [./V_V_inlet]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.000027 #mol/cm^3
      block = 'pos_electrode'
  [../]

  # Diffusivities
  [./D_H2O]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #cm^2/min
      block = 'neg_electrode membrane pos_electrode'
  [../]
  [./D_H_p]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0012 #cm^2/min
      block = 'neg_electrode membrane pos_electrode'
  [../]
  [./D_HSO4_m]
      order = FIRST
      family = MONOMIAL
      initial_condition = 6.0857E-4 #cm^2/min
      block = 'neg_electrode pos_electrode'
  [../]
  [./D_V_II]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.18745E-4 #cm^2/min
      block = 'neg_electrode'
  [../]
  [./D_V_III]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.18745E-4 #cm^2/min
      block = 'neg_electrode'
  [../]
  [./D_V_IV]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.9296E-4 #cm^2/min
      block = 'pos_electrode'
  [../]
  [./D_V_V]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.9296E-4 #cm^2/min
      block = 'pos_electrode'
  [../]

  # electrode porosity (switch to 1 inside membrane)
  [./eps]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.68
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # effective solid volume (1-eps)^(3/2)
  [./eff_sol_vol]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.18101936
      block = 'neg_electrode pos_electrode'
  [../]

  # velocity in z
  [./vel_z]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.0
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # water viscosity
  [./viscosity]
      order = FIRST
      family = MONOMIAL
      initial_condition = 1.667E-8 # kPa*min
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # electrolyte temperature
  [./T_e]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300 # K
      block = 'neg_electrode membrane pos_electrode'
  [../]

  # solid temperature (may need separate T for membrane?)
  [./T_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300 # K
      block = 'neg_collector neg_electrode membrane pos_electrode pos_collector'
  [../]

  # electrode conductivity (C/V/cm/min)
  [./sigma_s]
      order = FIRST
      family = MONOMIAL
      initial_condition = 300     # 500 S/m  : 1 S = 1 A/V = 1 C/V/s
      block = 'neg_electrode pos_electrode'
  [../]

  # collector conductivity (C/V/cm/min)
  [./sigma_c]
      order = FIRST
      family = MONOMIAL
      initial_condition = 600  # 1000 S/m  : 1 S = 1 A/V = 1 C/V/s
      block = 'neg_collector pos_collector'
  [../]

  # = (df^2/K/mu) * (eps^3/(1-eps)^2)  [cm^2/kPa/min]
  #
  #   df = 0.001 cm
  #   mu = 1.667E-8 kPa*min (10^-3 Pa*s)
  #   K = 5.55
  #   eps = 0.68
  [./DarcyCoeff]
      order = FIRST
      family = MONOMIAL
      initial_condition = 33.189
      block = 'neg_electrode pos_electrode'
  [../]

  # = kp / mu   [cm^2/kPa/min]
  #
  #   kp = 1.58E-14 cm^2
  #   mu = 1.667E-8 kPa*min (10^-3 Pa*s)
  [./SchloeglCoeff]
      order = FIRST
      family = MONOMIAL
      initial_condition = 9.4798E-7
      block = 'membrane'
  [../]

  # = (ko / mu) * (F*C) * f   [(cm^2/kPa/min) * (C/mol * mol/cm^3) * (kPa*cm^3/J)] = [C*cm^2/J/min]
  #
  #   ko = 1.13E-15 cm^2
  #   mu = 1.667E-8 kPa*min (10^-3 Pa*s)
  #
  #   F = 96,485.3 C/mol
  #   C = 0.0012 mol/cm^3 (should be coupled variable)
  #
  #   f = conversion factor necessary to deal with complex units
  #     = 0.001 kPa*cm^3/J
  #       [Will ultimately depend on units defined by all other variables]
  [./SchloeglElecCoeff]
      order = FIRST
      family = MONOMIAL
      initial_condition = 7.8485E-9
      block = 'membrane'
  [../]

  #Specific surface area
  [./As]
    order = FIRST
    family = MONOMIAL
    initial_condition = 2E4  # cm^-1
    block = 'neg_electrode pos_electrode'
  [../]

  #Specific surface area (adjusted = As * eps)
  #   NOT used or needed
  [./As_eps]
    order = FIRST
    family = MONOMIAL
    initial_condition = 13600  # cm^-1
    block = 'neg_electrode pos_electrode'
  [../]

  # Keff calculation to check values for problems
  #   Just to check some computed values
  [./Keff]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0 # C/V/cm/min
      block = 'neg_electrode membrane pos_electrode'
  [../]
[]

[ICs]
  ### ==================== Solid Potentials ==========================
  [./phi_s_neg_side]
      type = ConstantIC
      variable = phi_s
      value = -0.255 # in V
      block = 'neg_collector neg_electrode'
  [../]
  [./phi_s_pos_side]
      type = ConstantIC
      variable = phi_s
      value = 1.004 # in V
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
  [./phi_e_ionic_conductivity_in_neg_electrodes]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = eps
      ion_conc = 'H_p V_II V_III'
      diffusion = 'D_H_p D_V_II D_V_III'
      ion_valence = '1 2 3'
      block = 'neg_electrode'
  [../]
  [./phi_e_ionic_conductivity_in_pos_electrodes]
      type = ElectrolyteIonConductivity
      variable = phi_e
      porosity = eps
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

  ### ==================== Pressure Gradients ==========================
  # in electrodes
  [./pressure_laplace_electrodes]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = DarcyCoeff
      block = 'neg_electrode pos_electrode'
  [../]

  # in membrane
  [./pressure_laplace_membrane]
      type = VariableLaplacian
      variable = pressure
      coupled_coef = SchloeglCoeff
      block = 'membrane'
  [../]

  ### ==================== Fluid Velocities ==========================
  # equals sign
  [./v_x_equ]
      type = Reaction
      variable = vel_x
  [../]
  [./v_y_equ]
      type = Reaction
      variable = vel_y
  [../]

  # in electrodes
  [./x_darcy]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = DarcyCoeff
      block = 'neg_electrode pos_electrode'
  [../]

  [./y_darcy]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = DarcyCoeff
      block = 'neg_electrode pos_electrode'
  [../]

  # in membrane
  [./x_schloegl]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = pressure
      ux = SchloeglCoeff
      block = 'membrane'
  [../]
  [./x_schloegl_ele]
      type = VariableVectorCoupledGradient
      variable = vel_x
      coupled = phi_e
      ux = SchloeglElecCoeff
      block = 'membrane'
  [../]

  [./y_schloegl]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = pressure
      uy = SchloeglCoeff
      block = 'membrane'
  [../]
  [./y_schloegl_ele]
      type = VariableVectorCoupledGradient
      variable = vel_y
      coupled = phi_e
      uy = SchloeglElecCoeff
      block = 'membrane'
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


  ### ===================== Electrolyte Current ======================
  # --------------- Current density in x-dir from potential gradient ------------
  #  ie_x
  [./ie_x_equ]
      type = Reaction
      variable = ie_x
  [../]

  #  -K*grad(phi_e)_x   where K=f(ions, diff, etc....)
  [./ie_x_phigrad_neg_electrode]
      type = ElectrolyteCurrentFromPotentialGradient
      variable = ie_x
      direction = 0         # 0=x
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p V_II V_III'
      diffusion = 'D_H_p D_V_II D_V_III'
      ion_valence = '1 2 3'
      block = 'neg_electrode'
  [../]

  #  -K*grad(phi_e)_x   where K=f(ions, diff, etc....)
  [./ie_x_phigrad_pos_electrode]
      type = ElectrolyteCurrentFromPotentialGradient
      variable = ie_x
      direction = 0         # 0=x
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p V_IV V_V'
      diffusion = 'D_H_p D_V_IV D_V_V'
      ion_valence = '1 2 1'
      block = 'pos_electrode'
  [../]

  #  -K*grad(phi_e)_x   where K=f(ions, diff, etc....)
  [./ie_x_phigrad_membrane]
      type = ElectrolyteCurrentFromPotentialGradient
      variable = ie_x
      direction = 0         # 0=x
      electric_potential = phi_e
      porosity = 1
      temperature = T_e
      ion_conc = 'H_p'
      ion_valence = '1'
      diffusion = 'D_H_p'
      block = 'membrane'
  [../]

  #  -F*eps*SUM( zj*Dj*grad(ion)_x )
  [./ie_x_iongrad_neg_electrode]
      type = ElectrolyteCurrentFromIonGradient
      variable = ie_x
      direction = 0         # 0=x
      porosity = eps
      ion_conc = 'H_p V_II V_III'
      diffusion = 'D_H_p D_V_II D_V_III'
      ion_valence = '1 2 3'
      block = 'neg_electrode'
  [../]

  #  -F*eps*SUM( zj*Dj*grad(ion)_x )
  [./ie_x_iongrad_pos_electrode]
      type = ElectrolyteCurrentFromIonGradient
      variable = ie_x
      direction = 0         # 0=x
      porosity = eps
      ion_conc = 'H_p V_IV V_V'
      diffusion = 'D_H_p D_V_IV D_V_V'
      ion_valence = '1 2 1'
      block = 'pos_electrode'
  [../]


  # --------------- Current density in y-dir from potential gradient ---------------
  #  ie_y
  [./ie_y_equ]
      type = Reaction
      variable = ie_y
  [../]

  #  -K*grad(phi_e)_y   where K=f(ions, diff, etc....)
  [./ie_y_phigrad_neg_electrode]
      type = ElectrolyteCurrentFromPotentialGradient
      variable = ie_y
      direction = 1         # 1=y
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p V_II V_III'
      diffusion = 'D_H_p D_V_II D_V_III'
      ion_valence = '1 2 3'
      block = 'neg_electrode'
  [../]

  #  -K*grad(phi_e)_y   where K=f(ions, diff, etc....)
  [./ie_y_phigrad_pos_electrode]
      type = ElectrolyteCurrentFromPotentialGradient
      variable = ie_y
      direction = 1         # 1=y
      electric_potential = phi_e
      porosity = eps
      temperature = T_e
      ion_conc = 'H_p V_IV V_V'
      diffusion = 'D_H_p D_V_IV D_V_V'
      ion_valence = '1 2 1'
      block = 'pos_electrode'
  [../]

  #  -K*grad(phi_e)_y   where K=f(ions, diff, etc....)
  [./ie_y_phigrad_membrane]
      type = ElectrolyteCurrentFromPotentialGradient
      variable = ie_y
      direction = 1         # 1=y
      electric_potential = phi_e
      porosity = 1
      temperature = T_e
      ion_conc = 'H_p'
      ion_valence = '1'
      diffusion = 'D_H_p'
      block = 'membrane'
  [../]

  #  -F*eps*SUM( zj*Dj*grad(ion)_y )
  [./ie_y_iongrad_neg_electrode]
      type = ElectrolyteCurrentFromIonGradient
      variable = ie_y
      direction = 1         # 1=y
      porosity = eps
      ion_conc = 'H_p V_II V_III'
      diffusion = 'D_H_p D_V_II D_V_III'
      ion_valence = '1 2 3'
      block = 'neg_electrode'
  [../]

  #  -F*eps*SUM( zj*Dj*grad(ion)_y )
  [./ie_y_iongrad_pos_electrode]
      type = ElectrolyteCurrentFromIonGradient
      variable = ie_y
      direction = 1         # 1=y
      porosity = eps
      ion_conc = 'H_p V_IV V_V'
      diffusion = 'D_H_p D_V_IV D_V_V'
      ion_valence = '1 2 1'
      block = 'pos_electrode'
  [../]

  ### ======================= Electrode/Collector Current ==================
  # -------------- Current density in x-dir from potential gradient --------------
  #  is_x
  [./is_x_equ]
      type = Reaction
      variable = is_x
  [../]

  #  -sigma*(1-eps)*grad(phi_s)_x
  [./is_x_phigrad_electrode]
      type = ElectrodeCurrentFromPotentialGradient
      variable = is_x
      direction = 0         # 0=x
      electric_potential = phi_s
      solid_frac = eff_sol_vol
      conductivity = sigma_s
      block = 'neg_electrode pos_electrode'
  [../]

  #  -sigma*(1-eps)*grad(phi_s)_x
  [./is_x_phigrad_collector]
      type = ElectrodeCurrentFromPotentialGradient
      variable = is_x
      direction = 0         # 0=x
      electric_potential = phi_s
      solid_frac = 1
      conductivity = sigma_c
      block = 'neg_collector pos_collector'
  [../]

  # ----------------- Current density in y-dir from potential gradient ----------------
  #  is_y
  [./is_y_equ]
      type = Reaction
      variable = is_y
  [../]

  #  -sigma*(1-eps)*grad(phi_s)_y
  [./is_y_phigrad_electrode]
      type = ElectrodeCurrentFromPotentialGradient
      variable = is_y
      direction = 1         # 1=y
      electric_potential = phi_s
      solid_frac = eff_sol_vol
      conductivity = sigma_s
      block = 'neg_electrode pos_electrode'
  [../]

  #  -sigma*(1-eps)*grad(phi_s)_y
  [./is_y_phigrad_collector]
      type = ElectrodeCurrentFromPotentialGradient
      variable = is_y
      direction = 1         # 1=y
      electric_potential = phi_s
      solid_frac = 1
      conductivity = sigma_c
      block = 'neg_collector pos_collector'
  [../]


  ### ==================== H2O Transport ==========================
  # DG methods must apply same equations to full transport space for connectivity
  #   Non-transport kernels (such as reactions and time derivatives) are allowed
  #   to be different in each sub-domain, but the transport kernels (such as
  #   advection and diffusion) must be the same.

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
  ### NOTE ###
  #
  #     May need to force a new velocity term for JUST Hp
  #     such than vel inside membrane is zero
  [./Hp_gadv]
      type = GPoreConcAdvection
      variable = H_p
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./Hp_gdiff]
      type = GVarPoreDiffusion
      variable = H_p
      porosity = eps
      Dx = D_H_p
      Dy = D_H_p
      Dz = D_H_p
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


  ### ==================== HSO4- Transport ==========================
  # Divided Sub-domain kernels
  [./HSO4m_dot_electrodes]
      type = VariableCoefTimeDerivative
      variable = HSO4_m
      coupled_coef = eps
      block = 'neg_electrode pos_electrode'
  [../]

  # Transport kernels
  #     vel is Darcy vel so no eps correction
  [./HSO4m_gadv]
      type = GPoreConcAdvection
      variable = HSO4_m
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./HSO4m_gdiff]
      type = GVarPoreDiffusion
      variable = HSO4_m
      porosity = eps
      Dx = D_HSO4_m
      Dy = D_HSO4_m
      Dz = D_HSO4_m
  [../]
  [./HSO4m_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = HSO4_m
      valence = -1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_HSO4_m
      Dy = D_HSO4_m
      Dz = D_HSO4_m
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
  [./V2p_gadv]
      type = GPoreConcAdvection
      variable = V_II
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
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
  [./V3p_gadv]
      type = GPoreConcAdvection
      variable = V_III
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
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
  [./VO_2p_gadv]
      type = GPoreConcAdvection
      variable = V_IV
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
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
  #     vel is Darcy vel so no eps correction
  [./VO2_p_gadv]
      type = GPoreConcAdvection
      variable = V_V
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
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
[]

[DGKernels]
  ### ==================== H2O Transport ==========================
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

  ### ==================== H+ Transport ==========================
  [./Hp_dgadv]
      type = DGPoreConcAdvection
      variable = H_p
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./Hp_dgdiff]
      type = DGVarPoreDiffusion
      variable = H_p
      porosity = eps
      Dx = D_H_p
      Dy = D_H_p
      Dz = D_H_p
  [../]
  [./Hp_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = H_p
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_H_p
      Dy = D_H_p
      Dz = D_H_p
  [../]


  ### ==================== HSO4- Transport ==========================
  [./HSO4m_dgadv]
      type = DGPoreConcAdvection
      variable = HSO4_m
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./HSO4m_dgdiff]
      type = DGVarPoreDiffusion
      variable = HSO4_m
      porosity = eps
      Dx = D_H_p
      Dy = D_H_p
      Dz = D_H_p
  [../]
  [./HSO4m_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = HSO4_m
      valence = -1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_HSO4_m
      Dy = D_HSO4_m
      Dz = D_HSO4_m
  [../]


  ### ==================== V2+ Transport ==========================
  [./V2p_dgadv]
      type = DGPoreConcAdvection
      variable = V_II
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./V2p_dgdiff]
      type = DGVarPoreDiffusion
      variable = V_II
      porosity = eps
      Dx = D_V_II
      Dy = D_V_II
      Dz = D_V_II
  [../]
  [./V2p_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = V_II
      valence = 2
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_V_II
      Dy = D_V_II
      Dz = D_V_II
  [../]


  ### ==================== V3+ Transport ==========================
  [./V3p_dgadv]
      type = DGPoreConcAdvection
      variable = V_III
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./V3p_dgdiff]
      type = DGVarPoreDiffusion
      variable = V_III
      porosity = eps
      Dx = D_V_III
      Dy = D_V_III
      Dz = D_V_III
  [../]
  [./V3p_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = V_III
      valence = 3
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_V_III
      Dy = D_V_III
      Dz = D_V_III
  [../]


  ### ==================== VO_2+ Transport ==========================
  [./VO_2p_dgadv]
      type = DGPoreConcAdvection
      variable = V_IV
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./VO_2p_dgdiff]
      type = DGVarPoreDiffusion
      variable = V_IV
      porosity = eps
      Dx = D_V_IV
      Dy = D_V_IV
      Dz = D_V_IV
  [../]
  [./VO_2p_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = V_IV
      valence = 2
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_V_IV
      Dy = D_V_IV
      Dz = D_V_IV
  [../]


  ### ==================== VO2_+ Transport ==========================
  [./VO2_p_dgadv]
      type = DGPoreConcAdvection
      variable = V_V
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
  [./VO2_p_dgdiff]
      type = DGVarPoreDiffusion
      variable = V_V
      porosity = eps
      Dx = D_V_V
      Dy = D_V_V
      Dz = D_V_V
  [../]
  [./VO2_p_dgnpdiff]
      type = DGNernstPlanckDiffusion
      variable = V_V
      valence = 1
      porosity = eps
      electric_potential = phi_e
      temperature = T_e
      Dx = D_V_V
      Dy = D_V_V
      Dz = D_V_V
  [../]
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

  ### ====================== Darcy Flow Parameters ======================
  #in electrode
  [./darcy_calc]
      type = KozenyCarmanDarcyCoefficient
      variable = DarcyCoeff
      porosity = eps
      viscosity = viscosity
      particle_diameter = 0.001  #cm
      kozeny_carman_const = 5.55
      execute_on = 'initial timestep_end'
      block = 'neg_electrode pos_electrode'
  [../]

  # in membrane
  [./schloegl_darcy_calc]
      type = SchloeglDarcyCoefficient
      variable = SchloeglCoeff
      hydraulic_permeability = 1.58E-14 # cm^2
      viscosity = viscosity             # kPa*min
      execute_on = 'initial timestep_end'
      block = 'membrane'
  [../]

  [./schloegl_ele_calc]
      type = SchloeglElectrokineticCoefficient
      variable = SchloeglElecCoeff
      electrokinetic_permeability = 1.13E-15  # cm^2
      viscosity = viscosity                   # kPa*min
      ion_conc = H_p                       # mol/cm^3
      conversion_factor = 0.001               # kPa*cm^3/J
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

  # ============ Calculation of Conc Inlets =============
  # H2O
  [./H2O_inlet_pos_side]
      type = AuxPostprocessorValue
      variable = H2O_inlet_pos
      postprocessor = H2O_pos_out
      execute_on = 'initial timestep_end'
  [../]
  [./H2O_inlet_neg_side]
      type = AuxPostprocessorValue
      variable = H2O_inlet_neg
      postprocessor = H2O_neg_out
      execute_on = 'initial timestep_end'
  [../]

  # H_p
  [./H_p_inlet_pos_side]
      type = AuxPostprocessorValue
      variable = H_p_inlet_pos
      postprocessor = H_p_pos_out
      execute_on = 'initial timestep_end'
  [../]
  [./H_p_inlet_neg_side]
      type = AuxPostprocessorValue
      variable = H_p_inlet_neg
      postprocessor = H_p_neg_out
      execute_on = 'initial timestep_end'
  [../]

  # HSO4_m
  [./HSO4_m_inlet_pos_side]
      type = AuxPostprocessorValue
      variable = HSO4_m_inlet_pos
      postprocessor = HSO4_m_pos_out
      execute_on = 'initial timestep_end'
  [../]
  [./HSO4_m_inlet_neg_side]
      type = AuxPostprocessorValue
      variable = HSO4_m_inlet_neg
      postprocessor = HSO4_m_neg_out
      execute_on = 'initial timestep_end'
  [../]

  # V_II
  [./V_II_inlet_neg_side]
      type = AuxPostprocessorValue
      variable = V_II_inlet
      postprocessor = V_II_neg_out
      execute_on = 'initial timestep_end'
  [../]

  # V_III
  [./V_III_inlet_neg_side]
      type = AuxPostprocessorValue
      variable = V_III_inlet
      postprocessor = V_III_neg_out
      execute_on = 'initial timestep_end'
  [../]

  # V_IV
  [./V_IV_inlet_pos_side]
      type = AuxPostprocessorValue
      variable = V_IV_inlet
      postprocessor = V_IV_pos_out
      execute_on = 'initial timestep_end'
  [../]

  # V_V
  [./V_V_inlet_pos_side]
      type = AuxPostprocessorValue
      variable = V_V_inlet
      postprocessor = V_V_pos_out
      execute_on = 'initial timestep_end'
  [../]

[]

[BCs]
  ### ==================== Solid Potentials ==========================
  # Applied current on the neg & pos collector plates
  #   NOTE: SIGNS ARE REVERSED FOR DISCHARGING

  # NOTE 2: I CAN have 2 BCs on same side, as long as they are of different types!!!
  # ---- Set current density leaving and match with current density entering -------
  #### NOTE ####
  #   This BC may be redundant and not needed
  #[./phi_s_neg_side_current_charging]
  #    type = CoupledNeumannBC
  #    variable = phi_s
  #    boundary = 'neg_collector_left'
  #    #
  #    ## -I/a for charging (where I=current = 10 A && a=surface area = 10cm x 10cm)
  #    # 1 A = 1 C/s ==>  10 A = 600 C/min
  #    # value = I/A = 6 C/min/cm^2
  #    coupled = -6.0
  #[../]

  # ---- Fix a 'ground' state on one side of the system -------
  #   (This BC type may be more numerically stable)
  [./phi_s_neg_side_dirichlet]
      type = CoupledDirichletBC
      variable = phi_s
      boundary = 'neg_collector_left'
      #
      ## edge value was defined at 0 V
      coupled = 0 # in V
  [../]

  # ---- Set current density entering and match with current density leaving -------
  [./phi_s_pos_side_current_charging]
      type = CoupledNeumannBC
      variable = phi_s
      boundary = 'pos_collector_right'

      ## I/a for charging (where I=current = 10 A && a=surface area = 10cm x 10cm)
      # 1 A = 1 C/s ==>  10 A = 600 C/min
      # value = I/A = 6 C/min/cm^2
      coupled = 6.0
  [../]


  ### ==================== Electrolyte Potentials ==========================
  # zero fluxes are enforced naturally by the CGFE method
  # NOTE: Unclear if we need a mixed Cauchy BC here for conc gradients


  ### ==================== Pressure ==========================
  # exit pressure
  [./press_at_exit]
      type = CoupledDirichletBC
      variable = pressure
      boundary = 'pos_electrode_top neg_electrode_top'
      coupled = 300 # kPa
  [../]

  # inlet pressure gradient from velocity
  [./press_grad_at_inlet]
      type = CoupledNeumannBC
      variable = pressure
      boundary = 'pos_electrode_bottom neg_electrode_bottom'
      coupled = 66   # vel in cm/min (0.37 to 1.1 cm/s)
  [../]


  ### ==================== H2O ==========================
  [./H2O_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = H2O
      boundary = 'pos_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = H2O_inlet_pos
  [../]
  [./H2O_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = H2O
      boundary = 'neg_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = H2O_inlet_neg
  [../]
  [./H2O_FluxOut]
      type = DGFlowMassFluxBC
      variable = H2O
      boundary = 'pos_electrode_top neg_electrode_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]

  ### ==================== H+ ==========================
  [./Hp_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = H_p
      boundary = 'pos_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = H_p_inlet_pos
  [../]
  [./Hp_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = H_p
      boundary = 'neg_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = H_p_inlet_neg
  [../]
  [./Hp_FluxOut]
      type = DGFlowMassFluxBC
      variable = H_p
      boundary = 'pos_electrode_top neg_electrode_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ### ==================== HSO4- ==========================
  [./HSO4m_FluxIn_pos]
      type = DGFlowMassFluxBC
      variable = HSO4_m
      boundary = 'pos_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = HSO4_m_inlet_pos
  [../]
  [./HSO4m_FluxIn_neg]
      type = DGFlowMassFluxBC
      variable = HSO4_m
      boundary = 'neg_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = HSO4_m_inlet_neg
  [../]
  [./HSO4m_FluxOut]
      type = DGFlowMassFluxBC
      variable = HSO4_m
      boundary = 'pos_electrode_top neg_electrode_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ### ==================== V2+ ==========================
  [./V2p_FluxIn]
      type = DGFlowMassFluxBC
      variable = V_II
      boundary = 'neg_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = V_II_inlet
  [../]
  [./V2p_FluxOut]
      type = DGFlowMassFluxBC
      variable = V_II
      boundary = 'neg_electrode_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ### ==================== V3+ ==========================
  [./V3p_FluxIn]
      type = DGFlowMassFluxBC
      variable = V_III
      boundary = 'neg_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = V_III_inlet
  [../]
  [./V3p_FluxOut]
      type = DGFlowMassFluxBC
      variable = V_III
      boundary = 'neg_electrode_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ### ==================== VO_2+ ==========================
  [./VO_2p_FluxIn]
      type = DGFlowMassFluxBC
      variable = V_IV
      boundary = 'pos_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = V_IV_inlet
  [../]
  [./VO_2p_FluxOut]
      type = DGFlowMassFluxBC
      variable = V_IV
      boundary = 'pos_electrode_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]


  ### ==================== VO2_+ ==========================
  [./VO2_p_FluxIn]
      type = DGFlowMassFluxBC
      variable = V_V
      boundary = 'pos_electrode_bottom'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = V_V_inlet
  [../]
  [./VO2_p_FluxOut]
      type = DGFlowMassFluxBC
      variable = V_V
      boundary = 'pos_electrode_top'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
  [../]
[]


[Postprocessors]

  [./phi_s_pos_collector]
      type = SideAverageValue
      boundary = 'pos_collector_right'
      variable = phi_s
      execute_on = 'initial timestep_end'
  [../]

  [./phi_s_pos_electrode]
      type = SideAverageValue
      boundary = 'pos_electrode_interface_pos_collector'
      variable = phi_s
      execute_on = 'initial timestep_end'
  [../]

  [./H_p_mem]
      type = ElementAverageValue
      block = 'membrane'
      variable = H_p
      execute_on = 'initial timestep_end'
  [../]

  [./H2O_neg_out]
      type = SideAverageValue
      boundary = 'neg_electrode_top'
      variable = H2O
      execute_on = 'initial timestep_end'
  [../]

  [./H2O_pos_out]
      type = SideAverageValue
      boundary = 'pos_electrode_top'
      variable = H2O
      execute_on = 'initial timestep_end'
  [../]

  [./H_p_neg_out]
      type = SideAverageValue
      boundary = 'neg_electrode_top'
      variable = H_p
      execute_on = 'initial timestep_end'
  [../]

  [./H_p_pos_out]
      type = SideAverageValue
      boundary = 'pos_electrode_top'
      variable = H_p
      execute_on = 'initial timestep_end'
  [../]

  [./HSO4_m_neg_out]
      type = SideAverageValue
      boundary = 'neg_electrode_top'
      variable = HSO4_m
      execute_on = 'initial timestep_end'
  [../]

  [./HSO4_m_pos_out]
      type = SideAverageValue
      boundary = 'pos_electrode_top'
      variable = HSO4_m
      execute_on = 'initial timestep_end'
  [../]

  [./V_II_neg_out]
      type = SideAverageValue
      boundary = 'neg_electrode_top'
      variable = V_II
      execute_on = 'initial timestep_end'
  [../]

  [./V_III_neg_out]
      type = SideAverageValue
      boundary = 'neg_electrode_top'
      variable = V_III
      execute_on = 'initial timestep_end'
  [../]

  [./V_IV_pos_out]
      type = SideAverageValue
      boundary = 'pos_electrode_top'
      variable = V_IV
      execute_on = 'initial timestep_end'
  [../]

  [./V_V_pos_out]
      type = SideAverageValue
      boundary = 'pos_electrode_top'
      variable = V_V
      execute_on = 'initial timestep_end'
  [../]

[]

[Executioner]
  type = Transient
  scheme = bdf2

  # NOTE: Add arg -ksp_view to get info on methods used at linear steps
  petsc_options = '-snes_converged_reason

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

                        -ksp_pc_factor_mat_solver_type'

  petsc_options_value = 'fgmres
                         ksp

                         lu

                         50

                         NONZERO
                         NONZERO
                         NONZERO

                         5

                         1E-8
                         1E-8

                         fgmres
                         lu

                         30
                         30

                         30
                         30

                         mumps'

  #NOTE: turning off line search can help converge for high Renolds number
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 50
  l_tol = 1e-6
  l_max_its = 30

  # Case: time: 0 - 33.6 min (charging at 10 A)
  #       time: 33.6 - 35.6 min (zero current pull)
  #       time: 35.6 - 65 min (discharging at 10 A)

  start_time = -0.001
  end_time = 33.6
  dtmax = 0.5
  dtmin = 0.0001

  # First few times step needs to be fairly small, but afterwards can accelerate
  #   Current setup: Double step size if successful, otherwise reduce to 75%
  [./TimeStepper]
		  type = SolutionTimeAdaptiveDT
      dt = 0.001
      cutback_factor_at_failure = 0.75
      percent_change = 1
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
