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
#     ground potential (@ channel_interface_cathode)
#                      (@ plate_interface_cathode)  = 0
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
#     As = 2.52e+4 mm^-1 (etched active area) [2.1e+4 mm^-1 non-etched]
#     dp = 0.03 mm (avg particle size)
#     dh = 1.3072 mm (hydraulic diameter for Darcy-Weisbach)
#     lambda = 0.75 mm (avg dispersivity)
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
  tight_coupling = true

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
    file = CO2_electrolyzer_half_cell_plateless_v2_fine.msh

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
      initial_condition = 1e-15 #M
      block = 'channel cathode'
  [../]

  # concentration of H2 (umol/mm^3)
  [./C_H2]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1e-15 #M
      block = 'channel cathode'
  [../]

[]

[ICs]

[]

[AuxVariables]
  # ---------------- Temporarily setting var here ----------------
  [./phi_e]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0.0
      block = 'channel cathode catex_membrane'
  [../]


  # velocity magnitude
  [./vel_mag]
      order = FIRST
      family = LAGRANGE
      block = 'channel cathode catex_membrane'
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

  # volumetric flowrate
  [./Q_in]
      order = FIRST
      family = LAGRANGE
      initial_condition = 16.6667 #mm^3/s --> upto 1666.67 #mm^3/s
      block = 'channel'
  [../]

  # channel area
  [./A_xsec]
      order = FIRST
      family = LAGRANGE
      initial_condition = 1.73 #mm^2
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
  [./CO2_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = C_CO2
      valence = 0
      porosity = 1
      electric_potential = phi_e
      temperature = T_e
      Dx = D_CO2
      Dy = D_CO2
      Dz = D_CO2
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
  [./CO_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = C_CO
      valence = 0
      porosity = 1
      electric_potential = phi_e
      temperature = T_e
      Dx = D_CO
      Dy = D_CO
      Dz = D_CO
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
  [./H2_gnpdiff]
      type = GNernstPlanckDiffusion
      variable = C_H2
      valence = 0
      porosity = 1
      electric_potential = phi_e
      temperature = T_e
      Dx = D_H2
      Dy = D_H2
      Dz = D_H2
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

  # calculate inlet velocity
  [./vel_from_flowrate]
      type = AuxAvgLinearVelocity
      variable = vel_in

      flow_rate = Q_in
      xsec_area = A_xsec
      porosity = 1

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
      input_var = 2.938
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
      input_var = 0.031
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
      input_var = 0.031
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
      input_var = 4.41e-9
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

  ## =============== OH fluxes ================
  [./OH_FluxIn]
      type = DGFlowMassFluxBC
      variable = C_OH
      boundary = 'channel_enter'
      porosity = 1
      ux = vel_x
      uy = vel_y
      uz = vel_z
      input_var = 2.14e-6
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
      input_var = 3
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
      input_var = 1e-15
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
      input_var = 1e-15
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

[]


[Postprocessors]
  [./pressure_inlet]
      type = SideAverageValue
      boundary = 'channel_enter'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./pressure_outlet]
      type = SideAverageValue
      boundary = 'channel_exit'
      variable = pressure
      execute_on = 'initial timestep_end'
  [../]

  [./vy_inlet]
      type = SideAverageValue
      boundary = 'channel_enter'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./vy_outlet]
      type = SideAverageValue
      boundary = 'channel_exit'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]

  [./A_outlet]
      type = AreaPostprocessor
      boundary = 'channel_exit'
      execute_on = 'initial timestep_end'
  [../]

  [./A_membrane]
      type = AreaPostprocessor
      boundary = 'catex_mem_interface'
      execute_on = 'initial timestep_end'
  [../]

  [./Q_cross_mem]
      type = SideIntegralVariablePostprocessor
      boundary = 'catex_mem_interface'
      variable = vel_z
      execute_on = 'initial timestep_end'
  [../]

  [./Q_outlet]
      type = SideIntegralVariablePostprocessor
      boundary = 'channel_exit'
      variable = vel_y
      execute_on = 'initial timestep_end'
  [../]


  [./HCO3_inlet]
      type = SideAverageValue
      boundary = 'channel_enter'
      variable = C_HCO3
      execute_on = 'initial timestep_end'
  [../]

  [./HCO3_outlet]
      type = SideAverageValue
      boundary = 'channel_exit'
      variable = C_HCO3
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
                        -ksp_rtol

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

                         20
                         10

                         1e-6
                         1e-8

                         mumps
                          0.01
                          1e-8
                          4000'


  line_search = l2
  nl_rel_step_tol = 1e-12
  nl_abs_step_tol = 1e-12

  start_time = 0.0
  end_time = 10
  dtmax = 10

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
    interval = 1

[] #END Outputs
