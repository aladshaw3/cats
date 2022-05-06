[GlobalParams]
  faraday_const = 0.0964853
  gas_const = 8.314462e-06
  min_conductivity = 2e-05
  tight_coupling = False
  include_ion_gradients = False
  diff_length_unit = "mm"
  diff_time_unit = "s"
  dispersivity = 1.0
  disp_length_unit = "mm"
  vel_length_unit = "mm"
  vel_time_unit = "s"
  output_length_unit = "mm"
  output_time_unit = "s"
  effective_diffusivity_factor = 1.5
[]

[Problem]
[]

[Mesh]
  [./file]
    type = FileMeshGenerator
    file = CO2_electrolyzer_half_cell_plateless_v2_coarse.msh
  [../]

[]

[Variables]
  [./pressure]
    order = FIRST
    family = LAGRANGE
    scaling = 1
    initial_condition = 0
    block = 'channel cathode catex_membrane'
  [../]

  [./vel_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'channel cathode catex_membrane'
  [../]

  [./vel_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'channel cathode catex_membrane'
  [../]

  [./vel_z]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'channel cathode catex_membrane'
  [../]

  [./C_HCO3]
    order = FIRST
    family = LAGRANGE
    scaling = 1
    initial_condition = 2.938
    block = 'channel cathode'
  [../]

  [./C_CO3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.031
    block = 'channel cathode'
  [../]

  [./C_CO2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.031
    block = 'channel cathode'
  [../]

  [./C_H]
    order = FIRST
    family = LAGRANGE
    initial_condition = 4.41e-09
    block = 'channel cathode'
  [../]

  [./C_OH]
    order = FIRST
    family = LAGRANGE
    initial_condition = 2.14e-06
    block = 'channel cathode'
  [../]

  [./C_K]
    order = FIRST
    family = LAGRANGE
    initial_condition = 3
    block = 'channel cathode'
  [../]

  [./C_CO]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'channel cathode'
  [../]

  [./C_H2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'channel cathode'
  [../]

  [./r_w]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    scaling = 1
    block = 'channel cathode'
  [../]

  [./r_1]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    scaling = 1
    block = 'channel cathode'
  [../]

  [./r_2]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    scaling = 1
    block = 'channel cathode'
  [../]

  [./r_3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    scaling = 1
    block = 'channel cathode'
  [../]

  [./r_4]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    scaling = 1
    block = 'channel cathode'
  [../]

  [./phi_e]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'channel cathode catex_membrane'
  [../]

  [./phi_s]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'cathode'
  [../]

  [./phi_diff]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'cathode'
  [../]

  [./r_H2]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = InitialModifiedButlerVolmerReaction
      reaction_rate_const = 6.59167e-06
      equilibrium_potential = 0
      reduced_state_vars = '0'
      reduced_state_stoich = '1'
      oxidized_state_vars = 'C_H'
      oxidized_state_stoich = '0.1737'
      electric_potential_difference = phi_diff
      temperature = T_e
      number_of_electrons = 1
      electron_transfer_coef = 0.14
    [../]
    scaling = 1
    block = 'cathode'
  [../]

  [./r_CO]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = InitialModifiedButlerVolmerReaction
      reaction_rate_const = 2.0833e-07
      equilibrium_potential = -0.11
      reduced_state_vars = '0'
      reduced_state_stoich = '1'
      oxidized_state_vars = 'C_H C_CO2'
      oxidized_state_stoich = '0.6774 1.5'
      electric_potential_difference = phi_diff
      temperature = T_e
      number_of_electrons = 1
      electron_transfer_coef = 0.35
    [../]
    scaling = 1
    block = 'cathode'
  [../]

  [./J_H2]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = InitialButlerVolmerCurrentDensity
      number_of_electrons = 1
      specific_area = As
      rate_var = r_H2
    [../]
    block = 'cathode'
    scaling = 1
  [../]

  [./J_CO]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = InitialButlerVolmerCurrentDensity
      number_of_electrons = 1
      specific_area = As
      rate_var = r_CO
    [../]
    block = 'cathode'
    scaling = 1
  [../]

[]

[ICs]
[]

[AuxVariables]
  [./vel_mag]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode catex_membrane'
  [../]

  [./ie_mag]
    order = FIRST
    family = MONOMIAL
    block = 'channel cathode catex_membrane'
  [../]

  [./is_mag]
    order = FIRST
    family = MONOMIAL
    block = 'cathode'
  [../]

  [./vel_in]
    order = FIRST
    family = LAGRANGE
    block = 'channel'
  [../]

  [./T_e]
    order = FIRST
    family = LAGRANGE
    initial_condition = 298
    block = 'channel cathode catex_membrane'
  [../]

  [./T_s]
    order = FIRST
    family = LAGRANGE
    initial_condition = 298
    block = 'cathode'
  [../]

  [./viscosity]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.001
    block = 'channel cathode catex_membrane'
  [../]

  [./eps]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode catex_membrane'
  [../]

  [./dh]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1.3072
    block = 'channel'
  [../]

  [./dp]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.03
    block = 'cathode'
  [../]

  [./input_current]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'cathode catex_membrane'
  [../]

  [./cat_volt]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
    block = 'cathode'
  [../]

  [./sigma_s_eff]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0986
    block = 'cathode'
  [../]

  [./sigma_e_eff]
    order = FIRST
    family = LAGRANGE
    block = 'cathode channel catex_membrane'
  [../]

  [./is_x]
    order = FIRST
    family = MONOMIAL
    block = 'cathode'
  [../]

  [./is_y]
    order = FIRST
    family = MONOMIAL
    block = 'cathode'
  [../]

  [./is_z]
    order = FIRST
    family = MONOMIAL
    block = 'cathode'
  [../]

  [./ie_x]
    order = FIRST
    family = MONOMIAL
    block = 'cathode channel catex_membrane'
  [../]

  [./ie_y]
    order = FIRST
    family = MONOMIAL
    block = 'cathode channel catex_membrane'
  [../]

  [./ie_z]
    order = FIRST
    family = MONOMIAL
    block = 'cathode channel catex_membrane'
  [../]

  [./As]
    order = FIRST
    family = LAGRANGE
    initial_condition = 25200.0
    block = 'cathode'
  [../]

  [./kp]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1.58e-12
    block = 'catex_membrane'
  [../]

  [./k_phi]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1.13e-13
    block = 'catex_membrane'
  [../]

  [./C_H_mem]
    order = FIRST
    family = LAGRANGE
    initial_condition = 2.75
    block = 'catex_membrane'
  [../]

  [./C_HCO3_inlet]
    order = FIRST
    family = LAGRANGE
    scaling = 1
    initial_condition = 2.938
    block = 'channel'
  [../]

  [./C_CO3_inlet]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.031
    block = 'channel'
  [../]

  [./C_CO2_inlet]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.031
    block = 'channel'
  [../]

  [./C_H_inlet]
    order = FIRST
    family = LAGRANGE
    initial_condition = 4.41e-09
    block = 'channel'
  [../]

  [./C_OH_inlet]
    order = FIRST
    family = LAGRANGE
    initial_condition = 2.14e-06
    block = 'channel'
  [../]

  [./C_K_inlet]
    order = FIRST
    family = LAGRANGE
    initial_condition = 3
    block = 'channel'
  [../]

  [./C_CO_inlet]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'channel'
  [../]

  [./C_H2_inlet]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'channel'
  [../]

  [./Q_in]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 'channel'
  [../]

  [./A_xsec]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1.73
    block = 'channel'
  [../]

  [./recycle_rate]
    order = FIRST
    family = LAGRANGE
    block = 'channel'
  [../]

  [./DarcyWeisbach]
    order = FIRST
    family = LAGRANGE
    initial_condition = 53.4
    block = 'channel'
  [../]

  [./KozenyCarman]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.1638
    block = 'cathode'
  [../]

  [./SchloeglDarcy]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1.58e-09
    block = 'catex_membrane'
  [../]

  [./SchloeglElectrokinetic]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.02998
    block = 'catex_membrane'
  [../]

  [./D_HCO3]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./Dd_HCO3]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./D_CO3]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./Dd_CO3]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./D_CO2]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./Dd_CO2]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./D_H]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./D_H_mem]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0014
    block = 'catex_membrane'
  [../]

  [./Dd_H]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./D_OH]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./Dd_OH]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./D_K]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./Dd_K]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./D_CO]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./Dd_CO]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./D_H2]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

  [./Dd_H2]
    order = FIRST
    family = LAGRANGE
    block = 'channel cathode'
  [../]

