
[GlobalParams]
  # 'dg_scheme' and 'sigma' are parameters for the DG kernels
  dg_scheme = nipg
  sigma = 10

  # Maximum effective wall thickness for diffusion
  #   This value is calculated in the MonolithMicroscaleTotalThickness kernel,
  #   but cannot be automatically linked here due to the implementation standards
  #   of the Microscale kernel base. Thus, users should calculate this value
  #   first in an input file using the MonolithMicroscaleTotalThickness kernel.
  #   Then, place that value here to use the Microscale kernels to simulate
  #   mass-transfer and intralayer diffusion for monolith domains.
  micro_length = 0.036265525844469 #cm thick

  # Final setup for the Microscale is done by specifying the number of nodes
  #   for the microscale, and the coord_id number.
  num_nodes = 5
  coord_id = 0  #0 ==> washcoat (1=cylindrical particles, 2=spherical particles)

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
    xmax = 1.0    #2cm diameter (1cm radius)
    ymin = 0.0
    ymax = 5.0    #5cm length
[] # END Mesh

[Variables]

## Gas phase variable lists
    [./O2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./O2w_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./O2w_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./O2w_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./O2w_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./O2w_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2Ow_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2Ow_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2Ow_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2Ow_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2Ow_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NH3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NH3w_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NH3w_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NH3w_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NH3w_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NH3w_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NOx]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NOxw_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NOxw_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NOxw_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NOxw_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./NOxw_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2O]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2Ow_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2Ow_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2Ow_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2Ow_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2Ow_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./COw_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./COw_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./COw_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./COw_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./COw_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO2w_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO2w_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO2w_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO2w_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./CO2w_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2w_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2w_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2w_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2w_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./N2w_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2w_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2w_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2w_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2w_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./H2w_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./HC]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./HCw_n0]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./HCw_n1]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./HCw_n2]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./HCw_n3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

    [./HCw_n4]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1E-15
    [../]

## Reaction variable list
    [./r1_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r1_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r1_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r1_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r1_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r2_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r2_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r2_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r2_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r2_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r3_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r3_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r3_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r3_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r3_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r4_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r4_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r4_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r4_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r4_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r5_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r5_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r5_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r5_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r5_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r6_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r6_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r6_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r6_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r6_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r7_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r7_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r7_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r7_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r7_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r8_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r8_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r8_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r8_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r8_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r10_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r10_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r10_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r10_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r10_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r11_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r11_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r11_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r11_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r11_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r12_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r12_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r12_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r12_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r12_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r14_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r14_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r14_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r14_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r14_n4]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r15_n0]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r15_n1]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r15_n2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r15_n3]
        order = FIRST
        family = MONOMIAL
    [../]

    [./r15_n4]
        order = FIRST
        family = MONOMIAL
    [../]

## Inhibition Variables
  [./R_CO_n0]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'COw_n0'
         pre_exponentials = '2.59'
         activation_energies = '-36284.4'
     [../]
  [../]

  [./R_CO_n1]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'COw_n1'
         pre_exponentials = '2.59'
         activation_energies = '-36284.4'
     [../]
  [../]

  [./R_CO_n2]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'COw_n2'
         pre_exponentials = '2.59'
         activation_energies = '-36284.4'
     [../]
  [../]

  [./R_CO_n3]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'COw_n3'
         pre_exponentials = '2.59'
         activation_energies = '-36284.4'
     [../]
  [../]

  [./R_CO_n4]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'COw_n4'
         pre_exponentials = '2.59'
         activation_energies = '-36284.4'
     [../]
  [../]

  [./R_HC_n0]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'HCw_n0'
         pre_exponentials = '0'
         activation_energies = '0'
     [../]
  [../]

  [./R_HC_n1]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'HCw_n1'
         pre_exponentials = '0'
         activation_energies = '0'
     [../]
  [../]

  [./R_HC_n2]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'HCw_n2'
         pre_exponentials = '0'
         activation_energies = '0'
     [../]
  [../]

  [./R_HC_n3]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'HCw_n3'
         pre_exponentials = '0'
         activation_energies = '0'
     [../]
  [../]

  [./R_HC_n4]
    order = FIRST
    family = MONOMIAL
     [./InitialCondition]
         type = InitialLangmuirInhibition
         temperature = temp
         coupled_list = 'HCw_n4'
         pre_exponentials = '0'
         activation_energies = '0'
     [../]
  [../]

[] #END Variables

