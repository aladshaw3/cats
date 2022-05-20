# Case 01
# -------
#   - BCs
#     ---
#     100 mL/min total flow rate
#       -> inlet velocity = 963.33 mm/s   (CoupledNeumannBC for pressure)
#     100 mA/cm^2 total current density
#       -> 0.001 C/s/mm^2                 (CoupledNeumannBC for potential)
#     2.75 M H+ in membrane
#       -> 2.75 umol/mm^3                 (CoupledVariableGradientFluxBC for H+)
#
#     exit pressure (@ channel_exit) = 0
#     reference electrolyte potential = 0 (@channel_bottom)
#     ground reference for cathode = 0 (@cathode_interface_membrane
#                                       plate_interface_cathode)
#
#       [NOTE: Units for pressure in Pa]
#           units for viscosity should be in Pa*s or g/mm/s
#       [NOTE: Units for potential in V]
#
#   - ICs and Inlet Conc
#     ------------------
#     (Comes from KHCO3 solution of 3 M)
#       [NOTE: 1 umol/mm^3 = 1 M]
#     HCO3- = 2.938 M
#     CO3-- = 0.031 M
#     CO2   = 0.031 M
#     CO    = 1e-15 M
#     H2    = 1e-15 M
#     K+    = 3 M
#     H+    = 4.41e-9 M
#     OH-   = 2.14e-6 M
#
#     phi_e  and phi_s = 0
#     vel and pressure = 0
#
#   - Parameters
#     ----------
#     eps = 0.85 (porosity of cathode)
#     As = 30 mm^-1 (active area) = 6*(1-eps)/dp
#     dp = 0.03 mm (avg particle size)
#     dh = 1.3072 mm (hydraulic diameter for Darcy-Weisbach)
#     lambda = 1.0 mm (avg dispersivity)
#     n = 1 (fitted num of electrons transferred in each reaction)
#     mu = 1 mPa*s (fluid viscosity) [g/m/s]
#        = 0.001 Pa*s [g/mm/s]
#     K = 150 (Kozeny-Carman constant)
#     kp = 1.58e-12 mm^2 (Schloegl-Darcy Permeability)
#     k_phi = 1.13e-13 mm^2 (Schloegl-Darcy Electrokinetic Permeability)
#     conversion_factor = 10^9 (for Schloegl-Darcy Electrokinetic coef)
#     sigma_s = 1.698 S/mm [C/V/s/mm]
#         (sigma_s_eff) = 0.0986 S/mm
#     sigma_e ~= 0.01589 S/mm [C/V/s/mm]
#     min_conductivity = 2e-5 S/mm [C/V/s/mm] (background for tap water)
#     c_ref = 1 M = 1 umol/mm^3
#     gamma = 1 (assumes ideal solution)
#         [To reduce problem size, ONLY consider ideal solution]
#     Coupled Coeff for H+ flux at membrane
#       -> coef = (F/R/T)*Dmem*C_H
#             Dmem = 0.0014 mm^2/s
#             C_H = 2.75 M
#       coef = 0.14992 [umol/V/mm/s]
#
#   - Coefficients/Expressions
#     ------------------------
#     DarcyWeisbachCoefficient =~ 53.4 mm^3*s/g
#     KozenyCarmanDarcyCoefficient =~ 0.1638 mm^3*s/g
#     SchloeglDarcyCoefficient =~ 1.58e-9 mm^3*s/g
#     SchloeglElectrokineticCoefficient =~ 0.02998 C*s/g * (g/kg)*(mm^2/m^2)

[GlobalParams]
  # Override these defaults to apply unit conversion
  faraday_const = 0.0964853   # C/umol
  gas_const = 8.314462E-6     # J/K/umol

  # Given minimum conductivity
  min_conductivity = 2e-5 #C/V/s/mm
  tight_coupling = false
  include_ion_gradients = false #in current calculations

  # common to all SimpleGasPropertiesBase
  diff_length_unit = "mm"
  diff_time_unit = "s"
  dispersivity = 1.0 #mm
  disp_length_unit = "mm"
  vel_length_unit = "mm"
  vel_time_unit = "s"
  output_length_unit = "mm"
  output_time_unit = "s"
  effective_diffusivity_factor = 1.5

[] #END GlobalParams

[Problem]

[] #END Problem

[Mesh]
  [file]
    type = FileMeshGenerator
    file = CO2_electrolyzer_half_cell_plateless_v2_coarse.msh

    ### ========= boundary_name ==========
    # "channel_exit"
    # "channel_enter"
    # "channel_side_walls"
    # "channel_bottom"
    # "channel_interface_cathode"
    # "cathode_interface_membrane"
    # "plate_interface_cathode"
    # "cathode_left"
    # "cathode_right"
    # "cathode_bottom"
    # "cathode_top"
    # "catex_mem_bottom"
    # "catex_mem_top"
    # "catex_mem_interface"
    # "catex_mem_left"
    # "catex_mem_right"

    ### ====== block ========
    # "channel"
    # "cathode"
    # "catex_membrane"
  []