[]

[Kernels]
  [./pressure_laplace_channel]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = DarcyWeisbach
    block = 'channel'
  [../]

  [./pressure_laplace_cathode]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = KozenyCarman
    block = 'cathode'
  [../]

  [./pressure_laplace_membrane]
    type = VariableLaplacian
    variable = pressure
    coupled_coef = SchloeglDarcy
    block = 'catex_membrane'
  [../]

  [./v_x_equ]
    type = Reaction
    variable = vel_x
  [../]

  [./x_channel]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = DarcyWeisbach
    block = 'channel'
  [../]

  [./x_cathode]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = KozenyCarman
    block = 'cathode'
  [../]

  [./x_membrane]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = pressure
    ux = SchloeglDarcy
    block = 'catex_membrane'
  [../]

  [./x_schloegl_ele]
    type = VariableVectorCoupledGradient
    variable = vel_x
    coupled = phi_e
    ux = SchloeglElectrokinetic
    block = 'catex_membrane'
  [../]

  [./v_y_equ]
    type = Reaction
    variable = vel_y
  [../]

  [./y_channel]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    uy = DarcyWeisbach
    block = 'channel'
  [../]

  [./y_cathode]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    uy = KozenyCarman
    block = 'cathode'
  [../]

  [./y_membrane]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = pressure
    uy = SchloeglDarcy
    block = 'catex_membrane'
  [../]

  [./y_schloegl_ele]
    type = VariableVectorCoupledGradient
    variable = vel_y
    coupled = phi_e
    uy = SchloeglElectrokinetic
    block = 'catex_membrane'
  [../]

  [./v_z_equ]
    type = Reaction
    variable = vel_z
  [../]

  [./z_channel]
    type = VariableVectorCoupledGradient
    variable = vel_z
    coupled = pressure
    uz = DarcyWeisbach
    block = 'channel'
  [../]

  [./z_cathode]
    type = VariableVectorCoupledGradient
    variable = vel_z
    coupled = pressure
    uz = KozenyCarman
    block = 'cathode'
  [../]

  [./z_membrane]
    type = VariableVectorCoupledGradient
    variable = vel_z
    coupled = pressure
    uz = SchloeglDarcy
    block = 'catex_membrane'
  [../]

  [./z_schloegl_ele]
    type = VariableVectorCoupledGradient
    variable = vel_z
    coupled = phi_e
    uz = SchloeglElectrokinetic
    block = 'catex_membrane'
  [../]

  [./HCO3_dot]
    type = VariableCoefTimeDerivative
    variable = C_HCO3
    coupled_coef = eps
  [../]

  [./HCO3_gadv]
    type = GPoreConcAdvection
    variable = C_HCO3
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./HCO3_gdiff]
    type = GVarPoreDiffusion
    variable = C_HCO3
    porosity = 1
    Dx = Dd_HCO3
    Dy = Dd_HCO3
    Dz = Dd_HCO3
  [../]

  [./HCO3_gnpdiff]
    type = GNernstPlanckDiffusion
    variable = C_HCO3
    valence = -1
    porosity = 1
    electric_potential = phi_e
    temperature = T_e
    Dx = D_HCO3
    Dy = D_HCO3
    Dz = D_HCO3
  [../]

  [./HCO3_rate_bulk]
    type = ScaledWeightedCoupledSumFunction
    variable = C_HCO3
    coupled_list = 'r_1 r_2 r_3 r_4'
    weights = '1 -1 1 -1'
    scale = eps
  [../]

  [./CO3_dot]
    type = VariableCoefTimeDerivative
    variable = C_CO3
    coupled_coef = eps
  [../]

  [./CO3_gadv]
    type = GPoreConcAdvection
    variable = C_CO3
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./CO3_gdiff]
    type = GVarPoreDiffusion
    variable = C_CO3
    porosity = 1
    Dx = Dd_CO3
    Dy = Dd_CO3
    Dz = Dd_CO3
  [../]

  [./CO3_gnpdiff]
    type = GNernstPlanckDiffusion
    variable = C_CO3
    valence = -2
    porosity = 1
    electric_potential = phi_e
    temperature = T_e
    Dx = D_CO3
    Dy = D_CO3
    Dz = D_CO3
  [../]

  [./CO3_rate_bulk]
    type = ScaledWeightedCoupledSumFunction
    variable = C_CO3
    coupled_list = 'r_2 r_4'
    weights = '1 1'
    scale = eps
  [../]

  [./CO2_dot]
    type = VariableCoefTimeDerivative
    variable = C_CO2
    coupled_coef = eps
  [../]

  [./CO2_gadv]
    type = GPoreConcAdvection
    variable = C_CO2
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./CO2_gdiff]
    type = GVarPoreDiffusion
    variable = C_CO2
    porosity = 1
    Dx = Dd_CO2
    Dy = Dd_CO2
    Dz = Dd_CO2
  [../]

  [./CO2_rate_bulk]
    type = ScaledWeightedCoupledSumFunction
    variable = C_CO2
    coupled_list = 'r_1 r_3'
    weights = '-1 -1'
    scale = eps
  [../]

  [./CO2_surf_rate]
    type = ScaledWeightedCoupledSumFunction
    variable = C_CO2
    coupled_list = 'r_CO'
    weights = '1'
    scale = As
    block = 'cathode'
  [../]

  [./H_dot]
    type = VariableCoefTimeDerivative
    variable = C_H
    coupled_coef = eps
  [../]

  [./H_gadv]
    type = GPoreConcAdvection
    variable = C_H
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./H_gdiff]
    type = GVarPoreDiffusion
    variable = C_H
    porosity = 1
    Dx = Dd_H
    Dy = Dd_H
    Dz = Dd_H
  [../]

  [./H_gnpdiff]
    type = GNernstPlanckDiffusion
    variable = C_H
    valence = 1
    porosity = 1
    electric_potential = phi_e
    temperature = T_e
    Dx = D_H
    Dy = D_H
    Dz = D_H
  [../]

  [./H_rate_bulk]
    type = ScaledWeightedCoupledSumFunction
    variable = C_H
    coupled_list = 'r_w r_1 r_2'
    weights = '1 1 1'
    scale = eps
  [../]

  [./OH_dot]
    type = VariableCoefTimeDerivative
    variable = C_OH
    coupled_coef = eps
  [../]

  [./OH_gadv]
    type = GPoreConcAdvection
    variable = C_OH
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./OH_gdiff]
    type = GVarPoreDiffusion
    variable = C_OH
    porosity = 1
    Dx = Dd_OH
    Dy = Dd_OH
    Dz = Dd_OH
  [../]

  [./OH_gnpdiff]
    type = GNernstPlanckDiffusion
    variable = C_OH
    valence = -1
    porosity = 1
    electric_potential = phi_e
    temperature = T_e
    Dx = D_OH
    Dy = D_OH
    Dz = D_OH
  [../]

  [./OH_rate_bulk]
    type = ScaledWeightedCoupledSumFunction
    variable = C_OH
    coupled_list = 'r_w r_3 r_4'
    weights = '1 -1 -1'
    scale = eps
  [../]

  [./OH_surf_rate_cat]
    type = ScaledWeightedCoupledSumFunction
    variable = C_OH
    coupled_list = 'r_H2 r_CO'
    weights = '-2 -2'
    scale = As
    block = 'cathode'
    enable = True
  [../]

  [./K_dot]
    type = VariableCoefTimeDerivative
    variable = C_K
    coupled_coef = eps
  [../]

  [./K_gadv]
    type = GPoreConcAdvection
    variable = C_K
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./K_gdiff]
    type = GVarPoreDiffusion
    variable = C_K
    porosity = 1
    Dx = Dd_K
    Dy = Dd_K
    Dz = Dd_K
  [../]

  [./K_gnpdiff]
    type = GNernstPlanckDiffusion
    variable = C_K
    valence = 1
    porosity = 1
    electric_potential = phi_e
    temperature = T_e
    Dx = D_K
    Dy = D_K
    Dz = D_K
  [../]

  [./CO_dot]
    type = VariableCoefTimeDerivative
    variable = C_CO
    coupled_coef = eps
  [../]

  [./CO_gadv]
    type = GPoreConcAdvection
    variable = C_CO
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./CO_gdiff]
    type = GVarPoreDiffusion
    variable = C_CO
    porosity = 1
    Dx = Dd_CO
    Dy = Dd_CO
    Dz = Dd_CO
  [../]

  [./CO_surf_rate]
    type = ScaledWeightedCoupledSumFunction
    variable = C_CO
    coupled_list = 'r_CO'
    weights = '-1'
    scale = As
    block = 'cathode'
  [../]

  [./H2_dot]
    type = VariableCoefTimeDerivative
    variable = C_H2
    coupled_coef = eps
  [../]

  [./H2_gadv]
    type = GPoreConcAdvection
    variable = C_H2
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./H2_gdiff]
    type = GVarPoreDiffusion
    variable = C_H2
    porosity = 1
    Dx = Dd_H2
    Dy = Dd_H2
    Dz = Dd_H2
  [../]

  [./H2_surf_rate_cat]
    type = ScaledWeightedCoupledSumFunction
    variable = C_H2
    coupled_list = 'r_H2'
    weights = '-1'
    scale = As
    block = 'cathode'
  [../]

  [./r_w_equ]
    type = Reaction
    variable = r_w
  [../]

  [./r_w_rxn]
    type = ConstReaction
    variable = r_w
    this_variable = r_w
    forward_rate = 0.0016
    reverse_rate = 160000000000.0
    scale = 1
    reactants = '1'
    reactant_stoich = '1'
    products = 'C_H C_OH'
    product_stoich = '1 1'
  [../]

  [./r_1_equ]
    type = Reaction
    variable = r_1
  [../]

  [./r_1_rxn]
    type = ConstReaction
    variable = r_1
    this_variable = r_1
    forward_rate = 0.04
    reverse_rate = 93683.3333
    scale = 1
    reactants = 'C_CO2'
    reactant_stoich = '1'
    products = 'C_H C_HCO3'
    product_stoich = '1 1'
  [../]

  [./r_2_equ]
    type = Reaction
    variable = r_2
  [../]

  [./r_2_rxn]
    type = ConstReaction
    variable = r_2
    this_variable = r_2
    forward_rate = 56.28333
    reverse_rate = 1228800000000.0
    scale = 1
    reactants = 'C_HCO3'
    reactant_stoich = '1'
    products = 'C_H C_CO3'
    product_stoich = '1 1'
  [../]

  [./r_3_equ]
    type = Reaction
    variable = r_3
  [../]

  [./r_3_rxn]
    type = ConstReaction
    variable = r_3
    this_variable = r_3
    forward_rate = 2100
    reverse_rate = 4.918333e-05
    scale = 1
    reactants = 'C_CO2 C_OH'
    reactant_stoich = '1 1'
    products = 'C_HCO3'
    product_stoich = '1'
  [../]

  [./r_4_equ]
    type = Reaction
    variable = r_4
  [../]

  [./r_4_rxn]
    type = ConstReaction
    variable = r_4
    this_variable = r_4
    forward_rate = 6500000000.0
    reverse_rate = 1337000.0
    scale = 1
    reactants = 'C_HCO3 C_OH'
    reactant_stoich = '1 1'
    products = 'C_CO3'
    product_stoich = '1'
  [../]

  [./phi_e_conductivity_cathode_and_channel]
    type = ElectrolytePotentialConductivity
    variable = phi_e
    porosity = 1
    temperature = T_e
    ion_conc = 'C_H C_K'
    diffusion = 'D_H D_K'
    ion_valence = '1 1'
    block = 'cathode channel'
  [../]

  [./phi_e_ionic_conductivity_cathode_and_channel]
    type = ElectrolyteIonConductivity
    variable = phi_e
    porosity = 1
    ion_conc = 'C_H C_K'
    diffusion = 'D_H D_K'
    ion_valence = '1 1'
    block = 'cathode channel'
    enable = False
  [../]

  [./phi_e_J_cat]
    type = ScaledWeightedCoupledSumFunction
    variable = phi_e
    coupled_list = 'J_H2 J_CO'
    weights = '1 1'
    block = 'cathode'
  [../]

  [./phi_e_conductivity_in_membrane]
    type = ElectrolytePotentialConductivity
    variable = phi_e
    porosity = 1
    temperature = T_e
    ion_conc = 'C_H_mem'
    ion_valence = '1'
    diffusion = 'D_H_mem'
    block = 'catex_membrane'
  [../]

  [./phi_s_conductivity_in_electrode]
    type = ElectrodePotentialConductivity
    variable = phi_s
    solid_frac = 1
    conductivity = sigma_s_eff
  [../]

  [./phi_s_J_cat]
    type = ScaledWeightedCoupledSumFunction
    variable = phi_s
    coupled_list = 'J_H2 J_CO'
    weights = '-1 -1'
    block = 'cathode'
  [../]

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

  [./r_H2_equ]
    type = Reaction
    variable = r_H2
  [../]

  [./r_H2_rxn]
    type = ModifiedButlerVolmerReaction
    variable = r_H2
    reaction_rate_const = 6.59167e-06
    equilibrium_potential = 0
    reduced_state_vars = '0'
    reduced_state_stoich = '1'
    oxidized_state_vars = 'C_H'
    oxidized_state_stoich = '0.1737'
    electric_potential_difference = phi_diff
    temperature = T_e
    number_of_electrons = 1
    electron_transfer_coef = 0.14
    scale = 1
  [../]

  [./r_CO_equ]
    type = Reaction
    variable = r_CO
  [../]

  [./r_CO_rxn]
    type = ModifiedButlerVolmerReaction
    variable = r_CO
    reaction_rate_const = 2.0833e-07
    equilibrium_potential = -0.11
    reduced_state_vars = '0'
    reduced_state_stoich = '1'
    oxidized_state_vars = 'C_H C_CO2'
    oxidized_state_stoich = '0.6774 1.5'
    electric_potential_difference = phi_diff
    temperature = T_e
    number_of_electrons = 1
    electron_transfer_coef = 0.35
    scale = 2500000000.0
  [../]

  [./J_H2_equ]
    type = Reaction
    variable = J_H2
  [../]

  [./J_H2_rxn]
    type = ButlerVolmerCurrentDensity
    variable = J_H2
    number_of_electrons = 2
    specific_area = As
    rate_var = r_H2
  [../]

  [./J_CO_equ]
    type = Reaction
    variable = J_CO
  [../]

  [./J_CO_rxn]
    type = ButlerVolmerCurrentDensity
    variable = J_CO
    number_of_electrons = 2
    specific_area = As
    rate_var = r_CO
  [../]