[AuxVariables]

  [./temp]
      order = FIRST
      family = MONOMIAL
      initial_condition = 379
  [../]

  [./press]
      order = FIRST
      family = MONOMIAL
      initial_condition = 101.35
  [../]

  [./D]
    order = FIRST
    family = MONOMIAL
  [../]

  # e_b
  [./pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.775
  [../]

  # non_pore = (1 - pore)
  [./non_pore]
      order = FIRST
      family = MONOMIAL
  [../]

  # ew value
  [./micro_pore]
      order = FIRST
      family = MONOMIAL
      initial_condition = 0.4
  [../]

  # total_pore = ew* (1 - pore)
  # assume ew = 0.4
  [./total_pore]
      order = FIRST
      family = MONOMIAL
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

  # Effective pore diffusion - auto calculated in properties
  [./Deff]
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
  [../]

  [./vel_z]
      order = FIRST
      family = LAGRANGE
      initial_condition = 0
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
        coupled = O2w_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase O2 ===============
    # Exterior node
    [./O2w_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./O2w_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = O2w_n4
        node_id = 4
        macro_variable = O2
        lower_neighbor = O2w_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./O2w_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n4
        node_id = 4
        coupled_list = 'r1_n4 r2_n4 r15_n4 r3_n4 r12_n4'
        weights = '-0.5 -0.5 -0.25 -9 0'
        scale = non_pore
    [../]

    # node 3
    [./O2w_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./O2w_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = O2w_n3
        node_id = 3
        upper_neighbor = O2w_n4
        lower_neighbor = O2w_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./O2w_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n3
        node_id = 3
        coupled_list = 'r1_n3 r2_n3 r15_n3 r3_n3 r12_n3'
        weights = '-0.5 -0.5 -0.25 -9 0'
        scale = non_pore
    [../]

    # node 2
    [./O2w_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./O2w_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = O2w_n2
        node_id = 2
        upper_neighbor = O2w_n3
        lower_neighbor = O2w_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./O2w_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n2
        node_id = 2
        coupled_list = 'r1_n2 r2_n2 r15_n2 r3_n2 r12_n2'
        weights = '-0.5 -0.5 -0.25 -9 0'
        scale = non_pore
    [../]

    # node 1
    [./O2w_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./O2w_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = O2w_n1
        node_id = 1
        upper_neighbor = O2w_n2
        lower_neighbor = O2w_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./O2w_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n1
        node_id = 1
        coupled_list = 'r1_n1 r2_n1 r15_n1 r3_n1 r12_n1'
        weights = '-0.5 -0.5 -0.25 -9 0'
        scale = non_pore
    [../]

    # node 0
    [./O2w_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = O2w_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./O2w_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = O2w_n0
        node_id = 0
        upper_neighbor = O2w_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./O2w_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = O2w_n0
        node_id = 0
        coupled_list = 'r1_n0 r2_n0 r15_n0 r3_n0 r12_n0'
        weights = '-0.5 -0.5 -0.25 -9 0'
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
        coupled = H2Ow_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase H2O ===============
    # Exterior node
    [./H2Ow_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Ow_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./H2Ow_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = H2Ow_n4
        node_id = 4
        macro_variable = H2O
        lower_neighbor = H2Ow_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2Ow_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Ow_n4
        node_id = 4
        coupled_list = 'r2_n4 r8_n4 r11_n4 r6_n4 r7_n4 r14_n4 r15_n4 r3_n4 r10_n4 r12_n4'
        weights = '1 -1.5 -1 1 1 1 1.5 4 4 -7'
        scale = non_pore
    [../]

    # node 3
    [./H2Ow_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Ow_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./H2Ow_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = H2Ow_n3
        node_id = 3
        upper_neighbor = H2Ow_n4
        lower_neighbor = H2Ow_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2Ow_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Ow_n3
        node_id = 3
        coupled_list = 'r2_n3 r8_n3 r11_n3 r6_n3 r7_n3 r14_n3 r15_n3 r3_n3 r10_n3 r12_n3'
        weights = '1 -1.5 -1 1 1 1 1.5 4 4 -7'
        scale = non_pore
    [../]

    # node 2
    [./H2Ow_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Ow_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./H2Ow_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = H2Ow_n2
        node_id = 2
        upper_neighbor = H2Ow_n3
        lower_neighbor = H2Ow_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2Ow_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Ow_n2
        node_id = 2
        coupled_list = 'r2_n2 r8_n2 r11_n2 r6_n2 r7_n2 r14_n2 r15_n2 r3_n2 r10_n2 r12_n2'
        weights = '1 -1.5 -1 1 1 1 1.5 4 4 -7'
        scale = non_pore
    [../]

    # node 1
    [./H2Ow_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Ow_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./H2Ow_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = H2Ow_n1
        node_id = 1
        upper_neighbor = H2Ow_n2
        lower_neighbor = H2Ow_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2Ow_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Ow_n1
        node_id = 1
        coupled_list = 'r2_n1 r8_n1 r11_n1 r6_n1 r7_n1 r14_n1 r15_n1 r3_n1 r10_n1 r12_n1'
        weights = '1 -1.5 -1 1 1 1 1.5 4 4 -7'
        scale = non_pore
    [../]

    # node 0
    [./H2Ow_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2Ow_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./H2Ow_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = H2Ow_n0
        node_id = 0
        upper_neighbor = H2Ow_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2Ow_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2Ow_n0
        node_id = 0
        coupled_list = 'r2_n0 r8_n0 r11_n0 r6_n0 r7_n0 r14_n0 r15_n0 r3_n0 r10_n0 r12_n0'
        weights = '1 -1.5 -1 1 1 1 1.5 4 4 -7'
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
        coupled = NH3w_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase NH3 ===============
    # Exterior node
    [./NH3w_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NH3w_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./NH3w_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = NH3w_n4
        node_id = 4
        macro_variable = NH3
        lower_neighbor = NH3w_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./NH3w_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NH3w_n4
        node_id = 4
        coupled_list = 'r8_n4 r6_n4 r15_n4'
        weights = '1 1 -1'
        scale = non_pore
    [../]

    # node 3
    [./NH3w_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NH3w_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./NH3w_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = NH3w_n3
        node_id = 3
        upper_neighbor = NH3w_n4
        lower_neighbor = NH3w_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./NH3w_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NH3w_n3
        node_id = 3
        coupled_list = 'r8_n3 r6_n3 r15_n3'
        weights = '1 1 -1'
        scale = non_pore
    [../]

    # node 2
    [./NH3w_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NH3w_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./NH3w_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = NH3w_n2
        node_id = 2
        upper_neighbor = NH3w_n3
        lower_neighbor = NH3w_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./NH3w_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NH3w_n2
        node_id = 2
        coupled_list = 'r8_n2 r6_n2 r15_n2'
        weights = '1 1 -1'
        scale = non_pore
    [../]

    # node 1
    [./NH3w_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NH3w_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./NH3w_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = NH3w_n1
        node_id = 1
        upper_neighbor = NH3w_n2
        lower_neighbor = NH3w_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./NH3w_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NH3w_n1
        node_id = 1
        coupled_list = 'r8_n1 r6_n1 r15_n1'
        weights = '1 1 -1'
        scale = non_pore
    [../]

    # node 0
    [./NH3w_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NH3w_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./NH3w_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = NH3w_n0
        node_id = 0
        upper_neighbor = NH3w_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./NH3w_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NH3w_n0
        node_id = 0
        coupled_list = 'r8_n0 r6_n0 r15_n0'
        weights = '1 1 -1'
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
        coupled = NOxw_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase NO ===============
    # Exterior node
    [./NOxw_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NOxw_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./NOxw_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = NOxw_n4
        node_id = 4
        macro_variable = NOx
        lower_neighbor = NOxw_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./NOxw_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NOxw_n4
        node_id = 4
        coupled_list = 'r4_n4 r5_n4 r8_n4 r6_n4 r7_n4 r14_n4 r15_n4 r10_n4'
        weights = '-1 -2 -1 -1 -1 -2 -1 -18'
        scale = non_pore
    [../]

    # node 3
    [./NOxw_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NOxw_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./NOxw_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = NOxw_n3
        node_id = 3
        upper_neighbor = NOxw_n4
        lower_neighbor = NOxw_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./NOxw_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NOxw_n3
        node_id = 3
        coupled_list = 'r4_n3 r5_n3 r8_n3 r6_n3 r7_n3 r14_n3 r15_n3 r10_n3'
        weights = '-1 -2 -1 -1 -1 -2 -1 -18'
        scale = non_pore
    [../]

    # node 2
    [./NOxw_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NOxw_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./NOxw_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = NOxw_n2
        node_id = 2
        upper_neighbor = NOxw_n3
        lower_neighbor = NOxw_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./NOxw_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NOxw_n2
        node_id = 2
        coupled_list = 'r4_n2 r5_n2 r8_n2 r6_n2 r7_n2 r14_n2 r15_n2 r10_n2'
        weights = '-1 -2 -1 -1 -1 -2 -1 -18'
        scale = non_pore
    [../]

    # node 1
    [./NOxw_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NOxw_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./NOxw_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = NOxw_n1
        node_id = 1
        upper_neighbor = NOxw_n2
        lower_neighbor = NOxw_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./NOxw_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NOxw_n1
        node_id = 1
        coupled_list = 'r4_n1 r5_n1 r8_n1 r6_n1 r7_n1 r14_n1 r15_n1 r10_n1'
        weights = '-1 -2 -1 -1 -1 -2 -1 -18'
        scale = non_pore
    [../]

    # node 0
    [./NOxw_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = NOxw_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./NOxw_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = NOxw_n0
        node_id = 0
        upper_neighbor = NOxw_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./NOxw_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = NOxw_n0
        node_id = 0
        coupled_list = 'r4_n0 r5_n0 r8_n0 r6_n0 r7_n0 r14_n0 r15_n0 r10_n0'
        weights = '-1 -2 -1 -1 -1 -2 -1 -18'
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
        coupled = N2Ow_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase N2O ===============
    # Exterior node
    [./N2Ow_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2Ow_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./N2Ow_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = N2Ow_n4
        node_id = 4
        macro_variable = N2O
        lower_neighbor = N2Ow_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    [./N2Ow_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2Ow_n4
        node_id = 4
        coupled_list = 'r5_n4 r14_n4'
        weights = '1 1'
        scale = non_pore
    [../]

    # node 3
    [./N2Ow_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2Ow_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./N2Ow_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = N2Ow_n3
        node_id = 3
        upper_neighbor = N2Ow_n4
        lower_neighbor = N2Ow_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./N2Ow_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2Ow_n3
        node_id = 3
        coupled_list = 'r5_n3 r14_n3'
        weights = '1 1'
        scale = non_pore
    [../]

    # node 2
    [./N2Ow_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2Ow_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./N2Ow_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = N2Ow_n2
        node_id = 2
        upper_neighbor = N2Ow_n3
        lower_neighbor = N2Ow_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./N2Ow_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2Ow_n2
        node_id = 2
        coupled_list = 'r5_n2 r14_n2'
        weights = '1 1'
        scale = non_pore
    [../]

    # node 1
    [./N2Ow_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2Ow_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./N2Ow_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = N2Ow_n1
        node_id = 1
        upper_neighbor = N2Ow_n2
        lower_neighbor = N2Ow_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    [./N2Ow_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2Ow_n1
        node_id = 1
        coupled_list = 'r5_n1 r14_n1'
        weights = '1 1'
        scale = non_pore
    [../]

    # node 0
    [./N2Ow_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2Ow_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./N2Ow_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = N2Ow_n0
        node_id = 0
        upper_neighbor = N2Ow_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    [./N2Ow_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2Ow_n0
        node_id = 0
        coupled_list = 'r5_n0 r14_n0'
        weights = '1 1'
        scale = non_pore
    [../]

    # =============== Bulk phase CO ===============
    [./CO_dot]
        type = VariableCoefTimeDerivative
        variable = CO
        coupled_coef = pore
    [../]
    [./CO_gadv]
        type = GPoreConcAdvection
        variable = CO
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO_gdiff]
        type = GVarPoreDiffusion
        variable = CO
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./COw_trans]
        type = FilmMassTransfer
        variable = CO
        coupled = COw_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase CO ===============
    # Exterior node
    [./COw_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./COw_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = COw_n4
        node_id = 4
        macro_variable = CO
        lower_neighbor = COw_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./COw_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n4
        node_id = 4
        coupled_list = 'r1_n4 r4_n4 r5_n4 r8_n4 r11_n4 r12_n4'
        weights = '-1 -1 -1 -2.5 -1 7'
        scale = non_pore
    [../]

    # node 3
    [./COw_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./COw_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = COw_n3
        node_id = 3
        upper_neighbor = COw_n4
        lower_neighbor = COw_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./COw_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n3
        node_id = 3
        coupled_list = 'r1_n3 r4_n3 r5_n3 r8_n3 r11_n3 r12_n3'
        weights = '-1 -1 -1 -2.5 -1 7'
        scale = non_pore
    [../]

    # node 2
    [./COw_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./COw_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = COw_n2
        node_id = 2
        upper_neighbor = COw_n3
        lower_neighbor = COw_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./COw_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n2
        node_id = 2
        coupled_list = 'r1_n2 r4_n2 r5_n2 r8_n2 r11_n2 r12_n2'
        weights = '-1 -1 -1 -2.5 -1 7'
        scale = non_pore
    [../]

    # node 1
    [./COw_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./COw_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = COw_n1
        node_id = 1
        upper_neighbor = COw_n2
        lower_neighbor = COw_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./COw_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n1
        node_id = 1
        coupled_list = 'r1_n1 r4_n1 r5_n1 r8_n1 r11_n1 r12_n1'
        weights = '-1 -1 -1 -2.5 -1 7'
        scale = non_pore
    [../]

    # node 0
    [./COw_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = COw_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./COw_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = COw_n0
        node_id = 0
        upper_neighbor = COw_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./COw_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = COw_n0
        node_id = 0
        coupled_list = 'r1_n0 r4_n0 r5_n0 r8_n0 r11_n0 r12_n0'
        weights = '-1 -1 -1 -2.5 -1 7'
        scale = non_pore
    [../]

    # =============== Bulk phase CO2 ===============
    [./CO2_dot]
        type = VariableCoefTimeDerivative
        variable = CO2
        coupled_coef = pore
    [../]
    [./CO2_gadv]
        type = GPoreConcAdvection
        variable = CO2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO2_gdiff]
        type = GVarPoreDiffusion
        variable = CO2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./CO2w_trans]
        type = FilmMassTransfer
        variable = CO2
        coupled = CO2w_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase CO2 ===============
    # Exterior node
    [./CO2w_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./CO2w_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = CO2w_n4
        node_id = 4
        macro_variable = CO2
        lower_neighbor = CO2w_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./CO2w_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n4
        node_id = 4
        coupled_list = 'r1_n4 r4_n4 r5_n4 r8_n4 r11_n4 r3_n4 r10_n4'
        weights = '1 1 1 2.5 1 7 7'
        scale = non_pore
    [../]

    # node 3
    [./CO2w_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./CO2w_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n3
        node_id = 3
        upper_neighbor = CO2w_n4
        lower_neighbor = CO2w_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./CO2w_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n3
        node_id = 3
        coupled_list = 'r1_n3 r4_n3 r5_n3 r8_n3 r11_n3 r3_n3 r10_n3'
        weights = '1 1 1 2.5 1 7 7'
        scale = non_pore
    [../]

    # node 2
    [./CO2w_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./CO2w_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n2
        node_id = 2
        upper_neighbor = CO2w_n3
        lower_neighbor = CO2w_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./CO2w_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n2
        node_id = 2
        coupled_list = 'r1_n2 r4_n2 r5_n2 r8_n2 r11_n2 r3_n2 r10_n2'
        weights = '1 1 1 2.5 1 7 7'
        scale = non_pore
    [../]

    # node 1
    [./CO2w_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./CO2w_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = CO2w_n1
        node_id = 1
        upper_neighbor = CO2w_n2
        lower_neighbor = CO2w_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./CO2w_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n1
        node_id = 1
        coupled_list = 'r1_n1 r4_n1 r5_n1 r8_n1 r11_n1 r3_n1 r10_n1'
        weights = '1 1 1 2.5 1 7 7'
        scale = non_pore
    [../]

    # node 0
    [./CO2w_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = CO2w_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./CO2w_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = CO2w_n0
        node_id = 0
        upper_neighbor = CO2w_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./CO2w_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = CO2w_n0
        node_id = 0
        coupled_list = 'r1_n0 r4_n0 r5_n0 r8_n0 r11_n0 r3_n0 r10_n0'
        weights = '1 1 1 2.5 1 7 7'
        scale = non_pore
    [../]

    # =============== Bulk phase N2 ===============
    [./N2_dot]
        type = VariableCoefTimeDerivative
        variable = N2
        coupled_coef = pore
    [../]
    [./N2_gadv]
        type = GPoreConcAdvection
        variable = N2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./N2_gdiff]
        type = GVarPoreDiffusion
        variable = N2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./N2w_trans]
        type = FilmMassTransfer
        variable = N2
        coupled = N2w_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase N2 ===============
    # Exterior node
    [./N2w_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2w_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./N2w_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = N2w_n4
        node_id = 4
        macro_variable = N2
        lower_neighbor = N2w_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./N2w_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2w_n4
        node_id = 4
        coupled_list = 'r4_n4 r7_n4 r15_n4 r10_n4'
        weights = '0.5 0.5 1 9'
        scale = non_pore
    [../]

    # node 3
    [./N2w_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2w_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./N2w_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = N2w_n3
        node_id = 3
        upper_neighbor = N2w_n4
        lower_neighbor = N2w_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./N2w_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2w_n3
        node_id = 3
        coupled_list = 'r4_n3 r7_n3 r15_n3 r10_n3'
        weights = '0.5 0.5 1 9'
        scale = non_pore
    [../]

    # node 2
    [./N2w_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2w_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./N2w_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = N2w_n2
        node_id = 2
        upper_neighbor = N2w_n3
        lower_neighbor = N2w_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./N2w_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2w_n2
        node_id = 2
        coupled_list = 'r4_n2 r7_n2 r15_n2 r10_n2'
        weights = '0.5 0.5 1 9'
        scale = non_pore
    [../]

    # node 1
    [./N2w_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2w_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./N2w_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = N2w_n1
        node_id = 1
        upper_neighbor = N2w_n2
        lower_neighbor = N2w_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./N2w_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2w_n1
        node_id = 1
        coupled_list = 'r4_n1 r7_n1 r15_n1 r10_n1'
        weights = '0.5 0.5 1 9'
        scale = non_pore
    [../]

    # node 0
    [./N2w_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = N2w_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./N2w_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = N2w_n0
        node_id = 0
        upper_neighbor = N2w_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./N2w_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = N2w_n0
        node_id = 0
        coupled_list = 'r4_n0 r7_n0 r15_n0 r10_n0'
        weights = '0.5 0.5 1 9'
        scale = non_pore
    [../]

    # =============== Bulk phase H2 ===============
    [./H2_dot]
        type = VariableCoefTimeDerivative
        variable = H2
        coupled_coef = pore
    [../]
    [./H2_gadv]
        type = GPoreConcAdvection
        variable = H2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2_gdiff]
        type = GVarPoreDiffusion
        variable = H2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./H2w_trans]
        type = FilmMassTransfer
        variable = H2
        coupled = H2w_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase H2 ===============
    # Exterior node
    [./H2w_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2w_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./H2w_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = H2w_n4
        node_id = 4
        macro_variable = H2
        lower_neighbor = H2w_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2w_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2w_n4
        node_id = 4
        coupled_list = 'r2_n4 r11_n4 r6_n4 r7_n4 r14_n4 r12_n4'
        weights = '-1 1 -2.5 -1 -1 11'
        scale = non_pore
    [../]

    # node 3
    [./H2w_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2w_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./H2w_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = H2w_n3
        node_id = 3
        upper_neighbor = H2w_n4
        lower_neighbor = H2w_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2w_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2w_n3
        node_id = 3
        coupled_list = 'r2_n3 r11_n3 r6_n3 r7_n3 r14_n3 r12_n3'
        weights = '-1 1 -2.5 -1 -1 11'
        scale = non_pore
    [../]

    # node 2
    [./H2w_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2w_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./H2w_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = H2w_n2
        node_id = 2
        upper_neighbor = H2w_n3
        lower_neighbor = H2w_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2w_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2w_n2
        node_id = 2
        coupled_list = 'r2_n2 r11_n2 r6_n2 r7_n2 r14_n2 r12_n2'
        weights = '-1 1 -2.5 -1 -1 11'
        scale = non_pore
    [../]

    # node 1
    [./H2w_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2w_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./H2w_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = H2w_n1
        node_id = 1
        upper_neighbor = H2w_n2
        lower_neighbor = H2w_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2w_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2w_n1
        node_id = 1
        coupled_list = 'r2_n1 r11_n1 r6_n1 r7_n1 r14_n1 r12_n1'
        weights = '-1 1 -2.5 -1 -1 11'
        scale = non_pore
    [../]

    # node 0
    [./H2w_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = H2w_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./H2w_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = H2w_n0
        node_id = 0
        upper_neighbor = H2w_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./H2w_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = H2w_n0
        node_id = 0
        coupled_list = 'r2_n0 r11_n0 r6_n0 r7_n0 r14_n0 r12_n0'
        weights = '-1 1 -2.5 -1 -1 11'
        scale = non_pore
    [../]

    # =============== Bulk phase HC ===============
    [./HC_dot]
        type = VariableCoefTimeDerivative
        variable = HC
        coupled_coef = pore
    [../]
    [./HC_gadv]
        type = GPoreConcAdvection
        variable = HC
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./HC_gdiff]
        type = GVarPoreDiffusion
        variable = HC
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]
    [./HCw_trans]
        type = FilmMassTransfer
        variable = HC
        coupled = HCw_n4

        av_ratio = Ga
        rate_variable = km
        volume_frac = non_pore
    [../]

    # =============== Washcoat phase HC ===============
    # Exterior node
    [./HCw_4_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = HCw_n4
        nodal_time_var = total_pore
        node_id = 4
    [../]
    [./HCw_4_diff_outer]
        type = MicroscaleVariableDiffusionOuterBC
        variable = HCw_n4
        node_id = 4
        macro_variable = HC
        lower_neighbor = HCw_n3
        rate_variable = km
        current_diff = Deff
        lower_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./HCw_4_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = HCw_n4
        node_id = 4
        coupled_list = 'r3_n4 r10_n4 r12_n4'
        weights = '-1 -1 -1'
        scale = non_pore
    [../]

    # node 3
    [./HCw_3_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = HCw_n3
        nodal_time_var = total_pore
        node_id = 3
    [../]
    [./HCw_3_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = HCw_n3
        node_id = 3
        upper_neighbor = HCw_n4
        lower_neighbor = HCw_n2
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./HCw_3_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = HCw_n3
        node_id = 3
        coupled_list = 'r3_n3 r10_n3 r12_n3'
        weights = '-1 -1 -1'
        scale = non_pore
    [../]

    # node 2
    [./HCw_2_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = HCw_n2
        nodal_time_var = total_pore
        node_id = 2
    [../]
    [./HCw_2_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = HCw_n2
        node_id = 2
        upper_neighbor = HCw_n3
        lower_neighbor = HCw_n1
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./HCw_2_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = HCw_n2
        node_id = 2
        coupled_list = 'r3_n2 r10_n2 r12_n2'
        weights = '-1 -1 -1'
        scale = non_pore
    [../]

    # node 1
    [./HCw_1_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = HCw_n1
        nodal_time_var = total_pore
        node_id = 1
    [../]
    [./HCw_1_diff_outer]
        type = MicroscaleVariableDiffusion
        variable = HCw_n1
        node_id = 1
        upper_neighbor = HCw_n2
        lower_neighbor = HCw_n0
        current_diff = Deff
        lower_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./HCw_1_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = HCw_n1
        node_id = 1
        coupled_list = 'r3_n1 r10_n1 r12_n1'
        weights = '-1 -1 -1'
        scale = non_pore
    [../]

    # node 0
    [./HCw_0_dot]
        type = MicroscaleVariableCoefTimeDerivative
        variable = HCw_n0
        nodal_time_var = total_pore
        node_id = 0
    [../]
    [./HCw_0_diff_outer]
        type = MicroscaleVariableDiffusionInnerBC
        variable = HCw_n0
        node_id = 0
        upper_neighbor = HCw_n1
        current_diff = Deff
        upper_diff = Deff
    [../]
    # r3:  CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    # r10: CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    # r12: CxHyOz + (x - z) H2O --> x CO + (x + (y/2) - z) H2
    #
    # toluene ==> x = 7, y = 8, z = 0
    [./HCw_0_rxns]
        type = MicroscaleScaledWeightedCoupledSumFunction
        variable = HCw_n0
        node_id = 0
        coupled_list = 'r3_n0 r10_n0 r12_n0'
        weights = '-1 -1 -1'
        scale = non_pore
    [../]

# ------------------- Start Reaction Balances ----------------------
# -------------------------------------------------------------

## ======= CO Oxidation ======
# CO + 0.5 O2 --> CO2
    [./r1_n0_val]
        type = Reaction
        variable = r1_n0
    [../]
    [./r1_n0_rx]
      type = ArrheniusReaction
      variable = r1_n0
      this_variable = r1_n0

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0 O2w_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r1_n1_val]
        type = Reaction
        variable = r1_n1
    [../]
    [./r1_n1_rx]
      type = ArrheniusReaction
      variable = r1_n1
      this_variable = r1_n1

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1 O2w_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r1_n2_val]
        type = Reaction
        variable = r1_n2
    [../]
    [./r1_n2_rx]
      type = ArrheniusReaction
      variable = r1_n2
      this_variable = r1_n2

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2 O2w_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r1_n3_val]
        type = Reaction
        variable = r1_n3
    [../]
    [./r1_n3_rx]
      type = ArrheniusReaction
      variable = r1_n3
      this_variable = r1_n3

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3 O2w_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r1_n4_val]
        type = Reaction
        variable = r1_n4
    [../]
    [./r1_n4_rx]
      type = ArrheniusReaction
      variable = r1_n4
      this_variable = r1_n4

      forward_activation_energy = 235293.33281046877
      forward_pre_exponential = 1.6550871137667489e+31

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4 O2w_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= H2 Oxidation ======
# H2 + 0.5 O2 --> H2O
    [./r2_n0_val]
        type = Reaction
        variable = r2_n0
    [../]
    [./r2_n0_rx]
      type = ArrheniusReaction
      variable = r2_n0
      this_variable = r2_n0

      forward_activation_energy = 158891.38869742613
      forward_pre_exponential = 1.733658868809338e+24

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n0 O2w_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r2_n1_val]
        type = Reaction
        variable = r2_n1
    [../]
    [./r2_n1_rx]
      type = ArrheniusReaction
      variable = r2_n1
      this_variable = r2_n1

      forward_activation_energy = 158891.38869742613
      forward_pre_exponential = 1.733658868809338e+24

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n1 O2w_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r2_n2_val]
        type = Reaction
        variable = r2_n2
    [../]
    [./r2_n2_rx]
      type = ArrheniusReaction
      variable = r2_n2
      this_variable = r2_n2

      forward_activation_energy = 158891.38869742613
      forward_pre_exponential = 1.733658868809338e+24

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n2 O2w_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r2_n3_val]
        type = Reaction
        variable = r2_n3
    [../]
    [./r2_n3_rx]
      type = ArrheniusReaction
      variable = r2_n3
      this_variable = r2_n3

      forward_activation_energy = 158891.38869742613
      forward_pre_exponential = 1.733658868809338e+24

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n3 O2w_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r2_n4_val]
        type = Reaction
        variable = r2_n4
    [../]
    [./r2_n4_rx]
      type = ArrheniusReaction
      variable = r2_n4
      this_variable = r2_n4

      forward_activation_energy = 158891.38869742613
      forward_pre_exponential = 1.733658868809338e+24

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n4 O2w_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= CO/NO Rxn ======
# CO + NO --> CO2 (+ 0.5 N2)
    [./r4_n0_val]
        type = Reaction
        variable = r4_n0
    [../]
    [./r4_n0_rx]
      type = InhibitedArrheniusReaction
      variable = r4_n0
      this_variable = r4_n0

      forward_activation_energy = 304924.98618328216
      forward_pre_exponential = 3.473335911420499e+36
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n0

      #forward_pre_exponential = 3.473335911420499e+32
      #forward_activation_energy = 324924.98618328216

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0 NOxw_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r4_n1_val]
        type = Reaction
        variable = r4_n1
    [../]
    [./r4_n1_rx]
      type = InhibitedArrheniusReaction
      variable = r4_n1
      this_variable = r4_n1

      forward_activation_energy = 304924.98618328216
      forward_pre_exponential = 3.473335911420499e+36
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n1

      #forward_pre_exponential = 3.473335911420499e+32
      #forward_activation_energy = 324924.98618328216

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1 NOxw_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r4_n2_val]
        type = Reaction
        variable = r4_n2
    [../]
    [./r4_n2_rx]
      type = InhibitedArrheniusReaction
      variable = r4_n2
      this_variable = r4_n2

      forward_activation_energy = 304924.98618328216
      forward_pre_exponential = 3.473335911420499e+36
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n2

      #forward_pre_exponential = 3.473335911420499e+32
      #forward_activation_energy = 324924.98618328216

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2 NOxw_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r4_n3_val]
        type = Reaction
        variable = r4_n3
    [../]
    [./r4_n3_rx]
      type = InhibitedArrheniusReaction
      variable = r4_n3
      this_variable = r4_n3

      forward_activation_energy = 304924.98618328216
      forward_pre_exponential = 3.473335911420499e+36
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n3

      #forward_pre_exponential = 3.473335911420499e+32
      #forward_activation_energy = 324924.98618328216

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3 NOxw_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r4_n4_val]
        type = Reaction
        variable = r4_n4
    [../]
    [./r4_n4_rx]
      type = InhibitedArrheniusReaction
      variable = r4_n4
      this_variable = r4_n4

      forward_activation_energy = 304924.98618328216
      forward_pre_exponential = 3.473335911420499e+36
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n4

      #forward_pre_exponential = 3.473335911420499e+32
      #forward_activation_energy = 324924.98618328216

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4 NOxw_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= CO/NO Rxn ======
# CO + 2 NO --> CO2 + N2O
    [./r5_n0_val]
        type = Reaction
        variable = r5_n0
    [../]
    [./r5_n0_rx]
      type = InhibitedArrheniusReaction
      variable = r5_n0
      this_variable = r5_n0

      forward_activation_energy = 170429.67328083533
      forward_pre_exponential = 3.174729324826581e+22
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n0

      #forward_pre_exponential = 3.174729324826581e+18
      #forward_activation_energy = 190429.67328083533

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0 NOxw_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r5_n1_val]
        type = Reaction
        variable = r5_n1
    [../]
    [./r5_n1_rx]
      type = InhibitedArrheniusReaction
      variable = r5_n1
      this_variable = r5_n1

      forward_activation_energy = 170429.67328083533
      forward_pre_exponential = 3.174729324826581e+22
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n1

      #forward_pre_exponential = 3.174729324826581e+18
      #forward_activation_energy = 190429.67328083533

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1 NOxw_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r5_n2_val]
        type = Reaction
        variable = r5_n2
    [../]
    [./r5_n2_rx]
      type = InhibitedArrheniusReaction
      variable = r5_n2
      this_variable = r5_n2

      forward_activation_energy = 170429.67328083533
      forward_pre_exponential = 3.174729324826581e+22
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n2

      #forward_pre_exponential = 3.174729324826581e+18
      #forward_activation_energy = 190429.67328083533

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2 NOxw_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r5_n3_val]
        type = Reaction
        variable = r5_n3
    [../]
    [./r5_n3_rx]
      type = InhibitedArrheniusReaction
      variable = r5_n3
      this_variable = r5_n3

      forward_activation_energy = 170429.67328083533
      forward_pre_exponential = 3.174729324826581e+22
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n3

      #forward_pre_exponential = 3.174729324826581e+18
      #forward_activation_energy = 190429.67328083533

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3 NOxw_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r5_n4_val]
        type = Reaction
        variable = r5_n4
    [../]
    [./r5_n4_rx]
      type = InhibitedArrheniusReaction
      variable = r5_n4
      this_variable = r5_n4

      forward_activation_energy = 170429.67328083533
      forward_pre_exponential = 3.174729324826581e+22
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n4

      #forward_pre_exponential = 3.174729324826581e+18
      #forward_activation_energy = 190429.67328083533

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4 NOxw_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= CO/NO Rxn ======
# 2.5 CO + NO + 1.5 H2O --> 2.5 CO2 + NH3
    [./r8_n0_val]
        type = Reaction
        variable = r8_n0
    [../]
    [./r8_n0_rx]
      type = InhibitedArrheniusReaction
      variable = r8_n0
      this_variable = r8_n0

      forward_activation_energy = 304127.76066024584
      forward_pre_exponential = 1.8767305119846367e+38
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n0

      #forward_pre_exponential = 1.8767305119846367e+34
      #forward_activation_energy = 324127.76066024584

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0 NOxw_n0 H2Ow_n0'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r8_n1_val]
        type = Reaction
        variable = r8_n1
    [../]
    [./r8_n1_rx]
      type = InhibitedArrheniusReaction
      variable = r8_n1
      this_variable = r8_n1

      forward_activation_energy = 304127.76066024584
      forward_pre_exponential = 1.8767305119846367e+38
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n1

      #forward_pre_exponential = 1.8767305119846367e+34
      #forward_activation_energy = 324127.76066024584

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1 NOxw_n1 H2Ow_n1'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r8_n2_val]
        type = Reaction
        variable = r8_n2
    [../]
    [./r8_n2_rx]
      type = InhibitedArrheniusReaction
      variable = r8_n2
      this_variable = r8_n2

      forward_activation_energy = 304127.76066024584
      forward_pre_exponential = 1.8767305119846367e+38
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n2

      #forward_pre_exponential = 1.8767305119846367e+34
      #forward_activation_energy = 324127.76066024584

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2 NOxw_n2 H2Ow_n2'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r8_n3_val]
        type = Reaction
        variable = r8_n3
    [../]
    [./r8_n3_rx]
      type = InhibitedArrheniusReaction
      variable = r8_n3
      this_variable = r8_n3

      forward_activation_energy = 304127.76066024584
      forward_pre_exponential = 1.8767305119846367e+38
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n3

      #forward_pre_exponential = 1.8767305119846367e+34
      #forward_activation_energy = 324127.76066024584

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3 NOxw_n3 H2Ow_n3'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r8_n4_val]
        type = Reaction
        variable = r8_n4
    [../]
    [./r8_n4_rx]
      type = InhibitedArrheniusReaction
      variable = r8_n4
      this_variable = r8_n4

      forward_activation_energy = 304127.76066024584
      forward_pre_exponential = 1.8767305119846367e+38
      #forward_pre_exponential = 0
      forward_inhibition = R_HC_n4

      #forward_pre_exponential = 1.8767305119846367e+34
      #forward_activation_energy = 324127.76066024584

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4 NOxw_n4 H2Ow_n4'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= WGS Rxn ======
# CO + H2O <-- --> CO2 + H2
    [./r11_n0_val]
        type = Reaction
        variable = r11_n0
    [../]
    [./r11_n0_rx]
      type = ArrheniusEquilibriumReaction
      variable = r11_n0
      this_variable = r11_n0

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      enthalpy = 16769.16637626293
      entropy = 139.10839203326302

      temperature = temp
      scale = 1.0
      reactants = 'COw_n0 H2Ow_n0'
      reactant_stoich = '1 1'
      products = 'CO2w_n0 H2w_n0'
      product_stoich = '1 1'
    [../]

    [./r11_n1_val]
        type = Reaction
        variable = r11_n1
    [../]
    [./r11_n1_rx]
      type = ArrheniusEquilibriumReaction
      variable = r11_n1
      this_variable = r11_n1

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      enthalpy = 16769.16637626293
      entropy = 139.10839203326302

      temperature = temp
      scale = 1.0
      reactants = 'COw_n1 H2Ow_n1'
      reactant_stoich = '1 1'
      products = 'CO2w_n1 H2w_n1'
      product_stoich = '1 1'
    [../]

    [./r11_n2_val]
        type = Reaction
        variable = r11_n2
    [../]
    [./r11_n2_rx]
      type = ArrheniusEquilibriumReaction
      variable = r11_n2
      this_variable = r11_n2

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      enthalpy = 16769.16637626293
      entropy = 139.10839203326302

      temperature = temp
      scale = 1.0
      reactants = 'COw_n2 H2Ow_n2'
      reactant_stoich = '1 1'
      products = 'CO2w_n2 H2w_n2'
      product_stoich = '1 1'
    [../]

    [./r11_n3_val]
        type = Reaction
        variable = r11_n3
    [../]
    [./r11_n3_rx]
      type = ArrheniusEquilibriumReaction
      variable = r11_n3
      this_variable = r11_n3

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      enthalpy = 16769.16637626293
      entropy = 139.10839203326302

      temperature = temp
      scale = 1.0
      reactants = 'COw_n3 H2Ow_n3'
      reactant_stoich = '1 1'
      products = 'CO2w_n3 H2w_n3'
      product_stoich = '1 1'
    [../]

    [./r11_n4_val]
        type = Reaction
        variable = r11_n4
    [../]
    [./r11_n4_rx]
      type = ArrheniusEquilibriumReaction
      variable = r11_n4
      this_variable = r11_n4

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      enthalpy = 16769.16637626293
      entropy = 139.10839203326302

      temperature = temp
      scale = 1.0
      reactants = 'COw_n4 H2Ow_n4'
      reactant_stoich = '1 1'
      products = 'CO2w_n4 H2w_n4'
      product_stoich = '1 1'
    [../]

## ======= H2/NO Rxn ======
# 2.5 H2 + NO --> NH3 + H2O
    [./r6_n0_val]
        type = Reaction
        variable = r6_n0
    [../]
    [./r6_n0_rx]
      type = InhibitedArrheniusReaction
      variable = r6_n0
      this_variable = r6_n0

      forward_pre_exponential = 2.60E+14
      forward_activation_energy = 59342.9
      forward_inhibition = R_CO_n0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n0 NOxw_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r6_n1_val]
        type = Reaction
        variable = r6_n1
    [../]
    [./r6_n1_rx]
      type = InhibitedArrheniusReaction
      variable = r6_n1
      this_variable = r6_n1

      forward_pre_exponential = 2.60E+14
      forward_activation_energy = 59342.9
      forward_inhibition = R_CO_n1

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n1 NOxw_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r6_n2_val]
        type = Reaction
        variable = r6_n2
    [../]
    [./r6_n2_rx]
      type = InhibitedArrheniusReaction
      variable = r6_n2
      this_variable = r6_n2

      forward_pre_exponential = 2.60E+14
      forward_activation_energy = 59342.9
      forward_inhibition = R_CO_n2

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n2 NOxw_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r6_n3_val]
        type = Reaction
        variable = r6_n3
    [../]
    [./r6_n3_rx]
      type = InhibitedArrheniusReaction
      variable = r6_n3
      this_variable = r6_n3

      forward_pre_exponential = 2.60E+14
      forward_activation_energy = 59342.9
      forward_inhibition = R_CO_n3

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n3 NOxw_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r6_n4_val]
        type = Reaction
        variable = r6_n4
    [../]
    [./r6_n4_rx]
      type = InhibitedArrheniusReaction
      variable = r6_n4
      this_variable = r6_n4

      forward_pre_exponential = 2.60E+14
      forward_activation_energy = 59342.9
      forward_inhibition = R_CO_n4

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n4 NOxw_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= H2/NO Rxn ======
# H2 + NO --> H2O (+ 0.5 N2)
    [./r7_n0_val]
        type = Reaction
        variable = r7_n0
    [../]
    [./r7_n0_rx]
      type = InhibitedArrheniusReaction
      variable = r7_n0
      this_variable = r7_n0

      forward_pre_exponential = 6.96E+11
      forward_activation_energy = 32221.5
      forward_inhibition = R_CO_n0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n0 NOxw_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r7_n1_val]
        type = Reaction
        variable = r7_n1
    [../]
    [./r7_n1_rx]
      type = InhibitedArrheniusReaction
      variable = r7_n1
      this_variable = r7_n1

      forward_pre_exponential = 6.96E+11
      forward_activation_energy = 32221.5
      forward_inhibition = R_CO_n1

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n1 NOxw_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r7_n2_val]
        type = Reaction
        variable = r7_n2
    [../]
    [./r7_n2_rx]
      type = InhibitedArrheniusReaction
      variable = r7_n2
      this_variable = r7_n2

      forward_pre_exponential = 6.96E+11
      forward_activation_energy = 32221.5
      forward_inhibition = R_CO_n2

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n2 NOxw_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r7_n3_val]
        type = Reaction
        variable = r7_n3
    [../]
    [./r7_n3_rx]
      type = InhibitedArrheniusReaction
      variable = r7_n3
      this_variable = r7_n3

      forward_pre_exponential = 6.96E+11
      forward_activation_energy = 32221.5
      forward_inhibition = R_CO_n3

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n3 NOxw_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r7_n4_val]
        type = Reaction
        variable = r7_n4
    [../]
    [./r7_n4_rx]
      type = InhibitedArrheniusReaction
      variable = r7_n4
      this_variable = r7_n4

      forward_pre_exponential = 6.96E+11
      forward_activation_energy = 32221.5
      forward_inhibition = R_CO_n4

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n4 NOxw_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= H2/NO Rxn ======
# H2 + 2 NO --> N2O + H2O
    [./r14_n0_val]
        type = Reaction
        variable = r14_n0
    [../]
    [./r14_n0_rx]
      type = InhibitedArrheniusReaction
      variable = r14_n0
      this_variable = r14_n0

      forward_pre_exponential = 2.56E+09
      forward_activation_energy = 13318.5
      forward_inhibition = R_CO_n0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n0 NOxw_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r14_n1_val]
        type = Reaction
        variable = r14_n1
    [../]
    [./r14_n1_rx]
      type = InhibitedArrheniusReaction
      variable = r14_n1
      this_variable = r14_n1

      forward_pre_exponential = 2.56E+09
      forward_activation_energy = 13318.5
      forward_inhibition = R_CO_n1

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n1 NOxw_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r14_n2_val]
        type = Reaction
        variable = r14_n2
    [../]
    [./r14_n2_rx]
      type = InhibitedArrheniusReaction
      variable = r14_n2
      this_variable = r14_n2

      forward_pre_exponential = 2.56E+09
      forward_activation_energy = 13318.5
      forward_inhibition = R_CO_n2

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n2 NOxw_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r14_n3_val]
        type = Reaction
        variable = r14_n3
    [../]
    [./r14_n3_rx]
      type = InhibitedArrheniusReaction
      variable = r14_n3
      this_variable = r14_n3

      forward_pre_exponential = 2.56E+09
      forward_activation_energy = 13318.5
      forward_inhibition = R_CO_n3

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n3 NOxw_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r14_n4_val]
        type = Reaction
        variable = r14_n4
    [../]
    [./r14_n4_rx]
      type = InhibitedArrheniusReaction
      variable = r14_n4
      this_variable = r14_n4

      forward_pre_exponential = 2.56E+09
      forward_activation_energy = 13318.5
      forward_inhibition = R_CO_n4

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'H2w_n4 NOxw_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= SCR Rxn ======
# NH3 + NO + 0.25 O2 --> N2 + 1.5 H2O
    [./r15_n0_val]
        type = Reaction
        variable = r15_n0
    [../]
    [./r15_n0_rx]
      type = InhibitedArrheniusReaction
      variable = r15_n0
      this_variable = r15_n0

      forward_pre_exponential = 1e+41
      forward_activation_energy = 300000
      forward_beta = 0
      forward_inhibition = R_CO_n0

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'NH3w_n0 NOxw_n0 O2w_n0'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r15_n1_val]
        type = Reaction
        variable = r15_n1
    [../]
    [./r15_n1_rx]
      type = InhibitedArrheniusReaction
      variable = r15_n1
      this_variable = r15_n1

      forward_pre_exponential = 1e+41
      forward_activation_energy = 300000
      forward_beta = 0
      forward_inhibition = R_CO_n1

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'NH3w_n1 NOxw_n1 O2w_n1'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r15_n2_val]
        type = Reaction
        variable = r15_n2
    [../]
    [./r15_n2_rx]
      type = InhibitedArrheniusReaction
      variable = r15_n2
      this_variable = r15_n2

      forward_pre_exponential = 1e+41
      forward_activation_energy = 300000
      forward_beta = 0
      forward_inhibition = R_CO_n2

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'NH3w_n2 NOxw_n2 O2w_n2'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r15_n3_val]
        type = Reaction
        variable = r15_n3
    [../]
    [./r15_n3_rx]
      type = InhibitedArrheniusReaction
      variable = r15_n3
      this_variable = r15_n3

      forward_pre_exponential = 1e+41
      forward_activation_energy = 300000
      forward_beta = 0
      forward_inhibition = R_CO_n3

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'NH3w_n3 NOxw_n3 O2w_n3'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r15_n4_val]
        type = Reaction
        variable = r15_n4
    [../]
    [./r15_n4_rx]
      type = InhibitedArrheniusReaction
      variable = r15_n4
      this_variable = r15_n4

      forward_pre_exponential = 1e+41
      forward_activation_energy = 300000
      forward_beta = 0
      forward_inhibition = R_CO_n4

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'NH3w_n4 NOxw_n4 O2w_n4'
      reactant_stoich = '1 1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= HC oxidation Rxn ======
# CxHyOz + (x + (y/4) - (z/2)) O2 --> x CO2 + (y/2) H2O
    [./r3_n0_val]
        type = Reaction
        variable = r3_n0
    [../]
    [./r3_n0_rx]
      type = ArrheniusReaction
      variable = r3_n0
      this_variable = r3_n0

      forward_activation_energy = 284704.19832103234
      forward_pre_exponential = 2.189916847226846e+33

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n0 O2w_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r3_n1_val]
        type = Reaction
        variable = r3_n1
    [../]
    [./r3_n1_rx]
      type = ArrheniusReaction
      variable = r3_n1
      this_variable = r3_n1

      forward_activation_energy = 284704.19832103234
      forward_pre_exponential = 2.189916847226846e+33

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n1 O2w_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r3_n2_val]
        type = Reaction
        variable = r3_n2
    [../]
    [./r3_n2_rx]
      type = ArrheniusReaction
      variable = r3_n2
      this_variable = r3_n2

      forward_activation_energy = 284704.19832103234
      forward_pre_exponential = 2.189916847226846e+33

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n2 O2w_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r3_n3_val]
        type = Reaction
        variable = r3_n3
    [../]
    [./r3_n3_rx]
      type = ArrheniusReaction
      variable = r3_n3
      this_variable = r3_n3

      forward_activation_energy = 284704.19832103234
      forward_pre_exponential = 2.189916847226846e+33

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n3 O2w_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r3_n4_val]
        type = Reaction
        variable = r3_n4
    [../]
    [./r3_n4_rx]
      type = ArrheniusReaction
      variable = r3_n4
      this_variable = r3_n4

      forward_activation_energy = 284704.19832103234
      forward_pre_exponential = 2.189916847226846e+33

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n4 O2w_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= HC/NO Rxn ======
# CxHyOz + (2x + (y/2) - z) NO --> x CO2 + (y/2) H2O + (x + (y/4) - (z/2)) N2
    [./r10_n0_val]
        type = Reaction
        variable = r10_n0
    [../]
    [./r10_n0_rx]
      type = ArrheniusReaction
      variable = r10_n0
      this_variable = r10_n0

      forward_activation_energy = 344704.19832103234
      forward_pre_exponential = 4.489916847226846e+39

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n0 NOxw_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r10_n1_val]
        type = Reaction
        variable = r10_n1
    [../]
    [./r10_n1_rx]
      type = ArrheniusReaction
      variable = r10_n1
      this_variable = r10_n1

      forward_activation_energy = 344704.19832103234
      forward_pre_exponential = 4.489916847226846e+39

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n1 NOxw_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r10_n2_val]
        type = Reaction
        variable = r10_n2
    [../]
    [./r10_n2_rx]
      type = ArrheniusReaction
      variable = r10_n2
      this_variable = r10_n2

      forward_activation_energy = 344704.19832103234
      forward_pre_exponential = 4.489916847226846e+39

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n2 NOxw_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r10_n3_val]
        type = Reaction
        variable = r10_n3
    [../]
    [./r10_n3_rx]
      type = ArrheniusReaction
      variable = r10_n3
      this_variable = r10_n3

      forward_activation_energy = 344704.19832103234
      forward_pre_exponential = 4.489916847226846e+39

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n3 NOxw_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r10_n4_val]
        type = Reaction
        variable = r10_n4
    [../]
    [./r10_n4_rx]
      type = ArrheniusReaction
      variable = r10_n4
      this_variable = r10_n4

      forward_activation_energy = 344704.19832103234
      forward_pre_exponential = 4.489916847226846e+39

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n4 NOxw_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

## ======= HC Steam Reforming Rxn ======
# CxHyOz + x H2O --> x CO + (x + (y/2)) H2 + (z/2) O2
    [./r12_n0_val]
        type = Reaction
        variable = r12_n0
    [../]
    [./r12_n0_rx]
      type = ArrheniusReaction
      variable = r12_n0
      this_variable = r12_n0

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n0 H2Ow_n0'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r12_n1_val]
        type = Reaction
        variable = r12_n1
    [../]
    [./r12_n1_rx]
      type = ArrheniusReaction
      variable = r12_n1
      this_variable = r12_n1

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n1 H2Ow_n1'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r12_n2_val]
        type = Reaction
        variable = r12_n2
    [../]
    [./r12_n2_rx]
      type = ArrheniusReaction
      variable = r12_n2
      this_variable = r12_n2

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n2 H2Ow_n2'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r12_n3_val]
        type = Reaction
        variable = r12_n3
    [../]
    [./r12_n3_rx]
      type = ArrheniusReaction
      variable = r12_n3
      this_variable = r12_n3

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n3 H2Ow_n3'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

    [./r12_n4_val]
        type = Reaction
        variable = r12_n4
    [../]
    [./r12_n4_rx]
      type = ArrheniusReaction
      variable = r12_n4
      this_variable = r12_n4

      forward_activation_energy = 136610.55181420766
      forward_pre_exponential = 1.8429782328496848e+17

      reverse_activation_energy = 0
      reverse_pre_exponential = 0

      temperature = temp
      scale = 1.0
      reactants = 'HCw_n4 H2Ow_n4'
      reactant_stoich = '1 1'
      products = ''
      product_stoich = ''
    [../]

# ------------------ Start list of inhibition terms --------------------
# ============= CO Term =============
     [./R_CO_n0_eq]
       type = Reaction
       variable = R_CO_n0
     [../]
     [./R_CO_n0_lang]
       type = LangmuirInhibition
       variable = R_CO_n0
       temperature = temp
       coupled_list = 'COw_n0'
       pre_exponentials = '2.59'
       activation_energies = '-36284.4'
     [../]

     [./R_CO_n1_eq]
       type = Reaction
       variable = R_CO_n1
     [../]
     [./R_CO_n1_lang]
       type = LangmuirInhibition
       variable = R_CO_n1
       temperature = temp
       coupled_list = 'COw_n1'
       pre_exponentials = '2.59'
       activation_energies = '-36284.4'
     [../]

     [./R_CO_n2_eq]
       type = Reaction
       variable = R_CO_n2
     [../]
     [./R_CO_n2_lang]
       type = LangmuirInhibition
       variable = R_CO_n2
       temperature = temp
       coupled_list = 'COw_n2'
       pre_exponentials = '2.59'
       activation_energies = '-36284.4'
     [../]

     [./R_CO_n3_eq]
       type = Reaction
       variable = R_CO_n3
     [../]
     [./R_CO_n3_lang]
       type = LangmuirInhibition
       variable = R_CO_n3
       temperature = temp
       coupled_list = 'COw_n3'
       pre_exponentials = '2.59'
       activation_energies = '-36284.4'
     [../]

     [./R_CO_n4_eq]
       type = Reaction
       variable = R_CO_n4
     [../]
     [./R_CO_n4_lang]
       type = LangmuirInhibition
       variable = R_CO_n4
       temperature = temp
       coupled_list = 'COw_n4'
       pre_exponentials = '2.59'
       activation_energies = '-36284.4'
     [../]

# ============= HC Term =============
   [./R_HC_n0_eq]
     type = Reaction
     variable = R_HC_n0
   [../]
   [./R_HC_n0_lang]
     type = LangmuirInhibition
     variable = R_HC_n0
     temperature = temp
     coupled_list = 'HCw_n0'
     pre_exponentials = '0'
     activation_energies = '0'
   [../]

   [./R_HC_n1_eq]
     type = Reaction
     variable = R_HC_n1
   [../]
   [./R_HC_n1_lang]
     type = LangmuirInhibition
     variable = R_HC_n1
     temperature = temp
     coupled_list = 'HCw_n1'
     pre_exponentials = '0'
     activation_energies = '0'
   [../]

   [./R_HC_n2_eq]
     type = Reaction
     variable = R_HC_n2
   [../]
   [./R_HC_n2_lang]
     type = LangmuirInhibition
     variable = R_HC_n2
     temperature = temp
     coupled_list = 'HCw_n2'
     pre_exponentials = '0'
     activation_energies = '0'
   [../]

   [./R_HC_n3_eq]
     type = Reaction
     variable = R_HC_n3
   [../]
   [./R_HC_n3_lang]
     type = LangmuirInhibition
     variable = R_HC_n3
     temperature = temp
     coupled_list = 'HCw_n3'
     pre_exponentials = '0'
     activation_energies = '0'
   [../]

   [./R_HC_n4_eq]
     type = Reaction
     variable = R_HC_n4
   [../]
   [./R_HC_n4_lang]
     type = LangmuirInhibition
     variable = R_HC_n4
     temperature = temp
     coupled_list = 'HCw_n4'
     pre_exponentials = '0'
     activation_energies = '0'
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

    # =========== CO DG kernels ===========
    [./CO_dgadv]
        type = DGPoreConcAdvection
        variable = CO
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO_dgdiff]
        type = DGVarPoreDiffusion
        variable = CO
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== CO2 DG kernels ===========
    [./CO2_dgadv]
        type = DGPoreConcAdvection
        variable = CO2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./CO2_dgdiff]
        type = DGVarPoreDiffusion
        variable = CO2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== N2 DG kernels ===========
    [./N2_dgadv]
        type = DGPoreConcAdvection
        variable = N2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./N2_dgdiff]
        type = DGVarPoreDiffusion
        variable = N2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== H2 DG kernels ===========
    [./H2_dgadv]
        type = DGPoreConcAdvection
        variable = H2
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./H2_dgdiff]
        type = DGVarPoreDiffusion
        variable = H2
        porosity = pore
        Dx = D
        Dy = D
        Dz = D
    [../]

    # =========== HC DG kernels ===========
    [./HC_dgadv]
        type = DGPoreConcAdvection
        variable = HC
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]
    [./HC_dgdiff]
        type = DGVarPoreDiffusion
        variable = HC
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
        porosity = 0.775
        space_velocity = 500   #volumes per min
        inlet_temperature = temp
        ref_pressure = 101.35
        ref_temperature = 273.15
        radius = 1  #cm
        length = 5  #cm
        execute_on = 'initial timestep_end'
    [../]

    [./temp_AuxK]
      type = FunctionAux
      variable = temp
      function = data_fun
    [../]

    [./Ga_calc]
        type = MonolithAreaVolumeRatio
        variable = Ga
        cell_density = 93   #cells/cm^2
        channel_vol_ratio = pore
        per_solids_volume = true
        execute_on = 'initial timestep_end'
    [../]

    [./dh_calc]
        type = MonolithHydraulicDiameter
        variable = dh
        cell_density = 93   #cells/cm^2
        channel_vol_ratio = pore
        execute_on = 'initial timestep_end'
    [../]

    [./wt_calc]
        type = MonolithMicroscaleTotalThickness
        variable = wt
        cell_density = 93   #cells/cm^2
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

        ref_diffusivity = 0.561
        diff_length_unit = "cm"
        diff_time_unit = "s"
        ref_diff_temp = 473

        output_length_unit = "cm"
        output_time_unit = "min"

        execute_on = 'initial timestep_end'
    [../]

    [./Deff_calc]
        type = SimpleGasEffectivePoreDiffusivity
        variable = Deff

        pressure = press
        temperature = temp
        micro_porosity = micro_pore
        macro_porosity = pore
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
        per_solids_volume = false

        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[Functions]
  [./data_fun]
    type = PiecewiseMultilinear
    data_file = toluene_temperature.txt
  [../]