[] # END Mesh

[Variables]
  # fluid pressure (Pa)
  [./pressure]
      order = FIRST
      family = LAGRANGE
      scaling = 1
      initial_condition = 0 # Pa == 4 atm
      block = 'channel cathode catex_membrane'
  [../]

  # velocity in x (mm/s)
  [./vel_x]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]

  # velocity in y (mm/s)
  [./vel_y]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]

  # velocity in z (mm/s)
  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]

  # concentration of HCO3 (umol/mm^3)
  [./C_HCO3]
      order = FIRST
      family = LAGRANGE
      scaling = 1
      initial_condition = 2.938 #M
      block = 'channel cathode'
  [../]

  # concentration of CO3 (umol/mm^3)
  [./C_CO3]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.031 #M
      block = 'channel cathode'
  [../]

  # concentration of CO2 (umol/mm^3)
  [./C_CO2]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.031 #M
      block = 'channel cathode'
  [../]

  # concentration of H (umol/mm^3)
  [./C_H]
      order = FIRST
      family = LAGRANGE
      initial_condition = 4.41e-9 #M
      block = 'channel cathode'
  [../]

  # concentration of OH (umol/mm^3)
  [./C_OH]
      order = FIRST
      family = LAGRANGE
      initial_condition = 2.14e-6 #M
      block = 'channel cathode'
  [../]

  # concentration of K (umol/mm^3)
  [./C_K]
      order = FIRST
      family = LAGRANGE
      initial_condition = 3 #M
      block = 'channel cathode'
  [../]

  # concentration of CO (umol/mm^3)
  [./C_CO]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0 #M
      block = 'channel cathode'
  [../]

  # concentration of H2 (umol/mm^3)
  [./C_H2]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0 #M
      block = 'channel cathode'
  [../]


  # Speciation reaction rates
  # rate of water reaction
  [./r_w]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      scaling = 1
      block = 'channel cathode'
  [../]

  # rate of CO2 -> HCO3 reaction
  [./r_1]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      scaling = 1
      block = 'channel cathode'
  [../]

  # rate of HCO3 -> CO3 reaction
  [./r_2]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      scaling = 1
      block = 'channel cathode'
  [../]

  # rate of alt CO2 -> HCO3 reaction
  [./r_3]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      scaling = 1
      block = 'channel cathode'
  [../]

  # rate of alt HCO3 -> CO3 reaction
  [./r_4]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
      scaling = 1
      block = 'channel cathode'
  [../]

  # Potential in electrolyte (V)
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]

  # Potential in electrode (V)
  [./phi_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
      block = 'cathode'
  [../]

  # Potential difference (V)
  [./phi_diff]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
      block = 'cathode'
  [../]

  # -------- Butler-Volmer reaction rates ------------
  # reduced_state <----> oxidized_state
  # H2 + 2 OH- <----> 2 H2O + 2 e-
  [./r_H2]
      order = FIRST
      family = LAGRANGE
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 6.59167E-6    # umol/mm^2/s
          equilibrium_potential = 0         # V

          reduced_state_vars = '0'       # assumed
          reduced_state_stoich = '1'        # assumed

          oxidized_state_vars = 'C_H'
          oxidized_state_stoich = '0.1737'  # fitted param

          electric_potential_difference = phi_diff

          temperature = T_e
          number_of_electrons = 1         # params are fitted to this standard
          electron_transfer_coef = 0.14   # fitted param
      [../]
      scaling = 1
      block = 'cathode'
  [../]

  # CO + 2 OH- <----> CO2 + H2O + 2 e-
  [./r_CO]
      order = FIRST
      family = LAGRANGE
      [./InitialCondition]
          type = InitialModifiedButlerVolmerReaction

          reaction_rate_const = 519.39      # umol/mm^2/s
          equilibrium_potential = -0.11         # V

          reduced_state_vars = '0'        # assumed
          reduced_state_stoich = '1'         # assumed

          oxidized_state_vars = 'C_H C_CO2'
          oxidized_state_stoich = '0.6774 1.5'  # fitted param

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
      order = FIRST
      family = LAGRANGE
      [./InitialCondition]
          type = InitialButlerVolmerCurrentDensity

          number_of_electrons = 2       # params are fitted to this standard
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

          number_of_electrons = 2       # params are fitted to this standard
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
  # velocity magnitude
  [./vel_mag]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode catex_membrane'
  [../]

  # electrolyte current magnitude
  [./ie_mag]
      order = FIRST
      family = MONOMIAL
      block = 'channel cathode catex_membrane'
  [../]

  # electrode current magnitude
  [./is_mag]
      order = FIRST
      family = MONOMIAL
      block = 'cathode'
  [../]

  # velocity inlet
  [./vel_in]
      order = FIRST
      family = LAGRANGE
      block = 'channel'
  [../]

  # Electrolyte temperature
  [./T_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 298 #K
      block = 'channel cathode catex_membrane'
  [../]

  # Electrode temperature
  [./T_s]
      order = FIRST
      family = LAGRANGE
      initial_condition = 298 #K
      block = 'cathode'
  [../]

  # fluid viscosity
  [./viscosity]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.001 # Pa*s = g/mm/s
      block = 'channel cathode catex_membrane'
  [../]

  # domain porosity
  [./eps]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode catex_membrane'
  [../]

  # hydraulic diameter
  [./dh]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.3072 #mm
      block = 'channel'
  [../]

  # particle diameter
  [./dp]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.03 #mm
      block = 'cathode'
  [../]

  # input current
  [./input_current]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0 # C/s/mm^2
      block = 'cathode catex_membrane'
  [../]

  # cathode voltage
  [./cat_volt]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0 # V
      block = 'cathode'
  [../]

  # Effective cathode conductivity
  [./sigma_s_eff]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0986 # S/mm = [C/V/s/mm]
      block = 'cathode'
  [../]

  # Effective electrolyte conductivity # S/mm = [C/V/s/mm]
  [./sigma_e_eff]
      order = FIRST
      family = LAGRANGE
      block = 'cathode channel catex_membrane'
  [../]

  # Electric current in cathode in x [C/s/mm^2]
  [./is_x]
      order = FIRST
      family = MONOMIAL
      block = 'cathode'
  [../]
  # Electric current in cathode in y [C/s/mm^2]
  [./is_y]
      order = FIRST
      family = MONOMIAL
      block = 'cathode'
  [../]
  # Electric current in cathode in z [C/s/mm^2]
  [./is_z]
      order = FIRST
      family = MONOMIAL
      block = 'cathode'
  [../]

  # Electric current in electrolytes in x [C/s/mm^2]
  [./ie_x]
      order = FIRST
      family = MONOMIAL
      block = 'cathode channel catex_membrane'
  [../]
  # Electric current in electrolytes in y [C/s/mm^2]
  [./ie_y]
      order = FIRST
      family = MONOMIAL
      block = 'cathode channel catex_membrane'
  [../]
  # Electric current in electrolytes in z [C/s/mm^2]
  [./ie_z]
      order = FIRST
      family = MONOMIAL
      block = 'cathode channel catex_membrane'
  [../]

  # Effective catalytic surface area per volume
  [./As]
      order = FIRST
      family = LAGRANGE
      initial_condition = 30 # mm^-1
      block = 'cathode'
  [../]

  # membrane permeability
  [./kp]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.58e-12 #mm^2
      block = 'catex_membrane'
  [../]

  # membrane electro-permeability
  [./k_phi]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.13e-13 #mm^2
      block = 'catex_membrane'
  [../]

  # membrane concentration of H+
  [./C_H_mem]
      order = FIRST
      family = LAGRANGE
      initial_condition = 2.75 #umol/mm^3
      block = 'catex_membrane'
  [../]

  # concentration of HCO3 (umol/mm^3)
  [./C_HCO3_inlet]
      order = FIRST
      family = LAGRANGE
      scaling = 1
      initial_condition = 2.938 #M
      block = 'channel'
  [../]

  # concentration of CO3 (umol/mm^3)
  [./C_CO3_inlet]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.031 #M
      block = 'channel'
  [../]

  # concentration of CO2 (umol/mm^3)
  [./C_CO2_inlet]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.031 #M
      block = 'channel'
  [../]

  # concentration of H (umol/mm^3)
  [./C_H_inlet]
      order = FIRST
      family = LAGRANGE
      initial_condition = 4.41e-9 #M
      block = 'channel'
  [../]

  # concentration of OH (umol/mm^3)
  [./C_OH_inlet]
      order = FIRST
      family = LAGRANGE
      initial_condition = 2.14e-6 #M
      block = 'channel'
  [../]

  # concentration of K (umol/mm^3)
  [./C_K_inlet]
      order = FIRST
      family = LAGRANGE
      initial_condition = 3 #M
      block = 'channel'
  [../]

  # concentration of CO (umol/mm^3)
  [./C_CO_inlet]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0 #M
      block = 'channel'
  [../]

  # concentration of H2 (umol/mm^3)
  [./C_H2_inlet]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0 #M
      block = 'channel'
  [../]

  # volumetric flowrate
  [./Q_in]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0 #mm^3/s --> upto 1666.67 #mm^3/s
      block = 'channel'
  [../]

  # channel area
  [./A_xsec]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.73 #mm^2
      block = 'channel'
  [../]

  # Recycle rate in s^-1
  [./recycle_rate]
      order = FIRST
      family = LAGRANGE
      block = 'channel'
  [../]

  # DarcyWeisbachCoefficient
  [./DarcyWeisbach]
      order = FIRST
      family = LAGRANGE
      initial_condition = 53.4 #mm^3*s/g
      block = 'channel'
  [../]

  # KozenyCarmanDarcyCoefficient
  [./KozenyCarman]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.1638 #mm^3*s/g
      block = 'cathode'
  [../]

  # SchloeglDarcyCoefficient
  [./SchloeglDarcy]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.58e-9 #mm^3*s/g
      block = 'catex_membrane'
  [../]

  # SchloeglElectrokineticCoefficient
  [./SchloeglElectrokinetic]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.02998 #C*s/g * (g/kg)*(mm^2/m^2)
      block = 'catex_membrane'
  [../]

  # Diffusion of HCO3
  [./D_HCO3]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Dispersion of HCO3
  [./Dd_HCO3]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Diffusion of CO3
  [./D_CO3]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Dispersion of CO3
  [./Dd_CO3]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Diffusion of CO2
  [./D_CO2]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Dispersion of CO2
  [./Dd_CO2]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Diffusion of H
  [./D_H]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Diffusion of H in membrane
  [./D_H_mem]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0014  # mm^2/s
      block = 'catex_membrane'
  [../]

  # Dispersion of H
  [./Dd_H]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Diffusion of OH
  [./D_OH]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Dispersion of OH
  [./Dd_OH]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Diffusion of K
  [./D_K]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Dispersion of K
  [./Dd_K]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Diffusion of CO
  [./D_CO]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Dispersion of CO
  [./Dd_CO]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Diffusion of H2
  [./D_H2]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

  # Dispersion of H2
  [./Dd_H2]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode'
  [../]

[]

[Kernels]
  ## =============== Pressure ========================
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

  ## =================== vel in x ==========================
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

  ## =================== vel in y ==========================
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

  ## =================== vel in z ==========================
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


  ## ===================== HCO3 balance ====================
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

  ## ===================== CO3 balance ====================
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

  ## ===================== CO2 balance ====================
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

  ## ===================== H balance ====================
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

  ## ===================== OH balance ====================
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
      enable = true
  [../]

  ## ===================== K balance ====================
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

  ## ===================== CO balance ====================
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

  ## ===================== H2 balance ====================
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

  ## =============== water reaction ================
  [./r_w_equ]
      type = Reaction
      variable = r_w
  [../]
  [./r_w_rxn]  #   H2O <--> H+ + OH-
      type = ArrheniusReaction
      variable = r_w
      this_variable = r_w

      temperature = T_e

      forward_pre_exponential = 1.6E-3
      forward_activation_energy = 0

      reverse_pre_exponential = 26.2636
      reverse_activation_energy = -55830

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1 # umol/mm^3

      reactants = '1'
      reactant_stoich = '1'
      products = 'C_H C_OH'
      product_stoich = '1 1'
  [../]

  ## =============== r1 reaction ================
  [./r_1_equ]
      type = Reaction
      variable = r_1
  [../]
  [./r_1_rxn]  #   CO2 + H2O <--> H+ + HCO3-
      type = ArrheniusReaction
      variable = r_1
      this_variable = r_1

      temperature = T_e

      forward_pre_exponential = 4210430
      forward_activation_energy = 47646.57

      reverse_pre_exponential = 4.25e11
      reverse_activation_energy = 39946.57

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1 # umol/mm^3

      reactants = 'C_CO2'
      reactant_stoich = '1'
      products = 'C_H C_HCO3'
      product_stoich = '1 1'
  [../]

  ## =============== r2 reaction ================
  [./r_2_equ]
      type = Reaction
      variable = r_2
  [../]
  [./r_2_rxn]  #   HCO3- <--> H+ + CO3--
      type = ArrheniusReaction
      variable = r_2
      this_variable = r_2

      temperature = T_e

      forward_pre_exponential = 22579.63
      forward_activation_energy = 14900

      reverse_pre_exponential = 1.23e12
      reverse_activation_energy = 0

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1 # umol/mm^3

      reactants = 'C_HCO3'
      reactant_stoich = '1'
      products = 'C_H C_CO3'
      product_stoich = '1 1'
  [../]

  ## =============== r3 reaction ================
  [./r_3_equ]
      type = Reaction
      variable = r_3
  [../]
  [./r_3_rxn]  #   CO2 + OH- <--> HCO3-
      type = ArrheniusReaction
      variable = r_3
      this_variable = r_3

      temperature = T_e

      forward_pre_exponential = 2.19e9
      forward_activation_energy = 34336.83

      reverse_pre_exponential = 1.34705e10
      reverse_activation_energy = 82466.83

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1 # umol/mm^3

      reactants = 'C_CO2 C_OH'
      reactant_stoich = '1 1'
      products = 'C_HCO3'
      product_stoich = '1'
  [../]

  ## =============== r4 reaction ================
  [./r_4_equ]
      type = Reaction
      variable = r_4
  [../]
  [./r_4_rxn]  #   HCO3- + OH- <--> CO3-- + H2O
      type = ArrheniusReaction
      variable = r_4
      this_variable = r_4

      temperature = T_e

      forward_pre_exponential = 6.5e9
      forward_activation_energy = 0

      reverse_pre_exponential = 2.15e13
      reverse_activation_energy = 40930

      # Apply the 'scale' as the C_ref value for simplicity
      scale = 1 # umol/mm^3

      reactants = 'C_HCO3 C_OH'
      reactant_stoich = '1 1'
      products = 'C_CO3'
      product_stoich = '1'
  [../]


  ### ==================== Electrolyte Potentials ==========================
  # in cathode and channels
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
      enable = false
  [../]

  [./phi_e_J_cat]
      type = ScaledWeightedCoupledSumFunction
      variable = phi_e
      coupled_list = 'J_H2 J_CO'
      weights = '1 1'
      block = 'cathode'
  [../]

  # in membrane
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

  ### ==================== Cathode Potentials ==========================
  # in cathode
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


  ## =============== Butler-Volmer Kinetics ================
  [./r_H2_equ]
      type = Reaction
      variable = r_H2
  [../]
  [./r_H2_rxn]  # H2 + 2 OH- <----> 2 H2O + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_H2

      reaction_rate_const = 6.59167E-6    # umol/mm^2/s
      equilibrium_potential = 0         # V

      reduced_state_vars = 'C_H2'       # assumed
      reduced_state_stoich = '1'        # assumed

      oxidized_state_vars = 'C_H'
      oxidized_state_stoich = '0.1737'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.14   # fitted param

      # correlation factor between bulk and surface concentrations
      #   Adjusted to get FE values within range of literature
      scale = 1
  [../]

  [./r_CO_equ]
      type = Reaction
      variable = r_CO
  [../]
  [./r_CO_rxn]  # CO + 2 OH- <----> CO2 + H2O + 2 e-
      type = ModifiedButlerVolmerReaction
      variable = r_CO

      reaction_rate_const = 519.39    # umol/mm^2/s (adjusted)
      equilibrium_potential = -0.11         # V

      reduced_state_vars = 'C_CO'        # assumed
      reduced_state_stoich = '1'         # assumed

      oxidized_state_vars = 'C_H C_CO2'
      oxidized_state_stoich = '0.6774 1.5'  # fitted param

      electric_potential_difference = phi_diff

      temperature = T_e
      number_of_electrons = 1         # params are fitted to this standard
      electron_transfer_coef = 0.35   # fitted param

      # correlation factor between bulk and surface concentrations
      #   Adjusted to get FE values within range of literature
      scale = 1
  [../]

  ## =============== Butler-Volmer Current ================
  [./J_H2_equ]
      type = Reaction
      variable = J_H2
  [../]
  [./J_H2_rxn]  # H2 + OH- <----> 2 H2O + 2 e-
      type = ButlerVolmerCurrentDensity
      variable = J_H2

      number_of_electrons = 2  # params are fitted to this standard
      specific_area = As
      rate_var = r_H2
  [../]

  [./J_CO_equ]
      type = Reaction
      variable = J_CO
  [../]
  [./J_CO_rxn]  # CO + 2 OH- <----> CO2 + H2O + 2 e-
      type = ButlerVolmerCurrentDensity
      variable = J_CO

      number_of_electrons = 2  # params are fitted to this standard
      specific_area = As
      rate_var = r_CO
  [../]
[]

[DGKernels]

[]

[AuxKernels]
  # set porosity
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

  # calculate velocity magnitude
  [./vel_calc]
      type = VectorMagnitude
      variable = vel_mag
      ux = vel_x
      uy = vel_y
      uz = vel_z
      execute_on = 'initial timestep_end'
  [../]

  # calculate flowrate ramp up
  [./flowrate_step_input]
      type = TemporalStepFunction
      variable = Q_in

      start_value = 0.0
      aux_vals = '1666.67'

      # Ramp up initial flow rate to
      # full in 10 seconds
      aux_times = '5'
      time_spans = '10'

      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # calculate input current
  [./current_step_input]
      type = TemporalStepFunction
      variable = input_current

      start_value = 0.0
      aux_vals = '0.001'  # 100 mA/cm^2 ==> 0.001 C/s/mm^2

      # Input current should approximately be a step function
      aux_times = '15'
      time_spans = '0.5'

      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # calculate cathode voltage
  [./volt_step_input]
      type = TemporalStepFunction
      variable = cat_volt

      start_value = 0.0
      aux_vals = '0'  # V

      # Input current should approximately be a step function
      aux_times = '15'
      time_spans = '0.5'

      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # calculate inlet velocity
  [./vel_from_flowrate]
      type = AuxAvgLinearVelocity
      variable = vel_in

      flow_rate = Q_in
      xsec_area = A_xsec
      porosity = 1

      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # calculation of recycle rate
  [./recycle_calc]
      type = AuxAvgLinearVelocity
      variable = recycle_rate
      flow_rate = Q_in  # mm^3/s
      xsec_area = 500000 # mm^3 => Used as volume here
      porosity = 1
      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # Calculation of inlet concentrations
  [./C_HCO3_inlet_calc]
      type = AuxFirstOrderRecycleBC
      variable = C_HCO3_inlet
      outlet_postprocessor = C_HCO3_out_M
      recycle_rate = recycle_rate
      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # Calculation of inlet concentrations
  [./C_CO3_inlet_calc]
      type = AuxFirstOrderRecycleBC
      variable = C_CO3_inlet
      outlet_postprocessor = C_CO3_out_M
      recycle_rate = recycle_rate
      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # Calculation of inlet concentrations
  [./C_CO2_inlet_calc]
      type = AuxFirstOrderRecycleBC
      variable = C_CO2_inlet
      outlet_postprocessor = C_CO2_out_M
      recycle_rate = recycle_rate
      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # Calculation of inlet concentrations
  [./C_OH_inlet_calc]
      type = AuxFirstOrderRecycleBC
      variable = C_OH_inlet
      outlet_postprocessor = C_OH_out_M
      recycle_rate = recycle_rate
      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # Calculation of inlet concentrations
  [./C_H_inlet_calc]
      type = AuxFirstOrderRecycleBC
      variable = C_H_inlet
      outlet_postprocessor = C_H_out_M
      recycle_rate = recycle_rate
      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # Calculation of inlet concentrations
  [./C_K_inlet_calc]
      type = AuxFirstOrderRecycleBC
      variable = C_K_inlet
      outlet_postprocessor = C_K_out_M
      recycle_rate = recycle_rate
      execute_on = 'initial timestep_begin nonlinear'
  [../]

  # calculation of DarcyWeisbachCoefficient
  [./darcy_coef_calc_channels]
      type = DarcyWeisbachCoefficient
      variable = DarcyWeisbach

      # NOTE: Here we are replacing the full
      #       expression with the laminar flow
      #       approximation (manually).
      friction_factor = 64           # -
      density = viscosity            # g/mm/s
      velocity = 1                   # -
      hydraulic_diameter = 1.70877   #dh^2 (mm^2)

      execute_on = 'initial timestep_end'
      block = 'channel'
  [../]

  # calculation of KozenyCarmanDarcyCoefficient
  [./kozeny_coef_calc_elec]
      type = KozenyCarmanDarcyCoefficient
      variable = KozenyCarman

      porosity = eps
      viscosity = viscosity   #g/mm/s
      particle_diameter = dp #mm
      kozeny_carman_const = 150 #for spheres

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # calculation of SchloeglDarcyCoefficient
  [./darcy_coef_calc_mem]
      type = SchloeglDarcyCoefficient
      variable = SchloeglDarcy

      hydraulic_permeability = kp  #mm^2
      viscosity = viscosity  #g/mm/s

      execute_on = 'initial timestep_end'
      block = 'catex_membrane'
  [../]

  # calculation of SchloeglElectrokineticCoefficient
  [./elec_coef_calc_mem]
      type = SchloeglElectrokineticCoefficient
      variable = SchloeglElectrokinetic

      electrokinetic_permeability = k_phi  #mm^2
      viscosity = viscosity                #g/mm/s
      ion_conc = C_H_mem                   #umol/mm^3
      conversion_factor = 1e9

      execute_on = 'initial timestep_end'
      block = 'catex_membrane'
  [../]

  # ----------- Diffusion calc for HCO3 ----------------
  [./D_HCO3_calc_channels]
      type = SimpleFluidDispersion
      variable = D_HCO3
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.0011

      include_dispersivity_correction = false
      include_porosity_correction = false

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

      include_dispersivity_correction = false
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # Dispersion calc for HCO3
  [./Dd_HCO3_calc_channels]
      type = SimpleFluidDispersion
      variable = Dd_HCO3
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.0011

      include_dispersivity_correction = true
      include_porosity_correction = false

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

      include_dispersivity_correction = true
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]


  # --------------- Diffusion calc for CO3 --------------
  [./D_CO3_calc_channels]
      type = SimpleFluidDispersion
      variable = D_CO3
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.000801

      include_dispersivity_correction = false
      include_porosity_correction = false

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

      include_dispersivity_correction = false
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # Dispersion calc for CO3
  [./Dd_CO3_calc_channels]
      type = SimpleFluidDispersion
      variable = Dd_CO3
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.000801

      include_dispersivity_correction = true
      include_porosity_correction = false

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

      include_dispersivity_correction = true
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]


  # --------------- Diffusion calc for CO2 --------------
  [./D_CO2_calc_channels]
      type = SimpleFluidDispersion
      variable = D_CO2
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.00191

      include_dispersivity_correction = false
      include_porosity_correction = false

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

      include_dispersivity_correction = false
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # Dispersion calc for CO2
  [./Dd_CO2_calc_channels]
      type = SimpleFluidDispersion
      variable = Dd_CO2
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.00191

      include_dispersivity_correction = true
      include_porosity_correction = false

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

      include_dispersivity_correction = true
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]


  # --------------- Diffusion calc for H --------------
  [./D_H_calc_channels]
      type = SimpleFluidDispersion
      variable = D_H
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.00695

      include_dispersivity_correction = false
      include_porosity_correction = false

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

      include_dispersivity_correction = false
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # Dispersion calc for H
  [./Dd_H_calc_channels]
      type = SimpleFluidDispersion
      variable = Dd_H
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.00695

      include_dispersivity_correction = true
      include_porosity_correction = false

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

      include_dispersivity_correction = true
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]


  # --------------- Diffusion calc for OH --------------
  [./D_OH_calc_channels]
      type = SimpleFluidDispersion
      variable = D_OH
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.00493

      include_dispersivity_correction = false
      include_porosity_correction = false

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

      include_dispersivity_correction = false
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # Dispersion calc for OH
  [./Dd_OH_calc_channels]
      type = SimpleFluidDispersion
      variable = Dd_OH
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.00493

      include_dispersivity_correction = true
      include_porosity_correction = false

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

      include_dispersivity_correction = true
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]


  # --------------- Diffusion calc for CO --------------
  [./D_CO_calc_channels]
      type = SimpleFluidDispersion
      variable = D_CO
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.002107

      include_dispersivity_correction = false
      include_porosity_correction = false

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

      include_dispersivity_correction = false
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # Dispersion calc for CO
  [./Dd_CO_calc_channels]
      type = SimpleFluidDispersion
      variable = Dd_CO
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.002107

      include_dispersivity_correction = true
      include_porosity_correction = false

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

      include_dispersivity_correction = true
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]


  # --------------- Diffusion calc for H2 --------------
  [./D_H2_calc_channels]
      type = SimpleFluidDispersion
      variable = D_H2
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.00511

      include_dispersivity_correction = false
      include_porosity_correction = false

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

      include_dispersivity_correction = false
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # Dispersion calc for H2
  [./Dd_H2_calc_channels]
      type = SimpleFluidDispersion
      variable = Dd_H2
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.00511

      include_dispersivity_correction = true
      include_porosity_correction = false

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

      include_dispersivity_correction = true
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]


  # --------------- Diffusion calc for K --------------
  [./D_K_calc_channels]
      type = SimpleFluidDispersion
      variable = D_K
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.001849

      include_dispersivity_correction = false
      include_porosity_correction = false

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

      include_dispersivity_correction = false
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # Dispersion calc for K
  [./Dd_K_calc_channels]
      type = SimpleFluidDispersion
      variable = Dd_K
      temperature = T_e
      macro_porosity = eps
      ux = vel_x
      uy = vel_y
      uz = vel_z

      ref_diffusivity = 0.001849

      include_dispersivity_correction = true
      include_porosity_correction = false

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

      include_dispersivity_correction = true
      include_porosity_correction = true

      execute_on = 'initial timestep_end'
      block = 'cathode'
  [../]

  # calculation of effective electrolyte conductivity
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


  # Calculations for electrolyte current in cathode and channel
  [./ie_x_calc_cat]
      type = AuxElectrolyteCurrent
      variable = ie_x
      direction = 0         # 0=x
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
      direction = 1         # 1=y
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
      direction = 2         # 2=z
      electric_potential = phi_e
      porosity = 1
      temperature = T_e
      ion_conc = 'C_H C_K'
      diffusion = 'D_H D_K'
      ion_valence = '1 1'
      execute_on = 'initial timestep_end'
      block = 'channel cathode'
  [../]

  # Calculations for electrolyte current in membrane
  [./ie_x_calc_mem]
      type = AuxElectrolyteCurrent
      variable = ie_x
      direction = 0         # 0=x
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
      direction = 1         # 1=y
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
      direction = 2         # 2=z
      electric_potential = phi_e
      porosity = 1
      temperature = T_e
      ion_conc = 'C_H_mem'
      diffusion = 'D_H_mem'
      ion_valence = '1'
      execute_on = 'initial timestep_end'
      block = 'catex_membrane'
  [../]

  # Calculation of electrode currents
  [./is_x_calc]
      type = AuxElectrodeCurrent
      variable = is_x
      direction = 0         # 0=x
      electric_potential = phi_s
      solid_frac = 1
      conductivity = sigma_s_eff
      execute_on = 'initial timestep_end'
  [../]
  [./is_y_calc]
      type = AuxElectrodeCurrent
      variable = is_y
      direction = 1         # 1=y
      electric_potential = phi_s
      solid_frac = 1
      conductivity = sigma_s_eff
      execute_on = 'initial timestep_end'
  [../]
  [./is_z_calc]
      type = AuxElectrodeCurrent
      variable = is_z
      direction = 2         # 2=z
      electric_potential = phi_s
      solid_frac = 1
      conductivity = sigma_s_eff
      execute_on = 'initial timestep_end'
  [../]


  # calculate electrolyte current magnitude
  [./ie_calc]
      type = VectorMagnitude
      variable = ie_mag
      ux = ie_x
      uy = ie_y
      uz = ie_z
      execute_on = 'initial timestep_end'
  [../]

  # calculate electrode current magnitude
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
  # ====== exit pressure ======
  [./press_at_exit]
      type = DirichletBC
      variable = pressure
      boundary = 'channel_exit'
      value = 0 # Pa == 4 atm
  [../]

  # ===== inlet pressure grad =====
  [./press_grad_at_inlet]
      type = CoupledNeumannBC
      variable = pressure
      boundary = 'channel_enter'
      coupled = vel_in  # mm/s
  [../]


  ## =============== HCO3 fluxes ================
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

  ## =============== CO3 fluxes ================
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

  ## =============== CO2 fluxes ================
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

  ## =============== H fluxes ================
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
      #       -> coef = (F/R/T)*Dmem*C_H
      #             Dmem = 0.0014 mm^2/s
      #             C_H = 2.75 M
      #       coef = 0.14992 [umol/V/mm/s]
      coef = 0.14992
  [../]

  ## =============== OH fluxes ================
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


  ## =============== K fluxes ================
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

  ## =============== CO fluxes ================
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

  ## =============== H2 fluxes ================
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

  # ====== cathode state ======
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

  # ===== applied current =====
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

  # ==== Reference electrolyte state ====
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
  petsc_options_iname ='-ksp_type
                        -pc_type

                        -sub_pc_type

                        -snes_max_it

                        -sub_pc_factor_shift_type
                        -pc_factor_shift_type
                        -ksp_pc_factor_shift_type

                        -pc_gasm_overlap

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

                         #-ksp_pc_factor_mat_solver_type
                        	#-mat_mumps_cntl_1
                          #-mat_mumps_cntl_3
                          #-mat_mumps_icntl_23'

  ## NOTE: May be best to just use lu as pc_type instead of ksp
  petsc_options_value = 'fgmres
                         ksp

                         lu

                         50

                         NONZERO
                         NONZERO
                         NONZERO

                         20

                         1E-8
                         1E-8

                         fgmres
                         ilu

                         50
                         50

                         20
                         10

                         1e-8
                         1e-8'

                         #mumps
                          #0.01
                          #1e-8
                          #4000'


  line_search = l2  # none, l2, or bt
  nl_rel_step_tol = 1e-12
  nl_abs_step_tol = 1e-12

  start_time = 0.0
  end_time = 515  #Experiments were run for 500s, the added 15s accounts for ramp up
  dtmax = 10

  [./TimeStepper]
		  type = SolutionTimeAdaptiveDT
      dt = 0.05 #coarse
      #dt = 0.01 #fine
      cutback_factor_at_failure = 0.5
      percent_change = 0.5
  [../]

[] #END Executioner

[Preconditioning]
    [./SMP_PJFNK]
      type = SMP
      #full = true

      # NOTE: This is an alternative to 'full' coupling
      #     Helps create a more sparse Jacobian
      coupled_groups = 'pressure,vel_x pressure,vel_y, pressure,vel_z
                        C_HCO3,r_1 C_HCO3,r_2 C_HCO3,r_3 C_HCO3,r_4
                        C_CO3,r_2 C_CO3,r_4
                        C_CO2,r_1 C_CO2,r_3 C_CO2,r_CO
                        C_H,r_w C_H,r_1 C_H,r_2 C_H,r_H2 C_H,r_CO
                        C_OH,r_w C_OH,r_3 C_OH,r_4 C_OH,r_H2 C_OH,r_CO
                        C_CO,r_CO C_H2,r_H2
                        J_CO,r_CO J_H2,r_H2
                        J_CO,phi_e J_H2,phi_e J_CO,phi_s J_H2,phi_s
                        phi_diff,phi_s phi_diff,phi_e
                        phi_e,C_HCO3, phi_e,C_CO3, phi_e,C_H phi_e,C_OH phi_e,C_K'
      solve_type = pjfnk
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = true
    interval = 1

[] #END Outputs