[]

[DGKernels]
[]

[AuxKernels]
  [./eps_calc_none]
    type = ConstantAux
    variable = eps
    value = 0.999
    execute_on = 'initial timestep_end'
    block = 'channel catex_membrane'
  [../]

  [./eps_calc_cathode]
    type = ConstantAux
    variable = eps
    value = 0.85
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./vel_calc]
    type = VectorMagnitude
    variable = vel_mag
    ux = vel_x
    uy = vel_y
    uz = vel_z
    execute_on = 'initial timestep_end'
  [../]

  [./flowrate_step_input]
    type = TemporalStepFunction
    variable = Q_in
    start_value = 0.0
    aux_vals = '1666.67'
    aux_times = '5'
    time_spans = '10'
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./current_step_input]
    type = TemporalStepFunction
    variable = input_current
    start_value = 0.0
    aux_vals = '0.001 0.002 0.003 0.004'
    aux_times = '15 30 45 60'
    time_spans = '0.5 0.5 0.5 0.5'
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./volt_step_input]
    type = TemporalStepFunction
    variable = cat_volt
    start_value = 0.0
    aux_vals = '0'
    aux_times = '15'
    time_spans = '0.5'
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./vel_from_flowrate]
    type = AuxAvgLinearVelocity
    variable = vel_in
    flow_rate = Q_in
    xsec_area = A_xsec
    porosity = 1
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./recycle_calc]
    type = AuxAvgLinearVelocity
    variable = recycle_rate
    flow_rate = Q_in
    xsec_area = 500000
    porosity = 1
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./C_HCO3_inlet_calc]
    type = AuxFirstOrderRecycleBC
    variable = C_HCO3_inlet
    outlet_postprocessor = C_HCO3_out_M
    recycle_rate = recycle_rate
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./C_CO3_inlet_calc]
    type = AuxFirstOrderRecycleBC
    variable = C_CO3_inlet
    outlet_postprocessor = C_CO3_out_M
    recycle_rate = recycle_rate
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./C_CO2_inlet_calc]
    type = AuxFirstOrderRecycleBC
    variable = C_CO2_inlet
    outlet_postprocessor = C_CO2_out_M
    recycle_rate = recycle_rate
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./C_OH_inlet_calc]
    type = AuxFirstOrderRecycleBC
    variable = C_OH_inlet
    outlet_postprocessor = C_OH_out_M
    recycle_rate = recycle_rate
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./C_H_inlet_calc]
    type = AuxFirstOrderRecycleBC
    variable = C_H_inlet
    outlet_postprocessor = C_H_out_M
    recycle_rate = recycle_rate
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./C_K_inlet_calc]
    type = AuxFirstOrderRecycleBC
    variable = C_K_inlet
    outlet_postprocessor = C_K_out_M
    recycle_rate = recycle_rate
    execute_on = 'initial timestep_begin nonlinear'
  [../]

  [./darcy_coef_calc_channels]
    type = DarcyWeisbachCoefficient
    variable = DarcyWeisbach
    friction_factor = 64
    density = viscosity
    velocity = 1
    hydraulic_diameter = 1.70877
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./kozeny_coef_calc_elec]
    type = KozenyCarmanDarcyCoefficient
    variable = KozenyCarman
    porosity = eps
    viscosity = viscosity
    particle_diameter = dp
    kozeny_carman_const = 150
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./darcy_coef_calc_mem]
    type = SchloeglDarcyCoefficient
    variable = SchloeglDarcy
    hydraulic_permeability = kp
    viscosity = viscosity
    execute_on = 'initial timestep_end'
    block = 'catex_membrane'
  [../]

  [./elec_coef_calc_mem]
    type = SchloeglElectrokineticCoefficient
    variable = SchloeglElectrokinetic
    electrokinetic_permeability = k_phi
    viscosity = viscosity
    ion_conc = C_H_mem
    conversion_factor = 1000000000.0
    execute_on = 'initial timestep_end'
    block = 'catex_membrane'
  [../]

  [./D_HCO3_calc_channels]
    type = SimpleFluidDispersion
    variable = D_HCO3
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.0011
    include_dispersivity_correction = False
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./D_HCO3_calc_cathode]
    type = SimpleFluidDispersion
    variable = D_HCO3
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.0011
    include_dispersivity_correction = False
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./Dd_HCO3_calc_channels]
    type = SimpleFluidDispersion
    variable = Dd_HCO3
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.0011
    include_dispersivity_correction = True
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./Dd_HCO3_calc_cathode]
    type = SimpleFluidDispersion
    variable = Dd_HCO3
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.0011
    include_dispersivity_correction = True
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./D_CO3_calc_channels]
    type = SimpleFluidDispersion
    variable = D_CO3
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.000801
    include_dispersivity_correction = False
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./D_CO3_calc_cathode]
    type = SimpleFluidDispersion
    variable = D_CO3
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.000801
    include_dispersivity_correction = False
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./Dd_CO3_calc_channels]
    type = SimpleFluidDispersion
    variable = Dd_CO3
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.000801
    include_dispersivity_correction = True
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./Dd_CO3_calc_cathode]
    type = SimpleFluidDispersion
    variable = Dd_CO3
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.000801
    include_dispersivity_correction = True
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./D_CO2_calc_channels]
    type = SimpleFluidDispersion
    variable = D_CO2
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00191
    include_dispersivity_correction = False
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./D_CO2_calc_cathode]
    type = SimpleFluidDispersion
    variable = D_CO2
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00191
    include_dispersivity_correction = False
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./Dd_CO2_calc_channels]
    type = SimpleFluidDispersion
    variable = Dd_CO2
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00191
    include_dispersivity_correction = True
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./Dd_CO2_calc_cathode]
    type = SimpleFluidDispersion
    variable = Dd_CO2
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00191
    include_dispersivity_correction = True
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./D_H_calc_channels]
    type = SimpleFluidDispersion
    variable = D_H
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00695
    include_dispersivity_correction = False
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./D_H_calc_cathode]
    type = SimpleFluidDispersion
    variable = D_H
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00695
    include_dispersivity_correction = False
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./Dd_H_calc_channels]
    type = SimpleFluidDispersion
    variable = Dd_H
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00695
    include_dispersivity_correction = True
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./Dd_H_calc_cathode]
    type = SimpleFluidDispersion
    variable = Dd_H
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00695
    include_dispersivity_correction = True
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./D_OH_calc_channels]
    type = SimpleFluidDispersion
    variable = D_OH
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00493
    include_dispersivity_correction = False
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./D_OH_calc_cathode]
    type = SimpleFluidDispersion
    variable = D_OH
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00493
    include_dispersivity_correction = False
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./Dd_OH_calc_channels]
    type = SimpleFluidDispersion
    variable = Dd_OH
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00493
    include_dispersivity_correction = True
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./Dd_OH_calc_cathode]
    type = SimpleFluidDispersion
    variable = Dd_OH
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00493
    include_dispersivity_correction = True
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./D_CO_calc_channels]
    type = SimpleFluidDispersion
    variable = D_CO
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.002107
    include_dispersivity_correction = False
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./D_CO_calc_cathode]
    type = SimpleFluidDispersion
    variable = D_CO
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.002107
    include_dispersivity_correction = False
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./Dd_CO_calc_channels]
    type = SimpleFluidDispersion
    variable = Dd_CO
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.002107
    include_dispersivity_correction = True
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./Dd_CO_calc_cathode]
    type = SimpleFluidDispersion
    variable = Dd_CO
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.002107
    include_dispersivity_correction = True
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./D_H2_calc_channels]
    type = SimpleFluidDispersion
    variable = D_H2
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00511
    include_dispersivity_correction = False
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./D_H2_calc_cathode]
    type = SimpleFluidDispersion
    variable = D_H2
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00511
    include_dispersivity_correction = False
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./Dd_H2_calc_channels]
    type = SimpleFluidDispersion
    variable = Dd_H2
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00511
    include_dispersivity_correction = True
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./Dd_H2_calc_cathode]
    type = SimpleFluidDispersion
    variable = Dd_H2
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.00511
    include_dispersivity_correction = True
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./D_K_calc_channels]
    type = SimpleFluidDispersion
    variable = D_K
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.001849
    include_dispersivity_correction = False
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./D_K_calc_cathode]
    type = SimpleFluidDispersion
    variable = D_K
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.001849
    include_dispersivity_correction = False
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./Dd_K_calc_channels]
    type = SimpleFluidDispersion
    variable = Dd_K
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.001849
    include_dispersivity_correction = True
    include_porosity_correction = False
    execute_on = 'initial timestep_end'
    block = 'channel'
  [../]

  [./Dd_K_calc_cathode]
    type = SimpleFluidDispersion
    variable = Dd_K
    temperature = T_e
    macro_porosity = eps
    ux = vel_x
    uy = vel_y
    uz = vel_z
    ref_diffusivity = 0.001849
    include_dispersivity_correction = True
    include_porosity_correction = True
    execute_on = 'initial timestep_end'
    block = 'cathode'
  [../]

  [./sigma_e_calc_cat]
    type = ElectrolyteConductivity
    variable = sigma_e_eff
    temperature = T_e
    ion_conc = 'C_H C_K'
    diffusion = 'D_H D_K'
    ion_valence = '1 1'
    execute_on = 'initial timestep_end'
    block = 'channel cathode'
  [../]

  [./sigma_e_calc_mem]
    type = ElectrolyteConductivity
    variable = sigma_e_eff
    temperature = T_e
    ion_conc = 'C_H_mem'
    diffusion = 'D_H_mem'
    ion_valence = '1'
    execute_on = 'initial timestep_end'
    block = 'catex_membrane'
  [../]

  [./ie_x_calc_cat]
    type = AuxElectrolyteCurrent
    variable = ie_x
    direction = 0
    electric_potential = phi_e
    porosity = 1
    temperature = T_e
    ion_conc = 'C_H C_K'
    diffusion = 'D_H D_K'
    ion_valence = '1 1'
    execute_on = 'initial timestep_end'
    block = 'channel cathode'
  [../]

  [./ie_y_calc_cat]
    type = AuxElectrolyteCurrent
    variable = ie_y
    direction = 1
    electric_potential = phi_e
    porosity = 1
    temperature = T_e
    ion_conc = 'C_H C_K'
    diffusion = 'D_H D_K'
    ion_valence = '1 1'
    execute_on = 'initial timestep_end'
    block = 'channel cathode'
  [../]

  [./ie_z_calc_cat]
    type = AuxElectrolyteCurrent
    variable = ie_z
    direction = 2
    electric_potential = phi_e
    porosity = 1
    temperature = T_e
    ion_conc = 'C_H C_K'
    diffusion = 'D_H D_K'
    ion_valence = '1 1'
    execute_on = 'initial timestep_end'
    block = 'channel cathode'
  [../]

  [./ie_x_calc_mem]
    type = AuxElectrolyteCurrent
    variable = ie_x
    direction = 0
    electric_potential = phi_e
    porosity = 1
    temperature = T_e
    ion_conc = 'C_H_mem'
    diffusion = 'D_H_mem'
    ion_valence = '1'
    execute_on = 'initial timestep_end'
    block = 'catex_membrane'
  [../]

  [./ie_y_calc_mem]
    type = AuxElectrolyteCurrent
    variable = ie_y
    direction = 1
    electric_potential = phi_e
    porosity = 1
    temperature = T_e
    ion_conc = 'C_H_mem'
    diffusion = 'D_H_mem'
    ion_valence = '1'
    execute_on = 'initial timestep_end'
    block = 'catex_membrane'
  [../]

  [./ie_z_calc_mem]
    type = AuxElectrolyteCurrent
    variable = ie_z
    direction = 2
    electric_potential = phi_e
    porosity = 1
    temperature = T_e
    ion_conc = 'C_H_mem'
    diffusion = 'D_H_mem'
    ion_valence = '1'
    execute_on = 'initial timestep_end'
    block = 'catex_membrane'
  [../]

  [./is_x_calc]
    type = AuxElectrodeCurrent
    variable = is_x
    direction = 0
    electric_potential = phi_s
    solid_frac = 1
    conductivity = sigma_s_eff
    execute_on = 'initial timestep_end'
  [../]

  [./is_y_calc]
    type = AuxElectrodeCurrent
    variable = is_y
    direction = 1
    electric_potential = phi_s
    solid_frac = 1
    conductivity = sigma_s_eff
    execute_on = 'initial timestep_end'
  [../]

  [./is_z_calc]
    type = AuxElectrodeCurrent
    variable = is_z
    direction = 2
    electric_potential = phi_s
    solid_frac = 1
    conductivity = sigma_s_eff
    execute_on = 'initial timestep_end'
  [../]

  [./ie_calc]
    type = VectorMagnitude
    variable = ie_mag
    ux = ie_x
    uy = ie_y
    uz = ie_z
    execute_on = 'initial timestep_end'
  [../]

  [./is_calc]
    type = VectorMagnitude
    variable = is_mag
    ux = is_x
    uy = is_y
    uz = is_z
    execute_on = 'initial timestep_end'
  [../]