[]

[BCs]

    # ============== O2 BCs ================
    [./O2_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = O2
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 6500
    [../]
    [./O2_FluxOut]
        type = DGPoreConcFluxBC
        variable = O2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== H2O BCs ================
    [./H2O_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = H2O
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 130000
    [../]
    [./H2O_FluxOut]
        type = DGPoreConcFluxBC
        variable = H2O
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NH3 BCs ================
    [./NH3_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = NH3
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 1e-6
    [../]
    [./NH3_FluxOut]
        type = DGPoreConcFluxBC
        variable = NH3
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== NO BCs ================
    [./NOx_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = NOx
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 1070
    [../]
    [./NOx_FluxOut]
        type = DGPoreConcFluxBC
        variable = NOx
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== N2O BCs ================
    [./N2O_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = N2O
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 1e-6
    [../]
    [./N2O_FluxOut]
        type = DGPoreConcFluxBC
        variable = N2O
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== CO BCs ================
    [./CO_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = CO
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 5000
    [../]
    [./CO_FluxOut]
        type = DGPoreConcFluxBC
        variable = CO
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== CO2 BCs ================
    [./CO2_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = CO2
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 130000
    [../]
    [./CO2_FluxOut]
        type = DGPoreConcFluxBC
        variable = CO2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== N2 BCs ================
    [./N2_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = N2
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 990000
    [../]
    [./N2_FluxOut]
        type = DGPoreConcFluxBC
        variable = N2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== H2 BCs ================
    [./H2_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = H2
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 1670
    [../]
    [./H2_FluxOut]
        type = DGPoreConcFluxBC
        variable = H2
        boundary = 'top'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
    [../]

    # ============== HC BCs ================
    # toluene ==> x = 7, y = 8, z = 0
    #   inlet_ppm = 3000 / x
    [./HC_FluxIn]
        type = DGPoreConcFluxBC_ppm
        variable = HC
        boundary = 'bottom'
        porosity = pore
        ux = vel_x
        uy = vel_y
        uz = vel_z
        pressure = press
        temperature = temp
        inlet_ppm = 428.571
    [../]
    [./HC_FluxOut]
        type = DGPoreConcFluxBC
        variable = HC
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

    [./CO_out]
        type = SideAverageValue
        boundary = 'top'
        variable = CO
        execute_on = 'initial timestep_end'
    [../]

    [./CO_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CO
        execute_on = 'initial timestep_end'
    [../]

    [./CO2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]

    [./CO2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = CO2
        execute_on = 'initial timestep_end'
    [../]

    [./N2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = N2
        execute_on = 'initial timestep_end'
    [../]

    [./N2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = N2
        execute_on = 'initial timestep_end'
    [../]

    [./H2_out]
        type = SideAverageValue
        boundary = 'top'
        variable = H2
        execute_on = 'initial timestep_end'
    [../]

    [./H2_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = H2
        execute_on = 'initial timestep_end'
    [../]

    [./zHC_out]
        type = SideAverageValue
        boundary = 'top'
        variable = HC
        execute_on = 'initial timestep_end'
    [../]

    [./zHC_bypass]
        type = SideAverageValue
        boundary = 'bottom'
        variable = HC
        execute_on = 'initial timestep_end'
    [../]

    [./temp_avg]
        type = ElementAverageValue
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    [./temp_in]
        type = SideAverageValue
        boundary = 'bottom'
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    [./temp_out]
        type = SideAverageValue
        boundary = 'top'
        variable = temp
        execute_on = 'initial timestep_end'
    [../]

    [./R_HC_n0]
        type = ElementAverageValue
        variable = R_HC_n0
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
  line_search = bt
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-4
  nl_rel_step_tol = 1e-10
  nl_abs_step_tol = 1e-10
  nl_max_its = 10
  l_tol = 1e-6
  l_max_its = 300

  start_time = -1.0
  end_time = 102.0
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