[]

[BCs]
  [./press_at_exit]
    type = DirichletBC
    variable = pressure
    boundary = 'channel_exit'
    value = 0
  [../]

  [./press_grad_at_inlet]
    type = CoupledNeumannBC
    variable = pressure
    boundary = 'channel_enter'
    coupled = vel_in
  [../]

  [./HCO3_FluxIn]
    type = DGFlowMassFluxBC
    variable = C_HCO3
    boundary = 'channel_enter'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    input_var = C_HCO3_inlet
  [../]

  [./HCO3_FluxOut]
    type = DGFlowMassFluxBC
    variable = C_HCO3
    boundary = 'channel_exit'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./CO3_FluxIn]
    type = DGFlowMassFluxBC
    variable = C_CO3
    boundary = 'channel_enter'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    input_var = C_CO3_inlet
  [../]

  [./CO3_FluxOut]
    type = DGFlowMassFluxBC
    variable = C_CO3
    boundary = 'channel_exit'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./CO2_FluxIn]
    type = DGFlowMassFluxBC
    variable = C_CO2
    boundary = 'channel_enter'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    input_var = C_CO2_inlet
  [../]

  [./CO2_FluxOut]
    type = DGFlowMassFluxBC
    variable = C_CO2
    boundary = 'channel_exit'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./H_FluxIn]
    type = DGFlowMassFluxBC
    variable = C_H
    boundary = 'channel_enter'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    input_var = C_H_inlet
  [../]

  [./H_FluxOut]
    type = DGFlowMassFluxBC
    variable = C_H
    boundary = 'channel_exit'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./proton_membrane_flux]
    type = CoupledVariableGradientFluxBC
    variable = C_H
    boundary = 'cathode_interface_membrane'
    coupled = phi_e
    coef = 0.14992
  [../]

  [./OH_FluxIn]
    type = DGFlowMassFluxBC
    variable = C_OH
    boundary = 'channel_enter'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    input_var = C_OH_inlet
  [../]

  [./OH_FluxOut]
    type = DGFlowMassFluxBC
    variable = C_OH
    boundary = 'channel_exit'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./K_FluxIn]
    type = DGFlowMassFluxBC
    variable = C_K
    boundary = 'channel_enter'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    input_var = C_K_inlet
  [../]

  [./K_FluxOut]
    type = DGFlowMassFluxBC
    variable = C_K
    boundary = 'channel_exit'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./CO_FluxIn]
    type = DGFlowMassFluxBC
    variable = C_CO
    boundary = 'channel_enter'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    input_var = C_CO_inlet
  [../]

  [./CO_FluxOut]
    type = DGFlowMassFluxBC
    variable = C_CO
    boundary = 'channel_exit'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./H2_FluxIn]
    type = DGFlowMassFluxBC
    variable = C_H2
    boundary = 'channel_enter'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
    input_var = C_H2_inlet
  [../]

  [./H2_FluxOut]
    type = DGFlowMassFluxBC
    variable = C_H2
    boundary = 'channel_exit'
    porosity = 1
    ux = vel_x
    uy = vel_y
    uz = vel_z
  [../]

  [./applied_cathode_potential]
    type = CoupledDirichletBC
    variable = phi_s
    boundary = 'plate_interface_cathode channel_interface_cathode'
    coupled = 0
  [../]

  [./no_flux_cathode_potential]
    type = CoupledNeumannBC
    variable = phi_s
    boundary = 'cathode_interface_membrane'
    coupled = 0
  [../]

  [./applied_current_mem]
    type = CoupledNeumannBC
    variable = phi_e
    boundary = 'catex_mem_interface'
    coupled = input_current
  [../]

  [./no_flux_electrolyte_potential]
    type = CoupledNeumannBC
    variable = phi_e
    boundary = 'plate_interface_cathode'
    coupled = 0
  [../]

  [./reference_electrolyte_potential]
    type = DirichletBC
    variable = phi_e
    boundary = 'channel_bottom'
    value = 0
  [../]

[]

[Postprocessors]
  [./Diff_press_Pa]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = pressure
    execute_on = 'initial timestep_end'
  [../]

  [./A_chan_xsec_sq_mm]
    type = AreaPostprocessor
    boundary = 'channel_exit'
    execute_on = 'initial timestep_end'
  [../]

  [./A_mem_top_sq_mm]
    type = AreaPostprocessor
    boundary = 'catex_mem_interface'
    execute_on = 'initial timestep_end'
  [../]

  [./Q_xmem_cu_mm_p_s]
    type = SideIntegralVariablePostprocessor
    boundary = 'catex_mem_interface'
    variable = vel_z
    execute_on = 'initial timestep_end'
  [../]

  [./Q_out_cu_mm_p_s]
    type = SideIntegralVariablePostprocessor
    boundary = 'channel_exit'
    variable = vel_y
    execute_on = 'initial timestep_end'
  [../]

  [./Q_in_cu_mm_p_s]
    type = SideIntegralVariablePostprocessor
    boundary = 'channel_enter'
    variable = vel_y
    execute_on = 'initial timestep_end'
  [../]

  [./I_in_Amps]
    type = SideIntegralVariablePostprocessor
    boundary = 'catex_mem_interface'
    variable = ie_z
    execute_on = 'initial timestep_end'
  [../]

  [./Ie_from_mem_Amps]
    type = SideIntegralVariablePostprocessor
    boundary = 'cathode_interface_membrane'
    variable = ie_z
    execute_on = 'initial timestep_end'
  [../]

  [./Is_from_mem_Amps]
    type = SideIntegralVariablePostprocessor
    boundary = 'cathode_interface_membrane'
    variable = is_z
    execute_on = 'initial timestep_end'
  [../]

  [./Ie_from_cat_Amps]
    type = SideIntegralVariablePostprocessor
    boundary = 'plate_interface_cathode channel_interface_cathode'
    variable = ie_z
    execute_on = 'initial timestep_end'
  [../]

  [./Is_from_cat_Amps]
    type = SideIntegralVariablePostprocessor
    boundary = 'plate_interface_cathode channel_interface_cathode'
    variable = is_z
    execute_on = 'initial timestep_end'
  [../]

  [./V_solid_cathode]
    type = ElementAverageValue
    block = 'cathode'
    variable = phi_s
    execute_on = 'initial timestep_end'
  [../]

  [./V_elec_cathode]
    type = ElementAverageValue
    block = 'cathode'
    variable = phi_e
    execute_on = 'initial timestep_end'
  [../]

  [./C_HCO3_in_M]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = C_HCO3
    execute_on = 'initial timestep_end'
  [../]

  [./C_HCO3_out_M]
    type = SideAverageValue
    boundary = 'channel_exit'
    variable = C_HCO3
    execute_on = 'initial timestep_end'
  [../]

  [./C_CO3_in_M]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = C_CO3
    execute_on = 'initial timestep_end'
  [../]

  [./C_CO3_out_M]
    type = SideAverageValue
    boundary = 'channel_exit'
    variable = C_CO3
    execute_on = 'initial timestep_end'
  [../]

  [./C_CO2_in_M]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = C_CO2
    execute_on = 'initial timestep_end'
  [../]

  [./C_CO2_out_M]
    type = SideAverageValue
    boundary = 'channel_exit'
    variable = C_CO2
    execute_on = 'initial timestep_end'
  [../]

  [./C_CO_in_M]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = C_CO
    execute_on = 'initial timestep_end'
  [../]

  [./C_CO_out_M]
    type = SideAverageValue
    boundary = 'channel_exit'
    variable = C_CO
    execute_on = 'initial timestep_end'
  [../]

  [./C_H2_in_M]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = C_H2
    execute_on = 'initial timestep_end'
  [../]

  [./C_H2_out_M]
    type = SideAverageValue
    boundary = 'channel_exit'
    variable = C_H2
    execute_on = 'initial timestep_end'
  [../]

  [./C_H_in_M]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = C_H
    execute_on = 'initial timestep_end'
  [../]

  [./C_H_out_M]
    type = SideAverageValue
    boundary = 'channel_exit'
    variable = C_H
    execute_on = 'initial timestep_end'
  [../]

  [./C_OH_in_M]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = C_OH
    execute_on = 'initial timestep_end'
  [../]

  [./C_OH_out_M]
    type = SideAverageValue
    boundary = 'channel_exit'
    variable = C_OH
    execute_on = 'initial timestep_end'
  [../]

  [./C_K_in_M]
    type = SideAverageValue
    boundary = 'channel_enter'
    variable = C_K
    execute_on = 'initial timestep_end'
  [../]

  [./C_K_out_M]
    type = SideAverageValue
    boundary = 'channel_exit'
    variable = C_K
    execute_on = 'initial timestep_end'
  [../]

[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor -ksp_gmres_modifiedgramschmidt -ksp_ksp_gmres_modifiedgramschmidt'
  petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_max_it
                     -sub_pc_factor_shift_type -pc_factor_shift_type -ksp_pc_factor_shift_type -pc_gasm_overlap
                     -snes_atol -snes_rtol -ksp_ksp_type -ksp_pc_type
                     -ksp_gmres_restart -ksp_ksp_gmres_restart -ksp_max_it -ksp_ksp_max_it
                     -ksp_atol -ksp_rtol -ksp_pc_factor_mat_solver_type -mat_mumps_cntl_1
                     -mat_mumps_cntl_3 -mat_mumps_icntl_23'
  petsc_options_value = 'fgmres ksp lu 50
                     NONZERO NONZERO NONZERO 20
                     1e-08 1e-08 fgmres lu
                     50 50 20 10
                     1e-08 1e-08 mumps 0.01
                     1e-08 4000'
  line_search = l2
  nl_rel_step_tol = 1e-12
  nl_abs_step_tol = 1e-12
  start_time = 0.0
  end_time = 75
  dtmax = 1
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 0.1
    cutback_factor_at_failure = 0.5
    percent_change = 0.5
  [../]

[]

[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = True
    solve_type = pjfnk
  [../]

[]

[Outputs]
  exodus = True
  csv = True
  print_linear_residuals = True
  interval = 1
[]

